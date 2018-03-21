%% Step 7. Description:
%   This file calculates the Owens and Wong Objective Mapping Analysis (2003).
%   This calibration model assumes that Salinity measurements drift slowly
%   over time. To correct the salinity drift, the model makes use of
%   adjacent profiles (a time series) to estimate a time-varying
%   multiplicative correction term "r" by fitting to the estimated
%   climatological potential conductivities on theta surfaces. The
%   inclusion of contemporary high quality calibrated hydrographic data
%   with regional temperature - salinity relationships (by using nearby
%   historical hydrographic data) will help to determine whether a measured
%   trend is due to sensor drift or due to natural variability.
%
%   A total of 4 tests are developed:
%
%   TEST A: Includes ARGO and CTD climatology. MAPSCALE_AGE = 2 YEARS.
%   TEST B: Includes only CTD climatology. MAPSCALE_AGE = 2 YEARS.
%   TEST C: Includes ARGO and CTD climatology. MAPSCALE_AGE = 5 YEARS.
%   TEST D: Includes ARGO and CTD climatology. MAPSCALE_AGE = 10 YEARS.
%   TEST E: Includes only CTD climatology. MAPSCALE_AGE = 10 YEARS.
%
%   For more information, please ckech "DELAYED-MODE CALIBRATION OF
%   AUTONOMOUS CTD PROFILING FLOAT SALINITY DATA BY 0-S CLIMATOLOGY (Annie
%   P. Wong, Gregory C. Johnson and W. Brechner Owens. Journal Of
%   Atmospheric and Oceanic Technology (2002).
%
%   http://prelude.ocean.washington.edu/
%   <www.argoespana.es>
%
%   Pedro Velez & Alberto Gonzalez (2016)

Limpia
float_dirs = {''};

%   Checked Floats - Se puedo hacer el OW.
%    1900277 1900278 6900230 6900231 6900506 6900635 6900636 6900659 6900660
%    6900661 6900662 6900761 6900762 6900765 6900766 6900767 6900768 6900769
%    6900770 6900771 6900772 6900773 6900774 6900775 6900776 6900777 6900778
%    6900779 6900780 6900781 6900782 6900783 6900788 6901237 6901238 6901239
%    6901240 6901241 6901242 6901243 6901247]
%
%   Deffective Floats - Fallan el OW
%   6900786 6900787
%
%   Deffective Floats - No se puedo hacer algun paso previo al OW.
%   6900760 6900763 6900764 6900784 6900785 6900789
%
%   Deffective Floats - no data
%   1900275 1900276 1900279
%
%   Deffective Floats - ARVOR PROVOR - Format3.1
%   1900377 1900378 1900379 4900556 4900557 4900558 6901245  6901246

floats=[1900379];

%%Climatology Data Input Paths
OW_Config.HISTORICAL_DIRECTORY=fullfile(GlobalSU.ArgoDMQC,'/data/climatology');
OW_Config.HISTORICAL_CTD_PREFIX=fullfile(filesep,'CTD_for_DMQC_2014V01','ctd_');
OW_Config.HISTORICAL_BOTTLE_PREFIX=fullfile(filesep,'historical_bot','bot_');
OW_Config.HISTORICAL_ARGO_PREFIX= fullfile(filesep,'ARGO_for_DMQC_2017V02','argo_');

%%Float Input Path
OW_Config.FLOAT_SOURCE_DIRECTORY=fullfile(GlobalSU.ArgoDMQC,'Data','float_sourceQC1',filesep);
OW_Config.FLOAT_SOURCE_POSTFIX='.mat';

%% Mapping Output Path
OW_Config.FLOAT_MAPPED_DIRECTORY=fullfile(GlobalSU.ArgoDMQC,'Data','float_mapped',filesep);
OW_Config.FLOAT_MAPPED_PREFIX='map_';
OW_Config.FLOAT_MAPPED_POSTFIX='.mat';

%% Calibration Output Path
OW_Config.FLOAT_CALIB_DIRECTORY=fullfile(GlobalSU.ArgoDMQC,'Data','float_calib',filesep);
OW_Config.FLOAT_CALIB_PREFIX='cal_';
OW_Config.FLOAT_CALSERIES_PREFIX='calseries_';
OW_Config.FLOAT_CALIB_POSTFIX='.mat';

%%Diagnostic Plots Ou?tput Path
OW_Config.FLOAT_PLOTS_DIRECTORY=fullfile(GlobalSU.ArgoDMQC,'Data','float_plots',filesep);

%%Constants File Path
OW_Config.CONFIG_DIRECTORY=fullfile(GlobalSU.ArgoDMQC,'Data','constants',filesep);
OW_Config.CONFIG_COASTLINES='coastdat.mat';
OW_Config.CONFIG_WMO_BOXES='la_wmo_boxes.mat';
OW_Config.CONFIG_SAF='TypicalProfileAroundSAF.mat';

