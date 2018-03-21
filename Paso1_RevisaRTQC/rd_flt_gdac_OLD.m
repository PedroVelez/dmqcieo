function flt = rd_flt_gdac(inpath,verbose)
    %function to read in Argo float netcdf files.
    %Second argument is optional and may be single value or vector
    %if no second argument is passed then function loads all available profiles
    %PVB Jun 2011
    %PER Jun 2010
    
    if nargin < 2
        verbose=1;
    end
    profiles = 0:1000;  % set up large vector or possible profile #s
    
    grdir = dir([inpath,'/R*.nc']);
    gddir = dir([inpath,'/D*.nc']);
    NR = length(grdir); % number of R files
    ND = length(gddir); % numbe of D files
    
    if verbose==1
        fprintf('>>>>> Reading WMO %s with %d (%d RT, %d DM) profiles \n',inpath(end-16:end-10),NR+ND,NR,ND)
    end
    % loop over files
    for i1 = 1:NR+ND;
        % determine file name
        if i1 <= NR;
            fname = grdir(i1).name;
        else
            fname = gddir(i1-NR).name;
        end
        %check to see if this nunber matches those to load
        Nprof = str2double(fname(10:12));
        if any(Nprof == profiles)
            % load the data
            flt_prof(i1) = rd_flt_nc_prof(fullfile(inpath,fname));
            %        fprintf('%d, ',i1)
        end
    end
    
    %eliminate structure elements that never got filled and sort by cycle
    %number
    fkill = cellfun('isempty',{flt_prof.type});
    flt_prof = flt_prof(~fkill);
    
    for i1=1:size(flt_prof,2)
        cycle_number(i1)=flt_prof(i1).cycle_number(1);
    end
    [~,I] = sort(cycle_number); %Reordena la estructura por numeo de ciclos
    %[~,I] = sort([flt_prof.cycle_number]); %Reordena la estructura por numeo de ciclos
    
    flt = flt_prof(I);  % assign output structure
    
    
    for i1=1:size(flt_prof,2)
        data_mode(i1)=flt_prof(i1).data_mode(1);
    end
    if verbose==1
        %    fprintf('    > %s, from %s and procesed at %s \n',deblank(flt(1).inst_reference), deblank(flt(1).project),deblank(flt(1).datacentre))
        fprintf('    > with %d (%d RT, %d Au, %d DM) profiles Created %s and updated %s\n',NR+ND,length(strfind([data_mode],'R')),length(strfind([data_mode],'A')),length(strfind([data_mode],'D')),datestr(min([flt.date_creation])),datestr(max([flt.date_update])))
        fprintf('    > ')
        for i1=1:length(flt)
            fprintf('%3d%1s ',flt(i1).cycle_number,flt(i1).data_mode)
        end
        fprintf('\n')
    end
    
    
