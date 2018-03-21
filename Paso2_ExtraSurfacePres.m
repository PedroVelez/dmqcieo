%% Step 2. Description:
%   This file ONLY extracts Surface Pressure Values for ALL APEX floats
%   from [_tech.nc] files and also notifies if it's TNDP (SP>80% = zero).
%
%   Potential surface pressure errors of PROVOR floats are automatically corrected.
%
%   EXCEPTIONAL CASE: APEX floats with Platform Model < APF 9 surface pressure
%   values less than zero(0) are wrong reported as zero(0). This is known as "Truncated
%   Negative Drift Pressure" (TNDP). If more than 80% pressure data are
%   reported as zero, there is no correction available (TNDP) and salinity
%   is recomputed. If it's less than 80%, corrections are required and
%   PRES, PSAL and TEMP are recomputed. This information is contained at
%   "PRES_SurfaceOffsetTruncatedPlus5dbar_dBAR" parameter.
%
%   This script reads from QC1 and required corrections are overwritten at QC1.
%   <www.oceanografia.argo.es>
%
%   Pedro Velez & Alberto Gonzalez (2016)
%
%   Double Checked Floats
%    [1900275  1900276  1900277  1900278  1900279  1900377  1900378  1900379  4900556  4900557
%     4900558  6900230  6900231  6900506  6900635  6900636  6900659  6900660  6900661  6900662
%     6900760  6900761  6900762  6900763  6900764  6900765  6900766  6900767  6900768  6900769
%     6900770  6900771  6900772  6900773  6900774  6900775  6900776  6900777  6900778  6900779
%     6900780  6900781  6900782  6900783  6900784  6900785  6900786  6900789  6901237  6901241]

Limpia
floats=[1900379];

%----------------------------------------------------------------------
% Inicio
%----------------------------------------------------------------------
pathDM=fullfile(GlobalSU.ArgoDMQC,('Data'),filesep);
fprintf('>>>>> %s\n',mfilename)

