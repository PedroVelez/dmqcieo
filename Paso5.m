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
clc;clear all ;close all;load Globales;global GlobalSU

floats=[1900379];

alpha=0.0267;  %para SBE 41
tau=18.6;      %para SBE 41
avel=0.09;     %Ascend velocity
%alpha=0.141;  %para SBE 41 CP
%tau=6.68;     %para SBE 41 CP

SCIENTIFIC_CALIB_COMMENT_PSAL='';
SCIENTIFIC_CALIB_COMMENT_TEMP='No significant temperature drift detected - Calibration error is manufacturer specified accuracy.';
SCIENTIFIC_CALIB_EQUATION_PSAL='';

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
    
    fprintf('    > Loading DMCorrect_offset_PRES filename %s \n',flnameIn)
    DATA=load(flnameIn);
    cycle_number=[DATA.Profs.cycle_number]';
    Profs=DATA.Profs;
    juld=[DATA.Profs.juld_matlab]';
    clear DATA
    
    
    
    %% Cambios en cientific_calib_* y History Information fields.
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
        
        
        fprintf('    Saving to filename %s \n',flnameOut)
        
        %----------------------------------------------------------------------
        %% Figuras
        %----------------------------------------------------------------------
    end 
        
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
        
%         figure
%         surface([1:1:size(pres_adjusted_plot,2)],-double(pres_adjusted_plot),double(sals_adjusted_plot));grid on;hold on
%         shading interp;axis([-inf inf -2000 0]);colorbar
%         title(sprintf('%s Salinity section',Profs(1).platform_number'))
%         set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
%         
%         figure
%         surface(ones(size(pres_adjusted_plot,1),1)*cycle_number',-double(pres_adjusted_plot),double(tems_adjusted_plot));grid on
%         shading interp;axis([-inf inf -2000 0]);colorbar
%         title(sprintf('%s Temperature section',Profs(1).platform_number'))
%         
%         figure
%         subplot(1,2,1)
%         plot(tems_adjusted_plot(:,1:end));grid on;set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
%         title(sprintf('%s Temperature profiles',Profs(1).platform_number'))
%         
%         subplot(1,2,2);grid on;set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
%         plot(sals_adjusted_plot(:,1:end));grid on;set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
%         title(sprintf('%s Salinity profiles',Profs(1).platform_number'))
%         
%         figure(1);orient landscape;CreaFigura(1,strcat(flnameOut,'_01'),7)
%         figure(2);orient landscape;CreaFigura(2,strcat(flnameOut,'_01'),7)
%         figure(3);orient landscape;CreaFigura(3,strcat(flnameOut,'_01'),7)
%         figure(4);orient landscape;CreaFigura(4,strcat(flnameOut,'_01'),7)
%         figure(5);orient landscape;CreaFigura(5,strcat(flnameOut,'_01'),7)
        
        %----------------------------------------------------------------------
        %% Salvamos resultados
        %----------------------------------------------------------------------
        if length(floats)>1
            close all
        end
        save(flnameOut,'Profs','alpha','tau','avel')
   
end
fprintf('      %s >>>>>\n',mfilename)