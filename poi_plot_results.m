function poi_plot_results(cfg)

cfg = config(cfg);


% BarColors =brighten(jet(length(cfg.TestVec)),-0.2); %[1 0 0;  0 1 0;   0 0 1;  1 0 1];
o=[0 0 1];
p=[1 0 0];
s=[0 0.8 0];
j=[0 0.5 1];

% o = brighten([1 0 0],-0.2); %[1 0 0;  0 1 0;   0 0 1;  1 0 1];
% p = brighten([1 0 0],-0.5);
% o=[0.85 0.07 0.18];
% j=[0.75 0.32 0.09];
% s=[0.07 0.30 1];
% p=[0.30 0.74 0.93];
BarColors = [o; j; s; p];

% load data
resName = sprintf('%s/ROI/pathOfInterest/PathOfInterest_ROI_%s_%s_rad%d_spacing%d_%s_%s',cfg.path, cfg.sessionName, cfg.testTag, cfg.radiusExtract, cfg.gap, cfg.type, cfg.ROIfile);

load(resName);

resMAT=[];
resCondMAT=[];
groupMean=[];
groupSEM=[];
subtractMean=[];
groupMean2=[];
groupSEM2=[];

Y = [];
TEST = [];
ROI = [];
SUBJECT = [];

for iTest = 1:length(cfg.TestVec)
    for iSub = 1:length(cfg.SubVec)
        % get data from struct in mat.
        % resMAT(iSub,:) = res.subHemiCondVOI(iSub,cfg.TestVec(iTest)).VOI;
        % demean
        for iTest2 = 1:length(cfg.TestVec)
            allConds(iTest2,:) = res.subHemiCondVOI(iSub,cfg.TestVec(iTest2)).VOI;
            
        end
        
        if cfg.demean == 1
            resMAT(iSub,:) = res.subHemiCondVOI(iSub,cfg.TestVec(iTest)).VOI - mean(allConds);
        else
            resMAT(iSub,:) = res.subHemiCondVOI(iSub,cfg.TestVec(iTest)).VOI ;
        end
        
        %% flip (if needed. here: we want from dorsal to ventral)
%         resMAT(iSub,:) = fliplr(resMAT(iSub,:));
        
        %% remove the most ventral ROIs
        %resMAT2 = resMAT(:,1:end-2);
        resMAT2 = resMAT;
        %% get data into ANOVA structure
        for iROI = 1:size(resMAT2,2)
            Y = [Y resMAT2(iSub,iROI)];
            TEST = [TEST iTest];
            ROI = [ROI iROI];
            SUBJECT = [SUBJECT iSub];
        end
        
    end
    groupMean(iTest,:) = mean(resMAT2,1);
    groupSEM(iTest,:) = std(resMAT2)/sqrt(size(resMAT2,1));
    groupData(:,:,iTest) = resMAT2;
    
end

%% T tests

for iROI = 1:size(groupData,2)
[H P(iROI) CI STATS] = ttest(groupData(:,iROI,1),groupData(:,iROI,2));
end


% plot with error bars
h=figure(1);
set(gcf,'Units','points','Position',[100 100 700 500],'Color','w');

interpolatePoints=1;

