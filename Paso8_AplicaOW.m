%% Step 8. Description:
%   This file simply applies the Owens and Wong Objective Mapping Analysis (2003)
%   if needed. Parameters "iIOW" (Owens&Wong beginning) and iFOW (Owens&Wong
%   end) must be set if a objective analysis calibration is desired.
%   If not, both parameters must be filled by NaN.
%
%   *****************THIRD CALIBRATION IS CARRIED OUT**********************
%   Salinity is recomputed. File *.mat is created at QC2 level.
%
%   ****************THIRD SCIENTIFIC COMMENTS ARE MADE*********************
%   Each modification/recomputation must be registered at SCIENTIFIC_CALIB
%   and HISTORY fields [Please check Argo DM Manual v3.1 for more information].
%
%   *************FOURTH QUALITY CONTROL FLAG IS CARRIED OUT****************
%   A quality flag indicates the quality of an observation. The flags are
%   assigned in Real Time (RT) and can be modified in Delayed Mode (DM).
%   Flags are set in a range from 0 to 9 [Please check Argo DM Manual v3.1
%   for more information]. Each correction must be flagged.
%
%   *****************DELAYED MODE TAG "D" IS ASSIGNED *********************
%
%   Once all the calibrations are carried out, Real Time Tag (R) must be
%   changed to Delayed Mode Tag (D) in "data_mode" parameter.
%   <www.oceanografia.argo.es>
%
%   Pedro Velez & Alberto Gonzalez (2016)

Limpia

floats=[1900379];
iIOW=NaN; %Primer perfil a a?adir la correci?n de Ow.
iFOW=NaN; %Ultimo perfil a a?adir la correci?n de Ow.

HISTORY_INSTITUTION='SP  '; %[Default='    ']
HISTORY_SOFTWARE='AIEO';
HISTORY_REFERENCE='WOA05';

SCIENTIFIC_CALIB_EQUATION_PSAL='PSAL_ADJUSTED=PSAL+DeltaS, DeltaS is calculated a potential conductivity (ref to 0 dbar) multiplicative adjustment term r.';
SCIENTIFIC_CALIB_COMMENT_PSAL='Drift detected,adjusted salinity using WJO(2003), WOD2001 as database, mapping scales 8/4,4/2,sliding calibration window +/-20prof.';
PSAL_ADJUSTED_QC_FLAG='2';

ANALYSIS_CODE='';

%----------------------------------------------------------------------
% Inicio
%----------------------------------------------------------------------
fprintf('>>>>> %s\n',mfilename)

