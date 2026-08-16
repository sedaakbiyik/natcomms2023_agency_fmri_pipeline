function [Ysub, RDMs_true] = load_corr_maps(cfg)

cfg = config(cfg);

%% get the neural RDMs
for iSub = 1:length(cfg.SubVec)
    
    % load mask
%     if cfg.leave1out==1 %note from Moritz: cut this part out, don't need the individual masks
%         msk_fn = sprintf('%s/msk/SUB%02d/SUB%02d_%s.msk',cfg.path,cfg.SubVec(iSub),cfg.SubVec(iSub),cfg.mask_fn);
%     else
    msk_fn = sprintf('%s/msk/%s.msk',cfg.path,cfg.mask_fn);
%     end
    
    msk = cosmo_fmri_dataset(msk_fn,'mask',cfg.mask_name);
    
    disp(sprintf('loading subject %d, ROI %s',cfg.SubVec(iSub), cfg.mask_fn));
    
    % load whole brain
    if strcmp(cfg.type,'corrMat')
        
        %output_path = sprintf('%s/searchlight/%s_%s_volume_%s_rad%d',cfg.path,cfg.type,cfg.type2,cfg.Design,abs(cfg.radius));
        output_path = sprintf('%s/searchlight/%s_volume_%s_%s_rad%d',cfg.path,cfg.type,cfg.Design,cfg.classifier,abs(cfg.radius));
        output_fn = sprintf('%s/%s_SUB%02d_%s_%s_sm%dmm_volume_%s_rad%d.mat',output_path,cfg.sessionName,cfg.SubVec(iSub),cfg.type2,cfg.type,cfg.smoothing,cfg.classifier,abs(cfg.radius));
        load(output_fn);
        
        % get ROI data
        ds = cosmo_slice(ds_raw, msk.samples==1, 2);
        
        % get the correlation matrix
        matrices=real(cosmo_unflatten(ds,1));
        
        % was data fisher transformed? if so, transform back
        cfg.fisherz=1;
        if cfg.fisherz==1
            matrices = tanh(matrices);
        end
        
        % if data from many voxels: compute mean
        if ndims(matrices)==3
            matrices = mean(matrices,3);
        end
        
    elseif ~isempty(strfind(cfg.type,'classifyMat'))
        
        output_path = sprintf('%s/searchlight/%s_volume_%s_%s_rad%d',cfg.path,cfg.type,cfg.Design,cfg.classifier,abs(cfg.radius));
       
        
            if strcmp(cfg.decodingType,'cross_mod')
               output_fn = sprintf('%s/_SUB%02d_%s_sm%dmm_volume_%s_rad%d.mat',output_path, iSub,cfg.TestVec, cfg.smoothing,cfg.classifier,abs(cfg.radius));

           else
               output_fn = sprintf('%s/%s_SUB%02d_%s_sm%dmm_volume_%s_rad%d.mat',output_path,cfg.sessionName, iSub,cfg.TestVec, cfg.smoothing,cfg.classifier,abs(cfg.radius));
           end
           
%         output_fn = sprintf('%s/%s_SUB%02d_%s_sm%dmm_volume_%s_rad%d.mat',output_path,cfg.sessionName,iSub,cfg.type2,cfg.smoothing,cfg.classifier,abs(cfg.radius))
        
        
        load(output_fn);
        % get ROI data
%         matrices = confusionMat(:,:,msk.samples==1);
         matrices =   confusionMat(cfg.classes,cfg.classes,msk.samples==1);

        % if data from many voxels: compute mean
        if ndims(matrices)==3
            matrices = mean(matrices,3);
        end
        
        %         matrices = 100 - (matrices/12*100); % this is just to demonstrate
        %         that it makes no difference to compute 100 - % acc and 1 -
        %         normalized matrix
        
        % normalize matrix (into range from 0-1; chance is 1/length(matrices)
        matrices = matrices / sum(mean(matrices,2));
        
    end
    
    
    % simplify matrix by making it symmetrical
    symMat = (matrices + matrices')/2;
    
    % make DSM
%     DSM =  1 - symMat;
    DSM = symMat;
    
    % if leave one out cross validation was used for correlation MVPA:
    % replace diagonal with zeros
    % DSM(logical(eye(size(DSM)))) = 0;
    
    % fill into struct
    RDMs_true(iSub).RDM = DSM;
    fn = cfg.mask_fn;
    if length(fn)>60
        fn = fn(1:60);
    end
    RDMs_true(iSub).name = sprintf('%s | subject%d | Session: 1',fn, iSub);
    RDMs_true(iSub).color = [0 0 1];
    
    RDMs_true(iSub).condLabels = cfg.conditionsCross(cfg.condVec);
    
    DSM(logical(eye(size(DSM)))) = 0;
    Ysub(:,iSub) = zscore(squareform(DSM));
end