%% Objective Mapping Parameters
% max number of historical casts used in objective mapping
OW_Config.CONFIG_MAX_CASTS='300';
% 1=use PV constraint, 0=don't use PV constraint, in objective mapping
OW_Config.MAP_USE_PV='0';
% 1=use SAF separation criteria, 0=don't use SAF separation criteria, in objective mapping
OW_Config.MAP_USE_SAF='0';
% spatial decorrelation scales, in degrees
OW_Config.MAPSCALE_LONGITUDE_LARGE='2';
OW_Config.MAPSCALE_LONGITUDE_SMALL='1';
OW_Config.MAPSCALE_LATITUDE_LARGE='2';
OW_Config.MAPSCALE_LATITUDE_SMALL='1';
% cross-isobath scales, dimensionless, see BS(2005)
OW_Config.MAPSCALE_PHI_LARGE='0.5';
OW_Config.MAPSCALE_PHI_SMALL='0.1';
% temporal decorrelation scale, in years
OW_Config.MAPSCALE_AGE='2';
% exclude the top xxx dbar of the water column
OW_Config.MAP_P_EXCLUDE='200';
% only use historical data that are within +/- yyy dbar from float data
OW_Config.MAP_P_DELTA='250';

%% set_calseries
OW_Config.max_breaks=4;

%% Inicio
for i1=1:length(floats)
    flt_dir=deblank(float_dirs{1});
    flt_name=num2str(floats(i1));
    
    %% Hacemos cuatro tests
    %A Argo and CTD
    OW_Config.ANALYSIS_CODE='A';
    OW_Config.FLOAT_MAPPED_PREFIX='map_A_';
    OW_Config.FLOAT_CALIB_PREFIX='cal_A_';
    OW_Config.FLOAT_CALSERIES_PREFIX='calseries_A_';
    OW_Config.CONFIG_WMO_BOXES='wmo_boxes_CTD_for_DMQC_2014V01_ARGO_for_DMQC_2017V02.mat';
    OW_Config.MAPSCALE_AGE='2';
    fprintf('>>>>> OW working on %s, %s \n',flt_name,datestr(now));
    update_salinity_mapping(flt_dir,flt_name,OW_Config);
    set_calseries(flt_dir,flt_name,OW_Config);
    calculate_piecewisefit(flt_dir,flt_name,OW_Config);
    plot_diagnostics_ow(flt_dir,flt_name,OW_Config);
    close all
    
    %B CTD
    OW_Config.ANALYSIS_CODE='B';
    OW_Config.FLOAT_MAPPED_PREFIX='map_B_';
    OW_Config.FLOAT_CALIB_PREFIX='cal_B_';
    OW_Config.FLOAT_CALSERIES_PREFIX='calseries_B_';
    OW_Config.CONFIG_WMO_BOXES='wmo_boxes_CTD_for_DMQC_2014V01.mat';
    OW_Config.MAPSCALE_AGE='2';
    fprintf('>>>>> OW working on %s, %s \n',flt_name,datestr(now));
    update_salinity_mapping(flt_dir,flt_name,OW_Config);
    set_calseries(flt_dir,flt_name,OW_Config);
    calculate_piecewisefit(flt_dir,flt_name,OW_Config);
    plot_diagnostics_ow(flt_dir,flt_name,OW_Config);
    close all
    
    %C Argo and CTD
    OW_Config.ANALYSIS_CODE='C';
    OW_Config.FLOAT_MAPPED_PREFIX='map_C_';
    OW_Config.FLOAT_CALIB_PREFIX='cal_C_';
    OW_Config.FLOAT_CALSERIES_PREFIX='calseries_C_';
    OW_Config.CONFIG_WMO_BOXES='wmo_boxes_CTD_for_DMQC_2014V01_ARGO_for_DMQC_2017V02.mat';
    OW_Config.MAPSCALE_AGE='5';
    fprintf('>>>>> OW working on %s, %s \n',flt_name,datestr(now));
    update_salinity_mapping(flt_dir,flt_name,OW_Config);
    set_calseries(flt_dir,flt_name,OW_Config);
    calculate_piecewisefit(flt_dir,flt_name,OW_Config);
    plot_diagnostics_ow(flt_dir,flt_name,OW_Config);
    close all
    
    %D Argo and CTD
    OW_Config.ANALYSIS_CODE='D';
    OW_Config.FLOAT_MAPPED_PREFIX='map_D_';
    OW_Config.FLOAT_CALIB_PREFIX='cal_D_';
    OW_Config.FLOAT_CALSERIES_PREFIX='calseries_D_';
    OW_Config.CONFIG_WMO_BOXES='wmo_boxes_CTD_for_DMQC_2014V01_ARGO_for_DMQC_2017V02.mat';
    OW_Config.MAPSCALE_AGE='10';
    fprintf('>>>>> OW working on %s, %s \n',flt_name,datestr(now));
    update_salinity_mapping(flt_dir,flt_name,OW_Config);
    set_calseries(flt_dir,flt_name,OW_Config);
    calculate_piecewisefit(flt_dir,flt_name,OW_Config);
    plot_diagnostics_ow(flt_dir,flt_name,OW_Config);
    
    %E CTD
    OW_Config.ANALYSIS_CODE='E';
    OW_Config.FLOAT_MAPPED_PREFIX='map_E_';
    OW_Config.FLOAT_CALIB_PREFIX='cal_E_';
    OW_Config.FLOAT_CALSERIES_PREFIX='calseries_E_';
    OW_Config.CONFIG_WMO_BOXES='wmo_boxes_CTD_for_DMQC_2014V01.mat';
    OW_Config.MAPSCALE_AGE='10';
    fprintf('>>>>> OW working on %s, %s \n',flt_name,datestr(now));
    update_salinity_mapping(flt_dir,flt_name,OW_Config);
    set_calseries(flt_dir,flt_name,OW_Config);
    calculate_piecewisefit(flt_dir,flt_name,OW_Config);
    plot_diagnostics_ow(flt_dir,flt_name,OW_Config);
    
    if length(floats)>1
        close all
    end
end