for iboya=1:length(floats)
    flname_CAL=fullfile(GlobalSU.ArgoDMQC,'Data','float_calib',sprintf('cal_A_%s%6d',ANALYSIS_CODE,floats(iboya)));
    CAL=load(flname_CAL);
    
    flname_DATA=fullfile(GlobalSU.ArgoDMQC,'Data','float_sourceQC1',filesep,strcat(num2str(floats(iboya))));
    DATA=load(flname_DATA);
    fprintf('    > %s\n',DATA.Profs(1).platform_number')
    
    Profs=DATA.Profs;
    
    if isnan(iFOW)==1
        iFOW=size(Profs,2);
    end
    
    Soffset=CAL.cal_SAL-DATA.SAL;
    
    for icycle=1:length(Profs)
        if icycle>=iIOW && icycle<=iFOW
            Profs(icycle).editted=1;
            %History information
            N_HISTORY=size(Profs(icycle).history_institution,3);
            
            Config.HISTORY_INSTITUTION='SP  '; %[Default='    '] %It has to be 4 char in size
            Profs(icycle).history_institution(:,1,N_HISTORY+1)=HISTORY_INSTITUTION;
            Profs(icycle).history_step(:,1,N_HISTORY+1)='ARSQ';
            Profs(icycle).history_software(:,1,N_HISTORY+1)=HISTORY_SOFTWARE;
            Profs(icycle).history_software_release(:,1,N_HISTORY+1)='1   ';
            Profs(icycle).history_reference(1:length(HISTORY_REFERENCE),1,N_HISTORY+1)=HISTORY_REFERENCE;
            Profs(icycle).history_date(:,1,N_HISTORY+1)=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
            Profs(icycle).history_action(:,1,N_HISTORY+1)='QC  ';
            Profs(icycle).history_parameter(:,1,N_HISTORY+1)='PSAL            ';
            
            Profs(icycle).data_mode=strrep(Profs(icycle).data_mode,'R','D');
            Profs(icycle).data_mode=strrep(Profs(icycle).data_mode,'A','D');
            Profs(icycle).data_state_indicator=strrep(Profs(icycle).data_state_indicator,'2B  ','2C+ ');
            
            Profs(icycle).pres_adjusted=round(Profs(icycle).pres_adjusted*10)/10;
            Profs(icycle).pres_adjusted_qc;
            Profs(icycle).pres_adjusted_error;
            
            Profs(icycle).temp_adjusted=round(Profs(icycle).temp_adjusted*1000)/1000;
            Profs(icycle).temp_adjusted_qc;
            Profs(icycle).temp_adjusted_error;
            
            sizevar=Profs(icycle).temp_adjusted';
            
            Profs(icycle).psal_adjusted=round(CAL.cal_SAL(1:size(sizevar,1),icycle)'*1000)/1000;
            Profs(icycle).psal_adjusted_qc=strrep(Profs(icycle).psal_adjusted_qc,'1',PSAL_ADJUSTED_QC_FLAG);
            Profs(icycle).psal_adjusted_qc=strrep(Profs(icycle).psal_adjusted_qc,'2',PSAL_ADJUSTED_QC_FLAG);
            Profs(icycle).psal_adjusted_qc=strrep(Profs(icycle).psal_adjusted_qc,'3',PSAL_ADJUSTED_QC_FLAG);
            
            %Estimacion error en salinidad
            err=((CAL.cal_SAL_err(1:size(sizevar),icycle)).^2+(Profs(icycle).psal_adjusted_error'.^2)).^(1/2);
            Profs(icycle).psal_adjusted_error=max(err,0.01)';
            
            %Calibration information for each profile
            %Calibrations are applied to parameters to create adjusted parameters. Different calibration methods will be used by groups processing Argo data. When a method is applied, its description is stored in the following fields.
            %This section contains calibration information for each parameter of each profile.
            %Each item of this section has a N_PROF (number of profiles), N_CALIB (number of calibrations), N_PARAM (number of parameters) dimension.
            %If no calibration is available, N_CALIB is set to 1, all values of calibration section are set to fill values.
            
            for ipara=1:DATA.Profs(icycle).n_param
                if strncmp(DATA.Profs(icycle).station_parameters(:,ipara)','PSAL',4)
                    iPsal=ipara;
                end
            end
            
            Profs(icycle).n_calib=Profs(icycle).n_calib;
            N_CALIB=Profs(icycle).n_calib;
            Profs(icycle).parameter(:,N_CALIB,iPsal)=['PSAL' repmat(' ',[1 12])];
            Profs(icycle).n_calib=Profs(icycle).n_calib;
            Profs(icycle).parameter(1:4,Profs(icycle).n_calib,iPsal)='PSAL';
            
            var=strcat(deblank(Profs(icycle).scientific_calib_comment(:,1,iPsal)'),SCIENTIFIC_CALIB_COMMENT_PSAL);
            Profs(icycle).scientific_calib_comment(1:length(var),Profs(icycle).n_calib,iPsal)=var;
            
            var=strcat(deblank(Profs(icycle).scientific_calib_equation(:,1,iPsal)'),SCIENTIFIC_CALIB_EQUATION_PSAL);
            Profs(icycle).scientific_calib_equation(1:length(var),Profs(icycle).n_calib,iPsal)=var;
            
            var=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
            Profs(icycle).scientific_calib_date(1:length(var),Profs(icycle).n_calib,iPsal)=var;
            
            %Compute vertically averaged salinity (PSS?78) additive correction DS with errors
            avgSoffset=nanmean(Soffset(:,icycle));
            avgSoffset_error=nanmean(CAL.cal_SAL_err(:,icycle))';
            SCIENTIFIC_CALIB_PSAL=sprintf('r = %7.8f (+/- %7.8f), vertically averaged DeltaS = %7.4f  (+/-%7.4f)',CAL.pcond_factor(icycle),CAL.pcond_factor_err(icycle),avgSoffset,avgSoffset_error);
            Profs(icycle).scientific_calib_coefficient(1:length(SCIENTIFIC_CALIB_PSAL),N_CALIB,iPsal)=SCIENTIFIC_CALIB_PSAL;
            
        else
            Profs(icycle).editted=1;
            %History information
            N_HISTORY=size(Profs(icycle).history_institution,3);
            Profs(icycle).history_institution(:,1,N_HISTORY+1)=HISTORY_INSTITUTION;
            Profs(icycle).history_step(:,1,N_HISTORY+1)='ARSQ';
            Profs(icycle).history_software(:,1,N_HISTORY+1)=HISTORY_SOFTWARE;
            Profs(icycle).history_software_release(:,1,N_HISTORY+1)='1   ';
            Profs(icycle).history_reference(1:length(HISTORY_REFERENCE),1,N_HISTORY+1)=HISTORY_REFERENCE;
            Profs(icycle).history_date(:,1,N_HISTORY+1)=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
            Profs(icycle).history_action(:,1,N_HISTORY+1)='QC  ';
            Profs(icycle).history_parameter(:,1,N_HISTORY+1)='PSAL            ';
            
            %Asignacion err = 0.01 por criterio del Argo Steering Team
            sizevar=Profs(icycle).psal_adjusted';
            err=((CAL.cal_SAL_err(1:size(sizevar),icycle)).^2+(Profs(icycle).psal_adjusted_error'.^2)).^(1/2);
            Profs(icycle).psal_adjusted_error=max(err,0.01)';
            
            Profs(icycle).data_mode=strrep(Profs(icycle).data_mode,'R','D');
            Profs(icycle).data_mode=strrep(Profs(icycle).data_mode,'A','D');
            Profs(icycle).data_state_indicator=strrep(Profs(icycle).data_state_indicator,'2B  ','2C  ');
        end
        
        idx_pres=find(Profs(icycle).pres_adjusted_qc=='4');
        if idx_pres~=0;
            Profs(icycle).pres_adjusted_error(idx_pres)=NaN;
            Profs(icycle).pres_adjusted(idx_pres)=NaN;
        end
        idx_temp=find(Profs(icycle).temp_adjusted_qc=='4');
        if idx_temp~=0;
            Profs(icycle).temp_adjusted_error(idx_temp)=NaN;
            Profs(icycle).temp_adjusted(idx_temp)=NaN;
        end
        idx_sal=find(Profs(icycle).psal_adjusted_qc=='4');
        if idx_sal~=0;
            Profs(icycle).psal_adjusted_error(idx_sal)=NaN;
            Profs(icycle).psal_adjusted(idx_sal)=NaN;
        end
    end
    
    flname_out=fullfile(GlobalSU.ArgoDMQC,'Data','float_sourceQC2',filesep,sprintf('%6d',floats(iboya)));
    fprintf('    > Saving to filename %s \n',flname_out)
    save(flname_out,'Profs')
    
end

