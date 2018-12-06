Limpia


OW_Config.HISTORICAL_DIRECTORY=fullfile(GlobalSU.ArgoDMQC,'/data/climatology');
OW_Config.HISTORICAL_CTD_PREFIX=fullfile(filesep,'CTD_for_DMQC_2014V01','ctd_');
OW_Config.HISTORICAL_ARGO_PREFIX= fullfile(filesep,'ARGO_for_DMQC_2017V02','argo_');

OW_Config.CONFIG_DIRECTORY=fullfile(GlobalSU.ArgoDMQC,'Data','constants',filesep);

OW_Config.CONFIG_WMO_BOXES_Original='wmo_boxes.mat';
OW_Config.CONFIG_WMO_BOXES='wmo_boxes_CTD_for_DMQC_2014V01_ARGO_for_DMQC_2017V02.mat';

Or=load(strcat('/Volumes/Gdoye$/Proyectos/Argo/DelayedMode/Data/constants/',OW_Config.CONFIG_WMO_BOXES_Original));

for i1=1:648
    la_wmo_boxes(i1,1)=Or.la_wmo_boxes(i1,1);
    la_wmo_boxes(i1,4)=0;%exist(strcat('/Volumes/Gdoye$/Proyectos/Argo/DelayedMode/Data/climatology/',sprintf('%s%04d.mat',OW_Config.HISTORICAL_ARGO_PREFIX,la_wmo_boxes(i1,1))),'file');
    la_wmo_boxes(i1,2)=exist(strcat('/Volumes/Gdoye$/Proyectos/Argo/DelayedMode/Data/climatology/',sprintf('%s%04d.mat',OW_Config.HISTORICAL_CTD_PREFIX,la_wmo_boxes(i1,1))),'file');
end
la_wmo_boxes(la_wmo_boxes==2)=1;
la_wmo_boxes(:,3)=0;

save la_wmo_boxes 