if interpolatePoints==1
    smoothVal=3;
    nPoints=length(groupSEM)*smoothVal;
    for iRow=1:size(groupSEM,1)
        xy = interparc(nPoints,1:length(groupSEM),groupSEM(iRow,:),'spline');
        groupSEM2(iRow,:) = xy(:,2);
        xy = interparc(nPoints,1:length(groupMean),groupMean(iRow,:),'spline');
        groupMean2(iRow,:) = xy(:,2);
    end
    
    errorlines=shiftdim(cat(3,groupSEM2,groupSEM2),1);
    [h hp]=boundedline(xy(:,1)', groupMean2,  errorlines, 'alpha','cmap',BarColors);
else
    errorlines=shiftdim(cat(3,groupSEM,groupSEM),1);
    [h hp]=boundedline(1:size(groupMean,2), groupMean,  errorlines, 'alpha','cmap',BarColors);
end

set(h, 'linewidth', 3);



%title(sprintf('%s %s', hemi,res.cfg.ROINames{iROI}), 'fontsize', 16);


% add line at chance level
%line('XData', [0.5 length(groupMean)+0.5], 'YData', [0 0], 'LineWidth', 1,'LineStyle', '--', 'Color', [0 0 0]);



if strcmp(cfg.type,'univariate')
    % set legend, title, axes,..
     legend(cfg.TestNames(cfg.TestVec),'Location','NorthEastOutside', 'FontSize',14)
     ylabel('normalized beta','fontsize', 18);
     yAxis = [0 15];
%         set(gca,'ytick',[-1:0.5:1],'TickDir','out');
    title(sprintf('Univariate %s  %s', cfg.ROIfile, cfg.testTag));
    
elseif strcmp(cfg.type,'glmRSA_searchlight')
    % set legend, title, axes,..
    legend(cfg.rdmLabels(cfg.TestVec),'Location','NorthEastOutside', 'FontSize',14)
    ylabel('correlation','fontsize', 18);
    yAxis = [-0.30 0.7];
    title(sprintf('%s  %s', cfg.ROIfile, cfg.testTag));
     set(gca, 'ytick', [-0.30:0.1:0.70],'TickDir', 'out','fontsize', 20);
elseif strcmp(cfg.type,'classify')
    legend(cfg.TestNames(cfg.TestVec),'Location','NorthEastOutside', 'FontSize',14)
    ylabel('accuracy','fontsize', 18);
    yAxis = [0 0.35];
    title(sprintf('%s  %s', cfg.ROIfile, cfg.testTag));
%   set(gca, 'ytick', [0:0.05:0.25],'TickDir', 'out','fontsize', 20);
end

xAxis = ([0 22]);
axis([xAxis yAxis]);

% remove x axis completely
set(gca,'box','off'); % ,'xcolor',[1 0.999 1]
% set(gca,'xtick',1:size(groupMean,2)/8:size(groupMean,2));
set(gca, 'xtickLabel',[1:2:25],'TickDir', 'out');
%set(gca,'xcolor',[1 1 1])
xlabel('Tal z','fontsize', 24);

%hxlab = xlabel('posterior to anterior (in 3 mm) ','fontsize', 16);

%         xAxis = [0.5 size(groupMean,2)+0.5];
%         yAxis = [minval-1 maxval+1];
%         axis([xAxis yAxis]);
% set(gca,'Position',[0.1 0.1 0.8 0.6]);
%saveas(h,[plotname,'.jpg']);

% export_fig(plotname,  '-jpg', '-r300','-transparent');

fig_fn = sprintf('%s/figures/N%02d_PathOfInterest_rad%d_spacing%d_%s_%s_%s_%s',cfg.path, length(cfg.SubVec),cfg.radiusExtract, cfg.gap, cfg.type, cfg.ROIfile,cfg.testTag,cfg.sessionName);
% set(gca, 'PaperPosition', [0 0 8 10]); %x_width=10cm y_width=15cm
print(fig_fn,'-djpeg','-r300');


%% ANOVA
    FACTORS={TEST ROI SUBJECT};
    [P,table,STATS,TERMS] = anovan(Y, FACTORS, 'random',3,'model','interaction','display','on','varnames', {'TEST' 'ROI' 'SUBJECT'}); 
   
%   close all; 
    
end




function yy = smooth(y, span)
yy = y;
l = length(y);

for i = 1 : l
    if i < span
        d = i;
    else
        d = span;
    end
    
    w = d - 1;
    p2 = floor(w / 2);
    
    if i > (l - p2)
        p2 = l - i;
    end
    
    p1 = w - p2;
    
    yy(i) = sum(y(i - p1 : i + p2)) / d;
end
end



