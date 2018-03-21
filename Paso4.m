%% Step 4. Description:
%   This file ONLY corrects Pressure offsets based in the information
%   collected at Step3 for APEX floats ONLY. This file has expiration date
%   as soon as all the APEX Floats with Platform Models < APF 9 are disabled.
%   Its pressure values less than zero(0) are wrong reported as zero(0).
%   This is known as "Truncated Negative Drift Pressure" (TNDP).
%
%   ****************FIRST CALIBRATION IS CARRIED OUT***********************
%   Pressure is recomputed. Salinity is recomputed. Temperature is
%   recomputed if needed. If not, original values are kept.
%
%   ***************FIRST SCIENTIFIC COMMENTS ARE MADE**********************
%   Each modification/recomputation must be registered at SCIENTIFIC_CALIB
%   and HISTORY fields [Please check Argo DM Manual v3.1 for more information].
%
%   ************SECOND QUALITY CONTROL FLAG IS CARRIED OUT*****************
%   A quality flag indicates the quality of an observation. The flags are
%   assigned in Real Time (RT) and can be modified in Delayed Mode (DM).
%   Flags are set in a range from 0 to 9 [Please check Argo DM Manual v3.1
%   for more information]. Each correction must be flagged.
%   <www.oceanografia.argo.es>
%
%   Pedro Velez & Alberto Gonzalez (2016)

Limpia

%cTNPDi y cTNPDf se refieren a numero de orden del perfil.
floats=[1900379];

SCIENTIFIC_CALIB_COMMENT_PRES='No significant pressure drift detected - Calibration error is manufacturer specified accuracy';
SCIENTIFIC_CALIB_COMMENT_PSAL='No significant salinity drift detected - Calibration error is manufacturer specified accuracy';
SCIENTIFIC_CALIB_COMMENT_TEMP='No significant temperature drift detected - Calibration error is manufacturer specified accuracy';

SCIENTIFIC_CALIB_EQUATION_PRES='PRES_ADJUSTED(cycle i)=PRES (cycle i)-Surface Pressure(cycle i+1).';
SCIENTIFIC_CALIB_EQUATION_PSAL='';
SCIENTIFIC_CALIB_EQUATION_TEMP='';

SCIENTIFIC_CALIB_COEFFICIENT_PRES='Surface pressure=0 dbar';

HISTORY_INSTITUTION='SP  '; %[Default='    ']
HISTORY_SOFTWARE='AIEO';
HISTORY_REFERENCE='WOA05';

%% Inicio
fprintf('>>>>> %s\n',mfilename)
pathDM=fullfile(GlobalSU.ArgoDMQC,'Data',filesep);

