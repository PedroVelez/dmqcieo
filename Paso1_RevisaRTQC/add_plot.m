function [m,b,hadp] = add_plot(x,y,ltype,tlabel);
%function add_plot(x,y,ltype,label)
% overplots new line to existing plot  keeping same y scale but creating a new
% x-scale.   An axis for the new x-scale is added to the top of the plot.
%   x: vector of x values
%   y: vector of y values
%   ltype: (opt) string designating line color and type
%   label: a label for the axis
%
%  requires add_scale.m
%
% Paul E. Robbins copyright 1997.
%  (probbins@ucsd.edu; http://gyre.ucsd.edu/~robbins/)

if nargin == 2;
    ltype = 'k-';
end

if nargin <4
    tlabel = ' ';
end

xl = get(gca,'xlim');
xt = get(gca,'xtick') ;

% try to figure out good numbers from x
N = length(xt);
minx = min(x);
maxx = max(x);
difx = maxx-minx;
dx = difx/N; % size of  increment of x;
% now round this increment to one signficant figure
p = fix(log10(dx));
if dx < 1
    p = p-1;
end
DX = fix((dx/(10^p)))*10^p;		%  this is increment

% now figure out min and max
MINX = floor((minx/(10^p)))*10^p;
MAXX = ceil((maxx/(10^p)))*10^p;

X = MINX:DX:MAXX;

%figure out transformation of new x to old x scale
tl = [MINX-DX/2 MAXX+DX/2];
m = diff(xl)/diff(tl);
b = xl(1) - m*tl(1);
hold on
if isstr(ltype)
    hadp=plot(x*m+b,y,ltype);
else
    hadp=plot(x*m+b,y,'color',ltype);
end

%add scale
newxtick = X*m+b;

% pull color out of linetype
if isstr(ltype)
    clr = ltype(1);
else
    clr = ltype;
end

%h = add_scale('t',newxtick,X,clr);
%h2 = get(h,'ylabel');
%set(h2,'string',tlabel,'color',clr,'rotation',0);

function h2=add_scale(ax,ticks,labels,clr)
%function add_scale(axis,ticks)
%function add_scale(axis,ticks,color)
%function add_scale(axis,ticks,labels)
%function add_scale(axis,ticks,labels,color)
%
%add an additional scale to an existing plot.
%
%  INPUTS:
%    axis: either 't' or 'r' for TOP or RIGHTHAND
%    ticks: vector of location of additional ticks
%    labels (opt): matrix of strings (same length as ticks) for ticklabels
%         default is to labels with numeric values of tick
%    color (opt): color or scale and labels (default is white)
%
% Paul E. Robbins copyright 1995.
%  (probbins@ucsd.edu; http://gyre.ucsd.edu/~robbins/)

% sep 10 99; added check for axes type

if nargin == 2
    labels = [];
    for i = 1:length(ticks)
        labels = str2mat(labels,num2str(ticks(i)));
    end
    labels = labels(2:size(labels,1),:);
    clr = 'k';
end

if ~isstr(labels)
    %assume its a vector of numbers to convert to strings
    sstr = [];
    for i = 1:length(labels)
        if isnan(labels(i))
            sstr = str2mat(sstr,' ');
        else
            sstr = str2mat(sstr,num2str(labels(i)));
        end
    end
    labels = sstr(2:length(labels)+1,:);
end


if nargin == 3
    %figure out if third argument is labels or color
    if length(labels) > 1
        %assume a matrix of characters is a set of labels
        clr = 'k';
    else
        clr = labels;
        labels = [];
        for i = 1:length(ticks)
            labels = str2mat(labels,num2str(ticks(i)));
        end
        labels = labels(2:size(labels,1),:);
    end
    
end

if length(labels) < 1 		%if a null matrix is passed for  %labels
    for i = 1:length(ticks)
        labels = str2mat(labels,'  ');
    end
end

h = gca;
pos = get(h,'position');
xl = get(h,'xlim'); yl = get(h,'ylim');
sc = 1/18;  %amount to shrink the

if strcmp(ax,'T') | strcmp(ax,'t')
    % for adding ticks to top
    titlestr = get([get(h,'title')],'string');
    set([get(h,'title')],'string',' ')
    newpos = [pos(1) pos(2) pos(3) pos(4)*(1-sc)];
    set(h,'position',newpos)
    
    addpos = [pos(1) pos(2)+pos(4)*(1-sc) pos(3) pos(4)*sc];
    subplot('position',addpos)
    h2 = gca;
    for i = 1:length(ticks)
        plot([ticks(i) ticks(i)],[0 .3],'color',clr)
        hold on
        text(ticks(i),.4,labels(i,:),'Rotation',90,'FontSize',8,'color',clr);
    end
    plot([ticks(1) ticks(length(ticks))],[0 0],'color',clr)
    title(titlestr)
    hold off
    set(h2,'ylim',[0 1],'xlim',xl,'ytick',[],'xtick',[]);
    
    
    %set(h2,'visible','off')
    box off
    set(h2,'ycolor',[0 0 0])
    set(h2,'xcolor',[0 0 0])
elseif strcmp(ax,'R') | strcmp(ax,'r')
    ydir = get(gca,'ydir');
    % for adding ticks to right
    newpos = [pos(1) pos(2) pos(3)*(1-sc) pos(4)];
    set(h,'position',newpos)
    addpos = [pos(1)+pos(3)*(1-sc) pos(2) pos(3)*sc pos(4)];
    subplot('position',addpos)
    h2 = gca;
    for i = 1:length(ticks)
        plot([0 .3],[ticks(i) ticks(i)],'color',clr)
        hold on
        text(0.4,ticks(i),labels(i,:),'FontSize',8,'color',clr);
    end
    plot([0 0],[ticks(1) ticks(length(ticks))],'color',clr)
    hold off
    set(h2,'ylim',yl,'xlim',[0 1],'visible','off','ydir',ydir)
else
    display('Unable to resolve axis designator')
end
%resest main plot to be current axis

set(gcf,'currentaxes',h)

% search current window to see if any previous 'add-scales' need to be
% modified
% get new position of main window
pos = get(h,'position');

kids = get(gcf,'children');
kids(kids == h) = [];
for j = 1:length(kids)
    if strcmp(get(kids(j),'type'),'axes')
        kidxl = get(kids(j),'xlim');
        kidyl = get(kids(j),'ylim');
        kidpos = get(kids(j),'position');
        if all(kidxl == xl) & kidpos(1)==pos(1)
            %if its a top scale make sure to set width to size of main window
            set(kids(j),'position',[kidpos(1) kidpos(2) pos(3) kidpos(4)])
        elseif      all(kidyl == yl) & kidpos(2)==pos(2)
            %if its a top scale make sure to set width to size of main window
            set(kids(j),'position',[kidpos(1) kidpos(2) kidpos(3) pos(4)])
        end
    end
end
%
%set(gcf,'currentaxes',h)
