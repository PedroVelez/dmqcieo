%===================================================================================================
% Creation of delayed-mode netcdf files - ARGO FLOATS
% file_nc_dmqc_spain
%
% Input:  flotteur = float wmo number
%         M_FILE = matlab file from statistical method
% Output: 1 DM-file per cycle
%
% February 2016
%==================================================================================================
close all
clear all

disp('%%%%%%%')
disp('Delayed-Mode NetCDF files')

flotteur=input('Number of Float :  ');
root_in=['...'  num2str(flotteur) '/profiles/'];
root_mat=['.../MAT/'];
root_out=['.../DMQC/' num2str(flotteur) '/'];
rep=dir([root_in '*nc']);

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
file_out=['D' file_in(2:length(file_in))];end   
copyfile([root_in file_in],[root_out file_out]);

%************OPEN NETCDF FILE***********************************************

nc = netcdf([root_out file_out],'write');

format_v=nc{'FORMAT_VERSION'}(:)';
nc{'DATE_UPDATE'}(:)=datestr(now,'yyyymmddHHMMSS');

 % look at the vertical sampling scheme - DMQC on primary profile 
   if str2num(format_v) >=3;
  vert_samp_scheme=nc{'VERTICAL_SAMPLING_SCHEME'}(:,:);
  vert_primary=vert_samp_scheme(1:7);
  [av bv]=size(vert_primary);
    if av>1;
    index_VSC=find(vert_primary=='Primary');
    else;
    index_VSC=1;
    end;
  else;
  index_VSC=1;
  end;

  if str2num(format_v) >=3;
  [a b]=size(vert_samp_scheme);
   n_prof=a;
  else 
   n_prof=1;
  end;

  data_stat_ind=nc{'DATA_STATE_INDICATOR'}(:,:);
  [l1 l2]=size(data_stat_ind);
  if l1==1;
  ds='2C  ';
  l_ds=length(ds);
  nc{'DATA_STATE_INDICATOR'}(1,1:l_ds)=ds;
  nc{'DATA_MODE'}(:)='D';  
  else
  display('Multiprofile >2'); 
  ds2='2C  ';
  nc{'DATA_STATE_INDICATOR'}(index_VSC,:,:)=ds2;
  nc{'DATA_MODE'}(index_VSC)='D';
  end;

%-----------------------------------------------------------------
jul=nc{'JULD'}(:);
cyc=nc{'CYCLE_NUMBER'}(:);
lat=nc{'LATITUDE'}(:);
pres=nc{'PRES'}(:,:);
presad=nc{'PRES_ADJUSTED'}(:,:);
pres_qc=nc{'PRES_QC'}(:,:);
presad_qc=nc{'PRES_ADJUSTED_QC'}(:,:);
presad_er=nc{'PRES_ADJUSTED_ERROR'}(:,:);
psal=nc{'PSAL'}(:,:);
psal_qc=nc{'PSAL_QC'}(:,:);
psalad=nc{'PSAL_ADJUSTED'}(:,:);
psalad_qc=nc{'PSAL_ADJUSTED_QC'}(:,:);
psalad_er=nc{'PSAL_ADJUSTED_ERROR'}(:,:);
temp=nc{'TEMP'}(:,:);
temp_qc=nc{'TEMP_QC'}(:,:);
tempad=nc{'TEMP_ADJUSTED'}(:,:);
tempad_qc=nc{'TEMP_ADJUSTED_QC'}(:,:);
tempad_er=nc{'TEMP_ADJUSTED_ERROR'}(:,:);

%----------------------------------------------------------------------
% Check MAT File

lat_sp=C_FILE.Profs(i).latitude;
lon_sp=C_FILE.Profs(i).longitude;
jday_sp=C_FILE.Profs(i).juld;
cycle_sp=C_FILE.Profs(i).cycle_number;

display(['Lat nc :' num2str(lat(index_VSC,:)) ' - Lat mat :' num2str(lat_sp)]);
display(['Jul nc :' num2str(jul(index_VSC,:)) ' - Jul mat :' num2str(jday_sp)]);

% Chargement info MAT File
% PRESSURE
pres_sp=C_FILE.Profs(i).pres;
presad_sp=C_FILE.Profs(i).pres_adjusted;
presader_sp=C_FILE.Profs(i).pres_adjusted_error;
presqc_sp=C_FILE.Profs(i).pres_qc;
presqcad_sp=C_FILE.Profs(i).pres_adjusted_qc;