for iboya = 1:length(floats);
    flnameIn=fullfile(pathDM,filesep,'DMsurfpres',filesep,sprintf('%6d',floats(iboya)));DATA=load(flnameIn);
    flnameOut =fullfile(pathDM,'DMCorrect_offset_PRES',sprintf('%6d',floats(iboya)));
    flnameOut2=fullfile(GlobalSU.ArgoDMQC,('Data'),'DMCell_Thermal_Mass_Error',sprintf('%6d',floats(iboya)));
    
    Profs=DATA.Profs;
    
    for icycle=1:length(DATA.cycle_number)
        for ipara=1:Profs(icycle).n_param
            if strncmp(Profs(icycle).station_parameters(:,ipara)','PRES',4)
                iPres=ipara;
            elseif strncmp(Profs(icycle).station_parameters(:,ipara)','TEMP',4)
                iTemp=ipara;
            elseif strncmp(Profs(icycle).station_parameters(:,ipara)','PSAL',4)
                iPsal=ipara;
            end
        end
        
        %Crea variables para los valores adjusted
        ppre=Profs(icycle).pres;
        ptem=Profs(icycle).temp;
        psal=Profs(icycle).psal;
        
        %Siguiendo la tabla 3.4.6 copio los valores adjusted como copia de
        %los originales. Despues se modificaran en OW
        Profs(icycle).pres_adjusted=ppre;
        Profs(icycle).psal_adjusted=psal;
        Profs(icycle).temp_adjusted=ptem;
        
        %Asigno QC a DM incialmente como las de RT
        Profs(icycle).pres_adjusted_qc=Profs(icycle).pres_qc;
        Profs(icycle).psal_adjusted_qc=Profs(icycle).psal_qc;
        Profs(icycle).temp_adjusted_qc=Profs(icycle).temp_qc;
        
        %Salinity error due to pressure uncertainty is negligible, and can be ignored in the consideration of PSAL_ADJUSTED_ERROR.
        Profs(icycle).temp_adjusted_error=0.0025*ones(1,size(Profs(icycle).temp,2));
        Profs(icycle).pres_adjusted_error=2.4*ones(1,size(Profs(icycle).pres_adjusted_error,2));
        
        if isfield(Profs,'parameter_data_mode')==1
            Profs(icycle).parameter_data_mode(iPres)='D';
            Profs(icycle).parameter_data_mode(iPsal)='D';
        end
        
        %Verifico cuantas calibraciones hay hechas
        %Tengo que expandir las matrices de SCIENTIFIC_CALIB si es la primera
        if Profs(icycle).n_calib>1
            Profs(icycle).n_calib=Profs(icycle).n_calib+1;
        end
        
        %Anadir a parametres en n_calib
        fprintf('    > Ciclo %3d. n_calib %d \n',icycle,Profs(icycle).n_calib)
        Profs(icycle).parameter(1:4,Profs(icycle).n_calib,iPres)='PRES';
        Profs(icycle).parameter(1:4,Profs(icycle).n_calib,iTemp)='TEMP';
        Profs(icycle).parameter(1:4,Profs(icycle).n_calib,iPsal)='PSAL';
        
        %Hacemos un cambio en la variable "scientific_calib_coefficient" para
        %algunas boyas antiguas. Su valor estandar debe ser FillValue y no "none".
        
        %AQUI
        
        %Creo los campos de scientific_calib.
        Profs(icycle).scientific_calib_comment(1:length(SCIENTIFIC_CALIB_COMMENT_PRES),Profs(icycle).n_calib,iPres)=SCIENTIFIC_CALIB_COMMENT_PRES;
        Profs(icycle).scientific_calib_comment(1:length(SCIENTIFIC_CALIB_COMMENT_PSAL),Profs(icycle).n_calib,iPsal)=SCIENTIFIC_CALIB_COMMENT_PSAL;
        Profs(icycle).scientific_calib_comment(1:length(SCIENTIFIC_CALIB_COMMENT_TEMP),Profs(icycle).n_calib,iTemp)=SCIENTIFIC_CALIB_COMMENT_TEMP;
        
        Profs(icycle).scientific_calib_equation(1:length(SCIENTIFIC_CALIB_EQUATION_PRES),Profs(icycle).n_calib,iPres)=SCIENTIFIC_CALIB_EQUATION_PRES;
        Profs(icycle).scientific_calib_equation(1:length(SCIENTIFIC_CALIB_EQUATION_PSAL),Profs(icycle).n_calib,iPsal)=SCIENTIFIC_CALIB_EQUATION_PSAL;
        Profs(icycle).scientific_calib_equation(1:length(SCIENTIFIC_CALIB_EQUATION_TEMP),Profs(icycle).n_calib,iTemp)=SCIENTIFIC_CALIB_EQUATION_TEMP;
        
        Profs(icycle).scientific_calib_coefficient(1:length(SCIENTIFIC_CALIB_COEFFICIENT_PRES),Profs(icycle).n_calib,iPres)=SCIENTIFIC_CALIB_COEFFICIENT_PRES;
        
        Profs(icycle).scientific_calib_date(:,Profs(icycle).n_calib,iPres)=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
        Profs(icycle).scientific_calib_date(:,Profs(icycle).n_calib,iPsal)=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
        Profs(icycle).scientific_calib_date(:,Profs(icycle).n_calib,iTemp)=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
        
        
        
        %History information
        n_history=size(Profs(icycle).history_institution,3);
        Profs(icycle).n_history=n_history;
        Profs(icycle).history_institution(:,1,n_history+1)=HISTORY_INSTITUTION;
        Profs(icycle).history_step(:,1,n_history+1)='ARSQ';
        Profs(icycle).history_software(:,1,n_history+1)=HISTORY_SOFTWARE;
        Profs(icycle).history_software_release(:,1,n_history+1)='1   ';
        Profs(icycle).history_reference(1:length(HISTORY_REFERENCE),1,n_history+1)=HISTORY_REFERENCE;
        Profs(icycle).history_date(:,1,n_history+1)=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
        Profs(icycle).history_action(:,1,n_history+1)='QC  ';
        Profs(icycle).history_parameter(:,1,n_history+1)='PRES            ';
    end
    save(flnameOut,'Profs')
    save(flnameOut2,'Profs')
end
fprintf('      %s >>>>>\n',mfilename)

