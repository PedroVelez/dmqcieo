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

flotteur=6900772;
root_in=['/Volumes/Fisica$/Proyectos/Argo/DelayedMode/Data/float_sourceQC0/'  num2str(flotteur) '/profiles/'];
root_mat=['/Volumes/Fisica$/Proyectos/Argo/DelayedMode/Data/float_sourceQC2/'];
root_out=['/Volumes/Fisica$/Proyectos/Argo/DelayedMode/Data/float_sourceQC3/' num2str(flotteur) '/'];
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
        file_out=['D' file_in(2:length(file_in))];
    end
    copyfile([root_in file_in],[root_out file_out]);
    
    %************OPEN NETCDF FILE***********************************************
    
    ncid= netcdf.open([root_out file_out], 'WRITE');

    format_v=ncread([root_out file_out],'FORMAT_VERSION'); format_v=format_v(:)';
    date_update=ncread([root_out file_out],'DATE_UPDATE');date_update=datestr(now,'yyyymmddHHMMSS');
    
    % look at the vertical sampling scheme - DMQC on primary profile
    if str2num(format_v) >=3;
        vert_samp_scheme(:,:)=ncread([root_out file_out],'VERTICAL_SAMPLING_SCHEME');
        vert_primary=vert_samp_scheme(1:7)';
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
    
    data_stat_ind=ncread([root_out file_out],'DATA_STATE_INDICATOR');
    [l1 l2]=size(data_stat_ind);
    if l1==1;
        ds='2C  ';
        l_ds=length(ds);
        data_state_indicator=ncread([root_out file_out],'DATA_STATE_INDICATOR');
        data_state_indicator(1,1:l_ds)=ds;
        data_mode=ncread([root_out file_out],'DATA_MODE');
        data_mode(:)='D';
    else
        display('Multiprofile >2');
        ds2='2C  ';
        data_state_indicator(index_VSC,:,:)=ds2;
        data_mode(index_VSC)='D';
    end;
    
    %-----------------------------------------------------------------
    jul=ncread([root_out file_out],'JULD');
    cyc=ncread([root_out file_out],'CYCLE_NUMBER');
    lat=ncread([root_out file_out],'LATITUDE');
    pres=ncread([root_out file_out],'PRES');
    presad=ncread([root_out file_out],'PRES_ADJUSTED');
    pres_qc=ncread([root_out file_out],'PRES_QC');
    presad_qc=ncread([root_out file_out],'PRES_ADJUSTED_QC');
    presad_er=ncread([root_out file_out],'PRES_ADJUSTED_ERROR');
    psal=ncread([root_out file_out],'PSAL');
    psal_qc=ncread([root_out file_out],'PSAL_QC');
    psalad=ncread([root_out file_out],'PSAL_ADJUSTED');
    psalad_qc=ncread([root_out file_out],'PSAL_ADJUSTED_QC');
    psalad_er=ncread([root_out file_out],'PSAL_ADJUSTED_ERROR');
    temp=ncread([root_out file_out],'TEMP');
    temp_qc=ncread([root_out file_out],'TEMP_QC');
    tempad=ncread([root_out file_out],'TEMP_ADJUSTED');
    tempad_qc=ncread([root_out file_out],'TEMP_ADJUSTED_QC');
    tempad_er=ncread([root_out file_out],'TEMP_ADJUSTED_ERROR');
    
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
    pres_sp=C_FILE.Profs(i).pres;%pres_sp=pres_sp';
    presad_sp=C_FILE.Profs(i).pres_adjusted;
    presader_sp=C_FILE.Profs(i).pres_adjusted_error;
    presqc_sp=C_FILE.Profs(i).pres_qc;
    presqcad_sp=C_FILE.Profs(i).pres_adjusted_qc;
    
    display('Check difference pressure levels and values')
    pres=pres'; diff_value=pres-pres_sp;
    diff_levels=length(pres)-length(pres_sp);
    if diff_levels~=0;
        display('Difference in levels')
    elseif diff_value~=0;
        display('Difference in values')
    else
        display('Same cycle - No problem')
        display(['QC PRES nc  : ' num2str(pres_qc)']);
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
        psal_eq_sp=scom_calib_eq(:,1,ind_psal)';
        temp_eq_sp=scom_calib_eq(:,1,ind_temp)';
        pres_eq_sp=scom_calib_eq(:,1,ind_pres)';
    else
        temp_eq_sp=scom_calib_eq(:,2,ind_temp)';
        pres_eq_sp=scom_calib_eq(:,2,ind_pres)';
        psal_eq_sp=scom_calib_eq(:,2,ind_psal)';
    end;
    %- coefficient
    %temp_coef_sp=scom_calib_coef(:,2,2)';
    temp_coef_sp='none';
    if s1<4;
        psal_coef_sp=['CTL ',deblank(psal_scom_calib_coef(1,:))];
        pres_coef_sp=pres_scom_calib_coef(1,:);
    else
        psal_coef_sp=['CTL ',deblank(psal_scom_calib_coef(1,:)),deblank(psal_scom_calib_coef(4,:))];
        pres_coef_sp=pres_scom_calib_coef(2,:);
    end;
    %- comment
    temp_com_sp='No significant temperature drift detected';
    psal_com_sp='Salinity corrected using a potential conductivity (ref to 0 dbar) multiplicative adjustment term r.';
    pres_com_sp='Pressure adjusted using surface offset.';
    
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
        psal_scom_calib_dte=psal_scom_calib_dt(1,:);
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
    salad_sp=psalad(index_VSC,:);
    salqcad_sp=psalad_qc(index_VSC,:);
    salader_sp=psalad_er(index_VSC,:);
    
    is_99999=find(isnan(presad_sp));
    presad_sp(is_99999)=99999;
    presader_sp(is_99999)=99999;
    presad_sp=presad(index_VSC,:);
    presqcad_sp=presad_qc(index_VSC,:);
    presader_sp=presad_er(index_VSC,:);
    
    is_99999=find(isnan(tempad_sp));
    tempad_sp(is_99999)=99999;
    tempader_sp(is_99999)=99999;
    tempad_sp=tempad(index_VSC,:);
    tempqcad_sp=tempad_qc(index_VSC,:);
    tempader_spnc=tempad_er(index_VSC,:);
    
    %%%%%%%%%%%%%%%%%%%%%
    
    display('Change Profile QC');
    %change PROFILE_****_QC according to new user's manual
    %profile_qc are based on adjusted fields!!
    param=ncread([root_out file_out],'STATION_PARAMETERS');%param=nc{'STATION_PARAMETERS'}(index_VSC,:,:);
    param=param(index_VSC,:,:);
    for (k=1:size(param,1))
        clear J QQ QC K N PROFILE_QC name_par name_par2
        %name_par=[param(k,:) '_ADJUSTED_QC'];
        name_par=[strtrim(param(k,:)) '_ADJUSTED_QC']; %%02/05/2006 CC
        if name_par(1,1)=='_';
            display('Problem with name par  - use PSAL')
            param='PSAL';
            name_par=[param '_ADJUSTED_QC'];
        end;
        QQ=name_par(index_VSC,:);
        QC=str2num(QQ');
        display(['Parameter :' name_par])
        if isempty(QC);
            name_par=[strtrim(param(k,:)) '_QC'];
            QQ=name_par(index_VSC,:);
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
        PROFILE_QC=name_par2(index_VSC,:);
        %clear J QQ QC K N PROFILE_QC name_par name_par2
        
    end
    %********************
    %COMMENT CALIBRATION
    parameter=ncread([root_out file_out],'PARAMETER');
    station=str2num(strtrim(parameter(index_VSC,:,:))); %% CC 02/05/2006
    param=ncread([root_out file_out],'STATION_PARAMETERS');
    if(isempty(station))
        parameter(:)=param(:);    %To be confirmed
    end
    clear station
    
    % SALINITY
    pa=ncread([root_out file_out],'STATION_PARAMETERS');pa=pa(index_VSC,:,:);
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
    equation=ncread([root_out file_out],'SCIENTIFIC_CALIB_EQUATION');
    equation=equation(1:l_eq,index_VSC);
    
    old_coeff=ncread([root_out file_out],'SCIENTIFIC_CALIB_COEFFICIENT');
    old_coeff=old_coeff(:,index_VSC);   l_co=length(coeff);
    
    coeff=ncread([root_out file_out],'SCIENTIFIC_CALIB_COEFFICIENT');
    coeff=coeff(1:l_co,index_VSC);  l_com=length(comment);
    
    comment=ncread([root_out file_out],'SCIENTIFIC_CALIB_COMMENT');
    
   keyboard
   varid=netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COMMENT');
netcdf.putVar(ncid,varid,comment);
netcdf.close(ncid);

   
    
    
    comment=comment(1:l_com,index_VSC);
    if str2num(format_v)==2.2000;
        
        %calibration_date=ncread([root_out file_out],'CALIBRATION_DATE')
        %calibration_date=calibration_date(:,index_VSC)
        %   %calibration_date=datestr(now,'yyyymmddHHMMSS');
        %   %%%%%%%% NO SE PUEDE LEER ESTE PAR?METRO!%%%%%%%%%%%%%%%%%%%%%
        
        psal_scom_calib_dte=ncread([root_out file_out],'CALIBRATION_DATE');
        psal_scom_calib_dte=psal_scom_calib_dte(:,index_VSC);
    else
        psal_scom_calib_dte=ncread([root_out file_out],'SCIENTIFIC_CALIB_DATE');
        psal_scom_calib_dte=psal_scom_calib_dte(:,index_VSC);
    end;
    
    % TEMPERATURE
    
    pa=ncread([root_out file_out],'STATION_PARAMETERS'); pa=pa(index_VSC,:,:);
    
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
    scientific_calib_equation=ncread([root_out file_out],'SCIENTIFIC_CALIB_EQUATION');
    equation=scientific_calib_equation(1:l_eq,index_VSC)
    
    old_coeff=ncread([root_out file_out],'SCIENTIFIC_CALIB_COEFFICIENT');
    old_coeff=old_coeff(index_VSC,1,ind_temp,:);
    l_co=length(coeff);
    
    coeff=ncread([root_out file_out],'SCIENTIFIC_CALIB_COEFFICIENT');
    l_com=length(comment);
    
    comment=ncread([root_out file_out],'SCIENTIFIC_CALIB_COMMENT');
    
    if str2num(format_v)==2.2000;
        temp_scom_calib_dte=ncread([root_out file_out],'CALIBRATION_DATE');
    else
        temp_scom_calib_dte=ncread([root_out file_out],'SCIENTIFIC_CALIB_DATE');
    end;
    
    % PRESSURE
    pa=ncread([root_out file_out],'STATION_PARAMETERS'); pa=pa(index_VSC,:,:);
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
    
    %
    l_eq=length(equation);
    scientific_calib_equation=ncread([root_out file_out],'SCIENTIFIC_CALIB_EQUATION');
    equation=scientific_calib_equation(1:l_eq,index_VSC)
    
    old_coeff=ncread([root_out file_out],'SCIENTIFIC_CALIB_COEFFICIENT');
    old_coeff=old_coeff(index_VSC,1,ind_pres,:);
    l_co=length(coeff);
    
    coeff=ncread([root_out file_out],'SCIENTIFIC_CALIB_COEFFICIENT');
    l_com=length(comment);
    
    comment=ncread([root_out file_out],'SCIENTIFIC_CALIB_COMMENT');
    
    if str2num(format_v)==2.2000;
        temp_scom_calib_dte=ncread([root_out file_out],'CALIBRATION_DATE');
    else
        temp_scom_calib_dte=ncread([root_out file_out],'SCIENTIFIC_CALIB_DATE');
    end;
    
    %---------------------------------------------------------------------------------
    
    
    history_institution = ncread([root_out file_out],'HISTORY_INSTITUTION');
    new_hist = size(history_institution,1)+1;
    %     new_hist = size(history_institution,1);
    institution='SP';
    l_in=length(institution);
    history_institution(new_hist,1,1:l_in)=institution;
    
    %     step='ARSQ   ';
    %     history_step = ncread([root_out file_out],'HISTORY_STEP');
    %     history_step(new_hist,1,:)=step;
    
    soft='AIEO';
    l_so=length(soft);
    history_software = ncread([root_out file_out],'HISTORY_SOFTWARE');
    history_software(new_hist,1,1:l_so) = soft;
    
    soft_release='1.0';
    l_so_r=length(soft_release);
    history_software_release = ncread([root_out file_out],'HISTORY_SOFTWARE_RELEASE');
    history_software_release(new_hist,1,1:l_so_r) = soft_release;
    
    %ref='ARGOCTD2011V1';
    ref='WOD2001';
    l_ref=length(ref);
    history_reference = ncread([root_out file_out],'HISTORY_REFERENCE');
    history_reference(new_hist,1,1:l_ref) = ref;
    
    %nc{'HISTORY_DATE'}(new_hist,1,:)=datestr(now,'yyyymmddHHMMSS');
    history_date = ncread([root_out file_out],'HISTORY_DATE');
    %     history_date(new_hist,1,:) = psal_scom_calib_dte;
    
    
    action='IP';
    l_ac=length(action);
    history_action = ncread([root_out file_out],'HISTORY_ACTION');
    
    parameter='PSAL';
    l_pa=length(parameter);
    history_parameter = ncread([root_out file_out],'HISTORY_PARAMETER');
    history_parameter(new_hist,1,1:l_pa)=parameter;
    
    history_start_pres = ncread([root_out file_out],'HISTORY_START_PRES');
    history_start_pres(new_hist)=pres(1,1);
    
    history_stop_pres = ncread([root_out file_out],'HISTORY_STOP_PRES');
    history_stop_pres(new_hist)=pres(1,end);
    
    
    
    %---------------------
    %close(nc);
    %clear nc
    
end;