display('Check difference pressure levels and values')
diff_value=pres-pres_sp;
diff_levels=length(pres)-length(pres_sp);
if diff_levels~=0;
display('Difference in levels')
elseif diff_value~=0;
display('Difference in values')
else
display('Same cycle - No problem')
display(['QC PRES nc  : ' num2str(pres_qc)]);
display(['QC PRES mat : ' num2str(presqc_sp)]);
end;

% TEMPERATURE
temp_sp=C_FILE.Profs(i).temp;
tempad_sp=C_FILE.Profs(i).temp_adjusted;
tempader_sp=C_FILE.Profs(i).temp_adjusted_error;
tempqc_sp=C_FILE.Profs(i).temp_qc;
tempqcad_sp=C_FILE.Profs(i).temp_adjusted_qc;

% SALINITY
sal_sp=C_FILE.Profs(i).psal;
salad_sp=C_FILE.Profs(i).psal_adjusted;
salader_sp=C_FILE.Profs(i).psal_adjusted_error;
salqc_sp=C_FILE.Profs(i).psal_qc;
salqcad_sp=C_FILE.Profs(i).psal_adjusted_qc;


station_parameters=deblank(C_FILE.Profs(1).station_parameters');
station_parameters=strtrim(station_parameters);
[m,n]=size(station_parameters);
i_par=zeros(1,m);
  for i=1:m
    if(strcmp(station_parameters(i,:), 'PRES')==1)
      i_par(i)=1;
    end
  end
  ind_pres=find(i_par==1); 
  clear i_par
  for i=1:m
    if(strcmp(station_parameters(i,:), 'PSAL')==1)
      i_par(i)=1;
    end
  end
 ind_psal=find(i_par==1); 
 clear i_par
  for i=1:m
    if(strcmp(station_parameters(i,:), 'TEMP')==1)
      i_par(i)=1;
    end
  end
 ind_temp=find(i_par==1); 
 clear i_par


% SCIENTIFIC COMMENT 256x4x3 
scom_calib_eq=C_FILE.Profs(i).scientific_calib_equation;
pres_scom_calib_eq=scom_calib_eq(:,:,ind_pres)';
temp_scom_calib_eq=scom_calib_eq(:,:,ind_temp)';
psal_scom_calib_eq=scom_calib_eq(:,:,ind_psal)';
scom_calib_coef=C_FILE.Profs(i).scientific_calib_coefficient;
pres_scom_calib_coef=scom_calib_coef(:,:,ind_pres)';
temp_scom_calib_coef=scom_calib_coef(:,:,ind_temp)';
psal_scom_calib_coef=scom_calib_coef(:,:,ind_psal)';
scom_calib_com=C_FILE.Profs(i).scientific_calib_comment;
pres_scom_calib_com=scom_calib_com(:,:,ind_pres)';
temp_scom_calib_com=scom_calib_com(:,:,ind_temp)';
psal_scom_calib_com=scom_calib_com(:,:,ind_psal)';
scom_calib_dt=C_FILE.Profs(i).scientific_calib_date;
pres_scom_calib_dt=scom_calib_dt(:,:,ind_pres)';
temp_scom_calib_dt=scom_calib_dt(:,:,ind_temp)';
psal_scom_calib_dt=scom_calib_dt(:,:,ind_psal)';

point='. ';
%- equation
[s1 s2]=size(psal_scom_calib_eq);
if s1<4;
psal_eq_sp=[deblank(psal_scom_calib_eq(1,:)),point,deblank(psal_scom_calib_eq(2,:))];
temp_eq_sp=scom_calib_eq(:,1,ind_temp)';
pres_eq_sp=scom_calib_eq(:,1,ind_pres)';
else
temp_eq_sp=scom_calib_eq(:,2,ind_temp)';
pres_eq_sp=scom_calib_eq(:,2,ind_pres)';
psal_eq_sp=[deblank(psal_scom_calib_eq(2,:)),point,deblank(psal_scom_calib_eq(3,:)),point,deblank(psal_scom_calib_eq(4,:))];
end;
%- coefficient
%temp_coef_sp=scom_calib_coef(:,2,2)';
temp_coef_sp='none';
if s1<4;
psal_coef_sp=['CTL ',deblank(psal_scom_calib_coef(2,:))];
pres_coef_sp=pres_scom_calib_coef(1,:);
else
psal_coef_sp=['CTL ',deblank(psal_scom_calib_coef(3,:)),deblank(psal_scom_calib_coef(4,:))];
pres_coef_sp=pres_scom_calib_coef(2,:);
end;
%- comment
%temp_com_sp='No significant temperature drift detected';
%psal_com_sp='Salinity corrected using a potential conductivity (ref to 0 dbar) multiplicative adjustment term r.';
%pres_com_sp='Pressure adjusted using surface offset.';

display(['Size psal scientific calib : ' num2str(s1)]);
if s1<4;
psal_com_sp=psal_scom_calib_com(1,:);
temp_com_sp=temp_scom_calib_com(1,:);
pres_com_sp=pres_scom_calib_com(1,:);
else
psal_com_sp=psal_scom_calib_com(4,:);
temp_com_sp=temp_scom_calib_com(2,:);
pres_com_sp=pres_scom_calib_com(2,:);
end;

%-date calibration
if s1<4;
psal_scom_calib_dte=psal_scom_calib_dt(2,:);
temp_scom_calib_dte=temp_scom_calib_dt(1,:);
pres_scom_calib_dte=pres_scom_calib_dt(1,:);
else
psal_scom_calib_dte=psal_scom_calib_dt(4,:);
temp_scom_calib_dte=temp_scom_calib_dt(2,:);
pres_scom_calib_dte=pres_scom_calib_dt(2,:);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---------------------------------------------------


is_99999=find(isnan(salad_sp));
salad_sp(is_99999)=99999;
salader_sp(is_99999)=99999;
nc{'PSAL_ADJUSTED'}(index_VSC,:)=salad_sp;
nc{'PSAL_ADJUSTED_QC'}(index_VSC,:)=salqcad_sp;
nc{'PSAL_ADJUSTED_ERROR'}(index_VSC,:)=salader_sp; 

is_99999=find(isnan(presad_sp));
presad_sp(is_99999)=99999;
presader_sp(is_99999)=99999;
nc{'PRES_ADJUSTED'}(index_VSC,:)=presad_sp;
nc{'PRES_ADJUSTED_QC'}(index_VSC,:)=presqcad_sp;
nc{'PRES_ADJUSTED_ERROR'}(index_VSC,:)=presader_sp; 

is_99999=find(isnan(tempad_sp));
tempad_sp(is_99999)=99999;
tempader_sp(is_99999)=99999;
nc{'TEMP_ADJUSTED'}(index_VSC,:)=tempad_sp;
nc{'TEMP_ADJUSTED_QC'}(index_VSC,:)=tempqcad_sp;
nc{'TEMP_ADJUSTED_ERROR'}(index_VSC,:)=tempader_sp; 

%%%%%%%%%%%%%%%%%%%%%
 
 display('Change Profile QC');
  %change PROFILE_****_QC according to new user's manual
  %profile_qc are based on adjusted fields!!
  param=nc{'STATION_PARAMETERS'}(index_VSC,:,:);
 
 for(k=1:size(param,1))
    clear J QQ QC K N PROFILE_QC name_par name_par2
    %name_par=[param(k,:) '_ADJUSTED_QC'];
    name_par=[strtrim(param(k,:)) '_ADJUSTED_QC']; %%02/05/2006 CC
         if name_par(1,1)=='_';
         display('Problem with name par  - use PSAL')
         param='PSAL';
         name_par=[param '_ADJUSTED_QC'];
         end;
    QQ=nc{name_par}(index_VSC,:);
    QC=str2num(QQ');
    display(['Parameter :' name_par])
         if isempty(QC);
         name_par=[strtrim(param(k,:)) '_QC'];
         QQ=nc{name_par}(index_VSC,:);
         QC=str2num(QQ');
         display('Using QC of the raw parameter');
         end;
    J=find(QC~=9);
    QC=QC(J);
    K=find(QC==1 | QC==2 |QC==5 |QC==8);
    M=find(QC==3); %CC
    N=100*length(K)/length(QC);
    N1=100*length(M)/length(QC);%CC
   if(N==100)
     PROFILE_QC='A';
	%PROFILE_QC='1';
    elseif(N>=75 & N<100)
      PROFILE_QC='B';
	%PROFILE_QC='1';
    elseif(N>=50 & N<75)
      PROFILE_QC='C';
	%PROFILE_QC='2';
    elseif(N>=25 & N<50)
      PROFILE_QC='D';
	%PROFILE_QC='3';
    elseif(N>0 & N<25)
      PROFILE_QC='E';
	%PROFILE_QC='4';
    elseif(N==0 | N1>0) %CC
      PROFILE_QC='F'; %CC
	%PROFILE_QC='3'; %CC
    elseif(N==0 | N1==0) ;CC
   %elseif(N==0);
      PROFILE_QC='F';
	%PROFILE_QC='4';
   end

    name_par2=['PROFILE_' strtrim(param(k,:)) '_QC'];
    nc{name_par2}(index_VSC,:)=PROFILE_QC;
    %clear J QQ QC K N PROFILE_QC name_par name_par2

  end % for
%********************
% COMMENT CALIBRATION
  station=str2num(strtrim(nc{'PARAMETER'}(index_VSC,:,:))); %% CC 02/05/2006
  if(isempty(station))
    nc{'PARAMETER'}(:)=nc{'STATION_PARAMETERS'}(:);    %To be confirmed
  end
  clear station

% SALINITY
  pa=nc{'STATION_PARAMETERS'}(index_VSC,:,:);
  pa=strtrim(pa); % 02/05/2006 CC
  [m,n]=size(pa); %m should equal N_PARAM
  i_pa=zeros(1,m);
  for i=1:m
    if(strcmp(pa(i,:), 'PSAL')==1)
      i_pa(i)=1;
    end
  end
  ind_psal=find(i_pa==1); 
  clear i_pa pa 

equation=psal_eq_sp;
coeff=psal_coef_sp;
comment=psal_com_sp;


  l_eq=length(equation);
  nc{'SCIENTIFIC_CALIB_EQUATION'}(index_VSC,1,ind_psal,1:l_eq)=equation;
  old_coeff=nc{'SCIENTIFIC_CALIB_COEFFICIENT'}(index_VSC,1,ind_psal,:);
  l_co=length(coeff);
  nc{'SCIENTIFIC_CALIB_COEFFICIENT'}(index_VSC,1,ind_psal,1:l_co)=coeff;
  l_com=length(comment);
  nc{'SCIENTIFIC_CALIB_COMMENT'}(index_VSC,1,ind_psal,1:l_com)=comment;
  if str2num(format_v)==2.2000;
  %nc{'CALIBRATION_DATE'}(index_VSC,1,ind_psal,:)=datestr(now,'yyyymmddHHMMSS');
   nc{'CALIBRATION_DATE'}(index_VSC,1,ind_psal,:)=psal_scom_calib_dte;
  else
  %nc{'SCIENTIFIC_CALIB_DATE'}(index_VSC,1,ind_psal,:)=datestr(now,'yyyymmddHHMMSS');
   nc{'SCIENTIFIC_CALIB_DATE'}(index_VSC,1,ind_psal,:)=psal_scom_calib_dte;
  end;

% TEMPERATURE
  pa=nc{'STATION_PARAMETERS'}(index_VSC,:,:);
  pa=strtrim(pa); % 02/05/2006 CC
  [m,n]=size(pa); %m should equal N_PARAM
  i_pa=zeros(1,m);
  for i=1:m
    if(strcmp(pa(i,:), 'TEMP')==1)
      i_pa(i)=1;
    end
  end
  ind_temp=find(i_pa==1); 
  clear i_pa pa 

equation=temp_eq_sp;
coeff=temp_coef_sp;
comment=temp_com_sp;

  l_eq=length(equation);
  nc{'SCIENTIFIC_CALIB_EQUATION'}(index_VSC,1,ind_temp,1:l_eq)=equation;
  old_coeff=nc{'SCIENTIFIC_CALIB_COEFFICIENT'}(index_VSC,1,ind_temp,:);
  l_co=length(coeff);
  nc{'SCIENTIFIC_CALIB_COEFFICIENT'}(index_VSC,1,ind_temp,1:l_co)=coeff;
  l_com=length(comment);
  nc{'SCIENTIFIC_CALIB_COMMENT'}(index_VSC,1,ind_temp,1:l_com)=comment;
  if str2num(format_v)==2.2000;
  %nc{'CALIBRATION_DATE'}(index_VSC,1,ind_temp,:)=datestr(now,'yyyymmddHHMMSS');
   nc{'CALIBRATION_DATE'}(index_VSC,1,ind_temp,:)=temp_scom_calib_dte;
  else
  %nc{'SCIENTIFIC_CALIB_DATE'}(index_VSC,1,ind_temp,:)=datestr(now,'yyyymmddHHMMSS');
  nc{'SCIENTIFIC_CALIB_DATE'}(index_VSC,1,ind_temp,:)=temp_scom_calib_dte;
  end;

% PRESSURE
  pa=nc{'STATION_PARAMETERS'}(index_VSC,:,:);
  pa=strtrim(pa); % 02/05/2006 CC
  [m,n]=size(pa); %m should equal N_PARAM
  i_pa=zeros(1,m);
  for i=1:m
    if(strcmp(pa(i,:), 'PRES')==1)
      i_pa(i)=1;
    end
  end
  ind_pres=find(i_pa==1); 
  clear i_pa pa 

equation=pres_eq_sp;
coeff=pres_coef_sp;
comment=pres_com_sp;


  l_eq=length(equation);
  nc{'SCIENTIFIC_CALIB_EQUATION'}(index_VSC,1,ind_pres,1:l_eq)=equation;
  old_coeff=nc{'SCIENTIFIC_CALIB_COEFFICIENT'}(index_VSC,1,ind_pres,:);
  l_co=length(coeff);
  nc{'SCIENTIFIC_CALIB_COEFFICIENT'}(index_VSC,1,ind_pres,1:l_co)=coeff;
  l_com=length(comment);
  nc{'SCIENTIFIC_CALIB_COMMENT'}(index_VSC,1,ind_pres,1:l_com)=comment;
  if str2num(format_v)==2.2000;
  %nc{'CALIBRATION_DATE'}(index_VSC,1,ind_pres,:)=datestr(now,'yyyymmddHHMMSS');
  nc{'CALIBRATION_DATE'}(index_VSC,1,ind_pres,:)=pres_scom_calib_dte;
  else
  %nc{'SCIENTIFIC_CALIB_DATE'}(index_VSC,1,ind_pres,:)=datestr(now,'yyyymmddHHMMSS');
  nc{'SCIENTIFIC_CALIB_DATE'}(index_VSC,1,ind_pres,:)=pres_scom_calib_dte;
  end;

%---------------------------------------------------------------------------------

  new_hist=size(nc{'HISTORY_INSTITUTION'},1)+1;
  institution='SP';
  l_in=length(institution);
  nc{'HISTORY_INSTITUTION'}(new_hist,1,1:l_in)=institution;
  step='ARSQ';
  nc{'HISTORY_STEP'}(new_hist,1,:)=step;
  soft='AIEO';
  l_so=length(soft);
  nc{'HISTORY_SOFTWARE'}(new_hist,1,1:l_so)=soft;
  soft_release='1.0';
  l_so_r=length(soft_release);
  nc{'HISTORY_SOFTWARE_RELEASE'}(new_hist,1,1:l_so_r)=soft_release;  
  %ref='ARGOCTD2011V1';
  ref='WOD2001';
  l_ref=length(ref);
  nc{'HISTORY_REFERENCE'}(new_hist,1,1:l_ref)=ref;
  %nc{'HISTORY_DATE'}(new_hist,1,:)=datestr(now,'yyyymmddHHMMSS');
  nc{'HISTORY_DATE'}(new_hist,1,:)=psal_scom_calib_dte;
  action='IP';
  l_ac=length(action);
  nc{'HISTORY_ACTION'}(new_hist,1,1:l_ac)=action;
  parameter='PSAL';
  l_pa=length(parameter);
  nc{'HISTORY_PARAMETER'}(new_hist,1,1:l_pa)=parameter;
  nc{'HISTORY_START_PRES'}(new_hist)=nc{'PRES'}(1,1);
  nc{'HISTORY_STOP_PRES'}(new_hist)=nc{'PRES'}(1,end);

  


%---------------------
close(nc);
clear nc

end;


