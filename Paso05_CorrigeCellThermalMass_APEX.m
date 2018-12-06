%% Step 5. Description:
%   This file calculates the Thermal Mass Error for each measurement.
%   The drawback with free-flushing CTDs comes to bear because conductivity sensors
%   have a response-time dependence on the water volume flow rate through the
%   sensor and also experience a temporal lag in response while traversing
%   temperature gradients due to heat stored in the sensor materials. The
%   latter causes a cell thermal mass error in conductivity values and subsequent
%   derived parameters.
%
%   Depending on which CTD version is used in the mission, [alpha, tau & avel]
%   values must be checked.
%
%   ****************SECOND CALIBRATION IS CARRIED OUT**********************
%   Salinity is recomputed. Temperature is
%   recomputed if needed. If not, original values are kept.
%
%   ***************SECOND SCIENTIFIC COMMENTS ARE MADE*********************
%
%   Each SCIENTIFIC_CALIB modification/recomputation is supposed to be
%   registered at N_CALIB = N step.Thus, if some modification is needed in
%   this step, it should be saved at N_CALIB = 2 but in order to suit Coriolis
%   format, all changes are saved at N_CALIB = 1 (256 strings). [Please check
%   Argo DM Manual v3.1 for more information]
%
%   *************THIRD QUALITY CONTROL FLAG IS CARRIED OUT*****************
%   A quality flag indicates the quality of an observation. The flags are
%   assigned in Real Time (RT) and can be modified in Delayed Mode (DM).
%   Flags are set in a range from 0 to 9 [Please check Argo DM Manual v3.1
%   for more information]. Each correction must be flagged.
%   <www.oceanografia.argo.es>
%
%   Pedro Velez & Alberto Gonzalez (2016)

%Script para coger un perfil que tiene Cell Thermal Mass Error
clc;clear all;close all;load Globales;global GlobalSU

floats=[6900763];

alpha=0.0267;  %para SBE 41
tau=18.6;      %para SBE 41
avel=0.09;     %Ascend velocity
%alpha=0.141;  %para SBE 41 CP
%tau=6.68;     %para SBE 41 CP

SCIENTIFIC_CALIB_COMMENT_PSAL='Salinity corrected for CTM.';
SCIENTIFIC_CALIB_COMMENT_TEMP='.No significant temperature drift detected - Calibration error is manufacturer specified accuracy.';
SCIENTIFIC_CALIB_EQUATION_PSAL='PSAL Cell Thermal Mass celltm_sbe41.';
SCIENTIFIC_CALIB_COEFFICIENT_PSAL=sprintf('alpha = %6.4f, tau = %4.1f and Ascend velocity = %4.2f.',alpha,tau,avel);

HISTORY_INSTITUTION='SP  '; %[Default='    ']
HISTORY_SOFTWARE='AIEO';
HISTORY_REFERENCE='WOA05';
%----------------------------------------------------------------------
% Inicio
%----------------------------------------------------------------------
fprintf('>>>>> %s\n',mfilename)

