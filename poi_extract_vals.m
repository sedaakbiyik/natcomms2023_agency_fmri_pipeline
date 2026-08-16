function poi_extract_vals(cfg)
% performs ROI analysis in ROIs along axis ("pearl chain")

cfg = config(cfg);
cfg.pathToVMP = sprintf('%s/vmp/%s',cfg.path,cfg.type);

% NeuroElf is added to path via config.m

cfg.ROINames = cfg.ROIfile;

resName = sprintf('%s/ROI/pathOfInterest/PathOfInterest_ROI_%s_%s_rad%d_spacing%d_%s_%s',cfg.path, cfg.sessionName, cfg.testTag, cfg.radiusExtract, cfg.gap, cfg.type, cfg.ROIfile);


for iTest = 1:length(cfg.TestVec)
    
    %load vmp
    
    
    if strcmp(cfg.type,'glmRSA_searchlight')
        %modelVecs = {[1 4 17 2 7], [2 8 13 10], [3 6 9 10 18], [4 1 17], [5 7 15], [6 3 8 9 10 18], [7 5 15 1 4], [8 2 13], [9 3 6], [10 2 3 6 7], [11 2 8 9], [12 2 7 8 9], [13 11 2 8], [14 2 7], [15 16 2 5 7], [16 2 3 15 18], [17 1 4], [18 3 6 16 13 8]};
        
        % regress out all models with p < 0.05
    RDMs = create_rdms(cfg,0);
%         modelVecs = thresh.p;
%         modelVecs{10} = [10 2 3 6 7];
        
%         RDMcode = strrep(num2str(modelVecs{iTest}), '   ', 'x' );
%         RDMcode = strrep(RDMcode, '  ', 'x' );
    betaNames=cfg.rdmLabels;
    cfg.TestNames = cfg.rdmLabels;
    betaVec=cfg.TestVec;
    RDMcode = strrep(num2str(cfg.TestVec(iTest)), '   ', 'x' );
    RDMcode = strrep(RDMcode, '  ', 'x' );
    
    vmpName = sprintf('%s/%s_%s_N%d_%s_%s_%s_%s_%s_sm%dmm_volume_rad%d.vmp',cfg.pathToVMP,cfg.sessionName,cfg.type2,length(cfg.SubVec),cfg.decodingType, cfg.type,RDMcode,betaNames{betaVec(iTest)},cfg.Design,cfg.smoothing,abs(cfg.radius));
    
    elseif strcmp(cfg.type,'univariate')
        
        vmpName= sprintf('%s/vmp/univariate/N%d_singlesubjects_%s_%s_%s_%s_sm%dmm.vmp',cfg.path,length(cfg.SubVec),cfg.sessionName,cfg.TestNames{cfg.TestVec(iTest)},cfg.Design,cfg.motionCorr,cfg.smoothing);
    
    elseif strcmp(cfg.type,'classify')
        
        if strcmp(cfg.decodingType,'within_mod')
            vmpName = sprintf('%s/N%d_%s_%s_%s_%s_%s_sm%dmm_volume_rad%d_AllSubjects.vmp',cfg.pathToVMP,length(cfg.SubVec),cfg.type,cfg.sessionName,cfg.TestNames{cfg.TestVec(iTest)},cfg.Design,cfg.classifier, cfg.smoothing,abs(cfg.radiusMVPA));
        elseif strcmp(cfg.decodingType,'cross_mod')
            vmpName = sprintf('%s/N%d_%s_%s_%s_%s_sm%dmm_volume_rad%d_AllSubjects.vmp',cfg.pathToVMP,length(cfg.SubVec),cfg.type,cfg.TestNames{cfg.TestVec(iTest)},cfg.Design,cfg.classifier, cfg.smoothing,abs(cfg.radiusMVPA));
        end
        
        % vmpName = sprintf('%s/N%d_%s_%s_%s_%s_%s_sm%dmm_volume_rad%d_AllSubjects.vmp',cfg.pathToVMP,length(cfg.SubVec),cfg.type,cfg.sessionName,cfg.TestNames{iTest},cfg.Design,cfg.classifier, cfg.smoothing,abs(cfg.radiusMVPA));
    end
    
    vmp = xff(vmpName);
    
    disp(sprintf('running %s, Test: %s', cfg.ROIfile,cfg.TestNames{cfg.TestVec(iTest)}));
    
    % load voi
    voiName =  sprintf('%s/ROI/pathOfInterest/%s_rad%d_spacing%d.voi',cfg.path,cfg.ROIfile,cfg.radiusExtract, cfg.gap);
    voi = xff(voiName);
    
    for iVOI = 1:length(voi.VOI)
        for iSub = 1:length(cfg.SubVec)
            meanVal(iSub, iTest).VOI(iVOI) = mean(vmp.VoxelStats(iSub, voi.VOI(iVOI).Voxels));
        end
    end
end

res.subHemiCondVOI = meanVal;
res.cfg = cfg;

save(resName,'res');

