function flt = ReadArgoProfiles(inpath,verbose)
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
    Nprof = str2double(fname(10:13));
    if any(Nprof == profiles)
        % load the data
        %keyboard
        flt_prof(i1) = rd_flt_nc_prof(fullfile(inpath,fname));
        %        fprintf('%d, ',i1)
    end
end
%eliminate structure elements that never got filled and sort by cycle
%number
fkill = cellfun('isempty',{flt_prof.data_mode});
flt_prof = flt_prof(~fkill);
[~,I] = sort([flt_prof.cycle_number]); %Reordena la estructura por numeo de ciclos
flt = flt_prof(I);  % assign output structure
if verbose==1
%    fprintf('    > %s, from %s and procesed at %s \n',deblank(flt(1).inst_reference'), deblank(flt(1).project_name),deblank(flt(1).data_centre))
    fprintf('    > with %d (%d R, %d A, %d D) profiles Created %s and updated %s\n',NR+ND,length(strfind([flt.data_mode],'R')),length(strfind([flt.data_mode],'A')),length(strfind([flt.data_mode],'D')),flt(1).date_creation',flt(end).date_update')
    fprintf('    > ')
    keyboard
    for i1=1:length(flt)
        fprintf('%3d%1s ',flt(i1).cycle_number,flt(i1).data_mode)
    end
    fprintf('\n')
end


function flt_prof = rd_flt_nc_prof(ncfile)
%function to open and read netcdf file
[~,filestr] = fileparts(ncfile);
if strcmp(filestr(1),'R')
    flt_prof.data_mode2 = 'R';
elseif strcmp(filestr(1),'D')
    flt_prof.data_mode2 = 'D';
end

ncid= netcdf.open(ncfile, 'NC_NOWRITE');

[~,flt_prof.n_param]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'N_PARAM'));
[~,flt_prof.n_levels] = netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'N_LEVELS'));

[~,flt_prof.n_calib]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'N_CALIB'));
[~,flt_prof.n_history]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'N_HISTORY'));


%General information on the profile file
%This section contains information about the whole file.
flt_prof.data_type=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATA_TYPE'))';
flt_prof.format_version=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'FORMAT_VERSION'))';
flt_prof.handbook_version=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'HANDBOOK_VERSION'))';
flt_prof.reference_data_time=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'REFERENCE_DATE_TIME'));
flt_prof.date_creation=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATE_CREATION'));
flt_prof.date_update=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATE_UPDATE'));

% General information for each profile
% This section contains general information on each profile.
% Each item of this section has a N_PROF (number of profiles) dimension.
flt_prof.platform_number =netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PLATFORM_NUMBER'));
flt_prof.project_name= netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PROJECT_NAME'))';
flt_prof.pi_name=(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PI_NAME'))');
flt_prof.station_parameters=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'STATION_PARAMETERS'));
flt_prof.cycle_number= double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'CYCLE_NUMBER')));
flt_prof.direction=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DIRECTION'));
flt_prof.data_centre=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATA_CENTRE'));
flt_prof.dc_reference=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DC_REFERENCE'));
flt_prof.data_state_indicator=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATA_STATE_INDICATOR'))';
flt_prof.data_mode=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATA_MODE'))';
flt_prof.inst_reference=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'FLOAT_SERIAL_NO'));
try
    flt_prof.firmware_version=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'FIRMWARE_VERSION'));
catch ME
    fprintf('%s %s \n',ncfile,ME.message)
end
flt_prof.wmo_inst_type=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'WMO_INST_TYPE'))';
flt_prof.juld =netcdf.getVar(ncid,netcdf.inqVarID(ncid,'JULD'));

flt_prof.juld_matlab=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'JULD'))+datenum(str2double(flt_prof.reference_data_time(1:4)),str2double(flt_prof.reference_data_time(5:6)),str2double(flt_prof.reference_data_time(7:8)));

flt_prof.juld_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'JULD_QC'))';
flt_prof.juld_location=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'JULD_LOCATION'))';
flt_prof.latitude =netcdf.getVar(ncid,netcdf.inqVarID(ncid,'LATITUDE'));
flt_prof.longitude=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'LONGITUDE'));
flt_prof.position_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'POSITION_QC'))';
flt_prof.positioning_system=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'POSITIONING_SYSTEM'))';
flt_prof.profile_pres_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PROFILE_PRES_QC'));
flt_prof.profile_temp_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PROFILE_TEMP_QC'));
flt_prof.profile_psal_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PROFILE_PSAL_QC'));
try
    flt_prof.vertical_sampling_scheme=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'VERTICAL_SAMPLING_SCHEME'));
