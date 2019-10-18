%% Step 6. Description:
%   This file basically regroups all floats data in matrix format in order
%   that next step (Owens and Wong objective analysis, 2003) can be carried out.
%   <www.oceanografia.argo.es>
%
%   Pedro Velez & Alberto Gonzalez (2016)


% Vamos a poner los datos de las boyas en formato matricial
% para ser utilizados en el software OW de DMQC
Limpia
floats=[6901238];

for i1 = 1:length(floats)
    flnameIn=fullfile(GlobalSU.ArgoDMQC,'Data','DMCell_Thermal_Mass_Error',sprintf('%6d.mat',floats(i1)));
    flnameOut=fullfile(GlobalSU.ArgoDMQC,('Data'),'float_sourceQC1',strcat(num2str(floats(i1))));
    
    %% Creamos matrices
    if exist(flnameIn,'file')==0 %Si no hay hecha correcion de thermal mass
        %         fprintf('    > Loading float_sourceQC1 filename %s \n',fullfile(GlobalSU.ArgoDMQC,'Data','float_sourceQC1',num2str(floats(i1)),filesep,'profiles',filesep))
        %         Profs=ReadArgoProfilesDoble(fullfile(GlobalSU.ArgoDMQC,'Data','float_sourceQC1',num2str(floats(i1)),'profiles',filesep));
        %         LAT=[Profs.latitude];
        %         LONG=[Profs.longitude]+360;
        %         DATES=[Profs.juld_matlab];
        %         CYCLE_NO=[Profs.cycle_number];
        %         PROFILE_NO=[1:1:size(CYCLE_NO,2)];
        %         PRES=Profs(1).pres';
        %         SAL=Profs(1).psal';
        %         TEMP=Profs(1).temp';
        %         for icycle=2:1:size(Profs,2)
        %             PRES=merge(PRES,Profs(icycle).pres');
        %             TEMP=merge(TEMP,Profs(icycle).temp');
        %             SAL=merge(SAL,Profs(icycle).psal');
        %         end
        %         %Asigno QC a DM incialmente como las de RT
        %         for icycle=1:1:size(Profs,2)
        %             Profs(icycle).pres_adjusted_qc=Profs(icycle).pres_qc;
        %             Profs(icycle).psal_adjusted_qc=Profs(icycle).psal_qc;
        %             Profs(icycle).temp_adjusted_qc=Profs(icycle).temp_qc;
        %         end
    else %Si hay hecha correcion de thermal mass
        fprintf('    > Loading DMCell_Thermal_Mass_Error filename %s \n',flnameIn)
        DATA=load(flnameIn);
        for ipara=1:DATA.Profs(1).n_param
            if strncmp(DATA.Profs(1).station_parameters(:,ipara)','PRES',4)
                iPres=ipara;
            elseif strncmp(DATA.Profs(1).station_parameters(:,ipara)','TEMP',4)
                iTemp=ipara;
            elseif strncmp(DATA.Profs(1).station_parameters(:,ipara)','PSAL',4)
                iPsal=ipara;
            end
        end
        
        Profs=DATA.Profs;
        LAT=[Profs.latitude];
        LONG=[Profs.longitude]+360;
        DATES=[Profs.juld_matlab];
        CYCLE_NO=[Profs.cycle_number];
        PROFILE_NO=[1:1:size(CYCLE_NO,2)];
        PRES=Profs(1).pres_adjusted';
        SAL=Profs(1).psal_adjusted';
        TEMP=Profs(1).temp_adjusted';
        for icycle=2:1:size(Profs,2)
            PRES=merge(PRES,Profs(icycle).pres_adjusted');
            TEMP=merge(TEMP,Profs(icycle).temp_adjusted');
            SAL=merge(SAL,Profs(icycle).psal_adjusted');
        end
    end
    PTMP = sw_ptmp(SAL,TEMP,PRES,0);
    
    %% Figuras
    figure
    for icycle=1:size(Profs,2)
        h1(icycle)=plot(Profs(icycle).psal,Profs(icycle).temp,'o','Markersize',4,'MarkerFaceColor',[.65 .65 .65],'MarkerEdgeColor',[.65 .65 .65]);hold on
    end
    for i3=1:size(Profs,2)
        h2(i3)=plot(SAL(:,i3),TEMP(:,i3),'.-','Color',Colores(i3));hold on
    end
    legend([h1(1) h2(1)],'RT','DM')
    grid on;set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
    title(sprintf('%s TS Corrected QC=1,2,3',Profs(1).platform_number'))
    
    
    figure
    surface(ones(size(PRES,1),1)*PROFILE_NO,-double(PRES),double(SAL));grid on;hold on
    shading interp;axis([-inf inf -2000 0]);colorbar
    title(sprintf('%s Salinity section',Profs(1).platform_number'))
    set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
    
    figure
    surface(ones(size(PRES,1),1)*PROFILE_NO,-double(PRES),double(TEMP));grid on;hold on
    shading interp;axis([-inf inf -2000 0]);colorbar
    title(sprintf('%s Temperature section',Profs(1).platform_number'))
    
    figure
    subplot(1,2,1)
    plot(TEMP(:,1:end));grid on;set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
    title(sprintf('%s Temperature profiles',Profs(1).platform_number'))
    
    subplot(1,2,2);grid on;set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
    plot(SAL(:,1:end));grid on;set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
    title(sprintf('%s Salinity profiles',Profs(1).platform_number'))
    
    figure(1);orient landscape;CreaFigura(1,strcat(flnameOut,'_01'),7);
    figure(2);orient landscape;CreaFigura(2,strcat(flnameOut,'_02'),7);
    figure(3);orient landscape;CreaFigura(3,strcat(flnameOut,'_03'),7);
    figure(4);orient landscape;CreaFigura(4,strcat(flnameOut,'_04'),7);
    
    %% Salvamos resultados
    if length(floats)>1
        close all
    end
    fprintf('    > Saving data to filename %s \n',flnameOut)
    save(flnameOut,'Profs','LAT','LONG','DATES','PRES','SAL','TEMP','PTMP','PROFILE_NO','CYCLE_NO')
end
fprintf('      %s >>>>>\n',mfilename)
