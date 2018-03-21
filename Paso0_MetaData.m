%% Step 0. Description:
%   This file reads archives *.nc to get floats data necesary for the *Delayed-Mode Quality Control*.
%   These archives .nc contain basic information of each float, distributed in [_meta, _prof, _tech and Profs]*.nc.
%   If any of these statements cause any trouble, argo data version must be checked [3.1 currently].
%   Note that these raw files must be located at QC0 level.
%   The variable [Profs] is a structure that contains all the parameters gathered at Argo DM Manual v3.1.
%   Strings, dimensions and guidelines of each parameter are gathered at Argo DM Manual v3.1.1900378
%   Note this is the "Zero Step" of DMQC, so data still are in Real Time (RT) mode.
%   <www.oceanografia.argo.es>
%
%   Pedro Velez & Alberto Gonzalez (2016)
%
%% Platform number of the floats
Limpia
floats=[6900785];

%% Original path of floats data
inpath = fullfile(strcat(GlobalSU.ArgoDMQC,'/',fullfile('Data','float_sourceQC4')));
GlobalSU.ArgoDMQC;

%% Open archives .nc wto read floats data for DMQC
for ii=1:length(floats)
    % META-DATA FILE
    AMD=ReadArgoMetaFile(strcat(inpath,filesep,num2str(floats(ii)),filesep,strcat(num2str(floats(ii)),'_meta.nc')));
    % ARGO PROFILE FILE
    AD=ReadArgoFloatFile(strcat(inpath,filesep,num2str(floats(ii)),filesep,strcat(num2str(floats(ii)),'_prof.nc')));
    % TECHNICAL INFORMATION FILE
    ATE=ReadArgoTechFile(strcat(inpath,filesep,num2str(floats(ii)),filesep,strcat(num2str(floats(ii)),'_tech.nc')));
    % TRAJECTORY FILE
    %TJ=ReadArgoTrayectoryFile(strcat(inpath,filesep,num2str(floats(ii)),filesep,strcat(num2str(floats(ii)),'_Rtraj.nc')));
    % READ EACH ARGO PROFILE OF EACH FLOAT
    Profs=ReadArgoProfilesDoble(strcat(inpath,filesep,num2str(floats(ii)),filesep,'profiles',filesep));
end