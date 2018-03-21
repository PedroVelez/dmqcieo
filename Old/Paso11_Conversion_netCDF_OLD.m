%===================================================================================================
% Creation of delayed-mode netcdf files - ARGO FLOATS
% file_nc_dmqc_spain
%
% Input:  flotteur = float wmo number
%         M_FILE = matlab file from statistical method
% Output: 1 DM-file per cycle
%
% February 2016
% Pedro Velez & Alberto Gonzalez (2016)
%==================================================================================================
Limpia

floats=[4900557];

for iboya=1:length(floats)
    
    float=floats(iboya);
    root_in=['/Volumes/GDOYE$/Proyectos/Argo/DelayedMode/Data/float_sourceQC0/'  num2str(float) '/profiles/'];
    root_mat=['/Volumes/GDOYE$/Proyectos/Argo/DelayedMode/Data/float_sourceQC2/'];
    root_out=['/Volumes/GDOYE$/Proyectos/Argo/DelayedMode/Data/float_sourceQC3/' num2str(float) '/profiles/'];
    rep=dir([root_in '*nc']);
    fprintf('     >>>>> Delayed-Mode NetCDF files for %d \n',float);
    
    C_FILE=load([root_mat  num2str(float) '.mat']);

    for i=1:length(rep); 
        file_in=rep(i).name;
        display(['Name of the file : ' file_in]);
        %open R_file (or D_file) and check cycle number
        ll=length(num2str(float));
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
        %ncid= netcdf.open([root_out file_out], 'WRITE');
        %VARIABLES:
        %FORMAT_VERSION
        format_v=ncread([root_out file_out],'FORMAT_VERSION'); format_v=format_v(:)';
        ncwrite([root_out file_out],'FORMAT_VERSION',format_v);
        
        % DATE_UPDATE
        date_update=ncread([root_out file_out],'DATE_UPDATE');date_update=datestr(now,'yyyymmddHHMMSS');
        ncwrite([root_out file_out],'DATE_UPDATE',date_update);
        
        % VERTICAL_SAMPLING_SCHEME
        % look at the vertical sampling scheme - DMQC on primary profile
        keyboard
        if str2num(format_v) >=3;
            vert_samp_scheme(:,:)=ncread([root_in file_in],'VERTICAL_SAMPLING_SCHEME');
            ncwrite([root_out file_out],'VERTICAL_SAMPLING_SCHEME',vert_samp_scheme);
            vert_primary=vert_samp_scheme(1:7)';
            [av bv]=size(vert_primary');
            if av>1;
                index_VSC=find(vert_primary=='Primary');
            else
                index_VSC=1;
            end;
        else
            index_VSC=1;
        end;
        
        if str2num(format_v) >=3;
            [a b]=size(vert_samp_scheme);
            n_prof=a;
        else
            n_prof=1;
        end;
        ncwrite([root_out file_out],'VERTICAL_SAMPLING_SCHEME',vert_samp_scheme);
        % DATA_STATE_INDICATOR
        data_stat_ind=ncread([root_out file_out],'DATA_STATE_INDICATOR');
        [l1 l2]=size(data_stat_ind);
        if l1==4;
            ds='2C  ';
            l_ds=length(ds);
            data_state_indicator=ncread([root_out file_out],'DATA_STATE_INDICATOR');
            data_state_indicator(1:l_ds,1)=ds';%data_state_indicator=ds;
            ncwrite([root_out file_out],'DATA_STATE_INDICATOR',ds');
            
            % DATA_MODE
            data_mode=ncread([root_out file_out],'DATA_MODE');
            data_mode(:)='D'; ncwrite([root_out file_out],'DATA_MODE',data_mode);
        else
            display('Multiprofile >2');
            ds2='2C  ';
            data_state_indicator(index_VSC,:,:)=ds2;
            data_mode(index_VSC)='D';
            data_mode(:)='D'; ncwrite([root_out file_out],'DATA_MODE',data_mode);
        end;
        
        %% Check MAT File
        lat_sp=C_FILE.Profs(i).latitude; ncwrite([root_out file_out],'LATITUDE',lat_sp); %LATITUDE
        lon_sp=C_FILE.Profs(i).longitude; ncwrite([root_out file_out],'LONGITUDE',lon_sp); %LONGITUDE
        jday_sp=C_FILE.Profs(i).juld; ncwrite([root_out file_out],'JULD',jday_sp); %JULD
        cycle_sp=C_FILE.Profs(i).cycle_number; ncwrite([root_out file_out],'CYCLE_NUMBER',cycle_sp); %CYCLE_NUMBER
        
        %display(['Lat nc :' num2str(lat(index_VSC,:)) ' - Lat mat :' num2str(lat_sp)]);
        %display(['Jul nc :' num2str(jul(index_VSC,:)) ' - Jul mat :' num2str(jday_sp)]);
        
        % PROFILE_PRES_QC
        profile_pres_qc_sp=C_FILE.Profs(i).profile_pres_qc;
        ncwrite([root_out file_out],'PROFILE_PRES_QC',profile_pres_qc_sp);
        
        % PROFILE_TEMP_QC
        profile_temp_qc_sp=C_FILE.Profs(i).profile_temp_qc;
        ncwrite([root_out file_out],'PROFILE_TEMP_QC',profile_pres_qc_sp);
        
        % PROFILE_PSAL_QC
        profile_psal_qc_sp=C_FILE.Profs(i).profile_psal_qc;
        ncwrite([root_out file_out],'PROFILE_PSAL_QC',profile_psal_qc_sp);
        
        % Chargement info MAT File
        % PRESSURE
        
        pres_sp=C_FILE.Profs(i).pres; pres_sp=pres_sp';
        ncwrite([root_out file_out],'PRES',pres_sp); %PRES
        presad_sp=C_FILE.Profs(i).pres_adjusted;presad_sp=presad_sp';
        ncwrite([root_out file_out],'PRES_ADJUSTED',presad_sp); %PRES_ADJUSTED
        presader_sp=C_FILE.Profs(i).pres_adjusted_error;presader_sp=presader_sp';
        ncwrite([root_out file_out],'PRES_ADJUSTED_ERROR',presader_sp); %PRES_ADJUSTED_ERROR
        presqc_sp=C_FILE.Profs(i).pres_qc; presqc_sp=presqc_sp';
        ncwrite([root_out file_out],'PRES_QC',presqc_sp); %PRES_QC
        presqcad_sp=C_FILE.Profs(i).pres_adjusted_qc;presqcad_sp=presqcad_sp';
        ncwrite([root_out file_out],'PRES_ADJUSTED_QC',presqcad_sp); %PRES_ADJUSTED_QC
        display('Check difference pressure levels and values')
        
        % TEMPERATURE
        temp_sp=C_FILE.Profs(i).temp; temp_sp=temp_sp';
        ncwrite([root_out file_out],'TEMP',temp_sp); %TEMP
        tempad_sp=C_FILE.Profs(i).temp_adjusted;tempad_sp=tempad_sp';
        ncwrite([root_out file_out],'TEMP_ADJUSTED',tempad_sp); %TEMP_ADJUSTED
        tempader_sp=C_FILE.Profs(i).temp_adjusted_error;tempader_sp=tempader_sp';
        ncwrite([root_out file_out],'TEMP_ADJUSTED_ERROR',tempader_sp); %TEMP_ADJUSTED_ERROR
        tempqc_sp=C_FILE.Profs(i).temp_qc; tempqc_sp=tempqc_sp';
        ncwrite([root_out file_out],'TEMP_QC',tempqc_sp); %TEMP_QC
        tempqcad_sp=C_FILE.Profs(i).temp_adjusted_qc;tempqcad_sp=tempqcad_sp';
        ncwrite([root_out file_out],'TEMP_ADJUSTED_QC',tempqcad_sp); %TEMP_ADJUSTED_QC
        
        % SALINITY
        psal_sp=C_FILE.Profs(i).psal; psal_sp=psal_sp';
        ncwrite([root_out file_out],'PSAL',psal_sp); %PSAL
        salad_sp=C_FILE.Profs(i).psal_adjusted;salad_sp=salad_sp';
        ncwrite([root_out file_out],'PSAL_ADJUSTED',salad_sp); %PSAL_ADJUSTED
        salader_sp=C_FILE.Profs(i).psal_adjusted_error;salader_sp=salader_sp';
        ncwrite([root_out file_out],'PSAL_ADJUSTED_ERROR',salader_sp); %PSAL_ADJUSTED_ERROR
        salqc_sp=C_FILE.Profs(i).psal_qc; salqc_sp=salqc_sp';
        
        ncwrite([root_out file_out],'PSAL_QC',salqc_sp); %PSAL_QC
        salqcad_sp=C_FILE.Profs(i).psal_adjusted_qc;salqcad_sp=salqcad_sp';
        ncwrite([root_out file_out],'PSAL_ADJUSTED_QC',salqcad_sp); %PSAL_ADJUSTED_QC
        
        % SCIENTIFIC COMMENTS 256x1x3
        scom_calib_eq=C_FILE.Profs(i).scientific_calib_equation;
        %pres_scom_calib_eq=scom_calib_eq(:,:,ind_pres)';
        %temp_scom_calib_eq=scom_calib_eq(:,:,ind_temp)';
        %psal_scom_calib_eq=scom_calib_eq(:,:,ind_psal)';
        scom_calib_coef=C_FILE.Profs(i).scientific_calib_coefficient;
        %pres_scom_calib_coef=scom_calib_coef(:,:,ind_pres)';
        %temp_scom_calib_coef=scom_calib_coef(:,:,ind_temp)';
        %psal_scom_calib_coef=scom_calib_coef(:,:,ind_psal)';
        scom_calib_com=C_FILE.Profs(i).scientific_calib_comment;
        %pres_scom_calib_com=scom_calib_com(:,:,ind_pres)';
        %temp_scom_calib_com=scom_calib_com(:,:,ind_temp)';
        %psal_scom_calib_com=scom_calib_com(:,:,ind_psal)';
        scom_calib_dt=C_FILE.Profs(i).scientific_calib_date;
        %pres_scom_calib_dt=scom_calib_dt(:,:,ind_pres)';
        %temp_scom_calib_dt=scom_calib_dt(:,:,ind_temp)';
        %psal_scom_calib_dt=scom_calib_dt(:,:,ind_psal)';
        
        % HISTORY COMMENTS
        hist_sp=C_FILE.Profs(i).history_institution;
        step_sp=C_FILE.Profs(i).history_step;
        soft_sp = C_FILE.Profs(i).history_software;
        soft_release_sp = C_FILE.Profs(i).history_software_release;
        hist_reference_sp = C_FILE.Profs(i).history_reference;
        hist_date_sp = C_FILE.Profs(i).history_date;
        action_sp = C_FILE.Profs(i).history_action;
        hist_parameter = C_FILE.Profs(i).history_parameter;
        history_start_pres_sp = C_FILE.Profs(i).history_start_pres;
        history_stop_pres_sp = C_FILE.Profs(i).history_stop_pres;
        
        %---------------------------------------------------------------------%
        %----------------------CALIBRATION COMMENTS----------------------------
        %---------------------------------------------------------------------%
        
        parameter=ncread([root_out file_out],'PARAMETER'); %PARAMETER
        parameter_sp=C_FILE.Profs(i).parameter;
        parameter_sp_dim=reshape(parameter_sp,16,3);
        ncwrite([root_out file_out],'PARAMETER',parameter_sp_dim);
        
        sta_param_sp=C_FILE.Profs(i).station_parameters; %STATION_PARAMETERS
        param=ncread([root_out file_out],'STATION_PARAMETERS');
        ncwrite([root_out file_out],'STATION_PARAMETERS',sta_param_sp);
        
        % SCIENTIFIC_CALIB_EQUATION
        equation_old=ncread([root_in file_in],'SCIENTIFIC_CALIB_EQUATION');
        calib_eq_redim=reshape(scom_calib_eq,256,3);
        ncwrite([root_out file_out],'SCIENTIFIC_CALIB_EQUATION',calib_eq_redim);
        
        % SCIENTIFIC_CALIB_COEFFICIENT
        old_coeff=ncread([root_in file_in],'SCIENTIFIC_CALIB_COEFFICIENT');
        calib_coeff_redim=reshape(scom_calib_coef,256,3);
        ncwrite([root_out file_out],'SCIENTIFIC_CALIB_COEFFICIENT',calib_coeff_redim);
        
        % SCIENTIFIC_CALIB_COMMENT
        comment_old=ncread([root_in file_in],'SCIENTIFIC_CALIB_COMMENT');
        calib_comment_redim=reshape(scom_calib_com,256,3);
        ncwrite([root_out file_out],'SCIENTIFIC_CALIB_COMMENT',calib_comment_redim);
        
        % SCIENTIFIC_CALIB_DATE
        scom_calib_old=ncread([root_in file_in],'SCIENTIFIC_CALIB_DATE');
        calib_date_redim=reshape(scom_calib_dt,14,3);
        ncwrite([root_out file_out],'SCIENTIFIC_CALIB_DATE',calib_date_redim);
        ncfile=[root_out file_out];
        
        %Trozo de codigo para usar las funciones netcdf de bajo nivel
        %     ncid1= netcdf.open(ncfile, 'WRITE');
        %     varid = netcdf.inqVarID(ncid1,'SCIENTIFIC_CALIB_DATE');
        %     %orden de las variables [0 2 0 0] = [DATE_TIME  N_PARAM N_PROF N_CALIB]
        %     netcdf.putVar(ncid1,varid,[0 0 0 0],[14 1 1 1],calib_date_redim(:,1));
        %     netcdf.putVar(ncid1,varid,[0 1 0 0],[14 1 1 1],calib_date_redim(:,2));
        %     netcdf.putVar(ncid1,varid,[0 2 0 0],[14 1 1 1],calib_date_redim(:,3));
        %     netcdf.close(ncid1);
        
        %% HISTORY COMMENTS----------------------------
        
        % HISTORY_INSTITUTION
        history_institution = ncread([root_out file_out],'HISTORY_INSTITUTION');
        ncwrite([root_out file_out],'HISTORY_INSTITUTION',hist_sp);
        
        % HISTORY_STEP
        history_step = ncread([root_out file_out],'HISTORY_STEP');
        ncwrite([root_out file_out],'HISTORY_STEP',step_sp);
        
        % HISTORY_SOFTWARE
        history_software = ncread([root_out file_out],'HISTORY_SOFTWARE');
        ncwrite([root_out file_out],'HISTORY_SOFTWARE',soft_sp);
        
        % HISTORY_SOFTWARE_RELEASE
        history_software_release = ncread([root_out file_out],'HISTORY_SOFTWARE_RELEASE');
        ncwrite([root_out file_out],'HISTORY_SOFTWARE_RELEASE',soft_release_sp);
        
        % HISTORY_REFERENCE
        history_reference = ncread([root_out file_out],'HISTORY_REFERENCE');
        ncwrite([root_out file_out],'HISTORY_REFERENCE',hist_reference_sp);
        
        % HISTORY_DATE
        history_date = ncread([root_out file_out],'HISTORY_DATE');
        ncwrite([root_out file_out],'HISTORY_DATE',hist_date_sp);
        
        %HISTORY_ACTION
        history_action = ncread([root_out file_out],'HISTORY_ACTION');
        ncwrite([root_out file_out],'HISTORY_ACTION',action_sp);
        
        %HISTORY_PARAMETER
        history_parameter = ncread([root_out file_out],'HISTORY_PARAMETER');
        ncwrite([root_out file_out],'HISTORY_PARAMETER',hist_parameter);
        
        %HISTORY_START_PRES
        history_start_pres = ncread([root_out file_out],'HISTORY_START_PRES');
        ncwrite([root_out file_out],'HISTORY_START_PRES',history_start_pres);
        
        %HISTORY_STOP_PRES
        history_stop_pres = ncread([root_out file_out],'HISTORY_STOP_PRES');
        ncwrite([root_out file_out],'HISTORY_STOP_PRES',history_stop_pres_sp);
        
        %netcdf.close(ncid);
        %clear ncid
    end
    clear C_FILE
end