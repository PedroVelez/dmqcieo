%==================================================================================================
% This script completes information of second profile (N_PROF=2) for old PROVOR floats
% that has been converted to format 3.1 by IFREMER. These profiles (N_PROF=2)
% only contains one data of every variable. Useless for DMQC process. This
% data has been colected by the float under "Near-surface sampling: averaged,
% unpumped mode". New data is overwritten on Step 11 matrix.
% Alberto Gonzalez & Pedro Velez (2017)
%==================================================================================================
Limpia
float=[1900379];

load(strcat('/Volumes/GDOYE$/Proyectos/Argo/DelayedMode/Data/float_sourceQC2/',num2str(float),'.mat'));
%keyboard
for iboya=[Profs(:).cycle_number]
    %PROFILES MAYBE ARE NOT FOUND
    cc=find([Profs(1:size(Profs,2)).cycle_number]'==iboya);
    if exist(strcat('/Volumes/GDOYE$/Proyectos/Argo/DelayedMode/Data/float_sourceQC3/',num2str(float),'/profiles/D',num2str(float),'_',sprintf('%0.3d',iboya),'.nc'))>0
        ncfile=strcat('/Volumes/GDOYE$/Proyectos/Argo/DelayedMode/Data/float_sourceQC3/',num2str(float),'/profiles/D',num2str(float),'_',sprintf('%0.3d',iboya),'.nc');
        ncid=netcdf.open(ncfile, 'WRITE');
        size_pres=ncread(ncfile,'PRES'); size_temp=ncread(ncfile,'TEMP'); size_psal=ncread(ncfile,'PSAL'); %GETTING VARIABLE' SIZE
%=============================================================================================================================================================================
        %% MODIFICATIONS FOR N_PROF=1
%=============================================================================================================================================================================
        %% READ VALUE OF FILLVALUE
        
        %CHANGE OF NaN BY FILLVALUE FOR THE FIRST PROFILE BY INDEX IF REQUIRED!
        FillValue=netcdf.getAtt(ncid,netcdf.inqVarID(ncid,'PRES'),'_FillValue'); %GETTING A RANDOM FILLVALUE
        
        pres_adjusted=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED'),[0 0],[size(size_pres,1) 1]);
        idx_pres_ad=find(isnan(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED'),[0 0],[size(size_pres,1) 1]))==1);%LOOKING FOR NaN AT ORIGINAL VALUES
        pres_adjusted(idx_pres_ad)=FillValue;
        if isempty(idx_pres_ad)==0
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED'),[0 0],[size(pres_adjusted,1) 1],pres_adjusted);%FILLVALUE WRITTING
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED_ERROR'),[0 0],[size(pres_adjusted,1) 1],pres_adjusted);%FILLVALUE WRITTING
        end
        
        temp_adjusted=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED'),[0 0],[size(size_temp,1) 1]);
        idx_temp_ad=find(isnan(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED'),[0 0],[size(size_temp,1) 1]))==1);%LOOKING FOR NaN AT ORIGINAL VALUES
        temp_adjusted(idx_temp_ad)=FillValue;
        if isempty(idx_temp_ad)==0
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED'),[0 0],[size(temp_adjusted,1) 1],temp_adjusted);%FILLVALUE WRITTING
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED_ERROR'),[0 0],[size(temp_adjusted,1) 1],temp_adjusted);%FILLVALUE WRITTING
        end
        
        psal_adjusted=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED'),[0 0],[size(size_psal,1) 1]);
        idx_psal_ad=find(isnan(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED'),[0 0],[size(size_psal,1) 1]))==1);%LOOKING FOR NaN AT ORIGINAL VALUES
        psal_adjusted(idx_psal_ad)=FillValue;
        if isempty(idx_psal_ad)==0
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED'),[0 0],[size(psal_adjusted,1) 1],psal_adjusted);%FILLVALUE WRITTING
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED_ERROR'),[0 0],[size(psal_adjusted,1) 1],psal_adjusted);%FILLVALUE WRITTING
        end       
%=============================================================================================================================================================================
        %% MODIFICATIONS FOR N_PROF=2 
%=============================================================================================================================================================================
        %% VARIABLE_ADJUSTED
        %"PARAMETER_ADJUSTED" NEED TO BE FILLED BY THE SAME VALUE AS "PARAMETER" FOR n_prof=2 AT FIRST DATA
        %if PARAMETER_ADJUSTED=Fillvalue for n_prof=1, PARAMETER_ADJUSTED for n_prof=2 must be FillValue.
        %PARAMENTER_ADJUSTED_ERROR REQUIRES SAME ASSIGNMENT.
        if Profs(cc).n_prof==2
            if netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED'),[0 0],[1 1])==FillValue
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED'),[0 size(size_pres,2)-1],[1 1],FillValue);
            else
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED'),[0 size(size_pres,2)-1],[1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES'),[0 0],[1 1]));
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED_ERROR'),[0 size(size_pres,2)-1],[1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED_ERROR'),[0 0],[1 1]));
            end
            
            if netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED'),[0 0],[1 1])==FillValue
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED'),[0 size(size_pres,2)-1],[1 1],FillValue);
            else
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED'),[0 size(size_temp,2)-1],[1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP'),[0 0],[1 1]));
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED_ERROR'),[0 size(size_temp,2)-1],[1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED_ERROR'),[0 0],[1 1]));
            end
            
            if netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED'),[0 0],[1 1])==FillValue
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED'),[0 size(size_pres,2)-1],[1 1],FillValue);
                
            else
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED'),[0 size(size_psal,2)-1],[1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL'),[0 1],[1 1]));
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED_ERROR'),[0 size(size_psal,2)-1],[1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED_ERROR'),[0 0],[1 1]));
            end            
            %% QUALITY FLAG ASSIGMENT FOR DATA OF n_prof=2
            %% VARIABLE_QC
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PRES_QC'),[0 1],[1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_QC'),[0 0],[1 1]));
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'TEMP_QC'),[0 1],[1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP_QC'),[0 0],[1 1]));
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PSAL_QC'),[0 1],[1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL_QC'),[0 0],[1 1]));
            %% VARIABLE_ADJUSTED_QC
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED_QC'),[0 1],[1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_QC'),[0 0],[1 1]));
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED_QC'),[0 1],[1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP_QC'),[0 0],[1 1]));
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED_QC'),[0 1],[1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL_QC'),[0 0],[1 1]));
            %% PROFILE_VARIABLE_QC
            PFLAG=str2num(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES_ADJUSTED_QC'),[0 1],[1 1]))';
            TFLAG=str2num(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'TEMP_ADJUSTED_QC'),[0 1],[1 1]))';
            SFLAG=str2num(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PSAL_ADJUSTED_QC'),[0 1],[1 1]))';
            
            %PRESSURE
            s_FLAG=size(PFLAG,1);
            coef = find(PFLAG == 1 | PFLAG ==2 | PFLAG ==5 |PFLAG ==8);
            
            N = (size(coef,1)/s_FLAG(1,1)).*100;
            
            if N==0;
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PROFILE_PRES_QC'),[1],[1],'F');
            elseif  N>0 && N<25;
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PROFILE_PRES_QC'),[1],[1],'E');
            elseif N>=25 && N<50;
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PROFILE_PRES_QC'),[1],[1],'D');
            elseif N>=50 && N<75;
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PROFILE_PRES_QC'),[1],[1],'C');
            elseif N>=75 && N<100;
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PROFILE_PRES_QC'),[1],[1],'B');
            elseif N==100;
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PROFILE_PRES_QC'),[1],[1],'A');
            end
            clear s_FLAG
            %TEMPERATURE
            s_FLAG=size(TFLAG,1);
            coef = find(TFLAG == 1 | TFLAG ==2 | TFLAG ==5 |TFLAG ==8);
            
            N = (size(coef,1)/s_FLAG(1,1)).*100;
            
            if N==0;
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PROFILE_TEMP_QC'),[1],[1],'F');
            elseif  N>0 && N<25;
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PROFILE_TEMP_QC'),[1],[1],'E');
            elseif N>=25 && N<50;
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PROFILE_TEMP_QC'),[1],[1],'D');
            elseif N>=50 && N<75;
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PROFILE_TEMP_QC'),[1],[1],'C');
            elseif N>=75 && N<100;
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PROFILE_TEMP_QC'),[1],[1],'B');
            elseif N==100;
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PROFILE_TEMP_QC'),[1],[1],'A');
            end
            clear s_FLAG
            %SALINITY
            s_FLAG=size(SFLAG,1);
            coef = find(SFLAG == 1 | SFLAG ==2 | SFLAG ==5 |SFLAG ==8);
            
            N = (size(coef,1)/s_FLAG(1,1)).*100;
            
            if N==0;
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PROFILE_PSAL_QC'),[1],[1],'F');
            elseif  N>0 && N<25;
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PROFILE_PSAL_QC'),[1],[1],'E');
            elseif N>=25 && N<50;
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PROFILE_PSAL_QC'),[1],[1],'D');
            elseif N>=50 && N<75;
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PROFILE_PSAL_QC'),[1],[1],'C');
            elseif N>=75 && N<100;
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PROFILE_PSAL_QC'),[1],[1],'B');
            elseif N==100;
                netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PROFILE_PSAL_QC'),[1],[1],'A');
            end
            %% SCIENTIFIC_CALIB_COEFFICIENT FOR N_PROF=2
            %Some floats contain "none". Replaced by blank (Argo Manual 3.1)
            idx2=ncread(ncfile,'SCIENTIFIC_CALIB_COEFFICIENT');
            for k=0:1:2 %contador
                if idx2(1:4,k+1,1,2)'=='none'
                    netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COEFFICIENT'),[0 k 0 1],[size(idx2(1:4,k+1,1,2)',2) 1 1 1],'    ');
                end
            end
            %% SCIENTIFIC_CALIB_DATE N_PROF=2
            idx3=ncread(ncfile,'SCIENTIFIC_CALIB_DATE');
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_DATE'),[0 0 0 size(idx3,4)-1],[14 1 1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_DATE'),[0 0 0 0],[14 1 1 1]));
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_DATE'),[0 1 0 size(idx3,4)-1],[14 1 1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_DATE'),[0 1 0 0],[14 1 1 1]));
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_DATE'),[0 2 0 size(idx3,4)-1],[14 1 1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_DATE'),[0 2 0 0],[14 1 1 1]));
            %% SCIENTIFIC_CALIB_EQUATION FOR N_PROF=2
            %Some floats contain unexpected comments. Replaced by blank (Argo Manual 3.1)
            idx4=ncread(ncfile,'SCIENTIFIC_CALIB_EQUATION');
            for k=0:1:2 %contador
                if isempty(idx4(1:20,k+1,1,1)')==0
                    netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_EQUATION'),[0 k 0 0],[20 1 1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_EQUATION'),[0 k 0 1],[20 1 1 1]));
                end
            end
            %% SCIENTIFIC_CALIB_COMMENT FOR N_PROF=2
            idx5=ncread(ncfile,'SCIENTIFIC_CALIB_EQUATION');
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COMMENT'),[0 0 0 size(idx5,4)-1],[256 1 1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COMMENT'),[0 0 0 0],[256 1 1 1]));
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COMMENT'),[0 1 0 size(idx5,4)-1],[256 1 1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COMMENT'),[0 1 0 0],[256 1 1 1]));
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COMMENT'),[0 2 0 size(idx5,4)-1],[256 1 1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COMMENT'),[0 2 0 0],[256 1 1 1]));
            %% SCIENTIFIC_CALIB_COEFFICIENT FOR N_PROF=2
            idx6=ncread(ncfile,'SCIENTIFIC_CALIB_COEFFICIENT');
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COEFFICIENT'),[0 0 0 size(idx6,4)-1],[256 1 1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COEFFICIENT'),[0 0 0 0],[256 1 1 1]));
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COEFFICIENT'),[0 1 0 size(idx6,4)-1],[256 1 1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COEFFICIENT'),[0 1 0 0],[256 1 1 1]));
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COEFFICIENT'),[0 2 0 size(idx6,4)-1],[256 1 1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'SCIENTIFIC_CALIB_COEFFICIENT'),[0 2 0 0],[256 1 1 1]));
            %% DATA_STATE_INDICATOR=2C FOR N_PROF=2
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'DATA_STATE_INDICATOR'),[0 1],[4 1],'2C  ');
            %% PARAMETER FOR N_PROF=2
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PARAMETER'),[0 0 0 1],[16 1 1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PARAMETER'),[0 0 0 0],[16 1 1 1]));
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PARAMETER'),[0 1 0 1],[16 1 1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PARAMETER'),[0 1 0 0],[16 1 1 1]));
            netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PARAMETER'),[0 2 0 1],[16 1 1 1],netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PARAMETER'),[0 2 0 0],[16 1 1 1]));
            %keyboard
            clear idx1 idx2 idx3 idx4 idx5 idx6 idx_press idx_psal idx_temp idx_press_ad idx_psal_ad idx_temp_ad size_temp size_pres size_psal
            netcdf.close(ncid)
        end
    end
    
end