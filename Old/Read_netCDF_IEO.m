close all
clear all

disp('%%%%%%%')
disp('Delayed-Mode NetCDF files')

flotteur=6900772;
root_in=['/Volumes/GDOYE$/Proyectos/Argo/DelayedMode/Data/float_sourceQC0/'  num2str(flotteur) '/profiles/'];
root_mat=['/Volumes/GDOYE$/Proyectos/Argo/DelayedMode/Data/float_sourceQC2/'];
root_out=['/Volumes/GDOYE$/Proyectos/Argo/DelayedMode/Data/float_sourceQC3/' num2str(flotteur) '/profiles/'];
rep=dir([root_in '*nc']);
ejemplo='/Volumes/GDOYE$/Proyectos/Argo/DelayedMode/Data/float_sourceQC0/6900772/profiles/R6900772_001.nc'
C_FILE=load([root_mat  num2str(flotteur) '.mat']);

for i=1:length(rep)
    file_in=rep(i).name;
    display(['Name of the file : ' file_in]);
    %open R_file (or D_file) and check cycle number
    ll=length(num2str(flotteur));
    if(ll==7);
        if length(file_in)==16;
            cycle=str2num(file_in(length(file_in)-6:length(file_in)-4));
        else
            cycle=str2num(file_in(length(file_in)-5:length(file_in)-3));
        end;
    elseif(ll==5);
        if length(file_in)==14;
            cycle=str2num(file_in(length(file_in)-6:length(file_in)-4));
        else
            cycle=str2num(file_in(length(file_in)-5:length(file_in)-3));
        end;
    end;
    display(['Cycle number : ' num2str(cycle)]);
    
  %*************FILE D or R**************************************************
    %copy R_file in my directory and change the name into D_file (if necessary)
    %copyfile([root_in file_in],[root_out file_in]);
    file_out=file_in;
    
    if file_in(1)=='R';
        file_out=['D' file_in(2:length(file_in))];
    end
    copyfile([root_in file_in],[root_out file_out]); 
    
  %************OPEN NETCDF FILE**********************************************
    
    ncid= netcdf.open([root_out file_out], 'WRITE');

    format_v=ncread([root_out file_out],'FORMAT_VERSION'); format_v=format_v(:)';
    date_update=ncread([root_out file_out],'DATE_UPDATE');date_update=datestr(now,'yyyymmddHHMMSS');
    ncwrite([root_out file_out],'DATE_UPDATE',date_update);
    
    
    
    
    
    
