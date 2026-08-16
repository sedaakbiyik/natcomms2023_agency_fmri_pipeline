function plot_betas(cfg)

cfg = config(cfg);
cfg.ROIVec = 1:length(cfg.ROInames);

warning off;
cosmo_warning('once')

close all;

%% create output folder
output_path = sprintf('%s/figures/betaPlots',cfg.path);
[SUCCESS,MESSAGE,MESSAGEID] = mkdir(output_path);

for iSub=cfg.SubVec
    
    % load data
    ds = load_dataset(cfg,iSub); % adjust this script depending on your glm file structure
    
    %% select certain conditions
%     CondVec= [1 2 4 5 7 8 10 11 13 14 16 17 19 20]; % only visual
%     cond_idx = find(ismember(ds.sa.targets,CondVec));
%     ds=cosmo_slice(ds,cond_idx,1);
%     cfg.nConditions = length(CondVec);
    
    %% plot all data
    imagesc(ds.samples);
    set(gca, 'ytick',[1:length(ds.sa.labels)]);
    set(gca, 'yticklabel',ds.sa.labels,'Fontsize',5);
    colormap(paruly);
    colorbar;
    set(gcf, 'PaperPosition', [0 0 12 8]); %x_width=10cm y_width=15cm
    fig_fn = sprintf('%s/AllData_SUB%02d',output_path,iSub);
    title(sprintf('all betas, sub%d',iSub));
    print(fig_fn,'-djpeg','-r300');
    
    
    %% plot a selection of voxels using a mask
    
    for iROI = 1:length(cfg.ROIVec)
        mskName = sprintf('%s/msk/%s_spherical_%dmm_%s.msk',cfg.path,cfg.VOIname,cfg.ROIradius,cfg.ROInames{iROI});
        msk = cosmo_fmri_dataset(mskName,'mask', cfg.mask_name);
        
        imagesc(ds.samples(:,msk.samples==1));
        colorbar;
        set(gca, 'ytick',[1:length(ds.sa.labels)]);
        set(gca, 'yticklabel',ds.sa.labels,'Fontsize',5);
        set(gcf, 'PaperPosition', [0 0 12 8]); %x_width=10cm y_width=15cm
        fig_fn = sprintf('%s/%s_%dmm_%s_SUB%02d',output_path,cfg.VOIname,cfg.ROIradius,cfg.ROInames{iROI},iSub);
        title(sprintf('all betas, %s, sub%d',cfg.ROInames{iROI},iSub));
        print(fig_fn,'-djpeg','-r300');
        
        %% correlate all beta vectors (within mask) with each other
        
        mat = pdist(ds.samples(:,msk.samples==1),'correlation');
        
        imagesc(1- squareform(mat));
        colorbar;
        caxis([-1 1]);
        
        set(gca, 'ytick',[1:length(ds.sa.labels)]);
        set(gca, 'yticklabel',ds.sa.labels,'Fontsize',5);
        set(gcf, 'PaperPosition', [0 0 12 10]); %x_width=10cm y_width=15cm
        fig_fn = sprintf('%s/corrMatAllBetas_%s_%dmm_%s_SUB%02d',output_path,cfg.VOIname,cfg.ROIradius,cfg.ROInames{iROI},iSub);
        title(sprintf('corr mat all betas, %s, sub%d',cfg.ROInames{iROI},iSub));
        print(fig_fn,'-djpeg','-r300');
        
        
        %% correlate the averaged (across chunks) beta vectors (= standard correlation matrix)
        dsAve = cosmo_fx(ds, @(x)mean(x,1),'targets');
        mat = pdist(dsAve.samples(:,msk.samples==1),'correlation');
        
        imagesc(1- squareform(mat));
        caxis([0 1]);
        colorbar;
        
        set(gcf, 'PaperPosition', [0 0 4 3]); %x_width=10cm y_width=15cm
        fig_fn = sprintf('%s/corrMat_aveAcrossChunks_%s_%dmm_%s_SUB%02d',output_path,cfg.VOIname,cfg.ROIradius,cfg.ROInames{iROI},iSub);
        set(gca, 'ytick',[1:length(dsAve.sa.labels)]);
        set(gca, 'yticklabel',dsAve.sa.labels,'Fontsize',5);
        title(sprintf('corr mat ave across chunks, %s, sub%d',cfg.ROInames{iROI},iSub));
        print(fig_fn,'-djpeg','-r300');
        
        %% demean data across conditions before correlation (this better visualizes how similar/different conditions are to each other)
        
        for iCond = 1:cfg.nConditions
            dsDemean.samples(iCond,msk.samples==1) = dsAve.samples(iCond,msk.samples==1)- mean(dsAve.samples(:,msk.samples==1));
        end
        
        mat = pdist(dsDemean.samples(:,msk.samples==1),'correlation');
        
        imagesc(1- squareform(mat));
        caxis([-1 1]);
        colorbar;
        
        set(gcf, 'PaperPosition', [0 0 4 3]); %x_width=10cm y_width=15cm
        fig_fn = sprintf('%s/corrMat_demean_%s_%dmm_%s_SUB%02d',output_path,cfg.VOIname,cfg.ROIradius,cfg.ROInames{iROI},iSub);
        set(gca, 'ytick',[1:length(dsAve.sa.labels)]);
        set(gca, 'yticklabel',dsAve.sa.labels,'Fontsize',5);
        title(sprintf('corr mat ave across chunks, demeaned, %s, sub%d',cfg.ROInames{iROI},iSub));
        print(fig_fn,'-djpeg','-r300');
        
        
        %% plot the averaged betas
        imagesc(dsAve.samples);
        colorbar;
        set(gcf, 'PaperPosition', [0 0 5 3]); %x_width=10cm y_width=15cm
        set(gca, 'ytick',[1:length(dsAve.sa.labels)]);
        set(gca, 'yticklabel',dsAve.sa.labels,'Fontsize',5);
        fig_fn = sprintf('%s/aveAcrossChunks_SUB%02d',output_path,iSub);
        title(sprintf('ave across chunks, sub%d',iSub));
        print(fig_fn,'-djpeg','-r300');
        
        
        %% average across betas
        dsAve = cosmo_fx(ds, @(x)mean(x,1),'chunks');
        imagesc(dsAve.samples);
        colorbar;
        set(gcf, 'PaperPosition', [0 0 5 3]); %x_width=10cm y_width=15cm
        fig_fn = sprintf('%s/AllData_averagedAcrossBetas_SUB%02d',output_path,iSub);
        title(sprintf('ave across betas, sub%d',iSub));
        print(fig_fn,'-djpeg','-r300');
        
        
        %% correlate the averaged (across conds) beta vectors
        mat = pdist(dsAve.samples(:,msk.samples==1),'correlation');
        
        imagesc(1- squareform(mat));
        caxis([0 1]);
        colorbar;
        
        set(gcf, 'PaperPosition', [0 0 4 3]); %x_width=10cm y_width=15cm
        fig_fn = sprintf('%s/corrMat_aveAcrossConds_%s_%dmm_%s_SUB%02d',output_path,cfg.VOIname,cfg.ROIradius,cfg.ROInames{iROI},iSub);
        title(sprintf('corr mat ave across betas, %s, sub%d',cfg.ROInames{iROI},iSub));
        print(fig_fn,'-djpeg','-r300');
        
        
        % whole brain
        dsAve = cosmo_fx(ds, @(x)mean(x,1),'chunks');
        mat = pdist(dsAve.samples,'correlation');
        
        imagesc(1- squareform(mat));
        caxis([0 1]);
        colorbar;
        
        set(gcf, 'PaperPosition', [0 0 4 3]); %x_width=10cm y_width=15cm
        fig_fn = sprintf('%s/AllData_corrMat_aveAcrossCond_SUB%02d',output_path,iSub);
        set(gca, 'ytick',[1:length(dsAve.sa.labels)]);
        
        print(fig_fn,'-djpeg','-r300');
        
        
    end
end

close all;