for iboya=1:length(floats)
    flnameIn=fullfile(GlobalSU.ArgoDMQC,('Data'),filesep,'DMCorrect_offset_PRES',filesep,sprintf('%6d.mat',floats(iboya))); load(flnameIn)
    flnameOut=fullfile(GlobalSU.ArgoDMQC,('Data'),'DMCell_Thermal_Mass_Error',sprintf('%6d',floats(iboya)));
    pres_adjusted_plot=[];
    tems_adjusted_plot=[];
    sals_adjusted_plot=[];
    
    %% Correccion de DMCell_Thermal_Mass
    if exist(flnameIn,'file')==0
        %Si no hay hecha correci?n de presi?n en superfice leeo los datos de RT
        fprintf('    > Loading float_sourceQC1 filename %s \n',fullfile(pathDM,filesep,'float_sourceQC1',filesep,num2str(floats(iboya)),filesep,'profiles',filesep))
        Profs=ReadArgoProfilesDoble(fullfile(pathDM,filesep,'float_sourceQC1',filesep,num2str(floats(iboya)),filesep,'profiles',filesep));
        cycle_number=[Profs.cycle_number]';
        for icycle=1:size(Profs,2)
            sprintf('     > Profile %d/%d \n',icycle,length(cycle_number));
            Profs(icycle).temp_adjusted=Profs(icycle).temp;
            Profs(icycle).psal_adjusted=Profs(icycle).psal;
            Profs(icycle).pres_adjusted=Profs(icycle).pres;
            
            pres_c=Profs(icycle).pres_adjusted;
            tems_c=Profs(icycle).temp_adjusted; %Hasta ahora la temperatura no se ha corregido en nada.
            sals_c=Profs(icycle).psal_adjusted; %Salinidad corregida tras calibrar la presion con surface offset
            
            %Guardamos los indices de pre_c diferentes de NaN
            ind=find(isnan(pres_c)~=1 & isnan(sals_c)~=1 & isnan(tems_c)~=1);
            pre_ci=pres_c(ind);
            sal_ci=sals_c(ind);
            tem_ci=tems_c(ind);
            %Ordenos los datos de mas profundo a mas superficial
            [pre_ci,I]=sort(pre_ci,'descend');
            sal_ci=sal_ci(I);
            tem_ci=tem_ci(I);
            
            d_press=diff([pre_ci 0]);
            e_time=cumsum(-d_press/avel);
            
            if length(pre_ci)>=1 && length(sal_ci)>1 && length(tem_ci)>1 && sum(isnan(sal_ci))<length(sal_ci)
                sal_CTME=celltm_sbe41(sal_ci,1.00024*tem_ci,pre_ci,e_time,alpha,tau); %La temperatura debe estar en ITPS-68 para la correci?n
                %Reordenos el campo de salida como el original de pres
                [C,IA,IB] = intersect(pre_ci,pres_c,'stable');
                %Asigno los valores corregidos
                sals_adjusted=sals_c;
                sals_adjusted(IB)=sal_CTME;
                %uncertainty of the correction
                sals_therm_err=sals_c.*0;
                sals_therm_err(IB)=sal_CTME-sal_ci;
                %Reasigno los valores ajustados a los perfiles
                Profs(icycle).psal_adjusted=sals_adjusted;
                Profs(icycle).psal_adjusted_error=sals_therm_err;
                %Comprobaci?n
                h1(icycle)=plot(sals_c,tems_c,'ob');hold on
                h2(icycle)=plot(Profs(icycle).psal_adjusted(IB),Profs(icycle).temp_adjusted(IB),'or');
                plot(sal_ci,tem_ci,'.b')
                plot(sal_CTME,tem_ci,'.r');
            end
            %Solo para hacer el plot creamos matrices con temp, psal y pres
            pres_adjusted_plot=merge(pres_adjusted_plot,Profs(icycle).pres_adjusted');
            tems_adjusted_plot=merge(tems_adjusted_plot,Profs(icycle).temp_adjusted');
            sals_adjusted_plot=merge(sals_adjusted_plot,Profs(icycle).psal_adjusted');
        end
    else
        %Si hay hecha correci?n de presi?n en superfcie
        fprintf('    > Loading DMCorrect_offset_PRES filename %s \n',flnameIn)
        DATA=load(flnameIn);
        cycle_number=[DATA.Profs.cycle_number]';
        Profs=DATA.Profs;
        juld=[DATA.Profs.juld_matlab]';
        clear DATA
        
        for icycle=1:length(cycle_number)
            sprintf('     > Profile %d/%d \n',icycle,length(cycle_number));
            pres_c=Profs(icycle).pres_adjusted;
            tems_c=Profs(icycle).temp_adjusted; %Hasta ahora la temperatura no se ha corregido en nada.
            sals_c=Profs(icycle).psal_adjusted; %Salinidad corregida tras calibrar la presion con surface offset
            
            %Guardamos los indices de pre_c diferentes de NaN
            ind=find(isnan(pres_c)~=1 & isnan(sals_c)~=1 & isnan(tems_c)~=1);
            pre_ci=pres_c(ind);
            sal_ci=sals_c(ind);
            tem_ci=tems_c(ind);
            %Ordenos los datos de mas profundo a mas superficial
            [pre_ci,I]=sort(pre_ci,'descend');
            sal_ci=sal_ci(I);
            tem_ci=tem_ci(I);
            
            d_press=diff([pre_ci 0]);
            e_time=cumsum(-d_press/avel);
            
            if length(pre_ci)>=2 && length(sal_ci)>2 && length(tem_ci)>2 && length(sal_ci)-sum(isnan(sal_ci))>2
                sal_CTME=celltm_sbe41(sal_ci,1.00024*tem_ci,pre_ci,e_time,alpha,tau); %La temperatura debe estar en ITPS-68 para la correcion
                %Reordenos el campo de salida como el original de pres
                [C,IA,IB] = intersect(pre_ci,pres_c,'stable');
                %Asigno los valores corregidos
                sals_adjusted=sals_c;
                sals_adjusted(IB)=sal_CTME;
                %keyboard
                %uncertainty of the correction
                sals_therm_err=sals_c.*0;
                sals_therm_err(IB)=sal_CTME-sal_ci; %(ASSIGNATION ERROR)
                %Reasigno los valores ajustados a los perfiles
                Profs(icycle).psal_adjusted=sals_adjusted;
                %REVISAR ESTE TROZO DE C?DIGO
                idx=find(sals_therm_err<0.01);%L?MITE DE DETECCI?N POR CONVENIO ARGO
                sals_therm_err(idx)=0.01;
                Profs(icycle).psal_adjusted_error=sals_therm_err;
                
                %Comprobaci?n
                h1(icycle)=plot(sals_c,tems_c,'ob');hold on
                h2(icycle)=plot(Profs(icycle).psal_adjusted(IB),Profs(icycle).temp_adjusted(IB),'or');
                plot(sal_ci,tem_ci,'.b')
                plot(sal_CTME,tem_ci,'.r');
                grid on;axis([34 39 4 25])
                %                legend([h1(1) h2(1)],'RE TS','CTME TS')
                title(sprintf('DM Cell Thermal Mass Correction for  %3.3i',floats(iboya)))
            end
            %Solo para hacer el plot creamos matrices con temp, psal y pres
            pres_adjusted_plot=merge(pres_adjusted_plot,Profs(icycle).pres_adjusted');
            tems_adjusted_plot=merge(tems_adjusted_plot,Profs(icycle).temp_adjusted');
            sals_adjusted_plot=merge(sals_adjusted_plot,Profs(icycle).psal_adjusted');
        end
    end
    
    %----------------------------------------------------------------------
    %% Cambios en cientific_calib_* y History Information fields.
    %----------------------------------------------------------------------
    for icycle=1:length(cycle_number)
        for ipara=1:Profs(icycle).n_param
            if strncmp(Profs(icycle).station_parameters(:,ipara)','PRES',4)
                iPres=ipara;
            elseif strncmp(Profs(icycle).station_parameters(:,ipara)','TEMP',4)
                iTemp=ipara;
            elseif strncmp(Profs(icycle).station_parameters(:,ipara)','PSAL',4)
                iPsal=ipara;
            end
        end
        
        %Hacemos un cambio en la variable "scientific_calib_coefficient" para
        %algunas boyas antiguas. Su valor estandar debe ser FillValue y no "none".
        nonePres=find(Profs(icycle).scientific_calib_coefficient(1:4,1,iPres)'=='none');
        noneTemp=find(Profs(icycle).scientific_calib_coefficient(1:4,1,iTemp)'=='none');
        nonePsal=find(Profs(icycle).scientific_calib_coefficient(1:4,1,iPsal)'=='none');
        if isempty(nonePres)==0;
            Profs(icycle).scientific_calib_coefficient(nonePres(1:end),iPres)=...
                strrep(Profs(icycle).scientific_calib_coefficient(nonePres(1:end),iPres)','none','    ');
        end
        if isempty(noneTemp)==0;
            Profs(icycle).scientific_calib_coefficient(noneTemp(1:end),1,iTemp)=...
                strrep(Profs(icycle).scientific_calib_coefficient(noneTemp(1:end),1,iTemp)','none','    ');
        end
        if isempty(nonePsal)==0;
            Profs(icycle).scientific_calib_coefficient(nonePsal(1:end),1,iPsal)=...
                strrep(Profs(icycle).scientific_calib_coefficient(nonePsal(1:end),1,iPsal)','none','    ');
        end
        %if lenght(Profs(icycle).psal)>sum(isnan(Profs(icycle).psal)) || lenght(Profs(icycle).pres)>sum(isnan(Profs(icycle).pres)) || lenght(Profs(icycle).temp)>sum(isnan(Profs(icycle).temp))
        
        %Verifico cuantas calibraciones hay hechas
        %Tengo que expandir las matrices de SCIENTIFIC_CALIB si es la primera
        
        %Para APEX hay que sumar +1 (CON EN FIN DE COINCIDIR CON EL FORMATO
        %DE CORIOLIS, TODAS LAS MODIFICACIONES VAN A SER ALMACENADAS EN
        %N_CALIB = 1 EN LUGAR DE N_CALIB = N.
        Profs(icycle).n_calib=Profs(icycle).n_calib;
        Profs(icycle).parameter(1:4,Profs(icycle).n_calib,iPsal)='PSAL';
        var=strcat(deblank(Profs(icycle).scientific_calib_comment(:,1,iPsal)'),SCIENTIFIC_CALIB_COMMENT_PSAL);
        Profs(icycle).scientific_calib_comment(1:length(var),Profs(icycle).n_calib,iPsal)=var;
        var=strcat(deblank(Profs(icycle).scientific_calib_equation(:,1,iPsal)'),SCIENTIFIC_CALIB_EQUATION_PSAL);
        Profs(icycle).scientific_calib_equation(1:length(var),Profs(icycle).n_calib,iPsal)=var;
        var=strcat(deblank(Profs(icycle).scientific_calib_coefficient(:,1,iPsal)'),SCIENTIFIC_CALIB_COEFFICIENT_PSAL);
        Profs(icycle).scientific_calib_coefficient(1:length(var),Profs(icycle).n_calib,iPsal)=var;
        var=strcat(deblank(Profs(icycle).scientific_calib_comment(:,1,iTemp)'),SCIENTIFIC_CALIB_COMMENT_TEMP);
        Profs(icycle).scientific_calib_comment(1:length(var),Profs(icycle).n_calib,iTemp)=var;
        var=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
        Profs(icycle).scientific_calib_date(1:length(var),Profs(icycle).n_calib,iPsal)=var;
        Profs(icycle).scientific_calib_date(1:length(var),Profs(icycle).n_calib,iTemp)=var;
        
        %This is a stretch for APEX floats deployed by Gregorio Parrilla. Most of
        %them are spoiled. There is no data. These new comments will be
        %uploaded if QC=4.
        if Profs(icycle).pres_qc=='4';
            %Pressure
            Profs(icycle).scientific_calib_comment(:,1,iPres)=' ';
            Profs(icycle).scientific_calib_equation(:,1,iPres)=' ';
            Profs(icycle).scientific_calib_coefficient(:,1,iPres)=' ';
            SCIENTIFIC_CALIB_COMMENT_PRES='No significant pressure drift detected - Calibration error is manufacturer specified accuracy';
            var_pres=strcat(deblank(Profs(icycle).scientific_calib_comment(:,1,iPres)'),SCIENTIFIC_CALIB_COMMENT_PRES);
            Profs(icycle).scientific_calib_comment(1:length(var_pres),Profs(icycle).n_calib,iPres)=var_pres;
            var=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
            Profs(icycle).scientific_calib_date(1:length(var),Profs(icycle).n_calib,iPres)=var;
        end
        
        if Profs(icycle).temp_qc=='4';
            %Temperature
            Profs(icycle).scientific_calib_comment(:,1,iTemp)=' ';
            Profs(icycle).scientific_calib_equation(:,1,iTemp)=' ';
            Profs(icycle).scientific_calib_coefficient(:,1,iTemp)=' ';
            SCIENTIFIC_CALIB_COMMENT_TEMP='No significant temperature drift detected - Calibration error is manufacturer specified accuracy';
            var_temp=strcat(deblank(Profs(icycle).scientific_calib_comment(:,1,iTemp)'),SCIENTIFIC_CALIB_COMMENT_TEMP);
            Profs(icycle).scientific_calib_comment(1:length(var_temp),Profs(icycle).n_calib,iTemp)=var_temp;
            var=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
            Profs(icycle).scientific_calib_date(1:length(var),Profs(icycle).n_calib,iTemp)=var;
        end
        
        if Profs(icycle).psal_qc=='4';
            %Salinity
            Profs(icycle).scientific_calib_comment(:,1,iPsal)=' ';
            Profs(icycle).scientific_calib_equation(:,1,iPsal)=' ';
            Profs(icycle).scientific_calib_coefficient(:,1,iPsal)=' ';
            SCIENTIFIC_CALIB_COMMENT_PSAL='No correction - OW : Weighted least squares fit; Error provided by the manufacturer';
            var_sal=strcat(deblank(Profs(icycle).scientific_calib_comment(:,1,iPsal)'),SCIENTIFIC_CALIB_COMMENT_PSAL);
            Profs(icycle).scientific_calib_comment(1:length(var_sal),Profs(icycle).n_calib,iPsal)=var_sal;
            var=sprintf('%04d%02d%02d%02d%02d%02d',round(clock));
            Profs(icycle).scientific_calib_date(1:length(var),Profs(icycle).n_calib,iPsal)=var;
        end
        
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
        %
        fprintf('   >> Ciclo %3d. n_calib %d \n',icycle,Profs(icycle).n_calib)
        station_parameters=Profs(1).station_parameters;
        for ip=1:size(station_parameters,2)
            for ih=1:Profs(icycle).n_calib
                fprintf('    > Calib %d scientific_calib_coefficient %s: %s\n',ih,station_parameters(1:4,ip)',Profs(icycle).scientific_calib_coefficient(:,ih,ip));
                fprintf('    > Calib %d scientific_calib_comment     %s: %s\n',ih,station_parameters(1:4,ip)',Profs(icycle).scientific_calib_comment(:,ih,ip));
                fprintf('    > Calib %d scientific_calib_date        %s: %s\n',ih,station_parameters(1:4,ip)',Profs(icycle).scientific_calib_date(:,ih,ip));
                fprintf('    > Calib %d scientific_calib_equation    %s: %s\n',ih,station_parameters(1:4,ip)',Profs(icycle).scientific_calib_equation(:,ih,ip));
            end
        end
        
        if isfield(Profs,'parameter_data_mode')==1
            Profs(icycle).parameter_data_mode(iTemp)='D';
            Profs(icycle).parameter_data_mode(iPsal)='D';
        end
    end
    fprintf('    Saving to filename %s \n',flnameOut)
    
    %----------------------------------------------------------------------
    %% Figuras
    %----------------------------------------------------------------------
    
    
    figure
    for i1=1:size(Profs,2)
        h1(i1)=plot(Profs(i1).psal,Profs(i1).temp,'o','Markersize',4,'MarkerFaceColor',[.65 .65 .65],'MarkerEdgeColor',[.65 .65 .65]);hold on
    end
    for i1=1:size(Profs,2)
        h2(i1)=plot(Profs(i1).psal_adjusted,Profs(i1).temp_adjusted,'.','Color',Colores(i1));hold on
    end
    legend([h1(1) h2(1)],'RT','DM')
    grid on;set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
    title(sprintf('%s TS Corrected for surface offset and CM QC=1,2,3',Profs(1).platform_number'))
    
    figure
    surface([1:1:size(pres_adjusted_plot,2)],-double(pres_adjusted_plot),double(sals_adjusted_plot));grid on;hold on
    shading interp;axis([-inf inf -2000 0]);colorbar
    title(sprintf('%s Salinity section',Profs(1).platform_number'))
    set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
    
    figure
    surface(ones(size(pres_adjusted_plot,1),1)*cycle_number',-double(pres_adjusted_plot),double(tems_adjusted_plot));grid on
    shading interp;axis([-inf inf -2000 0]);colorbar
    title(sprintf('%s Temperature section',Profs(1).platform_number'))
    
    figure
    subplot(1,2,1)
    plot(tems_adjusted_plot(:,1:end));grid on;set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
    title(sprintf('%s Temperature profiles',Profs(1).platform_number'))
    
    subplot(1,2,2);grid on;set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
    plot(sals_adjusted_plot(:,1:end));grid on;set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
    title(sprintf('%s Salinity profiles',Profs(1).platform_number'))
    
    figure(1);orient landscape;CreaFigura(1,strcat(flnameOut,'_01'),7)
    figure(2);orient landscape;CreaFigura(2,strcat(flnameOut,'_01'),7)
    figure(3);orient landscape;CreaFigura(3,strcat(flnameOut,'_01'),7)
    figure(4);orient landscape;CreaFigura(4,strcat(flnameOut,'_01'),7)
    figure(5);orient landscape;CreaFigura(5,strcat(flnameOut,'_01'),7)
    
    %----------------------------------------------------------------------
    %% Salvamos resultados
    %----------------------------------------------------------------------
    if length(floats)>1
        close all
    end
    
    save(flnameOut,'Profs','alpha','tau','avel')
end

fprintf('      %s >>>>>\n',mfilename)