function compute_tsnr(iSub,cfg)

cfg.Design='twoPerRunwise';
cfg = config(cfg,iSub);
bvPath = sprintf('%s/sub%02d/bv', cfg.path,iSub);

%subjectID = sprintf('SUB%02d', iSub);
%cfg.preprocessing='SCCD_3DMCT_LTR_THP3c';

for iRun = cfg.RunVec
    
    %pathToData = sprintf('%s/subjects/%s/bv/', cfg.path, subjectID);
    
    fmrName=sprintf('%s/SUB%02d_%02d_%s_%s.fmr', bvPath, iSub, iRun, cfg.sessionName, cfg.preproc);
    %fmrName=sprintf('%s/data/bv/untitled_SCCTBL_3DMCTS_THPGLMF2c.fmr',cfg.path);

    
    fmr = xff(fmrName); 
    dim = size(fmr.Slice.STCData);
    nTpts = dim(3);
    nSlices = dim(4);
    
    figure;
    for i = 1 : nSlices
        subplot(7, 8, i);
        mat = mean(shiftdim(fmr.Slice.STCData(:,:,:,i),2))./std(shiftdim(fmr.Slice.STCData(:,:,:,i),2));
        mat = shiftdim(mat,1);
        mat = fliplr(mat);
        mat = rot90(mat);
        h = imagesc(mat);
        set(gca, 'xtick', [], 'ytick', []);
        hParent = get(h, 'Parent');
        set(hParent, 'CLim', [0 200]);
        title(sprintf('slice %d, mean: %0.1f',i, nanmean(mat(:))),'Fontsize',7);
        
        % count spikes
        temp = shiftdim(fmr.Slice.STCData(:,:,:,i),2);
        count=0;
        for i1=1:size(temp,1)
            for i2=1:size(temp,2)
                for i3=1:size(temp,3)
                    if temp(i1,i2,i3)> 800
                        count=count+1;
                    end
                end
            end
        end
        %hist(temp);
        nTemp = size(temp,1)*size(temp,2)*size(temp,3);
        %disp(count/nTemp);
        
        %hcbar = colorbar;
    end
    title(sprintf('sub: %d, run %d',iSub, iRun));
    subplot(7, 8, 51);
    caxis([0 200]);
    hcbar = colorbar;
    set(gca, 'Visible', 'off');
    set(gca, 'fontsize', 6);
    
    set(gcf, 'PaperPosition', [0 0 9 8]); %x_width=10cm y_width=15cm
    fig_fn = sprintf('%s/figures/TSNR_SUB%02d_RUN%02d_%s',cfg.path,iSub, iRun, cfg.sessionName);
    title(sprintf('all betas, sub%d',iSub));
    print(fig_fn,'-djpeg','-r300');
    
    
    %pause(3);
    close all;
    
end