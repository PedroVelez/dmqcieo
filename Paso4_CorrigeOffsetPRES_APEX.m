%% Step 4. Description:
%   This file ONLY corrects Pressure offsets based in the information
%   collected at Step3 for APEX floats ONLY. This file has expiration date
%   as soon as all the APEX Floats with Platform Models < APF 9 are disabled.
%   Its pressure values less than zero(0) are wrong reported as zero(0).
%   This is known as "Truncated Negative Drift Pressure" (TNDP).
%
%   cTNDPi = Beginning of TNDP anomaly (cycle).
%   cTNDPf = End of TNDP anomaly (cycle).
%
%   If TNDP anomaly is not perceived, cTNDPi == cTNDPf == NaN.
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
floats=[6900763];

cTNPDi=NaN; %Inicio de la fase TNDP
cTNPDf=NaN; %Fin de la fase TNDP
cTNPDn=NaN; %Inicio de la anomalia T/S
%
% SCIENTIFIC_CALIB_COMMENT_PRES='Pressure adjusted using pressure offset at the seasurface.Calibration error is manufacturer specified accuracy.';
% SCIENTIFIC_CALIB_COMMENT_PRES_TNPD='TNPD: APEX float that truncated negative pressure drift.But do not show T/S anomalies that increase negative pressure drift.';
% SCIENTIFIC_CALIB_COMMENT_PRES_TNPDA='TNPD: APEX float that truncated negative pressure drift.But show T/S anomalies that increase negative pressure drift.';
% SCIENTIFIC_CALIB_COMMENT_PSAL='Salinity recomputed after correcting pressure offset.';
% SCIENTIFIC_CALIB_COMMENT_TEMP='Adjusted temperature is the same as the real time temperature.';
%
% SCIENTIFIC_CALIB_EQUATION_PRES='PRES_ADJUSTED(cycle i)=PRES (cycle i)-Surface Pressure(cycle i+1).';
% SCIENTIFIC_CALIB_EQUATION_PSAL='PSAL (recomputed using PRES_ADJUSTED).PSAL Cell Thermal Mass celltm_sbe41.';
% SCIENTIFIC_CALIB_EQUATION_TEMP='TEMP_ADJUSTED=TEMP.';

% SCIENTIFIC_CALIB_COEFFICIENT_PRES='Surface pressure=0 dbar.';

SCIENTIFIC_CALIB_COMMENT_PRES='APEX float that not truncated negative pressure drift. Pressure adjusted by using pressure offset at the sea surface. Calibration error is manufacturer specified accuracy in dbar.';
SCIENTIFIC_CALIB_COMMENT_PRES_TNPD='TNPD: APEX float that truncated negative pressure drift. But do not show T/S anomalies that increase negative pressure drift.';
SCIENTIFIC_CALIB_COMMENT_PRES_TNPDA='TNPD: APEX float that truncated negative pressure drift. But show T/S anomalies that increase negative pressure drift.';
SCIENTIFIC_CALIB_COMMENT_PSAL='Salinity recomputed for pressure offset.';
SCIENTIFIC_CALIB_COMMENT_TEMP='Adjusted temperature is the same as the real time temperature.';

SCIENTIFIC_CALIB_EQUATION_PRES='PRES_ADJUSTED(cycle i)=PRES (cycle i)-Surface Pressure(cycle i+1).';
SCIENTIFIC_CALIB_EQUATION_PSAL='PSAL re-calculated using PRES_ADJUSTED.';
SCIENTIFIC_CALIB_EQUATION_TEMP='TEMP.';

SCIENTIFIC_CALIB_COEFFICIENT_PRES='Surface pressure=0 dbar';

HISTORY_INSTITUTION='SP  '; %[Default='    ']
HISTORY_SOFTWARE='AIEO';
HISTORY_REFERENCE='WOA05';
%----------------------------------------------------------------------
% Inicio
%----------------------------------------------------------------------
fprintf('>>>>> %s\n',mfilename)
pathDM=fullfile(GlobalSU.ArgoDMQC,'Data',filesep);

