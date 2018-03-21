%% Step 1. Description:
%   This file generates an interactive display in which the profiles can be
%   handled and modified one by one. Temperature and Salinity profiles can
%   be selected for visual inspection. Every profile is managed by cycles - bins 
%   and every measurement (data) is located at one point. Detected
%   anomalies can be flagged and erased if required by the PI.
%   Note that these raw files are the same at QC0 but must be located at QC1.
%   Required corrections are overwritten at QC1.
%
%   ************FIRST QUALITY CONTROL FLAG IS CARRIED OUT*****************
%   A quality flag indicates the quality of an observation. The flags are 
%   assigned in Real Time (RT) and can be modified in Delayed Mode (DM).
%   Flags are set in a range from 0 to 9 [Please check Argo DM Manual v3.1 
%   for more information]. Each correction must be flagged.
%   <www.oceanografia .argo.es>
%
%   Pedro Velez & Alberto Gonzalez (2016)

Limpia

addpath(fullfile(GlobalSU.ArgoDMQC,'Programas','Paso1_RevisaRTQC_matlab_codes'));

wmonum=1900379;

Config.inpath = fullfile(GlobalSU.ArgoDMQC,'Data','float_sourceQC1',num2str(wmonum),'profiles',filesep);
Config.outpath = fullfile(GlobalSU.ArgoDMQC,'Data','float_sourceQC1',num2str(wmonum),'profiles',filesep);

%HISTORY_INSTITUTION [Optional]
Config.HISTORY_INSTITUTION='SP  '; %[Default='    '] %It has to be 4 char in size
Config.HISTORY_SOFTWARE='AIEO';

%Climatology [Optional]
Config.CLIFile=strcat(fullfile(GlobalSU.ArgoDMQC,'Data','climatology',filesep),'WOA05.mat');
Config.CLIBorder=5; %size of the box for the climatology, in degrees [Default=10]


%Extrem values for axes [Optional]
Config.maxP=2000;    %[Default=automatic]
% Config.maxT=30;     %[Default=automatic]
% Config.minT=2;      %[Default=automatic]
% Config.maxS=38.8;    %[Default=automatic]
% Config.minS=34;     %[Default=automatic]

Config.QCms = 7;      % markersize for que QC plots [Default=5]
Config.POSBorder = 2; %Size of the box for the map, in degrees [Default=10]

argo_edit_gui(Config)