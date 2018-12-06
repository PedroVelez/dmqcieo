function flt = rd_flt_gdac(inpath,verbose,NumberOfProfile)
    
    %function to read in Argo float netcdf files.
    %Second argument is optional and may be single value or vector
    %if no second argument is passed then function loads all available profiles
    %AGS Sep 2017
    %PVB Jun 2011
    %PER Jun 2010
    
    %By default NumberOfProfile=1 since the regular Argo profile is the 1st
    %one. and the SST Argo profile is thje 2nd one.
    
    if nargin < 2
        verbose=1;
        NumberOfProfile=1;
    elseif nargin < 3
        NumberOfProfile=1;
    end
    
    profiles = 0:1000;  % set up large vector or possible profile #s
    
    grdir = dir([inpath,'/R*.nc']);
    gddir = dir([inpath,'/D*.nc']);
    NR = length(grdir); % number of R files
    ND = length(gddir); % numbe of D files
    %keyboard
    if verbose==1
        fprintf('>>>>> Reading WMO %s with %d (%d RT, %d DM) profiles \n',inpath(end-16:end-10),NR+ND,NR,ND)
        fprintf('     ')
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
        Nprof = str2double(fname(10:13));
        if any(Nprof == profiles)
            %keyboard
            % load the data
            flt_prof(i1)=rd_flt_nc_prof(fullfile(inpath,fname),NumberOfProfile);
            
            if verbose==1
                fprintf('%d, ',i1)
            end
        end
    end
    %keyboard
    %% eliminate structure elements that never got filled and sort by cycle
    %number
    fkill = cellfun('isempty',{flt_prof.data_mode});
    flt_prof = flt_prof(~fkill);
    
    [~,I] = sort([flt_prof.cycle_number]); %Reordena la estructura por numeo de ciclos
    flt = flt_prof(I);  % assign output structure
    
    if verbose==1
        fprintf('\n')
        fprintf('    > %s, from %s and procesed at %s \n',deblank(flt(1).inst_reference'), deblank(flt(1).project_name),deblank(flt(1).data_centre))
        fprintf('    > with %d (%d R, %d A, %d D) profiles Created %s and updated %s\n',NR+ND,length(strfind([flt.data_mode],'R')),length(strfind([flt.data_mode],'A')),length(strfind([flt.data_mode],'D')),flt(1).date_creation',flt(end).date_update')
        fprintf('    > ')
        for i1=1:length(flt)
            fprintf('%3d%1s ',flt(i1).cycle_number,flt(i1).data_mode)
        end
        fprintf('\n')
    end
    
function flt_prof = rd_flt_nc_prof(ncfile,NumberOfProfile)
    %function to open and read netcdf file
    [~,filestr] = fileparts(ncfile);
    if strcmp(filestr(1),'R')
        flt_prof.type = 'R';
    elseif strcmp(filestr(1),'D')
        flt_prof.type = 'D';
    end
    
    flt_prof.n_profS=NumberOfProfile;
    
    ncid= netcdf.open(ncfile, 'NC_NOWRITE');
    
    flt_prof.platform_number =netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PLATFORM_NUMBER'),[0 flt_prof.n_profS-1],[8 1])';
    %flt_prof.wmo_num =netcdf.getVar(ncid,varid);
    
    [~,flt_prof.n_param]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'N_PARAM'));
    
    flt_prof.date_creation=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATE_CREATION'));
    %flt_prof.date_creation=datenum(str2double(daynumr(1:4)),str2double(daynumr(5:6)),str2double(daynumr(7:8)));
    
    flt_prof.date_update=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATE_UPDATE'));
    %flt_prof.date_update=datenum(str2double(daynumr(1:4)),str2double(daynumr(5:6)),str2double(daynumr(7:8)));
    
    flt_prof.data_centre=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATA_CENTRE'),[0 flt_prof.n_profS-1],[2 1])';
    %flt_prof.project= netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PROJECT_NAME'))';
    
    flt_prof.station_parameters=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'STATION_PARAMETERS'),[0 0 flt_prof.n_profS-1],[16 flt_prof.n_param 1]);
    
    flt_prof.inst_reference=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'FLOAT_SERIAL_NO'),[0 flt_prof.n_profS-1],[16 1])';
    
    flt_prof.data_centre=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATA_CENTRE'),[0 flt_prof.n_profS-1],[2 1])';
    
    flt_prof.project_name= netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PROJECT_NAME'),[0 flt_prof.n_profS-1],[64 1])';
    
    flt_prof.pi_name=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PI_NAME'),[0 flt_prof.n_profS-1],[64 1])';
    
    flt_prof.cycle_number=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'CYCLE_NUMBER'),[flt_prof.n_profS-1],[1]))';
    
    %flt_prof.cycle_number= double(netcdf.getVar(ncid,varid));
    
    flt_prof.reference_data_time=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'REFERENCE_DATE_TIME'));
    %timeref=datenum(str2double(daynumr(1:4)),str2double(daynumr(5:6)),str2double(daynumr(7:8)));
    flt_prof.juld =netcdf.getVar(ncid,netcdf.inqVarID(ncid,'JULD'),[flt_prof.n_profS-1],[1])';
    %+timeref;
    
    flt_prof.latitude =netcdf.getVar(ncid,netcdf.inqVarID(ncid,'LATITUDE'),[flt_prof.n_profS-1],[1])';
    %flt_prof.lat =netcdf.getVar(ncid,varid);
    
    flt_prof.longitude=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'LONGITUDE'),[flt_prof.n_profS-1],[1])';
    %flt_prof.lon=netcdf.getVar(ncid,varid);
    
    %varid=netcdf.inqVarID(ncid,'JULD');
    %flt_prof.juld =netcdf.getVar(ncid,varid);
    
    [~,flt_prof.n_levels] = netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'N_LEVELS'));
    %[~,flt_prof.nd] = netcdf.inqDim(ncid,thedim);
    
    flt_prof.data_mode=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATA_MODE'),[flt_prof.n_profS-1],[1])';
    %flt_prof.data_mode=netcdf.getVar(ncid,varid);
    
    flt_prof.pres=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES'),[0 flt_prof.n_profS-1],[flt_prof.n_levels 1])'; % get all elements of pressure
    %flt_prof.pres=netcdf.getVar(ncid,varid)'; get all elements of pressure
    %badf= flt_prof.pres == netcdf.getAtt(ncid,varid,'_FillValue');
    %flt_prof.pres(badf)=NaN;
    %keyboard
    flt_prof.pres_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_QC'),[0 flt_prof.n_profS-1],[flt_prof.n_levels 1])';
    %flt_prof.pres_qc=netcdf.getVar(ncid,varid)';
    
    flt_prof.pres_adjusted=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED'),[0 flt_prof.n_profS-1],[flt_prof.n_levels 1])'; % get all elements of pressure
    %flt_prof.pres_adjusted=netcdf.getVar(ncid,varid)'; % get all elements of pressure
    %badf= flt_prof.pres_adjusted == netcdf.getAtt(ncid,varid,'_FillValue');
    %flt_prof.pres_adjusted(badf)=NaN;
    
    flt_prof.pres_adjusted_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED_QC'),[0 flt_prof.n_profS-1],[flt_prof.n_levels 1])';
    %flt_prof.pres_adjusted_qc=netcdf.getVar(ncid,varid)';
    
    flt_prof.pres_adjusted_error=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED_ERROR'),[0 flt_prof.n_profS-1],[flt_prof.n_levels 1])';
    %flt_prof.pres_adjusted_error=netcdf.getVar(ncid,varid)';
    
    flt_prof.temp=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP'),[0 flt_prof.n_profS-1],[flt_prof.n_levels 1])';
    %     flt_prof.temp=netcdf.getVar(ncid,varid)';
    %     badf= flt_prof.temp == netcdf.getAtt(ncid,varid,'_FillValue');
    %     flt_prof.temp(badf)=NaN;
    
    flt_prof.temp_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP_QC'),[0 flt_prof.n_profS-1],[flt_prof.n_levels 1])';
    %flt_prof.temp_qc=netcdf.getVar(ncid,varid)';
    
    flt_prof.temp_adjusted=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED'),[0 flt_prof.n_profS-1],[flt_prof.n_levels 1])';
    %     flt_prof.temp_adjusted=netcdf.getVar(ncid,varid)';
    %     badf= flt_prof.temp_adjusted == netcdf.getAtt(ncid,varid,'_FillValue');
    %     flt_prof.temp_adjusted(badf)=NaN;
    
    flt_prof.temp_adjusted_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED_QC'),[0 flt_prof.n_profS-1],[flt_prof.n_levels 1])';
    %     flt_prof.temp_adjusted_qc=netcdf.getVar(ncid,varid)';
    
    flt_prof.temp_adjusted_error=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED_ERROR'),[0 flt_prof.n_profS-1],[flt_prof.n_levels 1])';
    %     flt_prof.temp_adjusted_error=netcdf.getVar(ncid,varid)';
    
    flt_prof.psal=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL'),[0 flt_prof.n_profS-1],[flt_prof.n_levels 1])';
    %     flt_prof.psal=netcdf.getVar(ncid,varid)';
    %     badf= flt_prof.psal == netcdf.getAtt(ncid,varid,'_FillValue');
    %     flt_prof.psal(badf)=NaN;
    
    flt_prof.psal_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL_QC'),[0 flt_prof.n_profS-1],[flt_prof.n_levels 1])';
    %flt_prof.psal_qc=netcdf.getVar(ncid,varid)';
    
    flt_prof.psal_adjusted=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED'),[0 flt_prof.n_profS-1],[flt_prof.n_levels 1])';
    %     flt_prof.psal_adjusted=netcdf.getVar(ncid,varid)';
    %     badf= flt_prof.psal_adjusted == netcdf.getAtt(ncid,varid,'_FillValue');
    %     flt_prof.psal_adjusted(badf)=NaN;
    
    flt_prof.psal_adjusted_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED_QC'),[0 flt_prof.n_profS-1],[flt_prof.n_levels 1])';
    %     flt_prof.psal_adjusted_qc=netcdf.getVar(ncid,varid)';
    
    flt_prof.psal_adjusted_error=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED_ERROR'),[0 flt_prof.n_profS-1],[flt_prof.n_levels 1])';
    %     flt_prof.psal_adjusted_error=netcdf.getVar(ncid,varid)';
    
    flt_prof.profile_pres_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PROFILE_PRES_QC'),[flt_prof.n_profS-1],[1])';
    %     flt_prof.profile_pres_qc=netcdf.getVar(ncid,varid);
    
    flt_prof.profile_temp_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PROFILE_TEMP_QC'),[flt_prof.n_profS-1],[1])';
    %     flt_prof.profile_temp_qc=netcdf.getVar(ncid,varid);
    
    flt_prof.profile_psal_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PROFILE_PSAL_QC'),[flt_prof.n_profS-1],[1])';
    %     flt_prof.profile_psal_qc=netcdf.getVar(ncid,varid);
    
    %Using QC flags
    %Using QC flags
    flt_prof.pres(flt_prof.pres_qc=='4' |  flt_prof.pres_qc=='9')=NaN;
    flt_prof.pres_adjusted(flt_prof.pres_adjusted_qc=='4' |  flt_prof.pres_adjusted_qc=='9')=NaN;
    
    flt_prof.temp(flt_prof.temp_qc=='4' |  flt_prof.temp_qc=='9')=NaN;
    flt_prof.temp_adjusted(flt_prof.temp_adjusted_qc=='4' |  flt_prof.temp_adjusted_qc=='9')=NaN;
    
    flt_prof.psal(flt_prof.psal_qc=='4' |  flt_prof.psal_qc=='9')=NaN;
    flt_prof.psal_adjusted(flt_prof.psal_adjusted_qc=='4' |  flt_prof.psal_adjusted_qc=='9')=NaN;
    
    
    netcdf.close(ncid);
    
