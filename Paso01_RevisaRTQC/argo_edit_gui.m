function varargout = argo_edit_gui(varargin)
% ARGO_EDIT_GUI M-file for argo_edit_gui.fig
% varargout = argo_edit_gui(config)
%
% Config.inpath  - inpath for data profiles
%   Data should be in indivuadual profiles
% Config.outpath - outpath for data profiles
%
% Config.HISTORY_INSTITUTION - Institution [Default='    ']
%
% Climatology [Optional]
%
% Config.CLIFile  - name of the climatological file [Default= No climatology]
%	if the climatological filed is provided, it should have:
%       lat (J), lon(I), pre(K)
%       sal (I,J,K), tem(I,J,K)
%       name
% Config.CLIBorder  - size of the box for the climatology, in degrees [Default=10]
%
% Extrem values for axes [Optional]
% Config.maxP  - Maximum pressure    [Default=automatic]
% Config.maxT  - Maximum temperature [Default=automatic]
% Config.minT  - Minimun temperature [Default=automatic]
% Config.maxS  - Maximum salinity    [Default=automatic]
% Config.minS  - Minimum salinity    [Default=automatic]
%
% Config.QCms  - Markersize for que QC plots [Default=5]
% Config.POSBorder - Size of the box for the climatology, in degrees [Default=10]
%
%      ARGO_EDIT_GUI, by itself, creates a new ARGO_EDIT_GUI or raises the existing
%      singleton*.
%
%      H = ARGO_EDIT_GUI returns the handle to a new ARGO_EDIT_GUI or the handle to
%      the existing singleton*.
%
%      ARGO_EDIT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ARGO_EDIT_GUI.M with the given input arguments.
%
%      ARGO_EDIT_GUI('Property','Value',...) creates a new ARGO_EDIT_GUI or
%      raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before argo_edit_gui_OpeningFcn gets called.
%      An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to argo_edit_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help argo_edit_gui

% Last Modified by GUIDE v2.5 23-May-2013 16:52:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name', mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @argo_edit_gui_OpeningFcn, ...
    'gui_OutputFcn',  @argo_edit_gui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before argo_edit_gui is made visible.
function argo_edit_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to argo_edit_gui (see VARARGIN)
Config=varargin{1};

%Read float data
flt = rd_flt_gdac(Config.inpath);
for i = 1:length(flt)
    flt(i).current = 0;
    flt(i).editted = 0;
end

%Add some data to the flt structure that will be used later
if isfield(Config,'HISTORY_INSTITUTION')
    if size(Config.HISTORY_INSTITUTION,2)==4
        flt(1).HISTORY_INSTITUTION=Config.HISTORY_INSTITUTION;
    else
        fprintf('>>>>> Error with HISTORY_INSTITUTION it should be 4 char <<<<<<<<<<<<<<<<<<<<<')
        flt(1).HISTORY_INSTITUTION='    ';
    end
else
    flt(1).HISTORY_INSTITUTION='    ';
end
if isfield(Config,'HISTORY_SOFTWARE')
    flt(1).HISTORY_SOFTWARE=Config.HISTORY_SOFTWARE;
else
    flt(1).HISTORY_SOFTWARE='    ';
end


%Extrem values for axes
if isfield(Config,'maxP')
    flt(1).maxP=Config.maxP;
end
if isfield(Config,'maxT')
    flt(1).maxT=Config.maxT;
end
if isfield(Config,'minT')
    flt(1).minT=Config.minT;
end
if isfield(Config,'maxS')
    flt(1).maxS=Config.maxS;
end
if isfield(Config,'minS')
    flt(1).minS=Config.minS;
end

%Markers size for the QC Flags
if isfield(Config,'QCms')
    flt(1).QCms=Config.QCms;
else
    flt(1).QCms=3;
end

%Border size for the position plots
if isfield(Config,'POSBorder')
    flt(1).POSBorder=Config.POSBorder;
else
    flt(1).POSBorder=10;
end

%Paths
flt(1).inpath = Config.inpath;
flt(1).outpath = Config.outpath;

%Argo reference julian day
flt(1).jref= 2433283;  %argo reference julian day

%load the climatology field.
if isfield(Config,'CLIFile')
    %
    
    if exist(Config.CLIFile,'file')
        Cli=load(Config.CLIFile);
        lat = [flt.latitude];
        lon = [flt.longitude];
        %keyboard
        maxlon = max(lon);    minlon = min(lon);
        maxlat = max(lat);    minlat = min(lat);
        if isfield(Config,'CLIBorder')
            flt(1).CLIBorder=Config.CLIBorder;
        else
            flt(1).CLIBorder=10;
        end
        minlat=minlat-flt(1).CLIBorder;
        maxlat=maxlat+flt(1).CLIBorder;
        minlon=minlon-flt(1).CLIBorder;
        maxlon=maxlon+flt(1).CLIBorder;
        if minlat <-90  ;minlat = -90;end
        if maxlat > 90  ;maxlat = 90;end
        if minlon <-180 ;minlon = -180;end
        if maxlon > 180 ;maxlon = 180;end
        I=find(Cli.lon>minlon & Cli.lon<maxlon);
        J=find(Cli.lat>minlat & Cli.lat<maxlat);
        if isfield(flt(1),'maxP');
            K=find(Cli.pre>0 & Cli.pre<(flt(1).maxP+50));
        else
            K=find(Cli.pre>0 & Cli.pre<2050);
        end
        if isempty(I)==0 && isempty(J)==0 && isempty(K)==0
            flt(1).CLIis=1;
            flt(1).CLIlat=Cli.lat(J);
            flt(1).CLIlon=Cli.lon(I);
            flt(1).CLIpre=Cli.pre(K);
            flt(1).CLIsal=Cli.sal(I,J,K);
            flt(1).CLItem=Cli.tem(I,J,K);
            %flt(1).CLIname=Cli.name;
            flt(1).CLIname=Cli.nombre;
        end
    end
end
% Choose default command line output for argo_edit_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Save float data and configurations in mydata
setappdata(handles.figure1,'mydata',flt);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using argo_edit_gui.
if strcmp(get(hObject,'Visible'),'off')
    gui_plot_temperature(hObject,eventdata,handles,4)
    gui_plot_flags(hObject,eventdata,handles,5,'temp')
end

date1 = gregorian(flt(1).jref+flt(1).juld);
date2 = gregorian(flt(1).jref+flt(end).juld);

