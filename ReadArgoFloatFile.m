function D=ReadArgoFloatFile(file,Verbose)
if nargin<2
    Verbose=1;
end

D=struct('platform',{{}});
ncid=netcdf.open(file,'nc_nowrite');
D.platform=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PLATFORM_NUMBER'))';
t=str2num(D.platform);
if isempty(t)==0
    [dinname,D.nprof]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'N_PROF'));
    [dinname,D.nparam]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'N_PARAM'));
    daynumr=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATE_CREATION'));
    D.DATE_CREATION=datenum(str2double(daynumr(1:4)),str2double(daynumr(5:6)),str2double(daynumr(7:8)));
    daynumr=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATE_UPDATE'));
    D.DATE_UPDATE=datenum(str2double(daynumr(1:4)),str2double(daynumr(5:6)),str2double(daynumr(7:8)));
    D.project= netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PROJECT_NAME'))';
    D.cycle= netcdf.getVar(ncid,netcdf.inqVarID(ncid,'CYCLE_NUMBER'));
    daynumr=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'REFERENCE_DATE_TIME'));
    timeref=datenum(str2double(daynumr(1:4)),str2double(daynumr(5:6)),str2double(daynumr(7:8)));
    D.julds=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'JULD'))+timeref;
    D.stapar=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'STATION_PARAMETERS'));
    D.datamode=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATA_MODE'));
    D.datacentre=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATA_CENTRE'))';
    D.wmo_inst_type=str2num(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'WMO_INST_TYPE'))');
    D.PI_NAME=str2num(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PI_NAME'))');
    
    if Verbose==1
        fprintf('>>>>> Float %8d from %s and procesed at %s\n',t(1),deblank(D.project(1,:)),D.datacentre(1,:))
        fprintf('     > with %d profiles Created %s and updated %s\n',D.nprof,datestr(D.DATE_CREATION),datestr(D.DATE_UPDATE))
    end
    
    ipsal=0;
    itemp=0;
    idoxy=0;
    if D.nparam>=3
        ipsal=1;
        itemp=1;
    elseif D.nparam>=2
        itemp=1;
    end
    if D.nparam==4
        idoxy=1;
    end
    D.lats=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'LATITUDE'));
    D.lons=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'LONGITUDE'));
    positionqc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'POSITION_QC'));
    D.pres=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES')))';
    D.presqc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_QC'))';
    D.pres_ad=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED')))'; %Valores ajustado en DM
    D.pres_adqc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED_QC'))';
    if itemp==1
        D.tems=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP')))';
        D.temsqc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP_QC'))';
        D.tems_ad=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED')))';
        D.tems_adqc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED_QC'))';
    else
        D.tems=D.pres.*NaN;
        D.temsqc=D.pres.*NaN;
        D.tems_ad=D.pres.*NaN;
        D.tems_adqc=D.pres.*NaN;
    end
    if ipsal==1
        D.sals=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL')))';
        D.salsqc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL_QC'))';
        D.sals_ad=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED')))';
        D.sals_adqc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED_QC'))';
    else
        D.sals=pres.*NaN;
        D.salsqc=pres.*NaN;
        D.sals_ad=pres.*NaN;
        D.sals_adqc=pres.*NaN;
    end
    if idoxy==1
D.oxys=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DOXY')))';
        D.UnitOxys='micromole/kg';
        D.oxysqc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DOXY_QC'))';
        D.oxys_ad=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DOXY_ADJUSTED')))';
        D.oxys_adqc=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DOXY_ADJUSTED_QC'))';
    end
    
    %Argo Quality Control Manual
    %http://www.coriolis.eu.org/cdc/argo/argo-quality-control-manual.pdf
    %Argo user manual
    %http://www.usgodae.org/argo/argo-dm-user-manual.pdf
    %Real Time QC used to NaN values
    %QC=0 No QC was performed
    %QC=3 An adjustment has been applied, but the value may still be bad.
    %Test 15 or Test 16 or Test 17 failed and all other real-time QC tests
    %passed. These data are not to be used without scientific correction.
    %A flag ‘3’ may be assigned by an operator during additional visual QC for
    %bad data that may be corrected in delayed mode.
    %QC=4 Bad data. Not adjustable.
    %Data have failed one or more of the real-time QC tests, excluding Test 16.
    %A flag ‘4’ may be assigned by an operator during additional visual QC for
    %bad data that are not correctable
    %QC=9 Missing value