for ii=1:length(floats)
    %Leo del fichero de metadatos
    ncid=netcdf.open(strcat(pathDM,'float_sourceQC1',filesep,num2str(floats(ii)),filesep,strcat(num2str(floats(ii)),'_meta.nc')),'nc_nowrite');
    try
        platform_model=strtrim(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'FIRMWARE_VERSION'))');
    catch ME;
        platform_model=strtrim(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PLATFORM_MODEL'))');
    end
    netcdf.close(ncid);
    %Nombro las variables del archivo
    ATE=ReadArgoTechFile(strcat(pathDM,filesep,'float_sourceQC1',filesep,num2str(floats(ii)),filesep,strcat(num2str(floats(ii)),'_tech.nc')));
    platform=ATE.PLATFORM_NUMBER;
    format=ATE.FORMAT_VERSION;
    handbook=ATE.HANDBOOK_VERSION;
    datacentre=ATE.DATA_CENTRE;
    datecreation=ATE.DATE_CREATION;
    dateupdate=ATE.DATE_UPDATE;
    
    fprintf('>>>>> %s %s\n',platform,platform_model)
    
    if isfield(ATE,'PRES_SurfaceOffsetTruncatedplus5dBar_dBAR')==1
        surf_pressure=ATE.PRES_SurfaceOffsetTruncatedplus5dBar_dBAR;
        surf_pressure_c=ATE.PRES_SurfaceOffsetTruncatedplus5dBar_dBARCycle;
        disp('    > PRES_SurfaceOffsetTruncatedplus5dBar_dBAR')
        surf_pressure=surf_pressure-5;%Quito 5 por el plus5Dba
    elseif isfield(ATE,'PRES_SurfaceOffsetNotTruncated_dBAR')==1
        surf_pressure=ATE.PRES_SurfaceOffsetNotTruncated_dBAR;
        surf_pressure_c=ATE.PRES_SurfaceOffsetNotTruncated_dBARCycle;
        disp('    > PRES_SurfaceOffsetNotTruncated_dBAR')
    elseif isfield(ATE,'PRES_SurfaceOffsetCorrectedNotResetNegative_1dBarResolutio')==1
        surf_pressure=ATE.PRES_SurfaceOffsetCorrectedNotResetNegative_1dBarResolutio;
        surf_pressure_c=ATE.PRES_SurfaceOffsetCorrectedNotResetNegative_1dBarResolutioCycle;
        disp('    > PRES_SurfaceOffsetCorrectedNotResetNegative_1dBarResolutio')
    end
    
    
    % PRES_ADJUSTED (cycle i) = PRES (cycle i) ? SP (cycle i+1).
    % The CTD profile and the associated SP is staggered by one cycle because the SP
    % measurement is taken after the telemetry period, and therefore is stored in the memory
    % and telemetered during the next cycle. The real-time procedure does not match SP value
    % from cycle i+1 with PRES from cycle i, because real-time adjustment cannot wait 10
    % days. However, in delayed-mode, it is important to match the CTD profile with the
    % staggered telemetry of SP, because SP values can contain synoptic atmospheric
    % variations, and because a missing CTD profile is often associated with an erroneous SP
    % point. By this scheme, SP(1), which is taken before cycle 1 and therefore before the float
    % has had its first full dive, is not used in delayed-mode.
    surf_pressure=[surf_pressure(2:end) surf_pressure(end)];
    
    %Identificamos si la boya es TNPD: m?s del 80% de los valores SP son cero
    %pasamos los NaN a ceros
    surf_pressure(isnan(surf_pressure)==1)=0;
    n=size(surf_pressure,2);
    
    flname = fullfile(pathDM,filesep,'DMSurfpres',sprintf('%6d',floats(ii)));
    
    save(flname,'platform_model','surf_pressure','surf_pressure_c','platform','format','handbook','datacentre','datecreation','dateupdate')
    fprintf('    > Saving SurfaceOffset to filename %s \n',flname)
    
    %Obtenemos el porcentaje
    %Las provor corrgien automaticamente la presion en superficie
    %TNPD APEX floats with Apf-5, Apf-7, or Apf-8 controllers
    if (strcmp(platform_model(findstr('APF',platform_model):findstr('APF',platform_model)+3),'APF5')) || (strcmp(platform_model(findstr('APF',platform_model):findstr('APF',platform_model)+3),'APF7')) ||(strcmp(platform_model(findstr('APF',platform_model):findstr('APF',platform_model)+3),'APF8'))
        porc=(length(find(surf_pressure==0))*100)/n; %porcentage de surf_pressure a 0
        porc_erroneos=(length(find(surf_pressure>=900))*100)/n; %porcentage de surf_pressure superior a 900
        porc_erroneos900=(length(find(surf_pressure>=900 & surf_pressure<=2999))*100)/n; %porcentage de surf_pressure entre 900 et 3000
        porc_erroneos3000=(length(find(surf_pressure>=3000))*100)/n;%porcentage de surf_pressure superior a 3000
        fprintf('    > TNPD - 900<SP<3000 - 3000<SP - Total \n')
        fprintf('    > %4.2f -  %4.2f    - %4.2f   - %4.2f\n',porc,porc_erroneos900,porc_erroneos3000,(porc+porc_erroneos900+porc_erroneos3000))
        if porc>=80
            fprintf('    > Deriva de presi?n truncada negativamente, no hay ajuste de presi?n disponible (TNPD) \n');
        elseif (porc+porc_erroneos900+porc_erroneos3000)>80 %mantenemos el 80% ya que es donde lo situan en las TNPD
            fprintf('    > No deberia hacerse la correccion del sensor de presi?n.\n')
            %      elseif (porc+porc_erroneos900+porc_erroneos3000)<80
        end
        fprintf('    > adding TNPD computations \n')
        save('-append',flname,'porc','porc_erroneos','porc_erroneos900','porc_erroneos3000')
    end
end
