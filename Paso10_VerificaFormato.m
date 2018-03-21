%% Step 10. Description:
%   This file double checks all the previous steps making some tests. Plots
%   are generated. SCIENTIFIC and HISTORY fields are double checked. Profile
%   quality assignment is calculated. QC FLAG values are double checked. RT
%   profile vs DM profile sizes are double checked.
%   <www.oceanografia.argo.es>
%
%   Pedro Velez & Alberto Gonzalez (2016)

Limpia

floats=[1900379];

pathDM=fullfile(GlobalSU.ArgoDMQC,'Data',filesep);
inpathDM=fullfile(GlobalSU.ArgoDMQC,'Data','float_sourceQC2',filesep);

for iboya=1:length(floats)
    flnameout=fullfile(GlobalSU.ArgoDMQC,('Data'),'float_sourceQC2',strcat(num2str(floats(iboya))))
    %Leemos los datos medidos por la boya
    %Profs=ReadArgoProfiles(strcat(inpathAD,filesep,num2str(floats(iboya)),filesep,'profiles',filesep),1);
    DATA=load(strcat(inpathDM,sprintf('%6d',floats(iboya))));
    Profs=DATA.Profs;
    
    %% Figuras
    %Represento TS
    figure
    for i2=1:size(Profs,2)
        h1(i2)=plot(Profs(i2).psal,Profs(i2).temp,'o','Markersize',6,'MarkerFaceColor',[.65 .65 .65],'MarkerEdgeColor',[.65 .65 .65]);hold on
    end
    for i3=1:size(Profs,2)
        %prueba=Profs(i3).temp_adjusted';
        %h2(i3)=plot(Profs(i3).psal_adjusted(1:size(prueba)),Profs(i3).temp_adjusted,'b.-','Color',Colores(i3));hold on
        h2(i3)=plot(Profs(i3).psal_adjusted,Profs(i3).temp_adjusted,'b.-','Color',Colores(i3));hold on
    end
    
    legend([h1(1) h2(1)],'RT','DM')
    set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
    title(sprintf('%s TS Corrected QC=1,2,3',Profs(1).platform_number'))
    %Represento secciones
    pres_ad=[];
    tems_ad=[];
    sals_ad=[];
    pres=[];
    tems=[];
    sals=[];
    
    for icycle=1:size(Profs,2)
        pres_ad=merge(pres_ad,double(Profs(icycle).pres_adjusted'));
        tems_ad=merge(tems_ad,double(Profs(icycle).temp_adjusted'));
        sals_ad=merge(sals_ad,double(Profs(icycle).psal_adjusted'));
        pres=merge(pres,double(Profs(icycle).pres'));
        tems=merge(tems,double(Profs(icycle).temp'));
        sals=merge(sals,double(Profs(icycle).psal'));
    end
    
    %%Salinity
    figure
%    pcolor(ones(size(pres_ad,1),1)*[1:1:size(Profs,2)],pres_ad,sals_ad);grid on;hold on
    shading interp;colorbar
    contour(ones(size(pres_ad,1),1)*[1:1:size(Profs,2)],pres_ad,sals_ad,10,'k');
    colorbar
    title(sprintf('%s Corrected Salinity section',Profs(1).platform_number'))
    set(gca,'Xgrid','on','XMinorTick','on','Ygrid','off','YMinorTick','on','tickdir','out','ydir','reverse')
    ylabel('Pressure (dbar)')
    xlabel('Profile Number')
    %
    %Temperature
    figure
  %  pcolor(ones(size(pres_ad,1),1)*[1:1:size(Profs,2)],pres_ad,tems_ad);grid on;hold on
    shading interp;colorbar
    contour(ones(size(pres_ad,1),1)*[1:1:size(Profs,2)],pres_ad,tems_ad,10,'k');
    colorbar
    title(sprintf('%s Corrected Temperature section',Profs(1).platform_number'))
    set(gca,'Xgrid','on','XMinorTick','on','Ygrid','off','YMinorTick','on','tickdir','out','ydir','reverse')
    ylabel('Pressure (dbar)')
    xlabel('Profile Number')
    
    
    tems_adi=pres.*NaN;
    sals_adi=pres.*NaN;
    for icycle=1:size(Profs,2)
        ppre=pres(:,icycle);
        ppre_ad=pres_ad(:,icycle);
        ptem_ad=tems_ad(:,icycle);
        psal_ad=sals_ad(:,icycle);
        
        %Interpolo los adjustes en las presiones originales
        ind=find(isnan(psal_ad)==0 & isnan(ppre_ad)==0);
        psal2_ad=psal_ad(ind);
        ppre2_ad=ppre_ad(ind);
        if length(psal2_ad)>2
            [ppre2_ad,I,J] = unique(ppre2_ad);
            psal2_ad=psal2_ad(I);
            sals_adi(:,icycle)= interp1(ppre2_ad,psal2_ad,ppre);
        end
        %Interpolo los adjustes en las presiones originales
        ind=find(isnan(ptem_ad)==0 & isnan(ppre_ad)==0);
        ptem2_ad=ptem_ad(ind);
        ppre2_ad=ppre_ad(ind);
        if length(ptem2_ad)>2
            [ppre2_ad,I,J] = unique(ppre2_ad);
            ptem2_ad=ptem2_ad(I);
            tems_adi(:,icycle)= interp1(ppre2_ad,ptem2_ad,ppre);
        end
    end
    
    %Salinity differences
    figure
    %pcolor(ones(size(pres_ad,1),1)*[1:1:size(Profs,2)],pres,sals_adi-sals);grid on;hold on
    shading interp;colorbar
    contour(ones(size(pres_ad,1),1)*[1:1:size(Profs,2)],pres,sals_adi-sals,10,'k');
    colorbar
    title(sprintf('%s Corrected-Real time salinity section [%5.4f - %5.4f]',Profs(1).platform_number', nanmin(nanmin(sals_adi-sals)), nanmax(nanmax(sals_adi-sals))))
    set(gca,'Xgrid','on','XMinorTick','on','Ygrid','off','YMinorTick','on','tickdir','out','ydir','reverse')
    ylabel('Pressure (dbar)')
    xlabel('Cycle Number')
    
    %Temperature differences
    figure
    %pcolor(ones(size(pres_ad,1),1)*[1:1:size(Profs,2)],pres,tems_adi-tems);grid on;hold on
    shading interp;colorbar
    contour(ones(size(pres_ad,1),1)*[1:1:size(Profs,2)],pres,tems_adi-tems,10,'k');
    colorbar
    title(sprintf('%s Corrected-Real time temperature section [%5.4f - %5.4f]',Profs(1).platform_number', nanmin(nanmin(tems_adi-tems)), nanmax(nanmax(tems_adi-tems))))
    set(gca,'Xgrid','on','XMinorTick','on','Ygrid','off','YMinorTick','on','tickdir','out','ydir','reverse')
    ylabel('Pressure (dbar)')
    xlabel('Cycle Number')
    
    
    figure
    subplot(2,1,1)
    errorbar([1:1:size(Profs,2)],nanmean(sals_adi-sals),nanstd(sals_adi-sals));hold on;grid on
    plot([1:1:size(Profs,2)],nanmean(sals_adi-sals),'r','linewidth',2)
    set(gca,'Xgrid','on','XMinorTick','on','Ygrid','off','YMinorTick','on')
    title('Vertical mean Corrected-Real time temperature')
    xlabel('Cycle Number')
    subplot(2,1,2)
    errorbar([1:1:size(Profs,2)],nanmean(tems_adi-tems),nanstd(tems_adi-tems));hold on;grid on
    plot([1:1:size(Profs,2)],nanmean(tems_adi-tems),'r','linewidth',2)
    set(gca,'Xgrid','on','XMinorTick','on','Ygrid','off','YMinorTick','on')
    title('Vertical mean Corrected-Real time temperature')
    xlabel('Cycle Number')
    
    %----------------------------------------------------------------------
    %% Revision de scientific_calib
    %----------------------------------------------------------------------
    for icycle=1:size(Profs,2)
        fprintf('    > Ciclo %3d. N_CALIB %d N_HSITORY%d \n',icycle,Profs(icycle).n_calib,Profs(icycle).n_history)
        station_parameters=Profs(icycle).station_parameters;
        for ip=1:size(station_parameters,2)
            for ih=1:Profs(icycle).n_calib
                fprintf('      %d scientific_calib_coefficient %s: %s\n',ih,station_parameters(1:4,ip)',Profs(icycle).scientific_calib_coefficient(:,ih,ip));
                fprintf('      %d scientific_calib_comment     %s: %s\n',ih,station_parameters(1:4,ip)',Profs(icycle).scientific_calib_comment(:,ih,ip));
                fprintf('      %d scientific_calib_date        %s: %s\n',ih,station_parameters(1:4,ip)',Profs(icycle).scientific_calib_date(:,ih,ip));
                fprintf('      %d scientific_calib_equation    %s: %s\n',ih,station_parameters(1:4,ip)',Profs(icycle).scientific_calib_equation(:,ih,ip));
            end
        end
        for ih=1:Profs(icycle).n_history
            fprintf('      %d history_institution %s\n',ih,Profs(icycle).history_institution(1:2,:,ih));
            fprintf('      %d history_history_step %s\n',ih,Profs(icycle).history_step(:,:,ih));
            fprintf('      %d history_history_date %s\n',ih,Profs(icycle).history_date(:,:,ih));
            fprintf('      %d history_history_action %s\n',ih,Profs(icycle).history_action(:,:,ih));
        end
    end
    
    %----------------------------------------------------------------------
    %% Profile Quality Flag Assigment
    %----------------------------------------------------------------------
    %The computation should be taken from <PARAM_ADJUSTED>_QC if available and from
    %<PARAM>_QC otherwise.
    for icycle=1:size(Profs,2)
        PFLAG=str2num(Profs(icycle).pres_adjusted_qc');
        TFLAG=str2num(Profs(icycle).temp_adjusted_qc');
        SFLAG=str2num(Profs(icycle).psal_adjusted_qc');
        %         end
        %PRESSURE
        s_FLAG=size(PFLAG,1);
        coef = find(PFLAG == 1 | PFLAG ==2 | PFLAG ==5 |PFLAG ==8);
        
        N = (size(coef,1)/s_FLAG(1,1)).*100;
        
        if N==0;
            Profs(icycle).profile_pres_qc='F';
        elseif  N>0 && N<25;
            Profs(icycle).profile_pres_qc='E';
        elseif N>=25 && N<50;
            Profs(icycle).profile_pres_qc='D';
        elseif N>=50 && N<75;
            Profs(icycle).profile_pres_qc='C';
        elseif N>=75 && N<100;
            Profs(icycle).profile_pres_qc='B';
        elseif N==100;
            Profs(icycle).profile_pres_qc='A';
            %         elseif isnan(N)==1;
            %             Profs(icycle).profile_pres_qc='F';
        end
        
        %TEMPERATURE
        coef = find(TFLAG == 1 | TFLAG ==2 | TFLAG ==5 |TFLAG ==8);
        
        N = (size(coef,1)/s_FLAG(1,1)).*100;
        
        if N==0;
            Profs(icycle).profile_temp_qc='F';
        elseif  N>0 && N<25;
            Profs(icycle).profile_temp_qc='E';
        elseif N>=25 && N<50;
            Profs(icycle).profile_temp_qc='D';
        elseif N>=50 && N<75;
            Profs(icycle).profile_temp_qc='C';
        elseif N>=75 && N<100;
            Profs(icycle).profile_temp_qc='B';
        elseif N==100;
            Profs(icycle).profile_temp_qc='A';
        end
        
        %SALINITY
        coef = find(SFLAG == 1 | SFLAG ==2 | SFLAG ==5 |SFLAG ==8);
        
        N = (size(coef,1)/s_FLAG(1,1)).*100;
        
        if N==0;
            Profs(icycle).profile_psal_qc='F';
        elseif  N>0 && N<25;
            Profs(icycle).profile_psal_qc='E';
        elseif N>=25 && N<50;
            Profs(icycle).profile_psal_qc='D';
        elseif N>=50 && N<75;
            Profs(icycle).profile_psal_qc='C';
        elseif N>=75 && N<100;
            Profs(icycle).profile_psal_qc='B';
        elseif N==100;
            Profs(icycle).profile_psal_qc='A';
        end
        
    end
end

%----------------------------------------------------------------------
%% Some checks before writting the final file
%----------------------------------------------------------------------
%Verifica si es el mismo tama?o de los perfiles de RT para DMQC
for i2=1:size(Profs,2)
    if ne(length(Profs(i2).pres),length(Profs(i2).pres_adjusted))
        fprintf('ERROR DE FORMATO 1 - perfil %d\n',i2)
    end
    if ne(length(Profs(i2).psal),length(Profs(i2).psal_adjusted))
        fprintf('ERROR DE FORMATO 2 - perfil %d\n',i2)
    end
    if ne(length(Profs(i2).temp),length(Profs(i2).temp_adjusted))
        fprintf('ERROR DE FORMATO 3 - perfil %d\n',i2)
    end
    if ne(length(Profs(i2).temp),length(Profs(i2).psal)) | ne(length(Profs(i2).pres),length(Profs(i2).psal)) | ne(length(Profs(i2).pres),length(Profs(i2).temp))
        fprintf('ERROR DE FORMATO 4 - perfil %d\n',i2)
    end
    if ne(length(Profs(i2).pres_qc),length(Profs(i2).pres_adjusted_qc))
        fprintf('ERROR DE FORMATO QCF 5 - perfil %d\n',i2)
    end
    if ne(length(Profs(i2).psal_qc),length(Profs(i2).psal_adjusted_qc))
        fprintf('ERROR DE FORMATO QCF 6 - perfil %d\n',i2)
    end
    if ne(length(Profs(i2).temp_qc),length(Profs(i2).temp_adjusted_qc))
        fprintf('ERROR DE FORMATO QCF 7 - perfil %d\n',i2)
    end
    if ne(length(Profs(i2).temp_qc),length(Profs(i2).psal_qc)) | ne(length(Profs(i2).pres_qc),length(Profs(i2).psal_qc)) | ne(length(Profs(i2).pres_qc),length(Profs(i2).temp_qc))
        fprintf('ERROR DE FORMATO QCF 8 - perfil %d\n',i2)
    end
    
    %Verifica valor de la QC Flag
    for i3=1:size(Profs(i2).psal_adjusted_qc,2)
        if ~strcmp(Profs(i2).psal_adjusted_qc(i3),'0') & ~strcmp(Profs(i2).psal_adjusted_qc(i3),'1') & ~strcmp(Profs(i2).psal_adjusted_qc(i3),'2') & ~strcmp(Profs(i2).psal_adjusted_qc(i3),'3') & ~strcmp(Profs(i2).psal_adjusted_qc(i3),'4') & ~strcmp(Profs(i2).psal_adjusted_qc(i3),'5') & ~strcmp(Profs(i2).psal_adjusted_qc(i3),'8') & ~strcmp(Profs(i2).psal_adjusted_qc(i3),'9')
            keyboard
            fprintf('ERROR DE FORMATO QC FLAG PSAL - perfil %d\n',i2)
        end
        
        if ~strcmp(Profs(i2).temp_adjusted_qc(i3),'0') & ~strcmp(Profs(i2).temp_adjusted_qc(i3),'1') & ~strcmp(Profs(i2).temp_adjusted_qc(i3),'2') & ~strcmp(Profs(i2).temp_adjusted_qc(i3),'3') & ~strcmp(Profs(i2).temp_adjusted_qc(i3),'4') & ~strcmp(Profs(i2).temp_adjusted_qc(i3),'5') & ~strcmp(Profs(i2).temp_adjusted_qc(i3),'8') & ~strcmp(Profs(i2).temp_adjusted_qc(i3),'9')
            fprintf('ERROR DE FORMATO QC FLAG TEMP - perfil %d\n',i2)
        end
        
        if ~strcmp(Profs(i2).pres_adjusted_qc(i3),'0') & ~strcmp(Profs(i2).pres_adjusted_qc(i3),'1') & ~strcmp(Profs(i2).pres_adjusted_qc(i3),'2') & ~strcmp(Profs(i2).pres_adjusted_qc(i3),'3') & ~strcmp(Profs(i2).pres_adjusted_qc(i3),'4') & ~strcmp(Profs(i2).pres_adjusted_qc(i3),'5') & ~strcmp(Profs(i2).pres_adjusted_qc(i3),'8') & ~strcmp(Profs(i2).pres_adjusted_qc(i3),'9')
            fprintf('ERROR DE FORMATO QC FLAG PSAL - perfil %d\n',i2)
        end
        
    end
    %Verifica HISTORY INSTITUTION
    for i3=1:size(Profs(icycle).history_institution,3)
        if ~strncmp('IF',Profs(icycle).history_institution(:,:,i3)',2) & ~strncmp('SP',Profs(icycle).history_institution(:,:,i3)',2) & ~strncmp('  ',Profs(icycle).history_institution(:,:,i3)',2) & ~strncmp('TC',Profs(icycle).history_institution(:,:,i3)',2)
            fprintf('ERROR DE FORMATO HISTORY_INSTITUTION - perfil %d\n',i2)
            Profs(icycle).history_institution(:,:,i3)'
        end
    end
    %Verifica  N Calibraciones
    if size(Profs(i2).scientific_calib_comment,3)~= size(Profs(i2).scientific_calib_equation,3) | size(Profs(i2).scientific_calib_comment,3)~= size(Profs(i2).scientific_calib_coefficient,3) | size(Profs(i2).scientific_calib_comment,3)~= size(Profs(i2).scientific_calib_date,3)
        fprintf('ERROR DE FORMATO N_CALIB - perfil %d\n',i2)
    end
end
save(flnameout,'Profs')