catch ME
    fprintf('%s \n',ME.message)
end
%Measurements for each profile
%This section contains information on each level of each profile.
%Each variable in this section has a N_PROF (number of profiles), N_LEVELS (number of pressure levels) dimension.
try
    flt_prof.parameter_data_mode=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PARAMETER_DATA_MODE'));
catch ME
    flt_prof.parameter_data_mode=[];
    fprintf('%s %s \n',ncfile,ME.message)
end

% Pres
flt_prof.pres=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES'))'; % get all elements of pressure
flt_prof.pres(flt_prof.pres==netcdf.getAtt(ncid,netcdf.inqVarID(ncid,'PRES'),'_FillValue'))=NaN;
flt_prof.pres_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_QC'))';
flt_prof.pres_adjusted=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED'))'; % get all elements of pressure
flt_prof.pres_adjusted(flt_prof.pres_adjusted==netcdf.getAtt(ncid,netcdf.inqVarID(ncid,'PRES'),'_FillValue'))=NaN;
flt_prof.pres_adjusted_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED_QC'))';
flt_prof.pres_adjusted_error=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED_ERROR'))';
flt_prof.pres_adjusted_error(flt_prof.pres_adjusted_error==netcdf.getAtt(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED_ERROR'),'_FillValue'))=NaN;

%Temp
flt_prof.temp=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP'))';
flt_prof.temp(flt_prof.temp==netcdf.getAtt(ncid,netcdf.inqVarID(ncid,'TEMP'),'_FillValue'))=NaN;
flt_prof.temp_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP_QC'))';
flt_prof.temp_adjusted=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED'))';
flt_prof.temp_adjusted(flt_prof.temp_adjusted==netcdf.getAtt(ncid,netcdf.inqVarID(ncid,'TEMP'),'_FillValue'))=NaN;
flt_prof.temp_adjusted_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED_QC'))';
flt_prof.temp_adjusted_error=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED_ERROR'))';
flt_prof.temp_adjusted_error(flt_prof.temp_adjusted_error==netcdf.getAtt(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED_ERROR'),'_FillValue'))=NaN;


%Psal
flt_prof.psal=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL'))';
flt_prof.psal(flt_prof.psal==netcdf.getAtt(ncid,netcdf.inqVarID(ncid,'PSAL'),'_FillValue'))=NaN;
flt_prof.psal_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL_QC'))';
flt_prof.psal_adjusted=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED'))';
flt_prof.psal_adjusted(flt_prof.pres_adjusted==netcdf.getAtt(ncid,netcdf.inqVarID(ncid,'PSAL'),'_FillValue'))=NaN;
flt_prof.psal_adjusted_qc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED_QC'))';
flt_prof.psal_adjusted_error=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED_ERROR'))';
flt_prof.psal_adjusted_error(flt_prof.psal_adjusted_error==netcdf.getAtt(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED_ERROR'),'_FillValue'))=NaN;



%Using QC flags
flt_prof.pres(flt_prof.pres_qc=='4' |  flt_prof.pres_qc=='9')=NaN;
flt_prof.pres_adjusted(flt_prof.pres_adjusted_qc=='4' |  flt_prof.pres_adjusted_qc=='9')=NaN;

flt_prof.temp(flt_prof.temp_qc=='4' |  flt_prof.temp_qc=='9')=NaN;
flt_prof.temp_adjusted(flt_prof.temp_adjusted_qc=='4' |  flt_prof.temp_adjusted_qc=='9')=NaN;

flt_prof.psal(flt_prof.psal_qc=='4' |  flt_prof.psal_qc=='9')=NaN;
flt_prof.psal_adjusted(flt_prof.psal_adjusted_qc=='4' |  flt_prof.psal_adjusted_qc=='9')=NaN;

% Calibration information for each profile
% Calibrations are applied to parameters to create adjusted parameters. Different calibration methods will be used by groups processing Argo data. When a method is applied, its description is stored in the following fields.
% This section contains calibration information for each parameter of each profile.
% Each item of this section has a N_PROF (number of profiles), N_CALIB (number of calibrations), N_PARAM (number of parameters) dimension.
% If no calibration is available, N_CALIB is set to 1, all values of calibration section are set to fill values.

flt_prof.parameter=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PARAMETER'));
flt_prof.scientific_calib_equation=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_EQUATION'));
flt_prof.scientific_calib_coefficient=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COEFFICIENT'));
flt_prof.scientific_calib_comment=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COMMENT'));
flt_prof.scientific_calib_date=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_DATE'));

%Si if N_CALIB is set to 1 por compatibilidad creo las matrices con el tama?o adecuado
if flt_prof.n_calib==1
    for ipara=1:flt_prof.n_param
        if strncmp(flt_prof.station_parameters(:,ipara)','PRES',4)
            iPres=ipara;
        elseif strncmp(flt_prof.station_parameters(:,ipara)','TEMP',4)
            iTemp=ipara;
        elseif strncmp(flt_prof.station_parameters(:,ipara)','PSAL',4)
            iPsal=ipara;
        end
    end
    
    VT=flt_prof.parameter;
    VT(1:4,iPres,2)='    ';
    VT(1:4,iTemp,2)='    ';
    VT(1:4,iPsal,2)='    ';
    %keyboard
    flt_prof.parameter=reshape(VT,16,2,3);clear VT
    %flt_prof.parameter=reshape(VT,16,2,5);clear VT
    flt_prof.parameter=flt_prof.parameter(:,1,:);
    
    VT=flt_prof.scientific_calib_coefficient;
    VT(1:256,iPres,2)=repmat(' ',1,256);
    VT(1:256,iTemp,2)=repmat(' ',1,256);
    VT(1:256,iPsal,2)=repmat(' ',1,256);
    flt_prof.scientific_calib_coefficient=reshape(VT,256,2,3);clear VT
    %flt_prof.scientific_calib_coefficient=permute(VT,[1 3 2]);clear VT
    flt_prof.scientific_calib_coefficient=flt_prof.scientific_calib_coefficient(:,1,:);
    
    VT=flt_prof.scientific_calib_comment;
    VT(1:256,iPres,2)=repmat(' ',1,256);
    VT(1:256,iTemp,2)=repmat(' ',1,256);
    VT(1:256,iPsal,2)=repmat(' ',1,256);
    flt_prof.scientific_calib_comment=reshape(VT,256,2,3);clear VT
    %flt_prof.scientific_calib_comment=permute(VT,[1 3 2]);clear VT
    flt_prof.scientific_calib_comment=flt_prof.scientific_calib_comment(:,1,:);
    
    VT=flt_prof.scientific_calib_date;
    VT(1:14,iPres,2)=repmat(' ',1,14);
    VT(1:14,iTemp,2)=repmat(' ',1,14);
    VT(1:14,iPsal,2)=repmat(' ',1,14);
   
    flt_prof.scientific_calib_date=reshape(VT,14,2,3);clear VT
    %flt_prof.scientific_calib_date=permute(VT,[1 3 2]);clear VT
    flt_prof.scientific_calib_date=flt_prof.scientific_calib_date(:,1,:);
    
    VT=flt_prof.scientific_calib_equation;
    VT(1:256,iPres,2)=repmat(' ',1,256);
    VT(1:256,iTemp,2)=repmat(' ',1,256);
    VT(1:256,iPsal,2)=repmat(' ',1,256);
    flt_prof.scientific_calib_equation=reshape(VT,256,2,3);clear VT
    %flt_prof.scientific_calib_equation=permute(VT,[1 3 2]);clear VT
    flt_prof.scientific_calib_equation=flt_prof.scientific_calib_equation(:,1,:);
end


% History information for each profile
% This section contains history information for each action performed on each profile by a data centre.
% Each item of this section has a N_HISTORY (number of history records), N_PROF (number of profiles) dimension.
% A history record is created whenever an action is performed on a profile.
% The recorded actions are coded and described in the history code table from the reference table 7.
% On the GDAC, multi-profile history section is empty to reduce the size of the file. History section is available on mono-profile files, or in multi-profile files distributed from the web data selection.

flt_prof.history_institution=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'HISTORY_INSTITUTION'));
flt_prof.history_step=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'HISTORY_STEP'));
flt_prof.history_software=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'HISTORY_SOFTWARE'));
flt_prof.history_software_release=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'HISTORY_SOFTWARE_RELEASE'));
flt_prof.history_reference=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'HISTORY_REFERENCE'));
flt_prof.history_date=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'HISTORY_DATE'));
flt_prof.history_action=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'HISTORY_ACTION'));
flt_prof.history_parameter=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'HISTORY_PARAMETER'));
flt_prof.history_start_pres=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'HISTORY_START_PRES'));
flt_prof.history_stop_pres=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'HISTORY_STOP_PRES'));
flt_prof.history_previous_value=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'HISTORY_PREVIOUS_VALUE'));
flt_prof.history_qctest=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'HISTORY_QCTEST'));

netcdf.close(ncid);