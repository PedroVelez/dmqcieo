function D=ReadArgoTrayectoryFile(file)
ncid=netcdf.open(file,'nc_nowrite');
daynumr=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'REFERENCE_DATE_TIME'))';
timeref=datenum(str2double(daynumr(1:4)),str2double(daynumr(5:6)),str2double(daynumr(7:8)));

daynum       =netcdf.getVar(ncid,netcdf.inqVarID(ncid,'JULD'))+timeref;
lat        =netcdf.getVar(ncid,netcdf.inqVarID(ncid,'LATITUDE'));
lon        =netcdf.getVar(ncid,netcdf.inqVarID(ncid,'LONGITUDE'));

pres        =netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES'));
temp        =netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP'));
psal        =netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL'));

        info.JULD_TRANSMISSION_START=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'JULD_TRANSMISSION_START'));
info.JULD_DESCENT_START=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'JULD_DESCENT_START'));
info.JULD_PARK_START=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'JULD_PARK_START'));
info.JULD_PARK_END=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'JULD_PARK_START'));

info.positionqc =netcdf.getVar(ncid,netcdf.inqVarID(ncid,'POSITION_QC'));
info.positionacc =netcdf.getVar(ncid,netcdf.inqVarID(ncid,'POSITION_ACCURACY'));
info.cycle_number=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'CYCLE_NUMBER'));
info.data_mode=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATA_MODE'));
info.data_centre=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATA_CENTRE'));
info.wmo_inst_type=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'WMO_INST_TYPE'));
% trapar=nc_varget(file,'TRAJECTORY_PARAMETERS');
% if exist(trapar,1)==1
%     if size(trapar,1)==3
%         pre        =nc_varget(file,'PRES');
%         sal        =nc_varget(file,'PSAL');
%         tem        =nc_varget(file,'TEMP');
%     else
%     end
% else
%     pre=lon.*nan;
%     sal=lon.*nan;
%     tem=lon.*nan;
% end
%change absent data by nan

lat(lat==99999 | lat==-99999)=nan;
lon(lon==99999 | lon==-99999)=nan;
% tem(tem==99999 | tem==-99999)=nan;
% sal(sal==99999 | sal==-99999)=nan;
% pre(tem==99999 | pre==-99999)=nan;
%I take out those profiles with bad position
ipqc=find(info.positionqc==0|info.positionqc==3|info.positionqc==4|info.positionqc==9);
if ~isempty(ipqc)
    lat(ipqc)=nan;
    lon(ipqc)=nan;
end
D.julds=daynum;
D.lat=lat;
D.lon=lon;
D.info=info;
return