for iboya = 1:length(floats);
    ppresmin_adjusted=[];
    salssur_adjusted=[];
    temssur_adjusted=[];
    
    flnameIn=fullfile(pathDM,filesep,'DMsurfpres',filesep,sprintf('%6d',floats(iboya)));DATA=load(flnameIn);
    flnameOut =fullfile(pathDM,'DMCorrect_offset_PRES',sprintf('%6d',floats(iboya)));
    
    Profs=DATA.Profs;
    
    if strncmp(Profs(1).platform_type','PROVOR',6)==1
        fprintf('------------> NO Pressure correction %s FLOAT \n',Profs(1).platform_type)
    else
        fprintf('------------> Pressure correction %s FLOAT \n',Profs(1).platform_type)
        fprintf('    > Loaded SurfaceOffset and data from filename %s \n',flnameIn)
        %% Correction
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
            
            ppre=Profs(icycle).pres;
            ptem=Profs(icycle).temp;
            psal=Profs(icycle).psal;
            
            offset_pres=DATA.SSP(icycle);
            
            %Pressure
            %Corregiomos PRES original (RT) y la guardamos en valores ajustados
            pres_adjusted=ppre-offset_pres;
            Profs(icycle).pres_adjusted=pres_adjusted;
            
            %Salinity
            %Recalculo la salinidad con la nueva presi?n
            cndr = sw_cndr(psal,ptem,ppre);
            sals_adjusted = sw_salt(cndr,ptem,pres_adjusted);
            Profs(icycle).psal_adjusted=sals_adjusted;
            
            %Temperature
            %Dejo la temperatura como la original
            tems_adjusted=Profs(icycle).temp;
            Profs(icycle).temp_adjusted=tems_adjusted;
            
            %QC
            %Asigno QC a DM incialmente como las de RT
            Profs(icycle).pres_adjusted_qc=Profs(icycle).pres_qc;
            Profs(icycle).psal_adjusted_qc=Profs(icycle).psal_qc;
            Profs(icycle).temp_adjusted_qc=Profs(icycle).temp_qc;
            
            Profs(icycle).temp_adjusted_=0.0025*ones(1,size(Profs(icycle).temp,2));
            %Salinity error due to pressure uncertainty is negligible, and can be ignored in the consideration of PSAL_ADJUSTED_ERROR.
            
            % "station_parameter" variable correction. Sometimes RAW data
            % brings "TPP ESR MAE PLS"
            %         new_station_parameters = Profs(icycle).station_parameters(1:4,1:3);
            %         new_station_parameters(1,:)='PTP';
            %         new_station_parameters(2,:)='RES';
            %         new_station_parameters(3,:)='EMA';
            %         new_station_parameters(4,:)='SPL';
            %         Profs(icycle).station_parameters(1:4,1:3) = new_station_parameters;
            
            if isfield(Profs,'parameter_dsata_mode')==1
                Profs(icycle).parameter_data_mode(iPres)='D';
                Profs(icycle).parameter_data_mode(iPsal)='D';
            end
            
            %Valores en superficie para visualizacion
            pres_min_adjusted=min(pres_adjusted);
            J=find(pres_adjusted==min(pres_adjusted),1);
            ppresmin_adjusted=[ppresmin_adjusted pres_min_adjusted];
            % Poner NaN a salssur_adjusted y ptmpssur_adjusted cuando pres esta vacia
            if isempty(J)==1
                salssur_adjusted2=nan;
                temssur_adjusted2=nan;
                fprintf('    > el sensor de la boya %6d no da valores \n',floats(iboya))
            else
                salssur_adjusted2=sals_adjusted(J);
                temssur_adjusted2=tems_adjusted(J);
            end
            salssur_adjusted=[salssur_adjusted salssur_adjusted2];
            temssur_adjusted=[temssur_adjusted temssur_adjusted2];
        end
        
        %% Modifico los campos de History y Calib
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
            
            %Verifico cuantas calibraciones hay hechas
            %Tengo que expandir las matrices de SCIENTIFIC_CALIB si es la primera
            if Profs(icycle).n_calib>1
                Profs(icycle).n_calib=Profs(icycle).n_calib+1;
            end
            
            %Anadir a parametres en n_calib
            Profs(icycle).parameter(1:4,Profs(icycle).n_calib,iPres)='PRES';
            Profs(icycle).parameter(1:4,Profs(icycle).n_calib,iTemp)='TEMP';
            Profs(icycle).parameter(1:4,Profs(icycle).n_calib,iPsal)='PSAL';
            fprintf('    > Ciclo %3d. n_calib %d',icycle,Profs(icycle).n_calib)
            if icycle>=cTNPDi && icycle<=cTNPDf;
                fprintf('    > La boya  es TNPD a este ciclo\n');
                if isfinite(cTNPDn)==0 %No hay anomalia de del T/S.
                    fprintf('      scientific_calib Pres %s\n',SCIENTIFIC_CALIB_COMMENT_PRES_TNPD);
                    fprintf('      scientific_calib Psal %s\n',SCIENTIFIC_CALIB_COMMENT_PSAL);
                    fprintf('      scientific_calib_date %s\n',sprintf('%04d%02d%02d%02d%02d%02d',round(clock)));
                    
                    Profs(icycle).scientific_calib_comment(1:length(SCIENTIFIC_CALIB_COMMENT_PRES_TNPD),Profs(icycle).n_calib,iPres)=SCIENTIFIC_CALIB_COMMENT_PRES_TNPD;
                    Profs(icycle).scientific_calib_comment(:,Profs(icycle).n_calib,iPsal)=' '; %BORRAMOS EL CONTENIDO ANTERIOR PARA ESCRIBIR EN LA SIGUIENTE LINEA
                    Profs(icycle).scientific_calib_comment(1:length(SCIENTIFIC_CALIB_COMMENT_PSAL),Profs(icycle).n_calib,iPsal)=SCIENTIFIC_CALIB_COMMENT_PSAL;
                    
                    %strcat(deblank(Profs(icycle).scientific_calib_comment(:,1,iPsal)')
                    
                    
                    
                    Profs(icycle).pres_adjusted_qc=strrep(Profs(icycle).pres_adjusted_qc,'1','2');
                    Profs(icycle).pres_adjusted_qc=strrep(Profs(icycle).pres_adjusted_qc,'0','2');
                    
                    Profs(icycle).scientific_calib_date(:,Profs(icycle).n_calib,iPres)=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
                    Profs(icycle).scientific_calib_date(:,Profs(icycle).n_calib,iPsal)=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
                    %                  %History information
                    %                  n_history=size(Profs(icycle).history_institution,3);
                    %                  Profs(icycle).history_institution(:,1,n_history+1)=HISTORY_INSTITUTION;
                    %                  Profs(icycle).history_step(:,1,n_history+1)='ARSQ';
                    %                  Profs(icycle).history_software(:,1,n_history+1)=HISTORY_SOFTWARE;
                    %                  Profs(icycle).history_software_release(:,1,n_history+1)='1   ';
                    %                  Profs(icycle).history_reference(1:length(HISTORY_REFERENCE),1,n_history+1)=HISTORY_REFERENCE;
                    %                  Profs(icycle).history_date(:,1,n_history+1)=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
                    %                  Profs(icycle).history_action(:,1,n_history+1)='QC  ';
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
                    
                    fprintf('      QC_FLAG=2\n')
                    Profs(icycle).pres_adjusted_error=2.4*ones(1,size(Profs(icycle).pres_adjusted_error,2));
                elseif icycle>=cTNPDn
                    fprintf('      scientific_calib Pres %s\n',SCIENTIFIC_CALIB_COMMENT_PRES_TNPDA);
                    fprintf('      scientific_calib Psal %s\n',SCIENTIFIC_CALIB_COMMENT_PSAL);
                    fprintf('      scientific_calib_date %s\n',sprintf('%04d%02d%02d%02d%02d%02d',round(clock)));
                    
                    Profs(icycle).scientific_calib_comment(1:length(SCIENTIFIC_CALIB_COMMENT_PRES_TNPDA),Profs(icycle).n_calib,iPres)=SCIENTIFIC_CALIB_COMMENT_PRES_TNPDA;
                    Profs(icycle).scientific_calib_comment(:,Profs(icycle).n_calib,iPsal)=' '; %BORRAMOS EL CONTENIDO ANTERIOR PARA ESCRIBIR EN LA SIGUIENTE LINEA
                    Profs(icycle).scientific_calib_comment(1:length(SCIENTIFIC_CALIB_COMMENT_PSAL),Profs(icycle).n_calib,iPsal)=SCIENTIFIC_CALIB_COMMENT_PSAL; %Creo que no se pone este comentario
                    
                    Profs(icycle).scientific_calib_date(:,Profs(icycle).n_calib,iPres)=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
                    Profs(icycle).scientific_calib_date(:,Profs(icycle).n_calib,iPsal)=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
                    
                    %History information
                    %n_history=(Profs(icycle).n_history+1);
                    %n_history=size(Profs(icycle).history_institution,3);
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
                    
                    fprintf('      QC_FLAG=4\n')
                    Profs(icycle).pres_adjusted_qc=strrep(Profs(icycle).pres_adjusted_qc,'1','4');
                    Profs(icycle).pres_adjusted_qc=strrep(Profs(icycle).pres_adjusted_qc,'0','4');
                    Profs(icycle).pres_adjusted_error=NaN*ones(1,size(Profs(icycle).pres_adjusted_error,2));
                else
                    fprintf('      scientific_calib Pres %s\n',SCIENTIFIC_CALIB_COMMENT_PRES_TNPDA);
                    fprintf('      scientific_calib Psal %s\n',SCIENTIFIC_CALIB_COMMENT_PSAL);
                    fprintf('      scientific_calib_date %s\n',sprintf('%04d%02d%02d%02d%02d%02d',round(clock)));
                    
                    Profs(icycle).scientific_calib_comment(1:length(SCIENTIFIC_CALIB_COMMENT_PRES_TNPDA),Profs(icycle).n_calib,iPres)=SCIENTIFIC_CALIB_COMMENT_PRES_TNPDA;
                    Profs(icycle).scientific_calib_comment(:,Profs(icycle).n_calib,iPsal)=' '; %BORRAMOS EL CONTENIDO ANTERIOR PARA ESCRIBIR EN LA SIGUIENTE LINEA
                    Profs(icycle).scientific_calib_comment(1:length(SCIENTIFIC_CALIB_COMMENT_PSAL),Profs(icycle).n_calib,iPsal)=SCIENTIFIC_CALIB_COMMENT_PSAL;
                    
                    Profs(icycle).scientific_calib_date(:,Profs(icycle).n_calib,iPres)=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
                    Profs(icycle).scientific_calib_date(:,Profs(icycle).n_calib,iPsal)=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
                    
                    %History information
                    %n_history=(Profs(icycle).n_history+1);
                    %n_history=size(Profs(icycle).history_institution+1,3);
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
                    
                    fprintf('      QC_FLAG=4\n')
                    Profs(icycle).pres_adjusted_qc=strrep(Profs(icycle).pres_adjusted_qc,'1','2');
                    Profs(icycle).pres_adjusted_qc=strrep(Profs(icycle).pres_adjusted_qc,'0','2');
                    Profs(icycle).pres_adjusted_error=20*ones(1,size(Profs(icycle).pres_adjusted_error,2));
                end
            else
                fprintf('    > La boya no es TNPD a este ciclo.\n');
                fprintf('      scientific_calib Pres %s\n',SCIENTIFIC_CALIB_COMMENT_PRES);
                fprintf('      scientific_calib Psal %s\n',SCIENTIFIC_CALIB_COMMENT_PSAL);
                fprintf('      scientific_calib_date %s\n',sprintf('%04d%02d%02d%02d%02d%02d',round(clock)));
                fprintf('      scientific_calib equation PRES %s\n',SCIENTIFIC_CALIB_EQUATION_PRES);
                fprintf('      scientific_calib equation PSAL %s\n',SCIENTIFIC_CALIB_EQUATION_PSAL);
                fprintf('      scientific_calib equation TEMP %s\n',SCIENTIFIC_CALIB_EQUATION_TEMP);
                
                Profs(icycle).scientific_calib_comment(1:length(SCIENTIFIC_CALIB_COMMENT_PRES),Profs(icycle).n_calib,iPres)=SCIENTIFIC_CALIB_COMMENT_PRES;
                Profs(icycle).scientific_calib_comment(:,Profs(icycle).n_calib,iPsal)=' '; %BORRAMOS EL CONTENIDO ANTERIOR PARA ESCRIBIR EN LA SIGUIENTE LINEA
                Profs(icycle).scientific_calib_comment(1:length(SCIENTIFIC_CALIB_COMMENT_PSAL),Profs(icycle).n_calib,iPsal)=SCIENTIFIC_CALIB_COMMENT_PSAL;
                %Profs(icycle).scientific_calib_comment(1:length(SCIENTIFIC_CALIB_COMMENT_TEMP),Profs(icycle).n_calib,iTemp)=SCIENTIFIC_CALIB_COMMENT_TEMP;
                
                Profs(icycle).scientific_calib_equation(1:length(SCIENTIFIC_CALIB_EQUATION_PRES),Profs(icycle).n_calib,iPres)=SCIENTIFIC_CALIB_EQUATION_PRES;
                Profs(icycle).scientific_calib_equation(1:length(SCIENTIFIC_CALIB_EQUATION_PSAL),Profs(icycle).n_calib,iPsal)=SCIENTIFIC_CALIB_EQUATION_PSAL;
                %Profs(icycle).scientific_calib_equation(1:length(SCIENTIFIC_CALIB_EQUATION_TEMP),Profs(icycle).n_calib,iTemp)=SCIENTIFIC_CALIB_EQUATION_TEMP;
                
                Profs(icycle).scientific_calib_coefficient(1:length(SCIENTIFIC_CALIB_COEFFICIENT_PRES),Profs(icycle).n_calib,iPres)=SCIENTIFIC_CALIB_COEFFICIENT_PRES;
                
                Profs(icycle).scientific_calib_date(:,Profs(icycle).n_calib,iPres)=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
                Profs(icycle).scientific_calib_date(:,Profs(icycle).n_calib,iPsal)=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
                % Profs(icycle).scientific_calib_date(:,Profs(icycle).n_calib,iTemp)=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
                
                %History information
                %n_history=(Profs(icycle).n_history+1);
                %n_history=size(Profs(icycle).history_institution+1,3);
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
                
                Profs(icycle).pres_adjusted_qc=strrep(Profs(icycle).pres_adjusted_qc,'2','1');
                Profs(icycle).pres_adjusted_qc=strrep(Profs(icycle).pres_adjusted_qc,'3','1');
                Profs(icycle).pres_adjusted_error=2.4*ones(1,size(Profs(icycle).pres_adjusted_error,2));
            end
        end
        
        %% Figuras
        figure
        for i1=1:size(Profs,2)
            h1(i1)=plot(Profs(i1).psal,Profs(i1).temp,'o','Markersize',3,'MarkerFaceColor',[.65 .65 .65],'MarkerEdgeColor',[.65 .65 .65]);hold on
        end
        for i1=1:size(Profs,2)
            h2(i1)=plot(Profs(i1).psal_adjusted,Profs(i1).temp_adjusted,'.-','Color',Colores(i1));hold on
        end
        legend([h1(1) h2(1)],'RT','DM')
        grid on;set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
        title(sprintf('%s TS Corrected for surface offset QC=1,2,3',Profs(1).platform_number'))
        
        %Represento valores en superficie
        figure
        subplot(3,1,1)
        p1=plot(DATA.cycle_number,DATA.SSP,'color','b','Marker','*','Linestyle','none');hold on;grid on
        p2=plot(DATA.cycle_number,ppresmin_adjusted,'color','k','Marker','x','Linestyle','none');
        set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
        legend([p1,p2],'Surface pressure original','Minimum profile pressure adjusted Delayed Mode');
        title(sprintf('WMO %s %s. Surface values',deblank(DATA.platform),DATA.platform_model))
        subplot(3,1,2)
        h1=plot(DATA.cycle_number,salssur_adjusted,'bo-');hold on;grid on
        set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
        title('salinity adjusted')
        subplot(3,1,3)
        h2=plot(DATA.cycle_number,temssur_adjusted,'ko-');
        set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
        title('ptmps adjusted')
        
        fprintf('    > Saving to filename %s \n',flnameOut)
        
        figure(1);orient landscape;CreaFigura(1,strcat(flnameOut,'_01'),7)
        figure(2);orient landscape;CreaFigura(2,strcat(flnameOut,'_02'),7)
        
        %% Salvamos resultados
        if length(floats)>1
            close all
        end
        save(flnameOut,'Profs','cTNPDi','cTNPDf','cTNPDn')
    end
end
fprintf('      %s >>>>>\n',mfilename)