function flt_prof = rd_flt_nc_prof(ncfile)
    %function to open and read netcdf file
    [~,filestr] = fileparts(ncfile);
    if strcmp(filestr(1),'R')
        flt_prof.type = 'R';
    elseif strcmp(filestr(1),'D')
        flt_prof.type = 'D';
    end
    
    ncid= netcdf.open(ncfile, 'NC_NOWRITE');
    
    varid=netcdf.inqVarID(ncid,'PLATFORM_NUMBER');
    flt_prof.wmo_num =netcdf.getVar(ncid,varid);
    
    %flt_prof.inst_reference=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'INST_REFERENCE'))';
    
    [~,flt_prof.nparam]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'N_PARAM'));
    
    daynumr=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATE_CREATION'));
    flt_prof.date_creation=datenum(str2double(daynumr(1:4)),str2double(daynumr(5:6)),str2double(daynumr(7:8)));
    
    daynumr=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATE_UPDATE'));
    flt_prof.date_update=datenum(str2double(daynumr(1:4)),str2double(daynumr(5:6)),str2double(daynumr(7:8)));
    
    flt_prof.datacentre=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATA_CENTRE'))';
    flt_prof.project= netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PROJECT_NAME'))';
    
    flt_prof.stapar=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'STATION_PARAMETERS'));
    
    flt_prof.data_centre=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATA_CENTRE'))';
    
    flt_prof.pi_name=(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PI_NAME'))');
    
    varid=netcdf.inqVarID(ncid,'CYCLE_NUMBER');
    
    flt_prof.cycle_number= double(netcdf.getVar(ncid,varid));
    
    daynumr=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'REFERENCE_DATE_TIME'));
    timeref=datenum(str2double(daynumr(1:4)),str2double(daynumr(5:6)),str2double(daynumr(7:8)));
    flt_prof.julds=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'JULD'))+timeref;
    
    varid=netcdf.inqVarID(ncid,'LATITUDE');
    flt_prof.lat =netcdf.getVar(ncid,varid);
    
    varid=netcdf.inqVarID(ncid,'LONGITUDE');
    flt_prof.lon=netcdf.getVar(ncid,varid);
    
    varid=netcdf.inqVarID(ncid,'JULD');
    flt_prof.juld =netcdf.getVar(ncid,varid);
    
    %varid=netcdf.inqVarID(ncid,'INST_REFERENCE');
    %flt_inst_referece.juld =netcdf.getVar(ncid,varid);
    
    thedim=netcdf.inqDimID(ncid,'N_LEVELS');
    [~,flt_prof.nd] = netcdf.inqDim(ncid,thedim);
    
    varid=netcdf.inqVarID(ncid,'DATA_MODE');
    flt_prof.data_mode=netcdf.getVar(ncid,varid);
    
    varid=netcdf.inqVarID(ncid,'PRES');
    flt_prof.pres=netcdf.getVar(ncid,varid)'; % get all elements of pressure
    badf= flt_prof.pres == netcdf.getAtt(ncid,varid,'_FillValue');
    flt_prof.pres(badf)=NaN;
    
    varid=netcdf.inqVarID(ncid,'PRES_QC');
    flt_prof.pres_qc=netcdf.getVar(ncid,varid)';
    
    varid=netcdf.inqVarID(ncid,'PRES_ADJUSTED');
    flt_prof.pres_adjusted=netcdf.getVar(ncid,varid)'; % get all elements of pressure
    badf= flt_prof.pres_adjusted == netcdf.getAtt(ncid,varid,'_FillValue');
    flt_prof.pres_adjusted(badf)=NaN;
    
    varid=netcdf.inqVarID(ncid,'PRES_ADJUSTED_QC');
    flt_prof.pres_adjusted_qc=netcdf.getVar(ncid,varid)';
    
    varid=netcdf.inqVarID(ncid,'PRES_ADJUSTED_ERROR');
    flt_prof.pres_adjusted_error=netcdf.getVar(ncid,varid)';
    
    varid=netcdf.inqVarID(ncid,'TEMP');
    flt_prof.temp=netcdf.getVar(ncid,varid)';
    badf= flt_prof.temp == netcdf.getAtt(ncid,varid,'_FillValue');
    flt_prof.temp(badf)=NaN;
    
    varid=netcdf.inqVarID(ncid,'TEMP_QC');
    flt_prof.temp_qc=netcdf.getVar(ncid,varid)';
    
    varid=netcdf.inqVarID(ncid,'TEMP_ADJUSTED');
    flt_prof.temp_adjusted=netcdf.getVar(ncid,varid)';
    badf= flt_prof.temp_adjusted == netcdf.getAtt(ncid,varid,'_FillValue');
    flt_prof.temp_adjusted(badf)=NaN;
    
    varid=netcdf.inqVarID(ncid,'TEMP_ADJUSTED_QC');
    flt_prof.temp_adjusted_qc=netcdf.getVar(ncid,varid)';
    
    varid=netcdf.inqVarID(ncid,'TEMP_ADJUSTED_ERROR');
    flt_prof.temp_adjusted_error=netcdf.getVar(ncid,varid)';
    
    varid=netcdf.inqVarID(ncid,'PSAL');
    flt_prof.psal=netcdf.getVar(ncid,varid)';
    badf= flt_prof.psal == netcdf.getAtt(ncid,varid,'_FillValue');
    flt_prof.psal(badf)=NaN;
    
    varid=netcdf.inqVarID(ncid,'PSAL_QC');
    flt_prof.psal_qc=netcdf.getVar(ncid,varid)';
    
    varid=netcdf.inqVarID(ncid,'PSAL_ADJUSTED');
    flt_prof.psal_adjusted=netcdf.getVar(ncid,varid)';
    badf= flt_prof.psal_adjusted == netcdf.getAtt(ncid,varid,'_FillValue');
    flt_prof.psal_adjusted(badf)=NaN;
    
    varid=netcdf.inqVarID(ncid,'PSAL_ADJUSTED_QC');
    flt_prof.psal_adjusted_qc=netcdf.getVar(ncid,varid)';
    
    varid=netcdf.inqVarID(ncid,'PSAL_ADJUSTED_ERROR');
    flt_prof.psal_adjusted_error=netcdf.getVar(ncid,varid)';
    
    varid=netcdf.inqVarID(ncid,'PROFILE_PRES_QC');
    flt_prof.profile_pres_qc=netcdf.getVar(ncid,varid);
    
    varid=netcdf.inqVarID(ncid,'PROFILE_TEMP_QC');
    flt_prof.profile_temp_qc=netcdf.getVar(ncid,varid);
    
    varid=netcdf.inqVarID(ncid,'PROFILE_PSAL_QC');
    flt_prof.profile_psal_qc=netcdf.getVar(ncid,varid);
    
    %flt_prof.scient_calib_comment=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COMMENT'))';
    
    %Using QC flags
    flt_prof.pres(flt_prof.pres_qc=='4' |  flt_prof.pres_qc=='9')=NaN;
    flt_prof.pres_adjusted(flt_prof.pres_adjusted_qc=='4' |  flt_prof.pres_adjusted_qc=='9')=NaN;
    
    flt_prof.temp(flt_prof.temp_qc=='4' |  flt_prof.temp_qc=='9')=NaN;
    flt_prof.temp_adjusted(flt_prof.temp_adjusted_qc=='4' |  flt_prof.temp_adjusted_qc=='9')=NaN;
    
    flt_prof.psal(flt_prof.psal_qc=='4' |  flt_prof.psal_qc=='9')=NaN;
    flt_prof.psal_adjusted(flt_prof.psal_adjusted_qc=='4' |  flt_prof.psal_adjusted_qc=='9')=NaN;
    
    netcdf.close(ncid);
    
