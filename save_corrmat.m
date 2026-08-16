function save_corrmat(cfg)

cfg = config(cfg);
cfg.ROIVec = 1:length(cfg.ROInames);

warning off;
cosmo_warning('once')

close all;

%% create output folder
output_path = sprintf('%s/corrMats',cfg.path);
[SUCCESS,MESSAGE,MESSAGEID] = mkdir(output_path);

for iSub=cfg.SubVec
    
    % load data
    ds = load_dataset(cfg,iSub); % adjust this script depending on your glm file structure
    
    %% select certain conditions
    CondVec= [1:12]; % only visual
    cond_idx = find(ismember(ds.sa.targets,CondVec));
    ds=cosmo_slice(ds,cond_idx,1);
    
    %% plot a selection of voxels using a mask
    
    for iROI = 1:length(cfg.ROIVec)
        mskName = sprintf('%s/msk/%s_spherical_%dmm_%s.msk',cfg.path,cfg.VOIname,cfg.ROIradius,cfg.ROInames{iROI});
        msk = cosmo_fmri_dataset(mskName,'mask', cfg.mask_name);
         
        %% correlate the averaged (across chunks) beta vectors (= standard correlation matrix)
        dsAve = cosmo_fx(ds, @(x)mean(x,1),'targets');
        mat = pdist(dsAve.samples(:,msk.samples==1),'correlation');
        distMat = squareform(mat);
        imagesc(1- squareform(mat));
        caxis([0 1]);
        colorbar;
       
        set(gcf, 'PaperPosition', [0 0 4 3]); %x_width=10cm y_width=15cm
        fig_fn = sprintf('%s/%s_corrMat_aveAcrossChunks_%s_%dmm_%s_SUB%02d',output_path,cfg.sessionName,cfg.VOIname,cfg.ROIradius,cfg.ROInames{iROI},iSub);
        set(gca, 'ytick',[1:length(dsAve.sa.labels)]);
        set(gca, 'yticklabel',dsAve.sa.labels,'Fontsize',5);
        title(sprintf('corr mat ave across chunks, %s, sub%d',cfg.ROInames{iROI},iSub));
        print(fig_fn,'-djpeg','-r300');
        
        matrixName = sprintf('%s_SUB%02d_%s.csv',cfg.sessionName,iSub,cfg.ROInames{iROI});
        csvwrite(matrixName,distMat);
    end
end

close all;
