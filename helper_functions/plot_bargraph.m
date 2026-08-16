function plot_bargraph(cfg)
% input: cfg.data (subjects x roi x test)

% Note: add myaa (anti-aliasing) toolbox to path if needed


%% PLOT

inputData = cfg.data;
labels = cfg.labels;

for iTest = 1:size(inputData,3)
    for iROI = 1:size(inputData,2)
        % get mean and sem
        meanAcc(iROI,iTest) = mean(inputData(:,iROI,iTest));
        semAcc(iROI,iTest) = std(inputData(:,iROI,iTest)/sqrt(length(inputData(:,iROI,iTest))));
                
        % compute t test
        [H,P,CI,STATS] = ttest(inputData(:,iROI,iTest),0,0.05,'right');
        tRes(iROI,iTest) = P;
        tResT(iROI,iTest) = STATS.tstat;
        
    end
end




%meanAcc = fliplr(flipud(meanAcc));
%semAcc = fliplr(flipud(semAcc));
%tRes = fliplr(flipud(tRes));


h=figure;

% % %change width of bar width
overallWidth = 0.8;
[rrr,c] = size(meanAcc);
hbar = zeros(c,1);
width = overallWidth / c ;

if size(meanAcc,2)==2
    AdjnumberOfBars=0.5;
elseif size(meanAcc,2)==3
    AdjnumberOfBars=1;
    cfg.moveAsterisk = 0.015;
elseif size(meanAcc,2)==4
    AdjnumberOfBars=1.5;  
    cfg.moveAsterisk = 0.006;
elseif size(meanAcc,2)==5
    AdjnumberOfBars=1;  
    cfg.moveAsterisk = 0.003;
else
    AdjnumberOfBars=3.5;
    cfg.moveAsterisk = 0.006;
end
% 
offset = [-width:width*2/(c-1):width]*AdjnumberOfBars; % 4 bars=1.5, 2 bars=0.5
for i=1:c
    hbar(i) = bar(meanAcc(:,i),'BarWidth',width);
    set(hbar(i),'XData',get(hbar(i),'XData')+offset(i));
    hold on
end

% 
 iBar=0;
for i=1: size(meanAcc,2)
    iBar=iBar+1;
    set(hbar(iBar), 'facecolor', cfg.BarColors(i,:), 'edgecolor', 'k');
end

%cfg.moveAsterisk = 0.003;
%bar(meanAcc);

% set dimensions
xAxis = [0.5 length(meanAcc)+0.5];
yAxis = [min(cfg.range) max(cfg.range)];
axis([xAxis yAxis]);

% add error bars
hold on;
semRreordered = semAcc; %reshape(semR,length(Cfg.TaskVec),4)';
numgroups = size(semAcc, 1);
numbars = size(semAcc, 2);
groupwidth =  min(0.8, numbars/(numbars+AdjnumberOfBars)); %

% do fdr correction

for iNum = 1:numgroups
    %pVec(iNum) = tRes(iNum,:);
    [p_fdr_ROI(iNum), p_masked_ROI(iNum,:)] = fdr(tRes(iNum,:), 0.05);
end

for iNum = 1:numbars
    %pVec(iNum) = tRes(:,iNum);
    [p_fdr_tests(iNum), p_masked_tests(iNum,:)] = fdr(tRes(:,iNum), 0.05);
end
[p_fdr_all, p_masked_all] = fdr(tRes(:), 0.05);
p_masked_all = reshape(p_masked_all,numgroups,numbars);

for i = 1:numbars
    x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars); % Aligning error bar with individual bar
    errorbar(x, meanAcc(:,i), semAcc(:,i), 'k', 'linestyle', 'none');
    if cfg.significance==1
        % add asterisks for significance
        for j=1:numgroups
            if tRes(j,i) < 0.05 % one-tailed
                % find alpha level
                if tRes(j,i) < 0.005
                    alpha = '* * *';
                elseif tRes(j,i) < 0.01
                    alpha = '* *';
                elseif tRes(j,i) < 0.05
                    alpha = '*';
                end
                
                if cfg.sigP==1
                    p = sprintf('%s (p = %0.2g)',alpha,tRes(j,i));
                else
                    p =sprintf('%s',alpha);
                end
                
                if (cfg.fdr_corr ==1) && (tRes(j,i) <= p_fdr_all) % p_fdr_ROI(j)
                    text(x(j)+cfg.moveAsterisk,meanAcc(j,i)+semAcc(j,i)+0.03,p,'HorizontalAlignment','left','Color','r','FontName','Times New Roman','Fontsize',16,'Rotation',90);
                else
                    text(x(j)+cfg.moveAsterisk,meanAcc(j,i)+semAcc(j,i)+0.03,p,'HorizontalAlignment','left','FontName','Times New Roman','Fontsize',16,'Rotation',90);
                end
                
                
            end
        end
    end
end

% set box property to off and remove background color
set(gca,'box','off','color','none');

% Remove the default labels
set(gca,'XTickLabel','')

% add labels
% if iHemi==1
% labels = {'left DLOTC', 'left VLOTC'};
% else
% labels = {'right DLOTC', 'right VLOTC'};
% end

Xt = [1:1:length(labels)];
Xl = [0.5 length(labels)+0.5];
set(gca,'XTick',Xt,'XLim',Xl);

% set(gca, 'Ticklength', [0 0])
% 
set(gca, 'ytick', cfg.range,'TickDir', 'out');
set(gca,'XTick',[])
%set(gca,'XColor','w')

set(gca, 'xtickLabel', labels);
set(gca, 'fontsize', 16);
%hxlab = xlabel('Condition');
hylab = ylabel(cfg.ylabel);
%set(hxlab, 'Fontsize', 20);
set(hylab, 'Fontsize', 16);

if ~isempty(cfg.Testlabels)
hleg = legend(cfg.Testlabels);
set(hleg, 'fontsize', 16, 'box', 'off');
end


% adjust figure size
if ~isempty(cfg.adjustFigureSize)
set(gcf,'position',cfg.adjustFigureSize);
end

set(gcf,'color',[1 1 1]); % Set the figure frame color to white
set(gca,'color',[1 1 1]); % Set the axis frame color to white

%addpath('C:\moritzwurm\stuff');
myaa;
saveas(h,[cfg.plotname,'.tif']);
close all;



function [pID, p_masked] = fdr(pvals, q, fdrType)

if nargin < 3, fdrType = 'parametric'; end;
if isempty(pvals), pID = []; return; end;
p = sort(pvals(:));
V = length(p);
I = (1:V)';

cVID = 1;
cVN = sum(1./(1:V));

if nargin < 2
    pID = ones(size(pvals));
    thresholds = exp(linspace(log(0.1),log(0.000001), 100));
    for index = 1:length(thresholds)
        [tmp p_masked] = fdr(pvals, thresholds(index));
        pID(p_masked) = thresholds(index);
    end;
else
    if strcmpi(fdrType, 'parametric')
        pID = p(max(find(p<=I/V*q/cVID))); % standard FDR
    else
        pID = p(max(find(p<=I/V*q/cVN)));  % non-parametric FDR
    end;
end;
if isempty(pID), pID = 0; end;

if nargout > 1
    p_masked = pvals<=pID;
end