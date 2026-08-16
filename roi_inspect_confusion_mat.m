function roi_inspect_confusion_mat(cfg)

cfg = config(cfg);
% Note: add RSA toolbox to config.m if needed
cfg.corrType =    'Kendall_taua'; % ; 'Pearson'; %   'Spearman'; %

cfg.condVec = 1:18;
cfg.catVec = [1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,3,4];

for iROI = 1:length(cfg.ROIVec)
    cfg.mask_fn = cfg.ROImask{cfg.ROIVec(iROI)};
    corrMat_ROI = sprintf('%s/ROI/N%d_%s_%s_%s_sm%dmm_volume_rad%d',cfg.path,length(cfg.SubVec),cfg.ROImask{cfg.ROIVec(iROI)},cfg.type,cfg.type2,cfg.smoothing,abs(cfg.radius));
    %     if exist([corrMat_ROI '.mat'],'file')
    %         load(corrMat_ROI);
    %     else
    [Ysub, RDMs_true] = load_corr_maps(cfg);
    %         save(corrMat_ROI,'Ysub', 'RDMs_true');
    %     end
    
    %% get the model RDMs
    
    %     cfg.TestNames = cfg.rdmLabels;
    %
    %     [RDMs] = create_rdms(cfg.SubVec,0);
    %
    %     for iTest = 1:length(cfg.TestVec)
    %         RDMs_model(iTest).RDM = RDMs.mat{cfg.TestVec(iTest)};
    %         RDMs_model(iTest).name = RDMs.labels{cfg.TestVec(iTest)};
    %         RDMs_model(iTest).color = [0 0 1];
    %         %RDMs_model(iTest).condLabels = cfg.condLabels(cfg.condVec);
    %     end
    %
    %
    userOptions.analysisName = sprintf('%s_%s', cfg.type2, cfg.ROImask{cfg.ROIVec(iROI)});
    if length(userOptions.analysisName)>60
        userOptions.analysisName = userOptions.analysisName(1:60);
    end
    userOptions.rootPath = sprintf('%s/ROI/niliRSA/%s',cfg.path, userOptions.analysisName);
    [SUCCESS,MESSAGE,MESSAGEID] = mkdir(userOptions.rootPath);
    
    %     userOptions.resultsPath = userOptions.rootPath;
    %     userOptions.saveFiguresPDF = 0;
    %     userOptions.saveFiguresPS = 0;
    %     userOptions.saveFiguresEps = 0;
    %     userOptions.saveFiguresFig = 0;
    %     userOptions.saveFiguresJpg = 1;
    
    p=[1 0 0.6]; % pink
    r=[1 0 0.2]; % red
    g=[0 0.6 0.4]; % green
    b=[0 0.6 0.8]; % blue
    colors = [r;b;g; p];
    
    
    userOptions.conditionLabels = cfg.condLabels(cfg.condVec);
    userOptions.conditionColours = colors(cfg.catVec(cfg.condVec),:);
    userOptions.convexHulls = cfg.catVec(cfg.condVec);
    
    
    if cfg.reorderConds==1
        idx= cfg.ReorderVec;
        userOptions.conditionLabels = userOptions.conditionLabels(idx);
        userOptions.conditionColours = userOptions.conditionColours(idx,:);
        %userOptions.convexHulls = userOptions.convexHulls(idx);
        
        for iSub = 1:length(cfg.SubVec)
            RDMs_true(iSub).RDM = RDMs_true(iSub).RDM(idx,idx);
        end
        
        for iTest = 1:length(cfg.TestVec)
            RDMs_model(iTest).RDM = RDMs_model(iTest).RDM(idx,idx);
        end
        
    end
    
    % userOptions.customMask = cfg.customMask;
    userOptions.distanceMeasure = cfg.corrType; %'Spearman';
    
    RDMs_true = averageRDMs_subjectSession(RDMs_true, 'session');
    averageRDMs_true = averageRDMs_subjectSession(RDMs_true, 'subject');
    averageRDMs_true.condLabels = userOptions.conditionLabels;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %% First-order analysis %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % % Display the RDMs
    % figureRDMs(concatenateRDMs(RDMs_true, averageRDMs_true), userOptions, struct('fileName', 'RDMs', 'figureNumber', 1));
    % figureRDMs(averageRDMs_true, userOptions, struct('fileName', 'RDMs', 'figureNumber', 1));
    userOptions.colourScheme = 'paruly'; % 'autumn'; %
    figureRDMs(averageRDMs_true, userOptions, struct('fileName', 'RDMs', 'figureNumber', 1));
    set(gcf, 'PaperPosition', [0 0 12 6]); %x_width=10cm y_width=15cm
    fig_fn = sprintf('%s/figures/neuralRDM_%s_%s', cfg.path, cfg.type2, cfg.ROImask{cfg.ROIVec(iROI)});
    print(fig_fn,'-djpeg','-r300');
    close all;
    
    %    figureRDMs(RDMs_model, userOptions, struct('fileName', 'modelRDMs', 'figureNumber', 2));
    %                 set(gcf, 'PaperPosition', [0 0 15 15]); %x_width=10cm y_width=15cm
    % fig_fn = sprintf('%s/figures/modelRDMs', cfg.path);
    % print(fig_fn,'-djpeg','-r300');
    % close all;
    %
    % Determine dendrograms for the clustering of the conditions for the two data
    % streams
    %   [blankConditionLabels{1:size(averageRDMs_true(1).RDM, 2)}] = deal(' ');
    dendrogramConditions(averageRDMs_true, userOptions, struct('titleString', 'Dendrogram of conditions', 'figureNumber', 3));
    set(gcf, 'PaperPosition', [0 0 10 10]); %x_width=10cm y_width=15cm
    fig_fn = sprintf('%s/figures/dendrogram_%s_%s', cfg.path, cfg.type2, cfg.ROImask{cfg.ROIVec(iROI)});
    print(fig_fn,'-djpeg','-r300');
    close all;
    
    %% print dendrograms of models
    %     for iTest = 1:length(cfg.TestVec)
    %     dendrogramConditions(RDMs_model(iTest), userOptions, struct('titleString', RDMs_model(iTest).name, 'figureNumber', iTest+10));
    %     end
    %     close all;
    
    % Display MDS plots for the condition sets for both streams of data
    localOptions.titleString = 'MDS of conditions';
    localOptions.figureNumber = 6;
    localOptions.fontSize = 8;
    MDSConditions(averageRDMs_true, userOptions, localOptions);
    set(gcf, 'PaperPosition', [0 0 10 10]); %x_width=10cm y_width=15cm
    fig_fn = sprintf('%s/figures/MDS_%s_%s', cfg.path, cfg.type2, cfg.ROImask{cfg.ROIVec(iROI)});
    print(fig_fn,'-djpeg','-r300');
    close all;
    
end