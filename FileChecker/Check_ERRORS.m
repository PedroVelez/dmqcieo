Limpia
float=1900379;

GlobalSU.FileChecker='/Volumes/GDOYE$/Proyectos/Argo/DelayedMode/Programas/FileChecker/Output/';
file=strcat('/Volumes/GDOYE$/Proyectos/Argo/DelayedMode/Data/float_sourceQC2/',num2str(float),'.mat');load(file);
for iboya=[Profs(:).cycle_number]
    var=xml2struct(strcat(GlobalSU.FileChecker,'D',num2str(float),'_',sprintf('%0.3d',iboya),'.nc.filecheck'));
    value=var.Children(10).Attributes.Value; tester=str2num(value);
    if tester~=0;
    error=strcat('>>>>>> ERROR at PROFILE >>>>>>  ',num2str(iboya));
    disp(error)   
    end 
end
disp('Checking completed successfully')



