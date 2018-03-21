function [D]=ReadArgoMetaFile(file)
ncid=netcdf.open(file,'nc_nowrite');
D=struct('PLATFORM_NUMBER',{{}});
D.PTT=strtrim(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PTT'))'); %Transmission identifier
try
    D.PLATFORM_MODEL=strtrim(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PLATFORM_MODEL')))';
catch ME
    D.PLATFORM_MODEL=strtrim(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PLATFORM_TYPE')))';
end
D.PLATFORM_NUMBER=strtrim(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PLATFORM_NUMBER'))');
D.PLATFORM_MAKER=strtrim(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PLATFORM_MAKER'))');
try
    D.DEPLOY_MISSION=strtrim(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DEPLOY_MISSION'))');
catch ME
    D.DEPLOY_MISSION='';
end
try
    D.INST_REFERENCE=strtrim(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'FLOAT_SERIAL_NO'))');
catch ME
    D.INST_REFERENCE='';
end
D.TRANS_SYSTEM=strtrim(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TRANS_SYSTEM'))');
daynumr=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'START_DATE'))';
D.START_DATE=datenum(str2double(daynumr(1:4)),str2double(daynumr(5:6)),str2double(daynumr(7:8)));
D.LAUNCH_LATITUDE=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'LAUNCH_LATITUDE'));
D.LAUNCH_LONGITUDE=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'LAUNCH_LONGITUDE'));
D.DATA_CENTRE=strtrim(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DATA_CENTRE'))');
D.PROJECT_NAME=strtrim(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PROJECT_NAME'))');


D.WMO_INST_TYPE=strtrim(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'WMO_INST_TYPE'))');
try
    D.PARKING_PRESSURE=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PARKING_PRESSURE'));
catch ME
    D.PARKING_PRESSURE='';
end

try
    D.DEEPEST_PRESSURE=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DEEPEST_PRESSURE'));
catch ME
    D.DEEPEST_PRESSURE='';
end
D.SENSOR=strtrim(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SENSOR'))');
D.SENSOR_MAKER=strtrim(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SENSOR_MAKER'))');
D.SENSOR_MODEL=strtrim(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SENSOR_MODEL'))');
D.SENSOR_SERIAL_NO=strtrim(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SENSOR_SERIAL_NO'))');

D.END_MISSION_STATUS=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'END_MISSION_STATUS'))';
daynumr=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'END_MISSION_DATE'))';
D.END_MISSION_DATE=datenum(str2double(daynumr(1:4)),str2double(daynumr(5:6)),str2double(daynumr(7:8)));
return
