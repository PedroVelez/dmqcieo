function apply_therm_lag(ncfile)
    % based on ch_tlag_func.m
    % PER Nov 2010
    
    ncid= netcdf.open(ncfile, 'WRITE');
    
    varid=netcdf.inqVarID(ncid,'INST_REFERENCE');
    inst_reference= netcdf.getVar(ncid,varid)';
    
    if ~any(findstr(inst_reference,'SBE'))
        disp([ncfile,': ',inst_reference,' is not a SBE ctd'])
        netcdf.close(ncid)
        return
    end
    
    thedim=netcdf.inqDimID(ncid,'N_LEVELS');
    [~, nd] = netcdf.inqDim(ncid,thedim);
    
    if nd < 4
        disp([ncfile,': not enough points to calculate thermal lag'])
        netcdf.close(ncid)
        return
    end
    
    varid=netcdf.inqVarID(ncid,'LATITUDE');
    lat =netcdf.getVar(ncid,varid);
    
    varid=netcdf.inqVarID(ncid,'CYCLE_NUMBER');
    cycle_number= double(netcdf.getVar(ncid,varid));
    
    varid=netcdf.inqVarID(ncid,'PRES');
    f.pres=netcdf.getVar(ncid,varid)'; % get all elements of pressure
    badf= f.pres == netcdf.getAtt(ncid,varid,'_FillValue');
    f.pres(badf)=NaN;
    
    varid=netcdf.inqVarID(ncid,'PRES_QC');
    f.pres_qc=netcdf.getVar(ncid,varid)';
    
    varid=netcdf.inqVarID(ncid,'TEMP');
    f.temp=netcdf.getVar(ncid,varid)';
    badf= f.temp == netcdf.getAtt(ncid,varid,'_FillValue');
    f.temp(badf)=NaN;
    temp_68 = f.temp*1.00024;  %(convert to ITPS-68)
    
    varid=netcdf.inqVarID(ncid,'TEMP_QC');
    f.temp_qc=netcdf.getVar(ncid,varid)';
    
    varid=netcdf.inqVarID(ncid,'PSAL');
    f.psal=netcdf.getVar(ncid,varid)';
    badf= f.psal == netcdf.getAtt(ncid,varid,'_FillValue');
    f.psal(badf)=NaN;
    
    varid=netcdf.inqVarID(ncid,'PSAL_QC');
    f.psal_qc=netcdf.getVar(ncid,varid)';
    
    % calculate the salinity corrected for thermal leg
    % for WHOI SOLOs, vel = 10 cm/s
    vel = 0.1 ; % 10 cm/sec = 0.1 m/s
    % SBE 41CP new numbers as of 10/10/06
    alph=0.141;
    tau=6.68;
    ok = find(isfinite(f.pres) & isfinite(temp_68) & isfinite(f.psal));
    nok = length(ok);
    ref = max(ok);
    
    e_time = sw_dpth(f.pres',lat)/vel;
    e_time = e_time(ref)-e_time'; % rise time
    
    %Call G. Johnson's thermal mass function.  Note vectors must be ordered
    %from bottom of cast up.
    salt_cor=fliplr(celltm_sbe41(f.psal(ok(nok:-1:1)), temp_68(ok(nok:-1:1)), ...
        f.pres(ok(nok:-1:1)), e_time(ok(nok:-1:1)), ...
        alph,tau));
    
    % copy to adjusted fields;
    varid=netcdf.inqVarID(ncid,'PRES');
    foo=netcdf.getVar(ncid,varid)'; % get all elements of pressure
    varid=netcdf.inqVarID(ncid,'PRES_ADJUSTED');
    netcdf.putVar(ncid,varid,foo);
    
    varid=netcdf.inqVarID(ncid,'PRES_QC');
    foo=netcdf.getVar(ncid,varid)';
    varid=netcdf.inqVarID(ncid,'PRES_ADJUSTED_QC');
    netcdf.putVar(ncid,varid,foo);
    
    
    varid=netcdf.inqVarID(ncid,'TEMP');
    foo=netcdf.getVar(ncid,varid)';
    varid=netcdf.inqVarID(ncid,'TEMP_ADJUSTED');
    netcdf.putVar(ncid,varid,foo);
    
    varid=netcdf.inqVarID(ncid,'TEMP_QC');
    foo=netcdf.getVar(ncid,varid)';
    varid=netcdf.inqVarID(ncid,'TEMP_ADJUSTED_QC');
    netcdf.putVar(ncid,varid,foo);
    
    
    varid=netcdf.inqVarID(ncid,'PSAL');
    foo=netcdf.getVar(ncid,varid)';
    foo(ok) = salt_cor;   % add in the adjusted salinity field
    varid=netcdf.inqVarID(ncid,'PSAL_ADJUSTED');
    netcdf.putVar(ncid,varid,foo);
    
    varid=netcdf.inqVarID(ncid,'PSAL_QC');
    foo=netcdf.getVar(ncid,varid)';
    varid=netcdf.inqVarID(ncid,'PSAL_ADJUSTED_QC');
    netcdf.putVar(ncid,varid,foo);
    
    
    varid=netcdf.inqVarID(ncid,'PSAL_ADJUSTED_ERROR');
    psal_err = abs(f.psal-salt_cor);
    netcdf.putVar(ncid,varid,psal_err);
    
    % write out calibration and history comment
    %first figure out what 'Param' is psal
    varid = netcdf.inqVarID(ncid,'PARAMETER');
    params = netcdf.getVar(ncid,varid)';
    psal_index = strmatch('PSAL',params);
    equation='PSAL_ADJ corrects Conductivity Thermal Mass (CTM), Johnson et al., 2007, JAOT';
    coeff='CTM: alpha=0.141C, tau=6.89s, rise rate = 10 cm/s with error equal to the adjustment';
    comment='PSAL_ADJUSTED_ERR set to magnitude of thermal mass adjustment';
    
    varid=netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_EQUATION');
    netcdf.putVar(ncid,varid,[0 psal_index-1 0 0],[length(equation) 1 1 1],equation)
    varid=netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COEFFICIENT');
    netcdf.putVar(ncid,varid,[0 psal_index-1 0 0],[length(coeff) 1 1 1],coeff)
    varid=netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COMMENT');
    netcdf.putVar(ncid,varid,[0 psal_index-1 0 0],[length(comment) 1 1 1],comment)
    
    
    % write out history statement
    histdate = sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
    
    nhistory_id =  netcdf.inqdimID(ncid,'N_HISTORY');
    [foo, N_HISTORY] = netcdf.inqdim(ncid,nhistory_id);
    
    % note we are increminting history count by one, but netcdf indexing starts at
    % zero instead of one.
    varid = netcdf.inqVarID(ncid,'HISTORY_INSTITUTION');
    netcdf.putVar(ncid,varid,[0 0 N_HISTORY],[4 1 1],'IEO ')
    varid = netcdf.inqVarID(ncid,'HISTORY_STEP');
    netcdf.putVar(ncid,varid,[0 0 N_HISTORY],[4 1 1],'ARSQ')
    
    varid = netcdf.inqVarID(ncid,'HISTORY_SOFTWARE');
    netcdf.putVar(ncid,varid,[0 0 N_HISTORY],[4 1 1],' CTM')
    varid = netcdf.inqVarID(ncid,'HISTORY_SOFTWARE_RELEASE');
    netcdf.putVar(ncid,varid,[0 0 N_HISTORY],[4 1 1],'V1.0')
    
    varid = netcdf.inqVarID(ncid,'HISTORY_DATE');
    netcdf.putVar(ncid,varid,[0 0 N_HISTORY],[14 1 1],histdate)
    varid = netcdf.inqVarID(ncid,'HISTORY_ACTION');
    netcdf.putVar(ncid,varid,[0 0 N_HISTORY],[2 1 1],'IP')
    
    
    netcdf.close(ncid);