%% Step 5B. Description:
%This file updates information for old APEX floats. Most of them are
%spoiled. There almost is no data at all. PARAMETER_values, QC_values and
%SCIENTIFIC_values have been updated. Once all old APEX floats are
%processed, this script will be unuseful.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Pedro Velez & Alberto Gonzalez (2017)
clc;clear all;close all
floats=[1900278];

SCIENTIFIC_CALIB_COMMENT_PRES='No significant presure drift detected - Calibration error is manufacturer specified accuracy';
SCIENTIFIC_CALIB_COMMENT_TEMP='No significant temperature drift detected - Calibration error is manufacturer specified accuracy';
SCIENTIFIC_CALIB_COMMENT_PSAL='No correction - OW : Weighted least squares fit; Error provided by the manufacturer';
%----------------------------------------------------------------------
% Inicio
%----------------------------------------------------------------------
flname_ad=strcat('/Volumes/GDOYE$/Proyectos/Argo/DelayedMode/Data/float_sourceQC2/',num2str(floats),'.mat'); load(flname_ad);
for iboya=[Profs(:).cycle_number];
    %FillValue is set up
    ncfile=strcat('/Volumes/GDOYE$/Proyectos/Argo/DelayedMode/Data/float_sourceQC1/',num2str(floats),'/profiles/R',num2str(floats),'_',sprintf('%0.3d',iboya),'.nc');
    ncid=netcdf.open(ncfile, 'WRITE');
    FillValue=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED_ERROR')); %Random FillValue is got
    FillValue=FillValue(1,1);
    %Index iPres, iTemp and iPsal are organized
    for icycle=size([Profs(1).cycle_number],2):size([Profs.cycle_number],2); %keyboard
        for ipara=1:Profs(icycle).n_param
            if strncmp(Profs(icycle).station_parameters(:,ipara)','PRES',4)
                iPres=ipara;
            elseif strncmp(Profs(icycle).station_parameters(:,ipara)','TEMP',4)
                iTemp=ipara;
            elseif strncmp(Profs(icycle).station_parameters(:,ipara)','PSAL',4)
                iPsal=ipara;
            end
        end
        
        %  keyboard
        idx_pres=find(isnan(Profs(icycle).pres)==1);
        idx_temp=find(isnan(Profs(icycle).temp)==1);
        idx_psal=find(isnan(Profs(icycle).psal)==1);
        if isempty(idx_pres)==0; 
            Profs(icycle).pres_adjusted(idx_pres)=FillValue;
            Profs(icycle).pres_adjusted_error(idx_pres)=FillValue;
            Profs(icycle).pres_qc(idx_pres)='4';
            Profs(icycle).pres_adjusted_qc(idx_pres)='4';
            Profs(icycle).scientific_calib_comment(:,1,iPres)=' ';
            Profs(icycle).scientific_calib_comment(1:size(SCIENTIFIC_CALIB_COMMENT_PRES,2),1,iPres)=SCIENTIFIC_CALIB_COMMENT_PRES;
            Profs(icycle).scientific_calib_coefficient(:,1,iPres)=' ';
            Profs(icycle).scientific_calib_equation(:,1,iPres)=' ';
            Profs(icycle).scientific_calib_date(:,1,iPres)=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
        end
        if isempty(idx_temp)==0;
            Profs(icycle).temp_adjusted(idx_temp)=FillValue;
            Profs(icycle).temp_adjusted_error(idx_temp)=FillValue;
            Profs(icycle).temp_qc(idx_temp)='4';
            Profs(icycle).temp_adjusted_qc(idx_temp)='4';
            Profs(icycle).scientific_calib_comment(:,1,iTemp)=' ';
            Profs(icycle).scientific_calib_comment(1:size(SCIENTIFIC_CALIB_COMMENT_TEMP,2),1,iTemp)=SCIENTIFIC_CALIB_COMMENT_TEMP;
            Profs(icycle).scientific_calib_coefficient(:,1,iTemp)=' ';
            Profs(icycle).scientific_calib_equation(:,1,iTemp)=' ';
            Profs(icycle).scientific_calib_date(:,1,iTemp)=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
        end
        if isempty(idx_psal)==0;
            Profs(icycle).psal_adjusted(idx_psal)=FillValue;
            Profs(icycle).psal_adjusted_error(idx_psal)=FillValue;
            Profs(icycle).psal_qc(idx_psal)='4';
            Profs(icycle).psal_adjusted_qc(idx_psal)='4';
            Profs(icycle).scientific_calib_comment(:,1,iPsal)=' ';
            Profs(icycle).scientific_calib_comment(1:size(SCIENTIFIC_CALIB_COMMENT_PSAL,2),1,iPsal)=SCIENTIFIC_CALIB_COMMENT_PSAL;
            Profs(icycle).scientific_calib_coefficient(:,1,iPsal)=' ';
            Profs(icycle).scientific_calib_equation(:,1,iPsal)=' ';
            Profs(icycle).scientific_calib_date(:,1,iPsal)=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
        end
    end
end

save(flname_ad,'Profs');