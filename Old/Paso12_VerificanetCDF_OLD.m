%==================================================================================================
% This script completes information of second profile (N_PROF=2) for old PROVOR floats 
% that has been converted to format 3.1 by IFREMER. These profiles (N_PROF=2)
% only contains one data of every variable. Useless for DMQC process. This
% data has been colected by the float under "Near-surface sampling: averaged, 
% unpumped mode". New data is overwritten on Step 11 matrix.
% Alberto Gonzalez & Pedro Velez (2017)
%==================================================================================================

clear all; close all;
float=[4900558];load('/Volumes/GDOYE$/Proyectos/Argo/DelayedMode/Data/float_sourceQC2/4900558.mat');
root_in=['/Volumes/GDOYE$/Proyectos/Argo/DelayedMode/Data/float_sourceQC3/' num2str(float) '/profiles/'];

SCIENTIFIC_CALIB_COMMENT=''
for iboya=1:Profs(end).cycle_number;
  ncfile=strcat('/Volumes/GDOYE$/Proyectos/Argo/DelayedMode/Data/float_sourceQC3/4900557/profiles/D4900557_',sprintf('%0.3d',iboya),'.nc');
  ncid=netcdf.open(ncfile, 'WRITE');

  % PRESSURE
  idx1=ncread(ncfile,'PRES_ADJUSTED_QC'); idx2=ncread(ncfile,'SCIENTIFIC_CALIB_COMMENT');
  netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED_QC'),[0 size(idx1,2)-1],[size(idx1,1) 1]);
  netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED_QC'),[0 size(idx1,2)-1],[1 1],'1');
  netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COMMENT'),[0 0 0 size(idx2,4)-1],[63 1 1 1],'No QC was performed. Near-surface sampling: averaged, unpumped.');

  % TEMPERATURE
  netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED_QC'),[0 size(idx1,2)-1],[size(idx1,1) 1]);
  netcdf.putVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED_QC'),[0 size(idx1,2)-1],[1 1],'1');
  netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COMMENT'),[0 1 0 size(idx2,4)-1],[63 1 1 1],'No QC was performed. Near-surface sampling: averaged, unpumped.');

  % SALINITY
  netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED_QC'),[0 size(idx1,2)-1],[size(idx1,1) 1]);
  netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED_QC'),[0 size(idx1,2)-1],[1 1],'4');
  netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COMMENT'),[0 2 0 size(idx2,4)-1],[255 1 1 1]);
  netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COMMENT'),[0 2 0 size(idx2,4)-1],[88 1 1 1],'No QC was performed. Bad data, not adjustable. Near-surface sampling: averaged,unpumped.');
 keyboard
  clear idx1 idx2;
end