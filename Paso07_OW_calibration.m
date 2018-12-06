%% Step 7. Description:
%   This file calculates the Owens and Wong Objective Mapping Analysis (2003). This calibration
%   model assumes that Salinity measurements drift slowly over time. To correct the salinity drift,
%   the model makes use of adjacent profiles (a time series) to estimate a time-varying
%   multiplicative correction term "r" by fitting to the estimated climatological potential
%   conductivities on theta surfaces. The inclusion of contemporary high quality calibrated
%   hydrographic data with regional temperature - salinity relationships (by using nearby historical
%   hydrographic data) will help to determine whether a measured trend is due to sensor drift or
%   due to natural variability.
%
%   A total of 4 calibrations are carried out
%
%   TEST A: Includes ARGO and CTD climatology. MAPSCALE_AGE = 2 YEARS.
%   TEST B: Includes only CTD climatology. MAPSCALE_AGE = 2 YEARS.
%   TEST C: Includes ARGO and CTD climatology. MAPSCALE_AGE = 5 YEARS.
%   TEST D: Includes ARGO and CTD climatology. MAPSCALE_AGE = 10 YEARS.
%   TEST E: Includes only CTD climatology. MAPSCALE_AGE = 10 YEARS.
%
%   For more information, please check "DELAYED-MODE CALIBRATION OF AUTONOMOUS CTD PROFILING FLOAT
%   SALINITY DATA BY 0-S CLIMATOLOGY (Annie P. Wong, Gregory C. Johnson and W. Brechner Owens.
%   Journal Of Atmospheric and Oceanic Technology (2002).
%
%   <www.argoespana.es>
%
%   Pedro Velez & Alberto Gonzalez (2016)
clearvars ;close all; global GlobalSU;load Globales; clc

%%
float_dirs = {''};

floats=[6900780];

%% 
lo_system_configuration.PLOT_DIAGNOSIS_FORMAT='PDF';

%% Climatology Data Input Paths
lo_system_configuration.HISTORICAL_DIRECTORY=fullfile(GlobalSU.ArgoDMQC,'/data/climatology');
lo_system_configuration.HISTORICAL_CTD_PREFIX=fullfile(filesep,'CTD_for_DMQC_2017V01','ctd_');
lo_system_configuration.HISTORICAL_BOTTLE_PREFIX=fullfile(filesep,'historical_bot','bot_');
lo_system_configuration.HISTORICAL_ARGO_PREFIX= fullfile(filesep,'ARGO_for_DMQC_2017V02','argo_');

%% Float Input Path
lo_system_configuration.FLOAT_SOURCE_DIRECTORY=fullfile(GlobalSU.ArgoDMQC,'Data','float_sourceQC1',filesep);
lo_system_configuration.FLOAT_SOURCE_POSTFIX='.mat';

%% Mapping Output Path
lo_system_configuration.FLOAT_MAPPED_DIRECTORY=fullfile(GlobalSU.ArgoDMQC,'Data','float_mapped',filesep);
lo_system_configuration.FLOAT_MAPPED_PREFIX='map_';
lo_system_configuration.FLOAT_MAPPED_POSTFIX='.mat';

%% Calibration Output Path
lo_system_configuration.FLOAT_CALIB_DIRECTORY=fullfile(GlobalSU.ArgoDMQC,'Data','float_calib',filesep);
lo_system_configuration.FLOAT_CALIB_PREFIX='cal_';
lo_system_configuration.FLOAT_CALSERIES_PREFIX='calseries_';
lo_system_configuration.FLOAT_CALIB_POSTFIX='.mat';

%% Diagnostic Plots Output Path
lo_system_configuration.FLOAT_PLOTS_DIRECTORY=fullfile(GlobalSU.ArgoDMQC,'Data','float_plots',filesep);

%%Constants File Path
lo_system_configuration.CONFIG_DIRECTORY=fullfile(GlobalSU.ArgoDMQC,'Data','constants',filesep);
lo_system_configuration.CONFIG_COASTLINES='coastdat.mat';
lo_system_configuration.CONFIG_WMO_BOXES='la_wmo_boxes.mat';
lo_system_configuration.CONFIG_SAF='TypicalProfileAroundSAF.mat';

%% Objective Mapping Parameters
% max number of historical casts used in objective mapping
lo_system_configuration.CONFIG_MAX_CASTS='300';

% 1=use PV constraint, 0=don't use PV constraint, in objective mapping
lo_system_configuration.MAP_USE_PV='0';

% 1=use SAF separation criteria, 0=don't use SAF separation criteria, in objective mapping
lo_system_configuration.MAP_USE_SAF='0';

% spatial decorrelation scales, in degrees
lo_system_configuration.MAPSCALE_LONGITUDE_LARGE='2';
lo_system_configuration.MAPSCALE_LONGITUDE_SMALL='1';
lo_system_configuration.MAPSCALE_LATITUDE_LARGE='2';
lo_system_configuration.MAPSCALE_LATITUDE_SMALL='1';

% cross-isobath scales, dimensionless, see BS(2005)
lo_system_configuration.MAPSCALE_PHI_LARGE='0.5';
lo_system_configuration.MAPSCALE_PHI_SMALL='0.1';

% temporal decorrelation scale, in years
lo_system_configuration.MAPSCALE_AGE='2';
lo_system_configuration.MAPSCALE_AGE_LARGE='5';

% exclude the top xxx dbar of the water column
lo_system_configuration.MAP_P_EXCLUDE='200';

%only use historical data that are within +/- yyy dbar from float data
lo_system_configuration.MAP_P_DELTA='250';

%% set_calseries
lo_system_configuration.MAX_BREAKS=2;

%% Inicio

for i1=1:length(floats)
    flt_dir=deblank(float_dirs{1});
    flt_name=num2str(floats(i1));
    
    %% Hacemos cuatro tests
    %A Argo and CTD
    lo_system_configuration.ANALYSIS_CODE='A';
    lo_system_configuration.FLOAT_MAPPED_PREFIX='map_A_';
    lo_system_configuration.FLOAT_CALIB_PREFIX='cal_A_';
    lo_system_configuration.FLOAT_CALSERIES_PREFIX='calseries_A_';
    %lo_system_configuration.CONFIG_WMO_BOXES='wmo_boxes_CTD_for_DMQC_2014V01_ARGO_for_DMQC_2017V02.mat';
    lo_system_configuration.CONFIG_WMO_BOXES='wmo_boxes_CTD_for_DMQC.mat';
    lo_system_configuration.MAPSCALE_AGE='2';
    fprintf('>>>>> OW working on %s, %s \n',flt_name,datestr(now));
    update_salinity_mapping(flt_dir,flt_name,lo_system_configuration);
    set_calseries(flt_dir,flt_name,lo_system_configuration);
    calculate_piecewisefit(flt_dir,flt_name,lo_system_configuration);
    plot_diagnostics_ow(flt_dir,flt_name,lo_system_configuration);
    if length(floats)>1
        close all
    end
    
    %B CTD
    lo_system_configuration.ANALYSIS_CODE='B';
    lo_system_configuration.FLOAT_MAPPED_PREFIX='map_B_';
    lo_system_configuration.FLOAT_CALIB_PREFIX='cal_B_';
    lo_system_configuration.FLOAT_CALSERIES_PREFIX='calseries_B_';
    lo_system_configuration.CONFIG_WMO_BOXES='wmo_boxes_CTD_for_DMQC_2014V01.mat';
    lo_system_configuration.MAPSCALE_AGE='2';
    fprintf('>>>>> OW working on %s, %s \n',flt_name,datestr(now));
    update_salinity_mapping(flt_dir,flt_name,lo_system_configuration);
    set_calseries(flt_dir,flt_name,lo_system_configuration);
    calculate_piecewisefit(flt_dir,flt_name,lo_system_configuration);
    plot_diagnostics_ow(flt_dir,flt_name,lo_system_configuration);
    if length(floats)>1
        close all
    end
    
    
    %C Argo and CTD
    lo_system_configuration.ANALYSIS_CODE='C';
    lo_system_configuration.FLOAT_MAPPED_PREFIX='map_C_';
    lo_system_configuration.FLOAT_CALIB_PREFIX='cal_C_';
    lo_system_configuration.FLOAT_CALSERIES_PREFIX='calseries_C_';
    lo_system_configuration.CONFIG_WMO_BOXES='wmo_boxes_CTD_for_DMQC_2014V01_ARGO_for_DMQC_2017V02.mat';
    lo_system_configuration.MAPSCALE_AGE='5';
    fprintf('>>>>> OW working on %s, %s \n',flt_name,datestr(now));
    update_salinity_mapping(flt_dir,flt_name,lo_system_configuration);
    set_calseries(flt_dir,flt_name,lo_system_configuration);
    calculate_piecewisefit(flt_dir,flt_name,lo_system_configuration);
    plot_diagnostics_ow(flt_dir,flt_name,lo_system_configuration);
    if length(floats)>1
        close all
    end
    
    
    %D Argo and CTD
    lo_system_configuration.ANALYSIS_CODE='D';
    lo_system_configuration.FLOAT_MAPPED_PREFIX='map_D_';
    lo_system_configuration.FLOAT_CALIB_PREFIX='cal_D_';
    lo_system_configuration.FLOAT_CALSERIES_PREFIX='calseries_D_';
    lo_system_configuration.CONFIG_WMO_BOXES='wmo_boxes_CTD_for_DMQC_2014V01_ARGO_for_DMQC_2017V02.mat';
    lo_system_configuration.MAPSCALE_AGE='10';
    fprintf('>>>>> OW working on %s, %s \n',flt_name,datestr(now));
    update_salinity_mapping(flt_dir,flt_name,lo_system_configuration);
    set_calseries(flt_dir,flt_name,lo_system_configuration);
    calculate_piecewisefit(flt_dir,flt_name,lo_system_configuration);
    plot_diagnostics_ow(flt_dir,flt_name,lo_system_configuration);
    if length(floats)>1
        close all
    end
    
    
    %E CTD
    lo_system_configuration.ANALYSIS_CODE='E';
    lo_system_configuration.FLOAT_MAPPED_PREFIX='map_E_';
    lo_system_configuration.FLOAT_CALIB_PREFIX='cal_E_';
    lo_system_configuration.FLOAT_CALSERIES_PREFIX='calseries_E_';
    lo_system_configuration.CONFIG_WMO_BOXES='wmo_boxes_CTD_for_DMQC_2014V01.mat';
    lo_system_configuration.MAPSCALE_AGE='10';
    fprintf('>>>>> OW working on %s, %s \n',flt_name,datestr(now));
    update_salinity_mapping(flt_dir,flt_name,lo_system_configuration);
    set_calseries(flt_dir,flt_name,lo_system_configuration);
    calculate_piecewisefit(flt_dir,flt_name,lo_system_configuration);
    plot_diagnostics_ow(flt_dir,flt_name,lo_system_configuration);
    if length(floats)>1
        close all
    end
end

