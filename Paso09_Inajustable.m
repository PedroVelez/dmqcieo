%% Step 9. Description:
%   If any stretch of the signal is considered anomalous and unadjustable,
%   FLAG number 4 is assigned by this script to each profile selected (iIOW
%   & fIOW). These two parameters  must be filled.This decision must be made in
%   previous steps. If FLAG assingment is not needed, then iIOW & fIOW = NaN.
%   <www.oceanografia.argo.es>
%
%   Pedro Velez & Alberto Gonzalez (2016)

Limpia

floats=[1900379];

iIOW=1; %Primer perfil a declarar inajustable.
iFOW=31; %Ultimo perfil a declarar inajustable

HISTORY_INSTITUTION='SP  '; %[Default='    ']
HISTORY_SOFTWARE='AIEO';
HISTORY_REFERENCE='WOA05';


for iboya=1:length(floats)
    flname_DATA=fullfile(GlobalSU.ArgoDMQC,'Data','float_sourceQC2',filesep,strcat(num2str(floats(iboya))));
    DATA=load(flname_DATA);
    fprintf('    > %s\n',DATA.Profs(1).platform_number')
    Profs=DATA.Profs;
    for icycle=1:length(Profs);
        if icycle>=iIOW && icycle<=iFOW;
            %Profs(icycle).psal_adjusted_qc=strrep(Profs(icycle).psal_qc,'0','4');
            Profs(icycle).psal_adjusted_qc=strrep(Profs(icycle).psal_qc,'1','4');
            %Profs(icycle).psal_adjusted_qc=strrep(Profs(icycle).psal_qc,'2','4');
            %Profs(icycle).psal_adjusted_qc=strrep(Profs(icycle).psal_qc,'3','4');
            Profs(icycle).psal_adjusted=Profs(icycle).psal_adjusted.*NaN;
            Profs(icycle).editted=1;
            %NO HACE FALTA HACER HISTORY PORQUE ESTA EFECTUADO EN EL PASO
            %PREVIO
        end
        
        idx_pres=find(Profs(icycle).pres_adjusted_qc=='4');
        if idx_pres~=0;
            Profs(icycle).pres_adjusted_error(idx_pres)=NaN;
            Profs(icycle).pres_adjusted(idx_pres)=NaN;
        end
        idx_temp=find(Profs(icycle).temp_adjusted_qc=='4');
        if idx_temp~=0;
            Profs(icycle).temp_adjusted_error(idx_temp)=NaN;
            Profs(icycle).temp_adjusted(idx_temp)=NaN;
        end
        idx_sal=find(Profs(icycle).psal_adjusted_qc=='4');
        if idx_sal~=0;
            Profs(icycle).psal_adjusted_error(idx_sal)=NaN;
            Profs(icycle).psal_adjusted(idx_sal)=NaN;
        end
    end
    flname_out=fullfile(GlobalSU.ArgoDMQC,'Data','float_sourceQC2',filesep,sprintf('%6d',floats(iboya)));
    fprintf('    > Saving to filename %s \n',flname_out)
    save(flname_out,'Profs')
    
end



