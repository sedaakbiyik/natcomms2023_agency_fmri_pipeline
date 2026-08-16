function [ds_all cfg] = load_dataset(cfg,iSub)

cfg = config(cfg,iSub);
pathToGLM = sprintf('%s/glm/SUB%02d', cfg.path,iSub);

for iRun = 1:length(cfg.RunVec) % this loop is not needed if all runs are stored in the same glm file
    
    glmName = sprintf('%s/SUB%02d_%02d_%s_%s_%s_sm%dmm.glm',  pathToGLM, iSub, cfg.RunVec(iRun),cfg.sessionName, cfg.Design, cfg.motionCorr, cfg.smoothing);
    ds = cosmo_fmri_dataset(glmName,'mask', cfg.mask_name);
    % select only experimental conditions (no motion predictors)
    if strcmp(cfg.Design,'Runwise')
        cfg.nRepPerRun = 1; % one beta per condition and run
        sliced_ds{iRun}=cosmo_slice(ds,[1:cfg.nConditions] ,1);
        
        %% specify targets and chunks (depends on structure of glm file / order of betas in glm file)
        % construct sa.targets (= the vector of conditions)
        sliced_ds{iRun}.sa.targets = (1:cfg.nConditions)';
        % construct sa.chunks (= the vector of runs)
        sliced_ds{iRun}.sa.chunks = repmat(iRun,cfg.nConditions,1);
        % construct sa.labels (= labels, should correspond to sa.targets)
        sliced_ds{iRun}.sa.labels = sliced_ds{iRun}.sa.Name2;
      
   
    elseif strcmp(cfg.Design,'twoPerRunwise') 
       
        cfg.nRepPerRun = 2; % 2 beta per condition and run
        sliced_ds{iRun}=cosmo_slice(ds,[1:cfg.nConditions*cfg.nRepPerRun] ,1);
       
        %% specify targets and chunks (depends on structure of glm file / order of betas in glm file)
        % construct sa.targets (= the vector of conditions)
        sliced_ds{iRun}.sa.targets = reshape(repmat(1:cfg.nConditions,cfg.nRepPerRun,1),cfg.nConditions*cfg.nRepPerRun,[]);
        % construct sa.chunks (= the vector of runs)
        sliced_ds{iRun}.sa.chunks = repmat(iRun,cfg.nConditions*cfg.nRepPerRun,1);
        % construct sa.labels (= labels, should correspond to sa.targets)
        sliced_ds{iRun}.sa.labels = sliced_ds{iRun}.sa.Name2;
    end
end

ds_all=cosmo_stack(sliced_ds);


