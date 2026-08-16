function roi_analysis_from_maps(cfg)

close all;
cfg = config(cfg);
cfg.barColors = gray(size(cfg.mapVec,2)+2); % repmat([0.5 0.5 0.5],7,1); %[0.5 0.5 0.5; 0.8 0.8 0.8]; %[0.3 0.3 0.3; 0.7 0.7 0.7];
cfg.addAsterisk = 1;
subplotGrouping = 'ROI';

% univariate:
if strcmp(cfg.VOIname,'controlROIs_spherical_9mm_.voi') %strcmp(cfg.VOIname,'controlROIs_spherical_9mm_.voi')
    yBoundStruct={[-2 0 4],[-2 0 4],[0 0 9],[0 0 9]};
    cfg.yTitle='t'; % 'accuracy';
    modifyVal= @(x)(x); % leave values unchanged; if decoding, e.g. @(x)(x * 100 + 12.5); %
else
    % MVPA:
    yBoundStruct={[10 33.33 48],[10 33.33 48],[10 33.33 48],[10 33.33 48],[10 33.33 48],[10 33.33 48],[10 33.33 48],[10 33.33 48],[10 33.33 48],[10 33.33 48],[10 33.33 48],[10 33.33 48],[10 33.33 48]};
    cfg.yTitle= 'accuracy';
    modifyVal=@(x)(x * 100 + 33.33); % @(x)(x); % leave values unchanged; if decoding, e.g. @(x)(x * 100 + 12.5); %
end
%addpath(genpath('C:/moritzwurm/EffectSizeToolbox'));

for iGroup = 1:size(cfg.mapVec,1)
    
    for iCond = 1:size(cfg.mapVec,2)
        
        %% load map
        vmpName=sprintf('%s/vmp/%s/%s',cfg.path,cfg.type,cfg.mapNames{cfg.mapVec(iGroup,iCond)});
        ds = cosmo_fmri_dataset(vmpName,'mask',cfg.mask_name);
        
        disp(sprintf('loading %s...',vmpName));
        
        % get data
        for iROI = 1:length(cfg.ROIVec)
            msk_ds = cosmo_fmri_dataset(sprintf('%s/msk/%s%s.msk',cfg.path,cfg.VOInamer, cfg.ROImask{cfg.ROIVec(iROI)}),'mask',cfg.mask_name);
            ROI_fn{iROI} = cfg.ROImask{cfg.ROIVec(iROI)};
            dataMat(:, iROI ,iCond,iGroup) = mean(ds.samples(1:numel(cfg.SubVec),msk_ds.samples==1),2);
            dataCell{iROI ,iCond,iGroup} = mean(ds.samples(1:numel(cfg.SubVec),msk_ds.samples==1),2);
        end
    end
end

dataMat=squeeze(dataMat);
dataCell=squeeze(dataCell);

%% FDR correction
[H,P_all,CI,STATS] = ttest(dataMat,0,0.05,'right');
T = squeeze(STATS.tstat)
P_all = squeeze(P_all);
[cfg.p_fdr_all, p_masked_all] = fdr(P_all, 0.05);
cfg.thres = cfg.p_fdr_all;

mydataCell = cellfun(modifyVal,dataCell(:), 'uniformoutput',false);
mydataCell = mydataCell';
mydataCell = horzcat(mydataCell{:});
% csvwrite(sprintf('rois_data_%s.csv',cfg.mapNames{cfg.mapVec(iGroup,iCond)}),mydataCell);
fdr_output = [P_all;double(p_masked_all)]
% csvwrite(sprintf('fdr_correct_%s.csv',cfg.mapNames{cfg.mapVec(iGroup,iCond)}),fdr_output);

% %% 1-tailed BF
% data4BF = dataMat(1:21,:);
% save('C:\Users\moritz.wurm\Dropbox\CAD\ROI_T.mat','data4BF');
% load('C:\Users\moritz.wurm\Dropbox\CAD\BF_res');
% BF = reshape(BF_res,5,3);

% %% paired t tests
% ROIperms = nchoosek(1:length(cfg.ROIVec),2)';
% for iVOI = 1:size(ROIperms,2)
%     for iCond = 1:length(cfg.mapVec)
%         [H P(iCond,iVOI) CI STATS] = ttest(dataCell{ROIperms(1,iVOI) ,iCond},dataCell{ROIperms(2,iVOI) ,iCond});
%         disp(sprintf('%s, %s vs. %s: t(%d) = %0.3f, p = %0.4f (%0.2E)', cfg.TestLabels{cfg.mapVec(iCond)}, ROI_fn{ROIperms(1,iVOI)}, ROI_fn{ROIperms(2,iVOI)}, STATS.df, STATS.tstat, P(iCond,iVOI),P(iCond,iVOI)));
%     end
% end



