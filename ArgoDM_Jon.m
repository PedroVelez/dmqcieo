%lectura de los archivos .nc para extraer los datos que 
%serán revisados en Delayed-Mode
clear all;close all;clc
warning off

floats=[1900275];

% floats=[1900275 1900276 1900277 1900278 1900279 1900377 ...
 %        1900378 1900379 4900556 4900557 4900558 6900230 ...
  %       6900231 6900506];


for ii=1:length(floats)
    inpath='C:\Jonathan\OW\data\climatology\Float\';
    outpath='C:\Jonathan\OW\data\climatology\Datos_DMQC';
    name=[num2str(floats(ii)),'_prof.nc'];
    flname=[inpath,num2str(floats(ii)),'\',name];

    %nombro las variables del archivo
    platform=getnc(flname,'PLATFORM_NUMBER')'; 
    project=getnc(flname,'PROJECT_NAME')'; 
    cycle=getnc(flname,'CYCLE_NUMBER')'; 
    daynumr=getnc(flname,'REFERENCE_DATE_TIME')';
    timeref=datenum(str2double(daynumr(1:4)),str2double(daynumr(5:6)),str2double(daynumr(7:8)));
    date1=getnc(flname,'JULD')';
    date=date1+timeref;
    datamode=getnc(flname,'DATA_MODE')';
    stapar=getnc(flname,'STATION_PARAMETERS');
    inst_reference=getnc(flname,'INST_REFERENCE')';
    wmo_inst_type=getnc(flname,'WMO_INST_TYPE')';
    nprof=size (stapar,1);
    nparam=size (stapar,2);
    temp=getnc(flname,'TEMP')';
    sal=getnc(flname,'PSAL')';
    pres=getnc(flname,'PRES')';
    lat=getnc(flname,'LATITUDE')';
    lon=getnc(flname,'LONGITUDE')';
    %datos ajustados
    tempqc=getnc(flname,'TEMP_QC')';
    salqc=getnc(flname,'PSAL_QC')';
    presqc=getnc(flname,'PRES_QC')';
    temp_ad=getnc(flname,'TEMP_ADJUSTED')';
    sal_ad=getnc(flname,'PSAL_ADJUSTED')';
    pres_ad=getnc(flname,'PRES_ADJUSTED')';
    temp_adqc=getnc(flname,'TEMP_ADJUSTED_QC')';
    sal_adqc=getnc(flname,'PSAL_ADJUSTED_QC')';
    pres_adqc=getnc(flname,'PRES_ADJUSTED_QC')';
    
%QC used to NaN values for RT
%QC=3 
%Test 15 or Test 16 or Test 17 failed and all other real-time QC tests 
%passed. These data are not to be used without scientific correction. 
%A flag ‘3’ may be assigned by an operator during additional visual QC for 
%bad data that may be corrected in delayed mode.
%QC=4
%Data have failed one or more of the real-time QC tests, excluding Test 16.
%A flag ‘4’ may be assigned by an operator during additional visual QC for 
%bad data that are not correctable.
bpsal=find(salqc=='3' | salqc=='4' | salqc=='8' | salqc=='9');
sal(bpsal)=NaN; %Bad data
btemp=find(tempqc=='3' | tempqc=='4' | tempqc=='8' | tempqc=='9');
temp(btemp)=NaN; %Bad data
bpres=find(presqc=='3' | presqc=='4' | presqc=='8' | presqc=='9');
pres(bpres)=NaN; %Bad data

%QC used to NaN values for DM
%QC=3
%An adjustment has been applied, but the value may still be bad.
%QC=4 Bad data. Not adjustable.
bpsal_ad=find(sal_adqc=='4' | sal_adqc=='8' | sal_adqc=='9');
sal_ad(bpsal_ad)=NaN; %Bad data
btemp_ad=find(temp_adqc=='4' | temp_adqc=='8' | temp_adqc=='9');
temp_ad(btemp_ad)=NaN; %Bad data
bpres_ad=find(pres_adqc=='4' | pres_adqc=='8' | pres_adqc=='9');
pres_ad(bpres_ad)=NaN; %Bad data

%Change absent data by Nan
sal(sal==99999)=NaN;
temp(temp==99999)=NaN;
pres(pres==99999)=NaN;
sal_ad(sal_ad==99999)=NaN;
temp_ad(temp_ad==99999)=NaN;
pres_ad(pres_ad==99999)=NaN;
lat(lat==99999 | lat==-99999)=NaN;
lon(lon==99999 | lon==-99999)=NaN;

iDM=findstr(datamode,'D');
if length(iDM)>0
    disp(' >  Datos con DM')
    temp(iDM,:)=temp_ad(iDM,:);
    sal(iDM,:)=sal_ad(iDM,:);
    pres(iDM,:)=pres_ad(iDM,:);
end

%ia=findstr(datamode,'A');
%if length(ia)>0
%    disp(' >  Datos con A')
%    temp(ia,:)=temp_ad(ia,:);
%    sal(ia,:)=sal_ad(ia,:);
%    pres(ia,:)=pres_ad(ia,:);
%end

%Activar esto cuando no podamos hacer el ajuste del offset de presion
%(volveriamos desde paso posteriores)
% desactivado tb en las provor
for jj=1:size(pres,2)
    for kk=1:size(pres,1)
    end
end
for jj=1:size(pres_ad,2)
    for kk=1:size(pres_ad,1)
    end
end


    %calculo de variables derivadas
    ptmp=sw_ptmp(sal,temp,pres,0);

   flname = [outpath,'DM',sprintf('%3.3i',floats(ii))];
   disp(['    Saving to filename ',flname])
   eval(['save ',flname,' platform project cycle date datamode stapar inst_reference wmo_inst_type temp sal pres lat lon tempqc salqc presqc temp_ad sal_ad pres_ad temp_adqc sal_adqc pres_adqc ptmp'])
 
         
    
    %graficamos 
    figure
    subplot(131)
    hold on
    plot(ptmp,-pres,'-b');
    title(num2str(floats(ii)),'fontsize',16)
    xlabel('\theta  (ºC)','fontsize',12);
    ylabel('Pressure (db)','fontsize',12);

    subplot(132)
    hold on
    plot(sal,-pres,'-b');
    xlabel('Salinity','fontsize',12);
    ylabel('Pressure (db)','fontsize',12);
   
    subplot(133)
    hold on
    plot(sal,ptmp,'.b');
    xlabel('Salinity','fontsize',12);
    ylabel('\theta (ºC)','fontsize',12);

       
%     %subplot(224)
%     lon_min=-85;
%     lon_max=0;
%     lat_min=10;
%     lat_max=50;
%     m_proj('mercator','lat',[lat_min lat_max], 'long',[lon_min lon_max]);
%     hold on
%     m_usercoast('Atlantico','patch','k');
%     m_plot(lon,lat);
%     hold on
%     m_plot(lon(1),lat(1));
%     %m_plot(lonL94(indLon),latL94(indLat),'.r');
%     m_grid ('Linestyle','none','box','fancy','tickdir','out');
%     xlabel('Longitude (ºW)','fontsize',12);
%     ylabel('Latitude (ºN)','fontsize',12);

    orient tall
%     pause
% Hay que crear la carpeta con la numeración de la boya en la carpeta RESULTADOS_DMQC
    
%    outpath2='C:\Marta\ARGO\DMQC\RESULTADOS_DMQC\';  
%    name2=[num2str(floats(ii))];   
%    outname=[outpath2,num2str(floats(ii)),'\',name2];
%    eval(['print ',outname,' -depsc2']);
   %close
end