%set(handles.text2,'string',[sprintf('Float: %s with %d profiles',flt(1).wmo_num,length(flt)),char(10),...
set(handles.text2,'string',[sprintf('Float: %s with %d profiles',flt(1).platform_number,length(flt)),char(10),...
    sprintf('Dates: %d-%d-%d to %d-%d-%d',date1(1:3),date2(1:3)),char(10),...
    sprintf('Path: %s',flt(1).inpath)],'fontsize',10)

%counter to keep track of current profile
first_profile = min([flt.cycle_number]);
set(handles.text3,'string',num2str(first_profile))

%counter to keep track of current pressure bin
set(handles.text4,'string',num2str(1))

% plot the first profile in the main axes
gui_plot_profile(hObject, eventdata, handles,1)

%plot trajectory in axes 2
gui_plot_pos(hObject, eventdata, handles,2,0)

%Add extra menus to the plot popup
Spopupmenu=get(handles.popupmenu7,'string');
Spopupmenu(8)={'Temperature Section'};
Spopupmenu(9)={'Salinity Section'};
set(handles.popupmenu7,'string',Spopupmenu);
if isfield(flt(1),'CLIis')
    if  flt(1).CLIis==1
        Spopupmenu(10)={'T-S Climatology'};
    end
end
set(handles.popupmenu7,'string',Spopupmenu);


% UIWAIT makes argo_edit_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = argo_edit_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in quit_no_save.
% --------------------------------------------------------------------
function quit_no_save_Callback(hObject, eventdata, handles)
% hObject    handle to quit_no_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% quit the GUI
delete(handles.figure1)

% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end
delete(handles.figure1)


% --- Executes on selection change in axes1_menu.
function axes1_menu_Callback(hObject, eventdata, handles)
% hObject    handle to axes1_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns axes1_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from axes1_menu

popup_sel_index = get(handles.axes1_menu, 'Value');
switch popup_sel_index
    case 1
        gui_plot_temperature(hObject, eventdata, handles,4)
        gui_plot_flags(hObject, eventdata, handles,5,'temp')
    case 2
        gui_plot_salt(hObject, eventdata, handles,4)
        gui_plot_flags(hObject, eventdata, handles,5,'psal')
    case 3
        %gui_plot_pos(hObject, eventdata, handles,1,0)
end
gui_plot_profile(hObject, eventdata, handles,1)


% --- Executes during object creation, after setting all properties.
function axes1_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', {'Temperature', 'Salinity'});

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%--- function to plot cascade salt profiles
function gui_plot_salt(hObject, eventdata, handles,axs)
eval(['axes(handles.axes',num2str(axs),');'])
cla reset;
flt = getappdata(handles.figure1,'mydata');

prop = 'psal';

mean_salt = nanmean([getfield(flt,prop)]);

current_profile = str2double(get(handles.text3,'string'));
ii = find([flt.cycle_number] == current_profile);
for i = 1:length(flt)
    if i == ii
        %     plot((flt(i).psal-mean_salt)*10+flt(i).cycle_number,flt(i).pres,'b-')
        hsalt(i) = plot((getfield(flt,{i},prop)-mean_salt)*10+flt(i).cycle_number,flt(i).pres,'b-');
    elseif i == ii-1 | (ii == 1 & i ==2)
        %       plot((flt(i).psal-mean_salt)*10+flt(i).cycle_number,flt(i).pres,'m-')
        hsalt(i) = plot((getfield(flt,{i},prop)-mean_salt)*10+flt(i).cycle_number,flt(i).pres,'m-');
    else
        %        plot((flt(i).psal-mean_salt)*10+flt(i).cycle_number,flt(i).pres,'c-')
        hsalt(i) = plot((getfield(flt,{i},prop)-mean_salt)*10+flt(i).cycle_number,flt(i).pres,'c-');
        
    end
    hold on
end
if isfield(flt(1),'maxP')
    M1=nanmax(flt(ii).pres);if M1>flt(1).maxP;M1=flt(1).maxP;end
    if isnan(M1)==0 & M1~=0 ;set(gca,'ylim',[0 M1]);end
end

set(gca,'ydir','reverse','Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on','fontsize',10)
hold off

if axs == 4
    for i = 1:length(flt)
        set(hsalt(i),'hittest','off');
    end
    set(handles.axes4,'ButtonDownFcn', @(hObject,eventdata)argo_edit_gui('axes4_ButtonDownFcn',hObject,eventdata,guidata(hObject)))
end

%--- function to plot cascade temperature profiles
function gui_plot_temperature(hObject, eventdata, handles,axs)
%axes(handles.axes1);
eval(['axes(handles.axes',num2str(axs),');'])
cla reset;
flt = getappdata(handles.figure1,'mydata');
prop = 'temp';
current_profile = str2double(get(handles.text3,'string')); %keyboard;
ii = find([flt.cycle_number] == current_profile);
for i = 1:length(flt)
    if i == ii
        %     plot(flt(i).temp+flt(i).cycle_number,flt(i).pres,'b-')
        htemp(i) =  plot(getfield(flt,{i},prop)+flt(i).cycle_number,flt(i).pres,'b-','linewidth',2);
    elseif i == ii-1 | (ii == 1 & i ==2)
        % plot(flt(i).temp+flt(i).cycle_number,flt(i).pres,'m-')
        htemp(i) = plot(getfield(flt,{i},prop)+flt(i).cycle_number,flt(i).pres,'m-');
    else
        %    plot(flt(i).temp+flt(i).cycle_number,flt(i).pres,'c-')
        htemp(i) = plot(getfield(flt,{i},prop)+flt(i).cycle_number,flt(i).pres,'c-');
    end
    hold on
end
hold off

if isfield(flt(1),'maxP')
    M1=nanmax(flt(i).pres);
    if M1>flt(1).maxP || M1==0 ||isnan(M1)==1;M1=flt(1).maxP;end
    set(gca,'ylim',[0 M1])
end
set(gca,'ydir','reverse','Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on','fontsize',10)
if axs == 4
    for i = 1:length(flt)
        set(htemp(i),'hittest','off');
    end
    set(handles.axes4,'ButtonDownFcn', @(hObject,eventdata)argo_edit_gui('axes4_ButtonDownFcn',hObject,eventdata,guidata(hObject)))
end

%--- function to plot sections
function gui_plot_section(hObject, eventdata, handles,axs,prop,refresh)
eval(['axes(handles.axes',num2str(axs),');'])
flt = getappdata(handles.figure1,'mydata');

propY='pres';
current_profile = str2double(get(handles.text3,'string'));
ii = find([flt.cycle_number] == current_profile);

if refresh==0
    cla reset;
    Z=double(getfield(flt,{1},prop)');
    Y=double(getfield(flt,{1},propY)');
    X=flt(1).cycle_number*ones(1,size(flt(1).pres,2))';
    for i = 2:length(flt)
        Zt=double(getfield(flt,{i},prop));
        iQC = (getfield(flt(ii),[prop,'_qc']) == '4');Zt(iQC)=NaN;
        iQC = (getfield(flt(ii),[prop,'_qc']) == '3');Zt(iQC)=NaN;
        iQC = (getfield(flt(ii),[prop,'_qc']) == '2');Zt(iQC)=NaN;
        Z=merge(Z,Zt');
        Yt=double(flt(i).pres);
        iQC = (getfield(flt(ii),[propY,'_qc']) == '4');Yt(iQC)=NaN;
        iQC = (getfield(flt(ii),[propY,'_qc']) == '3');Yt(iQC)=NaN;
        iQC = (getfield(flt(ii),[propY,'_qc']) == '2');Yt(iQC)=NaN;
        Y=merge(Y,Yt');
        X=merge(X,flt(i).cycle_number*ones(1,size(flt(i).pres,2))');
    end
    flt(1).X=X;
    flt(1).Y=Y;
    if  strncmp(prop,'temp',4);
        MZ=round(nanmax(Z(:)));
        if isfield(flt(1),'maxT')
            if MZ>flt(1).maxT;M1=flt(1).maxT;end
        end
        mZ=round(nanmin(Z(:)));
        if isfield(flt(1),'minT')
            if mZ<flt(1).minT;mZ=flt(1).minT;end
        end
        dZ=1;
    elseif strncmp(prop,'psal',4);
        MZ=round(nanmax(Z(:))*10)/10;
        if isfield(flt(1),'maxS')
            if MZ>flt(1).maxS;MZ=flt(1).maxS;end
        end
        mZ=round(nanmin(Z(:))*10)/10;
        if isfield(flt(1),'minS')
            if mZ<flt(1).minS;mZ=flt(1).minS;end
        end
        dZ=0.1;
    end
    pcolor(X,Y,Z);hold on;shading interp;
    caxis([mZ MZ])
    contour(X,Y,Z,[mZ:dZ:MZ],'k')
    [c,h]=contour(X,Y,Z,[mZ:2*dZ:MZ],'k');
    clabel(c,h,'fontsize',07,'color','k','rotation',0,'background','w')
    if isfield(flt(1),'maxP')
        MY=nanmax(Y(:));
        if MY>flt(1).maxP || MY==0 ;MY=flt(1).maxP;end
        set(gca,'ylim',[0 MY])
    end
    
    set(gca,'Ydir','reverse','Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on','fontsize',10)
    
    handles.hLineContour=plot(flt(1).X(:,ii),flt(1).Y(:,ii),'y','linewidth',2);
    guidata(hObject, handles);
    setappdata(handles.figure1,'mydata',flt);
else
    if ishandle(handles.hLineContour)
        delete(handles.hLineContour)
    end
    handles.hLineContour=plot(flt(1).X(:,ii),flt(1).Y(:,ii),'y','linewidth',2);
    guidata(hObject, handles);
end

%--- function to plot TS
function gui_plot_ts(hObject, eventdata, handles,axs)
%axes(handles.axes1);
eval(['axes(handles.axes',num2str(axs),');'])
cla reset;
flt = getappdata(handles.figure1,'mydata');

prop1 = 'temp';
prop2 = 'psal';
current_profile = str2double(get(handles.text3,'string'));
ii = find([flt.cycle_number] == current_profile);

for i1 = 1:length(flt)
    if i1 == ii-1 | (ii == 1 & i1 ==2)
        htemp(i1)=plot(getfield(flt,{i1},prop2),getfield(flt,{i1},prop1),'m-');
    else
        htemp(i1)=plot(getfield(flt,{i1},prop2),getfield(flt,{i1},prop1),'c-');
    end
    hold on
end

if ii == 1
    htemp(end+1)=plot(getfield(flt,{2},prop2),getfield(flt,{2},prop1),'m-');
else
    htemp(end+1)=plot(getfield(flt,{ii-1},prop2),getfield(flt,{ii-1},prop1),'m-');
end
htemp(end+1)=plot(getfield(flt,{ii},prop2),getfield(flt,{ii},prop1),'b.-','linewidth',2);

if isfield(flt(1),'maxT') && isfield(flt(1),'minT')
    M1=nanmax(getfield(flt,{ii},prop1));if M1>flt(1).maxT;M1=flt(1).maxT;end
    m1=nanmin(getfield(flt,{ii},prop1));if m1<flt(1).minT;m1=flt(1).minT;end
    if isnan(M1)==0 & isnan(m1)==0;
        set(gca,'ylim',[m1 M1]);
    else
        set(gca,'ylim',[flt(1).minT flt(1).maxT]);
    end
end
if isfield(flt(1),'maxS') && isfield(flt(1),'minS')
    M2=nanmax(getfield(flt,{ii},prop2));if M2>flt(1).maxS;M2=flt(1).maxS;end
    m2=nanmin(getfield(flt,{ii},prop2));if m2<flt(1).minS;m2=flt(1).minS;end
    if isnan(M2)==0 & isnan(m2)==0;
        set(gca,'xlim',[m2 M2]);
    else
        set(gca,'xlim',[flt(1).minS flt(1).maxS]);
    end
end

%Allow cliking int he TS diagram
if axs == 2
    for i = 1:length(flt)
        set(htemp(i),'hittest','off');
    end
    set(handles.axes2,'ButtonDownFcn', @(hObject,eventdata)argo_edit_gui('axes2_ButtonDownFcn',hObject,eventdata,guidata(hObject)))
end
grid on
hold off

%--- function to plot T-S together with the Climatology
function gui_plot_ts_climatology(hObject, eventdata, handles,axs)
eval(['axes(handles.axes',num2str(axs),');'])
cla reset;
flt = getappdata(handles.figure1,'mydata');
prop1 = 'temp';
prop2 = 'psal';
current_profile = str2double(get(handles.text3,'string'));
ii = find([flt.cycle_number] == current_profile);
maxlon = max(flt(ii).longitude);    minlon = min(flt(ii).longitude);
maxlat = max(flt(ii).latitude);    minlat = min(flt(ii).latitude);
minlat=minlat-flt(1).CLIBorder;
maxlat=maxlat+flt(1).CLIBorder;
minlon=minlon-flt(1).CLIBorder;
maxlon=maxlon+flt(1).CLIBorder;
if minlat < -90 ; minlat = -90;end
if maxlat > 90 ; maxlat = 90;end
if minlon < -180 ; minlon = -180;end
if maxlon > 180 ; maxlon = 180;end

I=find(flt(1).CLIlon>minlon & flt(1).CLIlon<maxlon);
J=find(flt(1).CLIlat>minlat & flt(1).CLIlat<maxlat);
if isfield(flt(1),'maxP');
    MP=nanmax(flt(ii).pres);if (MP>flt(1).maxP | MP==0 | isnan(MP)==0);MP=flt(1).maxP;end
    K=find(flt(1).CLIpre>0 & flt(1).CLIpre<(MP+50));
else
    MP=nanmax(flt(ii).pres);
    K=find(flt(1).CLIpre>0 & flt(1).CLIpre<(MP+50));
end
if isempty(I)==0 && isempty(J)==0 && isempty(K)==0
    CLIsal=flt(1).CLIsal(I,J,K);
    CLItem=flt(1).CLItem(I,J,K);
    plot(CLIsal(:),CLItem(:),'o','markersize',4,'markeredge',[0.65 0.65 0.65],'markerfacecolor',[0.65 0.65 0.65]);hold on
    plot(getfield(flt,{ii},prop2),getfield(flt,{ii},prop1),'b.-','linewidth',2)
    if ii>1
        i=ii-1;plot(getfield(flt,{i},prop2),getfield(flt,{i},prop1),'m-')
    end
    if ii<length(flt)
        i=ii+1;plot(getfield(flt,{i},prop2),getfield(flt,{i},prop1),'c-')
    end
    %Find axis limits automatically
    if isfield(flt(1),'maxT') && isfield(flt(1),'minT')
        M1=nanmax(getfield(flt,{ii},prop1));if M1>flt(1).maxT;M1=flt(1).maxT;end
        m1=nanmin(getfield(flt,{ii},prop1));if m1<flt(1).minT;m1=flt(1).minT;end
        set(gca,'ylim',[m1 M1])
    end
    if isfield(flt(1),'maxS') && isfield(flt(1),'minS')
        M2=nanmax(getfield(flt,{ii},prop2));if M2>flt(1).maxS;M2=flt(1).maxS;end
        m2=nanmin(getfield(flt,{ii},prop2));if m2<flt(1).minS;m2=flt(1).minS;end
        set(gca,'xlim',[m2 M2])
    end
    
    grid on
    hold off
end

%--- function to plot  profiles in the main axes
function gui_plot_profile(hObject, eventdata, handles,axs)
eval(['axes(handles.axes',num2str(axs),');'])
%set(gca,'Nextplot','Replacechildren')
cla reset;
flt = getappdata(handles.figure1,'mydata');

current_bin = str2double(get(handles.text4,'string'));
current_profile = str2double(get(handles.text3,'string'));
popup_sel_index = get(handles.axes1_menu, 'Value');
ii = find([flt.cycle_number] == current_profile);

switch popup_sel_index
    case 1
        prop = 'temp';
    case 2
        prop = 'psal';
end

if ii > 1
    nbr = ii-1;
else
    nbr = 2;
end


iQC1 = getfield(flt(ii),[prop,'_qc']) == '1';
iQC2 = getfield(flt(ii),[prop,'_qc']) == '2';
iQC3 = getfield(flt(ii),[prop,'_qc']) == '3';
iQC4 = getfield(flt(ii),[prop,'_qc']) == '4';
iQC123 = getfield(flt(ii),[prop,'_qc']) == '1' | getfield(flt(ii),[prop,'_qc']) == '2' | getfield(flt(ii),[prop,'_qc']) == '3'; %All good profiles
iQCB=  getfield(flt(ii),[prop,'_qc']) == ' ';
if sum(iQCB)>0
    fprintf('>>>>> Warning %d empty values in %s_qc. Using them as QC=4. And rewriting file \n',sum(iQCB),prop)
    nQCB=findstr(flt(ii).(strcat(prop,'_qc')),' ');
    for inQCB=nQCB
        flt(ii).(strcat(prop,'_qc'))(inQCB)='4';
    end
    flt(ii).editted = 1;  %mark as editted
    setappdata(handles.figure1,'mydata',flt);
    gui_plot_profile(hObject, eventdata, handles,1);
end

h3  = plot(getfield(flt(nbr),prop),flt(nbr).pres,'m-','linewidth',1.7);hold on  % neighboring profile
h1a = plot(getfield(flt(ii),prop,{iQC4}),flt(ii).pres(iQC4),'ro','markersize',5,'markerfacecolor','r','markeredgecolor','r');
h2a = plot(getfield(flt(ii),prop,{iQC2}),flt(ii).pres(iQC2),'o','markersize',5,'markerfacecolor',[1 .5  0],'markeredgecolor',[1 .5  0]);%orange
h3a = plot(getfield(flt(ii),prop,{iQC3}),flt(ii).pres(iQC3),'o','markersize',5,'markerfacecolor',[1 .4 .1],'markeredgecolor',[1 .4 .1]);%orange-red

PresAProf=flt(ii).pres(iQC123);
PropAProf=getfield(flt(ii),prop,{iQC123});
h1 = plot(PropAProf(isnan(PresAProf)==0),PresAProf(isnan(PresAProf)==0),'b.-','linewidth',2); %Actual profile
h2 = plot(getfield(flt(ii),prop,{current_bin}),flt(ii).pres(current_bin),'m','marker','o','markersize',7,'markerfacecolor','b');

xlim = get(gca,'xlim');
switch popup_sel_index
    case 1
        if isfield(flt(1),'minT') && isfield(flt(1),'maxT') & length(getfield(flt(ii),prop,{iQC1}))>1
            M2=nanmax(getfield(flt(ii),prop,{iQC1}));if (M2>flt(1).maxT || M2==0 || isnan(M2)==0);M2=flt(1).maxT;end
            m2=nanmin(getfield(flt(ii),prop,{iQC1}));if m2<flt(1).minT || m2==0 || isnan(m2)==0;m2=flt(1).minT;end
            set(gca,'xlim',[m2 M2])
        end
    case 2
        if isfield(flt(1),'minS') && isfield(flt(1),'maxS') & length(getfield(flt(ii),prop,{iQC1}))>1
            M2=nanmax(getfield(flt(ii),prop,{iQC1}));if M2>flt(1).maxS || M2==0 || isnan(M2)==0;M2=flt(1).maxS;end
            m2=nanmin(getfield(flt(ii),prop,{iQC1}));if m2<flt(1).minS || m2==0 || isnan(m2)==0;m2=flt(1).minS;end
            set(gca,'xlim',[m2 M2])
        end
end

%plot profile of other variable
switch popup_sel_index
    case 1
        otherprop = 'psal';
    case 2
        otherprop = 'temp';
end
iQC1 = getfield(flt(ii),[otherprop,'_qc']) == '1';
oprop_data =getfield(flt(ii),otherprop,{iQC1});

if length(oprop_data)>1
    [m,b,hadp]=add_plot(oprop_data,flt(ii).pres(iQC1),'g-');
end

set(h1,'hittest','off');
set(h2,'hittest','off');
set(h3,'hittest','off');
set(h1a,'hittest','off');
set(h2a,'hittest','off');
set(h3a,'hittest','off');

%Add legend
if length(oprop_data)>1
    if ~isempty(h1a) && ~isempty(h2a) && ~isempty(h3a)
        HLeg=legend([h3 h1 h1a h2a h3a hadp],sprintf(' %s previous cycle',prop),sprintf(' %s actual cycle QC=1,2,3',prop),sprintf(' %s actual cycle QC=4',prop),sprintf(' %s actual cycle QC=2',prop),sprintf(' %s actual cycle QC=3',prop),sprintf(' %s actual cycle',otherprop),'Location','SouthEast');
    elseif ~isempty(h1a)
        HLeg=legend([h3 h1 h1a hadp],sprintf(' %s previous cycle',prop),sprintf(' %s actual cycle QC=1,2,3',prop),sprintf(' %s actual cycle QC=4',prop),sprintf(' %s actual cycle',otherprop),'Location','SouthEast');
    else
        HLeg=legend([h3 h1 hadp],sprintf(' %s previous cycle',prop),sprintf(' %s actual cycle QC=1,2,3',prop),sprintf(' %s actual cycle',otherprop),'Location','SouthEast');
    end
else
    if ~isempty(h1a) && ~isempty(h2a) && ~isempty(h3a)
        HLeg=legend([h3 h1 h1a h2a h3a],sprintf(' %s previous cycle',prop),sprintf(' %s actual cycle QC=1,2,3',prop),sprintf(' %s actual cycle QC=4',prop),sprintf(' %s actual cycle QC=2',prop),sprintf(' %s actual cycle QC=3',prop),'Location','SouthEast');
    elseif ~isempty(h1a)
        HLeg=legend([h3 h1 h1a],sprintf(' %s previous cycle',prop),sprintf(' %s actual cycle QC=1,2,3',prop),sprintf(' %s actual cycle QC=4',prop),'Location','SouthEast');
    else
        HLeg=legend([h3 h1],sprintf(' %s previous cycle',prop),sprintf(' %s actual cycle QC=1,2,3',prop),'Location','SouthEast');
    end
end

if isfield(flt(1),'maxP')
    M1=nanmax(flt(ii).pres);if (M1>flt(1).maxP | M1==0 | isnan(M1)==0);M1=flt(1).maxP;end
    if isnan(M1)==0;set(gca,'ylim',[0 M1]);end
end

set(gca,'ydir','reverse','Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on','fontsize',10)
set(HLeg,'fontsize',12,'Location','SouthEast','Box','off')

%Display info about this profile/bin
dd = gregorian(flt(ii).juld + flt(1).jref);
set(handles.text5,'string',[sprintf('Cycle #: %d (%d), Bin #: %d',current_profile,ii,current_bin),char(10),...
    sprintf('Lat: %6.3f, Lon: %7.3f',flt(ii).latitude,flt(ii).longitude),char(10),...
    sprintf('Date: %4d-%2d-%2d',dd(1:3)),char(10),...
    sprintf('P: %7.1f    %c',flt(ii).pres(current_bin),flt(ii).pres_qc(current_bin)),char(10),...
    sprintf('T: %7.2f    %c',flt(ii).temp(current_bin),flt(ii).temp_qc(current_bin)),char(10),...
    sprintf('S: %7.2f    %c',flt(ii).psal(current_bin),flt(ii).psal_qc(current_bin)),char(10),...
    ],'fontsize',10)
set(handles.axes1,'ButtonDownFcn', @(hObject,eventdata)argo_edit_gui('axes1_ButtonDownFcn',hObject,eventdata,guidata(hObject)))
set(handles.axes2,'ButtonDownFcn', @(hObject,eventdata)argo_edit_gui('axes2_ButtonDownFcn',hObject,eventdata,guidata(hObject)))
hold off

%--- function to plot flags
function gui_plot_flags(hObject, eventdata, handles,axs,prop)
%   axs:  axes number to plot in
%  prop:  either 'pres','temp','psal',...
eval(['axes(handles.axes',num2str(axs),');'])
cla reset;
flt = getappdata(handles.figure1,'mydata');
current_profile = str2double(get(handles.text3,'string'));
MarSize=flt(1).QCms;
fldname = [prop,'_qc'];
if isfield(flt,fldname)
    ncy = length(flt);
    for ii = 1:ncy
        if flt(ii).cycle_number==current_profile;
            MarSize=4;
        else
            MarSize=3;
        end
        qc = getfield(flt(ii),fldname);
        type = flt(ii).type;
        pres = flt(ii).pres;
        f1 = findstr('1',qc);
        f2 = findstr('2',qc);
        f3 = findstr('3',qc);
        f4 = findstr('4',qc);
        f9 = findstr('9',qc);
        
        if strmatch(type,'R')
            if any(f1)
                plot(flt(ii).cycle_number*ones(1,length(f1)),pres(f1),'o','MarkerEdgeColor','g','MarkerFaceColor','g','markersize',MarSize)
                hold on
            end
            if any(f2)
                plot(flt(ii).cycle_number*ones(1,length(f2)),pres(f2),'o','MarkerEdgeColor','y','MarkerFaceColor','y','markersize',MarSize)
                hold on
            end
            if any(f3)
                plot(flt(ii).cycle_number*ones(1,length(f3)),pres(f3),'o','MarkerEdgeColor','y','MarkerFaceColor','y','markersize',MarSize)
                hold on
            end
            if any(f4)
                plot(flt(ii).cycle_number*ones(1,length(f4)),pres(f4),'o','MarkerEdgeColor','r','MarkerFaceColor','r','markersize',MarSize)
                hold on
            end
            if any(f9)
                plot(flt(ii).cycle_number*ones(1,length(f9)),pres(f9),'o','MarkerEdgeColor','r','MarkerFaceColor','r','markersize',MarSize)
                hold on
            end
        else
            if any(f1)
                plot(flt(ii).cycle_number*ones(1,length(f1)),pres(f1),'s','MarkerEdgeColor','g','MarkerFaceColor','g','markersize',MarSize)
                hold on
            end
            if any(f2)
                plot(flt(ii).cycle_number*ones(1,length(f2)),pres(f2),'s','MarkerEdgeColor','y','MarkerFaceColor','y','markersize',MarSize)
                hold on
            end
            if any(f3)
                plot(flt(ii).cycle_number*ones(1,length(f3)),pres(f3),'s','MarkerEdgeColor','y','MarkerFaceColor','y','markersize',MarSize)
                hold on
            end
            if any(f4)
                plot(flt(ii).cycle_number*ones(1,length(f4)),pres(f4),'s','MarkerEdgeColor','r','MarkerFaceColor','r','markersize',MarSize)
                hold on
            end
            if any(f9)
                plot(flt(ii).cycle_number*ones(1,length(f9)),pres(f9),'s','MarkerEdgeColor','g','MarkerFaceColor','r','markersize',MarSize)
                hold on
            end
        end
        maxp = max(flt(ii).pres);
        %plot indicator if profile flags have been altered.
        if flt(ii).editted == 1;
            plot(flt(ii).cycle_number, -30,'rx')
            set(gca,'ylim',[-80 maxp]);
        end
    end
    
    plot(current_profile,0,'o','markersize',4,'MarkerFaceColor','b')
    hold off
    if isfield(flt(1),'maxP')
        maxP=nanmax(flt(ii).pres);if maxP>flt(1).maxP || maxP==0 || isnan(maxP)==1;maxP=flt(1).maxP;end
        if flt(ii).editted == 1;
            set(gca,'ylim',[-80 maxP]);
        else
            set(gca,'ylim',[0 maxP])
        end
    end
    set(gca,'ydir','reverse','Xgrid','on','XMinorTick','on','Ygrid','on','YMinorTick','on','fontsize',10)
    set(gca,'xlim',[ min([flt.cycle_number])-1  max([flt.cycle_number])+1])
else
    disp(['Unable to match field name ', prop])
end

function gui_plot_pos(hObject,eventdata,handles,axs,refresh_plot_pos)
% function to plot profile positions
eval(['axes(handles.axes',num2str(axs),');'])
flt = getappdata(handles.figure1,'mydata');
current_profile = str2double(get(handles.text3,'string'));
ii = find([flt.cycle_number] == current_profile);
if nargin==4
    refresh_plot_pos=0;
end
if refresh_plot_pos==0
    cla reset;
    lat = [flt.latitude];
    lon = [flt.longitude];
    maxlon = max(lon);    minlon = min(lon);
    maxlat = max(lat);    minlat = min(lat);
    
    if minlat-flt(1).POSBorder < -90 ; minlat = -90+flt(1).POSBorder;end
    if maxlat+flt(1).POSBorder > 90 ; maxlat = 90-flt(1).POSBorder;end
    if minlon-flt(1).POSBorder < -180 ; minlon = -180+flt(1).POSBorder;end
    if maxlon-flt(1).POSBorder > 180 ; maxlon = 180-flt(1).POSBorder;end
    
    
    m_proj('mercator','long',[minlon-flt(1).POSBorder maxlon+flt(1).POSBorder],'lat',[minlat-flt(1).POSBorder maxlat+flt(1).POSBorder])
    m_coast('patch',[.8 .9 .8]);hold on
    m_plot(lon,lat,'o','markersize',4,'markeredgecolor','k','markerfacecolor','b')
    m_plot(lon(1),lat(1),'g*','markersize',3)
    m_plot(lon(end),lat(end),'r*','markersize',3)
    m_grid;
    handles.hActualPosition=m_plot(lon(ii),lat(ii),'o','markeredgecolor','k','markerfacecolor','y','markersize',6);
    guidata(hObject,handles);
else
    if ishandle(handles.hActualPosition)
        delete(handles.hActualPosition)
    end
    
    lat = [flt.latitude];
    lon = [flt.longitude];
    maxlon = max(lon);    minlon = min(lon);
    maxlat = max(lat);    minlat = min(lat);
    
    if minlat-flt(1).POSBorder < -90 ; minlat = -90+flt(1).POSBorder;end
    if maxlat+flt(1).POSBorder > 90 ; maxlat = 90-flt(1).POSBorder;end
    if minlon-flt(1).POSBorder < -180 ; minlon = -180+flt(1).POSBorder;end
    if maxlon-flt(1).POSBorder > 180 ; maxlon = 180-flt(1).POSBorder;end
    
    m_proj('mercator','long',[minlon-flt(1).POSBorder maxlon+flt(1).POSBorder],'lat',[minlat-flt(1).POSBorder maxlat+flt(1).POSBorder])
    
    handles.hActualPosition=m_plot(lon(ii),lat(ii),'o','markeredgecolor','k','markerfacecolor','y','markersize',6);
    guidata(hObject, handles);
end

function gui_cont_temp(hObject, eventdata, handles,axs)
eval(['axes(handles.axes',num2str(axs),');'])
cla reset;
flt = getappdata(handles.figure1,'mydata');

% --- Executes on button press in button_previous.
function button_previous_Callback(hObject, eventdata, handles)
% hObject    handle to button_previous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

current_profile = str2double(get(handles.text3,'string'));
flt = getappdata(handles.figure1,'mydata');
ii = find([flt.cycle_number] == current_profile);
if ii > 1
    newprofile = flt(ii-1).cycle_number;
else
    newprofile = current_profile;
end
set(handles.text3,'string',num2str(newprofile),'fontsize',10)

% check if new profile is shallower then previous current_bin
i2 = find([flt.cycle_number] == newprofile);
current_bin = str2double(get(handles.text4,'string'));
if current_bin > length(flt(i2).pres)
    set(handles.text4,'string',num2str(length(flt(i2).pres)),'fontsize',10)
end

gui_plot_profile(hObject, eventdata, handles,1)

popup_sel_index = get(handles.axes1_menu, 'Value');
switch popup_sel_index
    case 1
        gui_plot_temperature(hObject, eventdata, handles,4)
        gui_plot_flags(hObject, eventdata, handles,5,'temp')
    case 2
        gui_plot_salt(hObject, eventdata, handles,4)
        gui_plot_flags(hObject, eventdata, handles,5,'psal')
end

popup_sel_2 = get(handles.popupmenu7, 'Value');
switch popup_sel_2
    case 1
        %Aqui
        gui_plot_pos(hObject, eventdata, handles,2,1)
    case 2
        gui_plot_ts(hObject, eventdata, handles,2)
    case 3
        gui_plot_temperature(hObject, eventdata, handles,2)
    case 4
        gui_plot_salt(hObject, eventdata, handles,2)
    case 8
        gui_plot_section(hObject, eventdata, handles,2,'temp',1)
    case 9
        gui_plot_section(hObject, eventdata, handles,2,'psal',1)
    case 10
        gui_plot_ts_climatology(hObject, eventdata, handles,2)
end

% --- Executes on button press in button_next.
function button_next_Callback(hObject, eventdata, handles)
% hObject    handle to button_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% advance profile counter by one and replot.
current_profile = str2double(get(handles.text3,'string'));
flt = getappdata(handles.figure1,'mydata');
ii = find([flt.cycle_number] == current_profile);
if ii < length(flt)
    newprofile = flt(ii+1).cycle_number;
else
    newprofile = current_profile;
end
set(handles.text3,'string',num2str(newprofile));


% check if new profile is shallower then previous current_bin
i2 = find([flt.cycle_number] == newprofile);
current_bin = str2double(get(handles.text4,'string'));
if current_bin > length(flt(i2).pres)
    set(handles.text4,'string',num2str(length(flt(i2).pres)),'fontsize',10)
end

gui_plot_profile(hObject, eventdata, handles,1)

popup_sel_index = get(handles.axes1_menu, 'Value');
switch popup_sel_index
    case 1
        gui_plot_temperature(hObject, eventdata, handles,4)
        gui_plot_flags(hObject, eventdata, handles,5,'temp')
    case 2
        gui_plot_salt(hObject, eventdata, handles,4)
        gui_plot_flags(hObject, eventdata, handles,5,'psal')
end

popup_sel_2 = get(handles.popupmenu7, 'Value');
switch popup_sel_2
    case 1
        gui_plot_pos(hObject, eventdata, handles,2,1)
    case 2
        gui_plot_ts(hObject, eventdata, handles,2)
    case 3
        gui_plot_temperature(hObject, eventdata, handles,2)
    case 4
        gui_plot_salt(hObject, eventdata, handles,2)
    case 8
        gui_plot_section(hObject, eventdata, handles,2,'temp',1)
    case 9
        gui_plot_section(hObject, eventdata, handles,2,'psal',1)
    case 10
        gui_plot_ts_climatology(hObject, eventdata, handles,2)
end

% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

xy1 = get(handles.axes1,'Currentpoint');
x1 = xy1(1,1);
y1 = xy1(1,2);

%match to closest point on current profile
current_profile = str2double(get(handles.text3,'string'));
flt = getappdata(handles.figure1,'mydata');
ii = find([flt.cycle_number] == current_profile);
pp = flt(ii).pres;
popup_sel_index = get(handles.axes1_menu, 'Value');
switch popup_sel_index
    case 1
        zz = flt(ii).temp;
    case 2
        zz = flt(ii).psal;
end
%scale by current axes dimensions
YL= diff(get(handles.axes1,'ylim'));
XL= diff(get(handles.axes1,'xlim'));
dd = (x1 - zz).^2/XL + (y1-pp).^2/YL;
id = find(dd == min(dd));
new_bin = id;
set(handles.text4,'string',num2str(new_bin))

gui_plot_profile(hObject, eventdata, handles,1)

% --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
xy1 = get(handles.axes2,'Currentpoint');
x1 = xy1(1,1);
y1 = xy1(1,2);
%plot(x1,y1,'m+'); hold on
flt = getappdata(handles.figure1,'mydata');
%fprintf('    > Axes 2 - Apbt: [x,y] = [%4.2f,%4.2f] \n',x1,y1)

mdt=sqrt((flt(1).psal-x1).^2+(flt(1).temp-y1).^2);
ip=1;
ib=find(mdt==min(mdt));
md=mdt(ib);
ii=flt(1).cycle_number;
for i1 = 2:length(flt)
    ii = [ii; flt(i1).cycle_number];
    mdt=sqrt((flt(i1).psal-x1).^2+(flt(i1).temp-y1).^2);
    if min(mdt)<md
        ib=find(mdt==min(mdt));
        ip=i1;
        md=min(mdt);
    end
    clear mdt
end
newprofile=ii(ip);

fprintf('    > [%5.2f,%5.2f] closest value [%5.2f,%5.2f] cycle %d\n',x1,y1,flt(ip).psal(ib),flt(ip).temp(ib),ii(ip))

%Update profile number in the GUI
set(handles.text3,'string',num2str(newprofile))

%Replot Main figure
gui_plot_profile(hObject, eventdata, handles,1)
%ReplotOther figures
popup_sel_index = get(handles.axes1_menu, 'Value');
switch popup_sel_index
    case 1
        gui_plot_temperature(hObject, eventdata, handles,4)
        gui_plot_flags(hObject, eventdata, handles,5,'temp')
        
    case 2
        gui_plot_salt(hObject, eventdata, handles,4)
        gui_plot_flags(hObject, eventdata, handles,5,'psal')
end
%Replot TS diagrama
gui_plot_ts(hObject, eventdata, handles,2)
hold on;plot(flt(ip).psal(ib),flt(ip).temp(ib),'o');hold off



% --- Executes on mouse press over axes background.
function axes4_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
xy1 = round(get(handles.axes4,'Currentpoint'));
x1 = xy1(1,1);
y1 = xy1(1,2);
fprintf('Axes 4 - Apbt: [x,y] = [%d,%d] \n',x1,y1)

%match to closest profile
flt = getappdata(handles.figure1,'mydata');
popup_sel_index = get(handles.axes1_menu, 'Value');
switch popup_sel_index
    case 1
        prop_base = 'temp';
    case 2
        prop_base = 'psal';
end

prop_ext = '';
%prop_ext = '_adjusted';
prop = [prop_base,prop_ext];

if strcmp(prop_base,'psal')
    mean_salt = nanmean([getfield(flt,prop)]);
end
zz = []; pp = [];ii = [];
for i = 1:length(flt)
    if strcmp(prop_base,'psal')
        % transformation used in plotting
        zz = [zz ; [(getfield(flt,{i},prop)-mean_salt)*10+flt(i).cycle_number]'];
    else
        zz = [zz ; [getfield(flt,{i},prop)+flt(i).cycle_number]'];
    end
    pp = [pp; flt(i).pres'];
    ii = [ii; [flt(i).pres*0+flt(i).cycle_number]'];
end

%scale by current axes dimensions
YL= diff(get(handles.axes1,'ylim'));
XL= diff(get(handles.axes1,'xlim'));
dd = (x1 - zz).^2/XL + (y1-pp).^2/YL;
id = find(dd == min(dd));
newprofile = ii(id);
fprintf('    > Clicked on profile %d\n',newprofile)

%Update profile number in the GUI
set(handles.text3,'string',num2str(newprofile))

%Replot Main figure
gui_plot_profile(hObject, eventdata, handles,1)
%ReplotOther figures
popup_sel_index = get(handles.axes1_menu, 'Value');
switch popup_sel_index
    case 1
        gui_plot_temperature(hObject, eventdata, handles,4)
        gui_plot_flags(hObject, eventdata, handles,5,'temp')
        
    case 2
        gui_plot_salt(hObject, eventdata, handles,4)
        gui_plot_flags(hObject, eventdata, handles,5,'psal')
end
popup_sel_2 = get(handles.popupmenu7, 'Value');
switch popup_sel_2
    case 1
        gui_plot_pos(hObject, eventdata, handles,2)
    case 2
        gui_plot_ts(hObject, eventdata, handles,2)
    case 3
        gui_plot_temperature(hObject, eventdata, handles,2)
    case 4
        gui_plot_salt(hObject, eventdata, handles,2)
    case 8
        gui_plot_section(hObject, eventdata, handles,2,'temp',1)
    case 9
        gui_plot_section(hObject, eventdata, handles,2,'psal',1)
    case 10
        gui_plot_ts_climatology(hObject, eventdata, handles,2)
end

% --- Executes on key release with focus on figure1 and none of its controls.
function figure1_KeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)

%disp([eventdata.Character ' ' eventdata.Key])
switch eventdata.Key
    case 'rightarrow'
        current_profile = str2double(get(handles.text3,'string'));
        flt = getappdata(handles.figure1,'mydata');
        ii = find([flt.cycle_number] == current_profile);
        if ii < length(flt)
            newprofile = flt(ii+1).cycle_number;
        else
            newprofile = current_profile;
        end
        set(handles.text3,'string',num2str(newprofile))
        
        % check if new profile is shallower then previous current_bin
        i2 = find([flt.cycle_number] == newprofile);
        current_bin = str2double(get(handles.text4,'string'));
        if current_bin > length(flt(i2).pres)
            set(handles.text4,'string',num2str(length(flt(i2).pres)))
        end
        
        gui_plot_profile(hObject, eventdata, handles,1)
        
        popup_sel_index = get(handles.axes1_menu, 'Value');
        switch popup_sel_index
            case 1
                gui_plot_temperature(hObject, eventdata, handles,4)
                gui_plot_flags(hObject, eventdata, handles,5,'temp')
                
            case 2
                gui_plot_salt(hObject, eventdata, handles,4)
                gui_plot_flags(hObject, eventdata, handles,5,'psal')
        end
        
        
        popup_sel_2 = get(handles.popupmenu7, 'Value');
        switch popup_sel_2
            case 1
                % trajectory
            case 2
                gui_plot_ts(hObject, eventdata, handles,2)
            case 3
                gui_plot_temperature(hObject, eventdata, handles,2)
            case 4
                gui_plot_salt(hObject, eventdata, handles,2)
            case 8
                gui_plot_section(hObject, eventdata, handles,2,'temp',1)
            case 9
                gui_plot_section(hObject, eventdata, handles,2,'psal',1)
            case 10
                gui_plot_ts_climatology(hObject, eventdata, handles,2)
                
        end
    case 'leftarrow'
        current_profile = str2double(get(handles.text3,'string'));
        flt = getappdata(handles.figure1,'mydata');
        ii = find([flt.cycle_number] == current_profile);
        if ii > 1
            newprofile = flt(ii-1).cycle_number;
        else
            newprofile = current_profile;
        end
        set(handles.text3,'string',num2str(newprofile))
        
        % check if new profile is shallower then previous current_bin
        i2 = find([flt.cycle_number] == newprofile);
        current_bin = str2double(get(handles.text4,'string'));
        if current_bin > length(flt(i2).pres)
            set(handles.text4,'string',num2str(length(flt(i2).pres)))
        end
        
        gui_plot_profile(hObject, eventdata, handles,1)
        
        popup_sel_index = get(handles.axes1_menu, 'Value');
        switch popup_sel_index
            case 1
                gui_plot_temperature(hObject, eventdata, handles,4)
                gui_plot_flags(hObject, eventdata, handles,5,'temp')
                
            case 2
                gui_plot_salt(hObject, eventdata, handles,4)
                gui_plot_flags(hObject, eventdata, handles,5,'psal')
        end
        
        popup_sel_2 = get(handles.popupmenu7, 'Value');
        switch popup_sel_2
            case 1
                % trajectory
            case 2
                gui_plot_ts(hObject, eventdata, handles,2)
            case 3
                gui_plot_temperature(hObject, eventdata, handles,2)
            case 4
                gui_plot_salt(hObject, eventdata, handles,2)
            case 8
                gui_plot_section(hObject, eventdata, handles,2,'temp',1)
            case 9
                gui_plot_section(hObject, eventdata, handles,2,'psal',1)
            case 10
                gui_plot_ts_climatology(hObject, eventdata, handles,2)
        end
        
    case 'uparrow'
        % decrement bin counter by one and replot.
        current_bin = str2double(get(handles.text4,'string'));
        current_profile = str2double(get(handles.text3,'string'));
        
        flt = getappdata(handles.figure1,'mydata');
        ii = find([flt.cycle_number] == current_profile);
        
        if current_bin > 1
            new_bin =  current_bin -1;
        else
            new_bin =  current_bin;
        end
        set(handles.text4,'string',num2str(new_bin))
        
        gui_plot_profile(hObject, eventdata, handles,1)
        
    case 'downarrow'
        % advance bin counter by one and replot.
        current_bin = str2double(get(handles.text4,'string'));
        current_profile = str2double(get(handles.text3,'string'));
        
        flt = getappdata(handles.figure1,'mydata');
        ii = find([flt.cycle_number] == current_profile);
        
        if current_bin < length(flt(ii).pres)
            new_bin =  current_bin +1;
        else
            new_bin =  current_bin;
        end
        set(handles.text4,'string',num2str(new_bin))
        
        gui_plot_profile(hObject, eventdata, handles,1)
end

% --- Executes on button press in button_higher.
function button_higher_Callback(hObject, eventdata, handles)
% hObject    handle to button_higher (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% decrement bin counter by one and replot.
current_bin = str2double(get(handles.text4,'string'));
current_profile = str2double(get(handles.text3,'string'));

flt = getappdata(handles.figure1,'mydata');
ii = find([flt.cycle_number] == current_profile);

if current_bin > 1
    new_bin =  current_bin -1;
else
    new_bin =  current_bin;
end
set(handles.text4,'string',num2str(new_bin))

gui_plot_profile(hObject, eventdata, handles,1)

% --- Executes on button press in button_lower.
function button_lower_Callback(hObject, eventdata, handles)
% hObject    handle to button_lower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% advance bin counter by one and replot.
current_bin = str2double(get(handles.text4,'string'));
current_profile = str2double(get(handles.text3,'string'));

flt = getappdata(handles.figure1,'mydata');
ii = find([flt.cycle_number] == current_profile);

if current_bin < length(flt(ii).pres)
    new_bin =  current_bin +1;
else
    new_bin =  current_bin;
end
set(handles.text4,'string',num2str(new_bin))

gui_plot_profile(hObject, eventdata, handles,1)

% --- Executes on selection change in variables_to_flag.
function variables_to_flag_Callback(hObject, eventdata, handles)
% hObject    handle to variables_to_flag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns variables_to_flag contents as cell array
%        contents{get(hObject,'Value')} returns selected item from variables_to_flag

% --- Executes during object creation, after setting all properties.
function variables_to_flag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to variables_to_flag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in flag_select.
function flag_select_Callback(hObject, eventdata, handles)
% hObject    handle to flag_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns flag_select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from flag_select

% --- Executes during object creation, after setting all properties.
function flag_select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flag_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in flag_point.
function flag_point_Callback(hObject, eventdata, handles)
% hObject    handle to flag_point (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Apply flag to Point
current_profile = str2double(get(handles.text3,'string'));
flt = getappdata(handles.figure1,'mydata');
ii = find([flt.cycle_number] == current_profile);
current_bin = str2double(get(handles.text4,'string'));

popup_flag_val = get(handles.flag_select, 'Value'); %query popup to determine what flag value is specified.
popup_flag_obj = get(handles.variables_to_flag, 'Value'); %query popup to determine what variables to apply flag value to

switch popup_flag_obj
    case 1  % flag only variable in foreground
        popup_sel_index = get(handles.axes1_menu, 'Value'); %query popup to determine what variable is in fore
        switch popup_sel_index
            case 1
                props = {'temp'};
            case 2
                props = {'psal'};
        end
    case 2  %flag T,S
        props = {'temp','psal'};
    case 3  % Flag P,T, S
        props = {'pres','temp','psal'};
end

%set the flag
for i = 1:length(props)
    flt = setfield(flt,{ii},[char(props(i)),'_qc'],{current_bin},num2str(popup_flag_val));
end

flt(ii).editted = 1;  %mark as editted
setappdata(handles.figure1,'mydata',flt);
gui_plot_profile(hObject, eventdata, handles,1);

popup_sel_index = get(handles.axes1_menu, 'Value'); %query popup to determine what variable is in fore
switch popup_sel_index
    case 1
        prop = 'temp';
    case 2
        prop = 'psal';
end
gui_plot_flags(hObject, eventdata, handles,5,prop)

popup_sel_index = get(handles.popupmenu7, 'Value');
switch popup_sel_index
    case 2
        gui_plot_ts(hObject, eventdata, handles,2)
    case 8
        gui_plot_section(hObject, eventdata, handles,2,'temp',1)
    case 9
        gui_plot_section(hObject, eventdata, handles,2,'psal',1)
end

% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Apply flag to Point and all ABOVE

current_profile = str2double(get(handles.text3,'string'));
flt = getappdata(handles.figure1,'mydata');
ii = find([flt.cycle_number] == current_profile);
current_bin = str2double(get(handles.text4,'string'));

popup_flag_val = get(handles.flag_select, 'Value');%query popup to determine what flag value is specified.
popup_flag_obj = get(handles.variables_to_flag, 'Value');%query popup to determine what variables to apply flag value to
popup_sel_index = get(handles.axes1_menu, 'Value'); %query popup to determine what variable is in fore


switch popup_flag_obj
    case 1  % flag only variable in foreground
        switch popup_sel_index
            case 1
                props = {'temp'};
            case 2
                props = {'psal'};
        end
    case 2  %flag T,S;
        props = {'temp','psal'};
    case 3  % Flag P,T, S
        props = {'pres','temp','psal'};
end

%set the flag
for i = 1:length(props)
    flt = setfield(flt,{ii},[char(props(i)),'_qc'],{1:current_bin},num2str(popup_flag_val));
end
flt(ii).editted = 1;  %mark as editted
setappdata(handles.figure1,'mydata',flt);
gui_plot_profile(hObject, eventdata, handles,1)

switch popup_sel_index
    case 1
        prop = 'temp';
    case 2
        prop = 'psal';
end

gui_plot_flags(hObject, eventdata, handles,5,prop)
popup_sel_index = get(handles.popupmenu7, 'Value');
switch popup_sel_index
    case 2
        gui_plot_ts(hObject, eventdata, handles,2)
    case 8
        gui_plot_section(hObject, eventdata, handles,2,'temp',1)
    case 9
        gui_plot_section(hObject, eventdata, handles,2,'psal',1)
end

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Apply flag to Point and all BELOW

current_profile = str2double(get(handles.text3,'string'));
flt = getappdata(handles.figure1,'mydata');
ii = find([flt.cycle_number] == current_profile);
current_bin = str2double(get(handles.text4,'string'));
max_bin = length(getfield(flt,{ii},'pres'));

%query popup to determine what flag value is specified.
popup_flag_val = get(handles.flag_select, 'Value'); %query popup to determine what variables to apply flag value to
popup_flag_obj = get(handles.variables_to_flag, 'Value');
popup_sel_index = get(handles.axes1_menu, 'Value');

switch popup_flag_obj
    case 1  % flag only variable in foreground
        switch popup_sel_index
            case 1
                props = {'temp'};
            case 2
                props = {'psal'};
        end
    case 2  %flag T,S
        props = {'temp','psal'};
    case 3  % Flag P,T, S
        props = {'pres','temp','psal'};
end

%set the flag
for i = 1:length(props)
    flt = setfield(flt,{ii},[char(props(i)),'_qc'],{current_bin:max_bin},num2str(popup_flag_val));
end
flt(ii).editted = 1;  %mark as editted
setappdata(handles.figure1,'mydata',flt);
gui_plot_profile(hObject, eventdata, handles,1)

switch popup_sel_index
    case 1
        prop = 'temp';
    case 2
        prop = 'psal';
end
gui_plot_flags(hObject, eventdata, handles,5,prop)

% --- Executes on button press in togglebutton2.
function togglebutton2_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of togglebutton2

% --- Executes on button press in save_changes.
function save_changes_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to save_changes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%save the changes
%make directory
flt = getappdata(handles.figure1,'mydata');
if ~strcmp(flt(1).inpath,flt(1).outpath)
    if exist(flt(1).outpath,'dir')==0
        mkdir(flt(1).outpath)
    end
    if ismac==1
        eval(['!cp ',flt(1).inpath,filesep,'* ',flt(1).outpath])
    elseif ispc==1
        fprintf('    > Copying Argo Profiles from "%s" "%s" \n',flt(1).inpath,flt(1).outpath)
        eval(sprintf('!copy "%s" "%s"',flt(1).inpath,flt(1).outpath))
    end
end
wrt_flt_gdac(flt);

% --- Executes on key press with focus on quit_no_save and none of its controls.
function quit_no_save_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to quit_no_save (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in popupmenu7. This is the menu that
% selects the different graphics
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        popupmenu7
popup_sel_index = get(handles.popupmenu7, 'Value');
switch popup_sel_index
    case 1
        gui_plot_pos(hObject, eventdata, handles,2,0)
    case 2
        gui_plot_ts(hObject, eventdata, handles,2)
    case 3
        gui_plot_temperature(hObject, eventdata, handles,2)
    case 4
        gui_plot_salt(hObject, eventdata, handles,2)
    case 5
        gui_plot_flags(hObject, eventdata, handles,2,'pres')
    case 6
        gui_plot_flags(hObject, eventdata, handles,2,'temp')
    case 7
        gui_plot_flags(hObject, eventdata, handles,2,'psal')
    case 8
        gui_plot_section(hObject, eventdata, handles,2,'temp',0)
    case 9
        gui_plot_section(hObject, eventdata, handles,2,'psal',0)
    case 10
        gui_plot_ts_climatology(hObject, eventdata, handles,2)
end

% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in zoom_axes1.
function zoom_axes1_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structumintre with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of zoom_axes1
axs = 1;
eval(['axes(handles.axes',num2str(axs),');'])
button_state = get(hObject,'Value');
if button_state == 1
    zoom on
else
    zoom off
end

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents z= cellstr(get(hObject,'String')) returns popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu8


% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