%% plot
if size(cfg.mapVec,1)==1 % no bar grouping
    
    if strcmp(subplotGrouping,'map')
        for iMap = 1:length(cfg.mapVec)
            subplot(1,length(cfg.mapVec),iMap);
            cfg.labels =  cfg.ROImask;
            cfg.subheader = cfg.TestLabels(iMap);
            cfg.yBounds = yBoundStruct{iMap}; %lower_upper_bound;
            cfg.P=P_all(:,iMap);
            data = cellfun(modifyVal,dataCell(:,iMap), 'uniformoutput',false);
            plotBars(data,cfg);
        end
    elseif strcmp(subplotGrouping,'ROI')
        for iROI = 1:length(cfg.ROIVec)
            subplot(1,length(cfg.ROIVec),iROI);
            cfg.labels =  cfg.TestLabels(cfg.mapVec);
            cfg.subheader = cfg.ROImask(iROI);
            cfg.yBounds = yBoundStruct{iROI}; %lower_upper_bound;
            cfg.P=P_all(iROI,:)';
            data = cellfun(modifyVal,dataCell(iROI,:)', 'uniformoutput',false);
            plotBars(data,cfg);
        end
    end
    
elseif size(cfg.mapVec,1)>1 % bar grouping
    if strcmp(subplotGrouping,'ROI')
        for iROI = 1:length(cfg.ROIVec)
            subplot(1,length(cfg.ROIVec),iROI);
            cfg.labels = cfg.TestLabels;
            cfg.subheader = cfg.ROImask(iROI);
            cfg.yBounds = yBoundStruct{iROI};
            cfg.P=squeeze(P_all(iROI,:,:));
            data = cellfun(modifyVal,squeeze(dataCell(iROI,:,:))', 'uniformoutput',false);
            plotBars2(data,cfg.labels,cfg);
        end
    end
    
end

fig_fn = sprintf('../figures/ROI_N%d_%s_%s',length(cfg.SubVec),cfg.analysisName, cfg.fileName);
set(gcf, 'PaperPosition', [0 0 8 2]); %x_width=10cm y_width=15cm
print(fig_fn,'-djpeg','-r600');

%close all;


% %% ANOVA
% Y = [];
% TEST = [];
% SUB = [];
% ROI = [];
% for iSub = 1:length(cfg.SubVec)
%     for iTest = 1:length(cfg.mapVec)
%         for iVOI = 1:length(cfg.ROIVec)
%             Y = [Y dataMat(iSub, iVOI ,iTest)];
%             TEST = [TEST iTest];
%             ROI = [ROI iVOI];
%             SUB = [SUB iSub];
%         end
%     end
% end
% % ANOVA


% % 
% % % Seda's ANOVA
% % Y = [];
% % Agent = [];
% % SUB = [];
% % ROI = [];
% % for iSub = 1:length(cfg.SubVec)
% %     for iTest = 1:length(cfg.mapVec)
% %         for iVOI = 1:length(cfg.ROIVec)
% %             Y = [Y dataMat(iSub, iVOI ,iTest)];
% %             Agent = [Agent iTest];
% %             ROI = [ROI iVOI];
% %             SUB = [SUB iSub];
% %         end
% %     end
% % end
% ANOVA
%
% FACTORS={TEST ROI SUB};
% [P,table,STATS,TERMS] = anovan(Y, FACTORS, 'random',3,'model','full','display','on','varnames', {'TEST' 'ROI' 'SUBJECT'}); % the third factor (subjects, third row) is nested in the second factor (subject group, second column)


%         y = dataCell{iVOI,3} * 100 + 12.5;
%         [H P CI STATS] = ttest2(y(res.presOrder==1),y(res.presOrder==2));
%         BF10 = t2smpbf(STATS.tstat, length(find(res.presOrder==1)),length(find(res.presOrder==2)));
%         disp(sprintf('independent t test, %s: t=%0.3f, p=%0.3f, BF=%0.3f',ROI_fn{iVOI},STATS.tstat,P,BF10));
%
%         iFig=iFig+1;
%         subplot(2,4,iFig);
%         x = res.VIDverbalize';
%         behavName = 'verbalization';
%         plotCorr(x,y,ROIname,behavName, cfg);




function plotCorr(x,y,ROIname,behavName, cfg)

[r p] = corr(x,y);
BF10 = corrbf(r,length(cfg.SubVec));
corrText = sprintf('r=%0.3f, p=%0.3f, BF=%0.3f',r,p,BF10);
disp(sprintf('%s, %s: %s',ROIname, behavName, corrText));
%         scatter(x,y);
%         hold on;
for i = 1:length(x)
    if mod(i,2) % odd
        colorCode = [1 0 0];
    else
        colorCode = [0 0 1];
    end
    plot(x(i),y(i),'o','Color',colorCode,'MarkerSize',6,'LineWidth', 1,'MarkerFaceColor',colorCode);
    hold on;
end

text(1,11,corrText);
underscore2space=@(x) strrep(x,'_',' ');
% title(underscore2space(sprintf('%s',ROIname)),'FontSize',10);
xlabel(behavName,'FontSize',10);
ylabel('mean accuracy','FontSize',10);
xf = [min(x), max(x)];
plot(xf, polyval(polyfit(x,y,1), xf));
axis([0 7 8 20]);
set(gca, 'xtick',1:6,'Fontsize',8);
set(gca, 'ytick',8:2:20,'Fontsize',8);
set(gca, 'box', 'off');
%export_fig('../N22_crossmodalCluster_mcc001_verbalization',  '-jpg', '-r300','-transparent');


function plotBars(data,cfg)
%   aHand =axes('parent', h);
for i = 1:length(data)
    mER = mean(data{i});
    sem = stdErrMean(data{i},1);
    hb = bar(i,mER, 'FaceColor',cfg.barColors(i,:),'EdgeColor','none');
    hold on;
    plot([i i],[mER-sem,mER+sem],'Color',cfg.barColors(i,:),'LineWidth',2)
    hold on;
    %     figure(99);
    %     hbx = plotSpread(data{i},'spreadWidth',1);
    %     jitter = 1 - get(hbx{1},'XData');
    %     close(figure(99));
    
    %plot([i i],[mER-sem,mER+sem],'Color',[0.5 0.5 0.5],'LineWidth',2);
   %plot(i+jitter,data{i},'o','MarkerEdgeColor',[0.4 0.4 0.4],'MarkerFaceColor',[0.7 0.7 0.7],'MarkerSize',3); %
%     [cfg.p_fdr_all, p_masked_all] = fdr(cfg.P_all, 0.05);

    %  hb = errorbar(i,mER,sem, 'Color',[0 0 0],'LineWidth',1);
    if cfg.addAsterisk==1
        asteriskGap =[(cfg.yBounds(end) - cfg.yBounds(1))/20,(cfg.yBounds(end) - cfg.yBounds(1))/20,(cfg.yBounds(end) - cfg.yBounds(1))/20* 3];
        cfg.moveAsterisk=-0.05;
        y =  cfg.yBounds(end) - (cfg.yBounds(end) - cfg.yBounds(1))/20; %70; %double(meanVals(iCond)+SEMVals(iCond)+8);
        if cfg.P(i) <= cfg.thres && cfg.P(i) <= 0.05
            text(i,y,sprintf('*'),'HorizontalAlignment','center','Color','k','FontName','Times New Roman','Fontsize',10,'Rotation',0);
        end
        if cfg.P(i) <= cfg.thres && cfg.P(i) <= 0.01
            text(i,y-asteriskGap(1),sprintf('*'),'HorizontalAlignment','center','Color','k','FontName','Times New Roman','Fontsize',10,'Rotation',0);
        end
        if cfg.P(i) <= cfg.thres && cfg.P(i) <= 0.001
            text(i,y-asteriskGap(2),sprintf('*'),'HorizontalAlignment','center','Color','k','FontName','Times New Roman','Fontsize',10,'Rotation',0);
        end
        if cfg.P(i) <= cfg.thres && cfg.P(i) <= 0.0001
            text(i,y-asteriskGap(3),sprintf('*'),'HorizontalAlignment','center','Color','k','FontName','Times New Roman','Fontsize',10,'Rotation',0);
        end
        
                
    
    end
    
    x = i;
    y = cfg.yBounds(1) - (cfg.yBounds(end) - cfg.yBounds(1))/20;
    text(x,y,cfg.labels{i},'HorizontalAlignment','right','FontName','Arial','Fontsize',-6/10*numel(cfg.labels)+12,'Rotation',45);
end

% plot subject lines
plot(repmat(1:numel(data),numel(data{1,1}),1)',cell2mat(data')','Color',[0 0 1],'LineWidth',0.7);


ylabel(cfg.yTitle, 'fontsize', 10);
set(gca, 'xtick',[],'Fontsize',10);
%set(gca, 'ytick',cfg.yBounds,'Fontsize',10);
% set(gca, 'xtickLabel', cfg.labels,'Fontsize',5);
set(gca, 'box', 'off'); % show only left and lower axes
set(gca,'box','off','xcolor',[1 0.999 1]);
set(gca,'TickDir','out');
xAxis = [0.5 length(data)+0.5];
yAxis = [cfg.yBounds(1) cfg.yBounds(end)];
axis([xAxis yAxis]);
title(cfg.subheader, 'fontsize', 10);

% add line at chance level
line('XData', [0.5 length(data)+0.5], 'YData', [cfg.yBounds(2) cfg.yBounds(2)], 'LineWidth', 0.5,'LineStyle', '--', 'Color', [0 0 0]);

scale = 0.3;
pos = get(gca, 'Position');
pos(2) = pos(2)+scale*pos(4);
pos(4) = (1-scale)*pos(4);
set(gca, 'Position', pos);

scale = 0.2;
pos = get(gca, 'Position');
pos(1) = pos(1)+scale*pos(3);
pos(3) = (1-scale)*pos(3);
set(gca, 'Position', pos);


function plotBars2(data,cfg)
numgroups = size(data,2);
numbars = size(data,1);
overallWidth=0.9; % of the group
gap = 0.05; % between bars
width = overallWidth / numbars;
%offset = [-width/2 width/2];
offset = linspace(-overallWidth/2+width/numbars+gap,overallWidth/2-width/numbars-gap,numbars);

for i = 1:numgroups
    for j = 1:numbars
        mER = mean(data{j,i});
        sem = stdErrMean(data{j,i},1);
        hb = bar(i,mER, 'FaceColor',cfg.barColors(j,:), 'EdgeColor','none','BarWidth',width-gap);
        set(hb,'XData',get(hb,'XData')+offset(j));
        hold on;
        hb = plot([i i],[mER-sem,mER+sem],'Color',cfg.barColors(j,:),'LineWidth',2);
        set(hb,'XData',get(hb,'XData')+offset(j));
        hold on;
        
        xPos(j) = hb.XData(1);
        
        if cfg.addAsterisk==1
            asteriskGap =[(cfg.yBounds(end) - cfg.yBounds(1))/20,(cfg.yBounds(end) - cfg.yBounds(1))/20*2,(cfg.yBounds(end) - cfg.yBounds(1))/20* 3];
            cfg.moveAsterisk=-0.05;
            y =  cfg.yBounds(end) - (cfg.yBounds(end) - cfg.yBounds(1))/50; %70; %double(meanVals(iCond)+SEMVals(iCond)+8);
            if cfg.P(i,j) <= cfg.thres && cfg.P(i,j) <= 0.05
                text(xPos(j),y,sprintf('*'),'HorizontalAlignment','center','Color','k','FontName','Times New Roman','Fontsize',10,'Rotation',0);
            end
            if cfg.P(i,j) <= cfg.thres && cfg.P(i,j) <= 0.01
                text(xPos(j),y-asteriskGap(1),sprintf('*'),'HorizontalAlignment','center','Color','k','FontName','Times New Roman','Fontsize',10,'Rotation',0);
            end
            if cfg.P(i,j) <= cfg.thres && cfg.P(i,j) <= 0.001
                text(xPos(j),y-asteriskGap(2),sprintf('*'),'HorizontalAlignment','center','Color','k','FontName','Times New Roman','Fontsize',10,'Rotation',0);
            end
            if cfg.P(i,j) <= cfg.thres && cfg.P(i,j) <= 0.0001
                text(xPos(j),y-asteriskGap(3),sprintf('*'),'HorizontalAlignment','center','Color','k','FontName','Times New Roman','Fontsize',10,'Rotation',0);
            end
        end
    end
    % plot subject lines
    plot(repmat(xPos,numel(data{1,1}),1)',cell2mat(data(:,i)')','Color',[0 0 1],'LineWidth',0.7);
    
    x = i;
    y = cfg.yBounds(1) - (cfg.yBounds(3) - cfg.yBounds(1))/20;
    text(x,y,cfg.labels{i},'HorizontalAlignment','center','FontName','Arial','Fontsize',-6/10*numel(cfg.labels)+12,'Rotation',0);
end

ylabel(cfg.yTitle, 'fontsize', 8);
set(gca, 'xtick',[],'Fontsize',5);
% set(gca, 'xtickLabel', cfg.labels,'Fontsize',5);
set(gca, 'box', 'off'); % show only left and lower axes
xAxis = [0.5 length(data)+0.5];
yAxis = [cfg.yBounds(1) cfg.yBounds(3)];
axis([xAxis yAxis]);
title(cfg.subheader, 'fontsize', 10);

function plotSubjects2(data,i, offset)
allColors = jet(20);
if ceil(offset)==0
    subjectColors = allColors(1:length(data),:);
else
    subjectColors = allColors(end-length(data):end,:);
end

for iSub = 1:length(data)
    x = i + offset +(rand(size(i))-0.5)*0.3; %add a little random "jitter" to aid visibility
    y = data(iSub);
    plot(x,y,'o', 'MarkerFaceColor',subjectColors(iSub,:),'MarkerEdgeColor',[0 0 0],'MarkerSize',5);
end
