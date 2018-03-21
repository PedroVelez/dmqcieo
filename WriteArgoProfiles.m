function flt = Write_flt_DMQC(flt,outpath)
% function to write output to Argo float netcdf files.
%
% assumes that a properly formatted netcdf file exists on outpath.
% function opens netcdf file and updates fields with passed values
%
%
%PVB Jun 2011
%PER Jun 2010

for i = 1:size(flt,2)
    %Check if eddited
    if flt(i).editted
        flname = fullfile(sprintf('%s',deblank(flt(i).platform_number'),filesep,'Profiles',filesep,sprintf('%c%s_%3.3d.nc',flt(i).data_mode,deblank(flt(i).platform_number'),flt(i).cycle_number)));
        
        if exist(fullfile(outpath,flname),'file')
            fprintf('Writing %s\n',fullfile(outpath,flname));
            flt(i).HISTORY_INSTITUTION=flt(1).HISTORY_INSTITUTION;
            flt(i).HISTORY_SOFTWARE=flt(1).HISTORY_SOFTWARE;
            wrt_flt_nc_prof(flt(i),fullfile(outpath,flname))
            fprintf('    > Saving %s\n',fullfile(outpath,flname));
        else
            fprintf('    > Unable to locate %s\n',fullfile(outpath,flname));
        end
    end
end

function wrt_flt_nc_prof(flt,ncfile)
ncid= netcdf.open(ncfile, 'WRITE');

varid=netcdf.inqVarID(ncid,'PRES_QC');
netcdf.putVar(ncid,varid,flt.pres_qc);

varid=netcdf.inqVarID(ncid,'PRES_ADJUSTED_QC');
netcdf.putVar(ncid,varid,flt.pres_adjusted_qc);

varid=netcdf.inqVarID(ncid,'TEMP_ADJUSTED_QC');
netcdf.putVar(ncid,varid,flt.temp_adjusted_qc);

varid=netcdf.inqVarID(ncid,'PSAL_ADJUSTED_QC');
netcdf.putVar(ncid,varid,flt.psal_adjusted_qc);

varid=netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COMMENT')';
netcdf.putVar(ncid,varid,flt.scientific_calib_comment);


%Write out history statement
histdate = sprintf('%04d%02d%02d%02d%02d%02d',round(clock));

nhistory_id =  netcdf.inqDimID(ncid,'N_HISTORY');
[~, N_HISTORY] = netcdf.inqDim(ncid,nhistory_id);

%Note we are increminting history count by one, but netcdf indexing starts at
%Zero instead of one.

varid = netcdf.inqVarID(ncid,'HISTORY_INSTITUTION');
netcdf.putVar(ncid,varid,[0 0 N_HISTORY],[4 1 1],flt(1).HISTORY_INSTITUTION)

varid = netcdf.inqVarID(ncid,'HISTORY_STEP');
netcdf.putVar(ncid,varid,[0 0 N_HISTORY],[4 1 1],'ARSQ')

varid = netcdf.inqVarID(ncid,'HISTORY_SOFTWARE');
netcdf.putVar(ncid,varid,[0 0 N_HISTORY],[4 1 1],flt(1).HISTORY_SOFTWARE)

varid = netcdf.inqVarID(ncid,'HISTORY_DATE');
netcdf.putVar(ncid,varid,[0 0 N_HISTORY],[14 1 1],histdate)

varid = netcdf.inqVarID(ncid,'HISTORY_ACTION');
netcdf.putVar(ncid,varid,[0 0 N_HISTORY],[2 1 1],'CF')

netcdf.close(ncid);