%     bpres=find(D.presqc=='0' | D.presqc=='3' | D.presqc=='4' |  D.presqc=='9');
%     pres(bpres)=NaN; %Bad data
%     if itemp==1
%         btemp=find(D.temsqc=='0' | D.temsqc=='3' | D.temsqc=='4' | D.temsqc=='9');
%         D.tems(btemp)=NaN; %Bad data
%     end
%     if ipsal==1
%         bpsal=find(D.salsqc=='0' | D.salsqc=='3' | D.salsqc=='4' | D.salsqc=='9');
%         D.sals(bpsal)=NaN; %Bad data
%     end
    %Delayed Mode QC used to NaN values
    %QC=0 No QC was performed
    %QC=3 An adjustment has been applied, but the value may still be
    %bad..(I keep this data!!)
    %QC=4 Bad data. Not adjustable.
    %QC=9 Missing value
    bpres_ad=find(D.pres_adqc=='4' | D.pres_adqc=='9');
    D.pres_ad(bpres_ad)=NaN; %Bad data
    btemp_ad=find(D.tems_adqc=='4' | D.tems_adqc=='9');
    D.tems_ad(btemp_ad)=NaN; %Bad data
    if ipsal==1
        bpsal_ad=find(D.sals_adqc=='4' | D.sals_adqc=='9');
        D.sals_ad(bpsal_ad)=NaN; %Bad data
    end
    %Change absent data by Nan
    D.pres(D.pres==99999)=NaN;
    D.tems(D.tems==99999)=NaN;
    D.sals(D.sals==99999)=NaN;
    if idoxy==1
        D.oxys(D.oxys==99999)=NaN;
    end
    D.pres_ad(D.pres_ad==99999)=NaN;
    D.tems_ad(D.tems_ad==99999)=NaN;
    D.sals_ad(D.sals_ad==99999)=NaN;
    D.lats(D.lats==99999 | D.lats==-99999)=NaN;
    D.lons(D.lons==99999 | D.lons==-99999)=NaN;
    
    %Find those profiles with DM or A
    iDM=findstr(D.datamode','D');
    iA=findstr(D.datamode','A');
    
    if ~isempty(iA)
        if Verbose==1
            fprintf('     > %4d of %4d profiles with Automatic Deleyed Mode control (A)\n',size(iA,2),size(D.tems,1))
        end
        D.tems(iA,:)=D.tems_ad(iA,:);
        D.sals(iA,:)=D.sals_ad(iA,:);
        D.pres(iA,:)=D.pres_ad(iA,:);
    end
    if ~isempty(iDM)
        if Verbose==1
            fprintf('     > %4d of %4d profiles with Delayed Mode QC (DM)\n',size(iDM,2),size(D.tems,1))
        end
        D.tems(iDM,:)=D.tems_ad(iDM,:);
        D.sals(iDM,:)=D.sals_ad(iDM,:);
        D.pres(iDM,:)=D.pres_ad(iDM,:);
    end
    
    %I take out those profiles with bad position
    ipQC=find(positionqc==0|positionqc==3|positionqc==4|positionqc==9);
    if ~isempty(ipQC)
        if Verbose==1
            fprintf('     > Data with Delayed Mode QC (DM)\n')
        end
        D.tems(ipQC,:)=NaN;
        D.sals(ipQC,:)=NaN;
        D.pres(ipQC,:)=NaN;
    end
else
    D.lats=NaN;D.lons=NaN;D.daynum=NaN;D.pres=NaN;D.sals=NaN;D.tems=NaN;D.stapar=NaN;D.project=NaN;D.cycle=NaN;D.nprof=NaN;D.nparam=NaN;D.info=NaN;
end
return
