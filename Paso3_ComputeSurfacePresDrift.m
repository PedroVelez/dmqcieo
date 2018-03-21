%% Step 3. Description:
%   This file ONLY calculate Presure values from Surface Pressure values
%   calculated at Step2 for APEX floats ONLY.
%
%   RSP: Raw Surface Pressure: "surf_pressure" from [_tech.nc] files.
%   MPP: Minimum Profile (from Real Time) Pressure.
%   MAPRT: Minimum Adjusted Profile Pressure.
%   SSPM: Smoothed Surface Pressure
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
%     6900780  6900781  6900782  6900783  6900784  6900785  6900786  6900789  6901237  6901241];
%
%   Format failure at floats == 1900377  4900556 4900557 4900558 6900662
Limpia
floats=[1900379];

%----------------------------------------------------------------------
% Inicio
%----------------------------------------------------------------------
fprintf('>>>>> %s\n',mfilename)
pathDM=fullfile(GlobalSU.ArgoDMQC,'Data',filesep);
inpathAD=fullfile(GlobalSU.ArgoDMQC,'Data','float_sourceQC1');

for iboya=1:length(floats)
    %Leemos los datos de los archivos t?cnicos (surf_pressure)
    flname = fullfile(pathDM,'DMSurfpres',filesep,sprintf('%6d',floats(iboya)));
    load(flname)
    fprintf('    > %s %s\n',platform,platform_model)
    fprintf('    > Loaded SurfaceOffset from filename %s \n',flname)
    
    %Leemos los datos medidos por la boya
    Profs=ReadArgoProfilesDoble(strcat(inpathAD,filesep,num2str(floats(iboya)),filesep,'profiles',filesep));
    cycle_number=[Profs.cycle_number]';
    
    %Iniciamos los calculos
    %RSP Raw Surface Pressure:surf_pressure de los archivos t?cnicos.
    %MPP Minimum Profile (from Real Time) Pressure
    %MAPRT Minimum Adjusted Profile Pressure (este proceso es autom?tico en coriolis)
    %SSPM Smoothed Surface Pressure
    %Nota: hay que comprobar la coincidencia de los ciclos entre _tech y _prof
    
    for iprof=1:size(cycle_number,1)
        if find(surf_pressure_c==cycle_number(iprof))
            RSP(iprof)=surf_pressure(find(surf_pressure_c==cycle_number(iprof)));
        else
            RSP(iprof)=NaN;
        end
    end
    
    %Este primer bucle es para eliminar los perfiles que han sido truncados
    %a cero. ACTIVAR ESTO UNICAMENTE CUANDO TODOS LOS DEM?S VALORES SEAN
    %POSITIVOS (si hay negativos, el cero es valor real)
    %     if size(find(RSP>=0),2)==size(RSP,2)
    %         RSP(RSP==0)=NaN;
    %     end
    
    %Eliminamos los datos err?neos
    RSP(RSP>=20)=NaN;
    %Eliminamos valores que difieren en 5 dbar del anterior
    for ij=1:size(RSP,2)-1
        if abs(RSP(ij)-RSP(ij+1))>5;
            RSP(ij+1)=NaN;
        end
    end
    
    %Obtenemos la presi?n medida en el perfil
    MPP=[]; MAPRT=[];SSPM=[];
    for iprof=1:size(Profs,2)
        %extraemos la presion Real time m?nima del perfil (MPP)
        MPP=[MPP min(Profs(iprof).pres(:))'];
        %extraemos la pres_adjustada minima del perfil (MAP)
        MAPRT=[MAPRT min(Profs(iprof).pres_adjusted(:))'];
    end
    
    %Calcula Surface Pressure suavizada: CSP
    %SSP=NaN(length(cycle_number),1);
    %SSPM=SSP*ones(1,size(pres,2));
    SSP=smooth(RSP,5);
    
    for ij=1:1:size(Profs,2);
        var=Profs(ij).temp;
        var2=Profs(ij).temp_adjusted;
        idx=find(var==99999);
        idx2=find(var2==99999);
        var(idx)=NaN;
        var2(idx2)=NaN;
        Profs(ij).temp=var;
        Profs(ij).temp_adjusted=var2;
    end
    
    %%Representamos
    figure
    for i1=1:size(Profs,2)
        plot(Profs(i1).psal,Profs(i1).temp,'.-','Color',Colores(i1));hold on
    end
    grid on;set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
    title(sprintf('%s TS Real Time QC=1,2,3',Profs(1).platform_number'))
    orient landscape
    CreaFigura(1,strcat(flname,'_01'),7);
    
    figure
    p1=plot(cycle_number,MPP,'color','r','Marker','+','Linestyle','none','markersize',8);hold on;grid on
    p2=plot(cycle_number,MAPRT,'color','g','Marker','o','Linestyle','none','markersize',8);
    p3=plot(cycle_number,RSP,'color','b','Marker','*','Linestyle','none','markersize',8);
    p4=plot(cycle_number,SSP,'color','k','Marker','x','Linestyle','none','markersize',8);
    set(gca,'Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on')
    legend([p1,p2,p3,p4],'Minimum profile pressure (MPP)','RT Minimum adjusted profile pressure (MAP)', ...
        'Surface pressure from technical files (RSP)','Smoothed Surface pressure from technical files (SSP)');
    title(sprintf('WMO %s %s. Surface pressure',deblank(platform),platform_model))
    axis([-inf inf -inf inf])
    orient landscape
    CreaFigura(2,strcat(flname,'_02'),7);
    
    flname = fullfile(pathDM,'DMSurfpres',filesep,sprintf('%6d',floats(iboya)));
    fprintf('    > Actualizando %s con la deriva de presion \n',flname)
    save(flname,'-append','MPP','MAPRT','RSP','SSP','SSPM','Profs','cycle_number')
    if length(floats)>1
        close all;
        clear MPP MAPRT RSP SSP Profs cycle_number pres pres_ad_RT
    end
end