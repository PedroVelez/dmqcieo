Limpia

OW_Config.HISTORICAL_DIRECTORY=fullfile(GlobalSU.ArgoDMQC,'/data/climatology');
OW_Config.HISTORICAL_CTD_PREFIX=fullfile(filesep,'CTD_for_DMQC_2018V01','ctd_');
OW_Config.HISTORICAL_ARGO_PREFIX= fullfile(filesep,'ARGO_for_DMQC_2017V02','argo_');
OW_Config.CONFIG_DIRECTORY=fullfile(GlobalSU.ArgoDMQC,'Data','constants',filesep);
OW_Config.CONFIG_WMO_BOXES_Original='wmo_boxes.mat';


%% 
Or=load(fullfile(OW_Config.CONFIG_DIRECTORY,OW_Config.CONFIG_WMO_BOXES_Original));

%% Only CTD
OW_Config.CONFIG_WMO_BOXES='wmo_boxes_CTD_for_DMQC';
for i1=1:648
    la_wmo_boxes(i1,1)=Or.la_wmo_boxes(i1,1);
    la_wmo_boxes(i1,2)=exist(fullfile(OW_Config.HISTORICAL_DIRECTORY,sprintf('%s%04d.mat',OW_Config.HISTORICAL_CTD_PREFIX,la_wmo_boxes(i1,1))),'file');
    la_wmo_boxes(:,3)=0;
    la_wmo_boxes(i1,4)=0;
end
la_wmo_boxes(la_wmo_boxes==2)=1;

save(fullfile(OW_Config.CONFIG_DIRECTORY,OW_Config.CONFIG_WMO_BOXES),'la_wmo_boxes')
