function roi_save_from_maps(cfg)

% cfg=FE_config(cfg);
close all;
cfg = config(cfg);


% univariate:
if strcmp(cfg.type,'univariate') %strcmp(cfg.VOIname,'controlROIs_spherical_9mm_.voi')
    yBoundStruct={[-8 0 8],[-8 0 8],[-8 0 8],[-8 0 8],[-8 0 8],[-8 0 8]};
    cfg.yTitle='t';
    modifyVal= @(x)(x); % leave values unchanged; if decoding, e.g. @(x)(x * 100 + 12.5); %
else
    % MVPA: Seda: this is only for 3-way now, include if here depending on
    % testvec value to be able to use other schemes
    yBoundStruct={[10 33.33 45],[10 33.33 45],[10 33.33 45],[10 33.33 45],[10 33.33 45],[10 33.33 45],[10 33.33 45],[10 33.33 45],[10 33.33 45],[10 33.33 45],[10 33.33 45],[10 33.33 45],[10 33.33 45],[10 33.33 45],[10 33.33 45],[10 33.33 45]};
    cfg.yTitle= 'accuracy';
      %   modifyVal=@(x)(x * 100 + 50); % @(x)(x); % leave values unchanged;
    modifyVal=@(x)(x * 100 + 33.33); % @(x)(x); % leave values unchanged;
end

for iGroup = 1:size(cfg.mapVec,1)
    
    for iCond = 1:size(cfg.mapVec,2)
        %% load map
        vmpName=sprintf('%s/vmp/%s/%s',cfg.path,cfg.type,cfg.mapNames{cfg.mapVec(iGroup,iCond)});
        ds = cosmo_fmri_dataset(vmpName,'mask',cfg.mask_name);
        
        disp(sprintf('loading %s...',vmpName));
        
        % get data
        for iROI = 1:length(cfg.ROIVec)
            msk_ds = cosmo_fmri_dataset(sprintf('%s/msk/%s%s.msk',cfg.path, cfg.VOInamer, cfg.ROImask{cfg.ROIVec(iROI)}),'mask',cfg.mask_name);
            ROI_fn{iROI} = cfg.ROImask{cfg.ROIVec(iROI)};
            dataMat(:, iROI ,iCond,iGroup) = mean(ds.samples(1:numel(cfg.SubVec),msk_ds.samples==1),2);
            dataCell{iROI ,iCond,iGroup} = mean(ds.samples(1:numel(cfg.SubVec),msk_ds.samples==1),2);
        end
        
    end
end

dataMat=squeeze(dataMat);
dataCell=squeeze(dataCell);
%% FDR correction

[H,P_all,CI,STATS] = ttest(dataMat,0,0.05,'right'); %should work for everything since we adjust in vmp group files
T = squeeze(STATS.tstat)
P_all = squeeze(P_all);
[cfg.p_fdr_all, p_masked_all] = fdr(P_all, 0.05);

mydataCell = cellfun(modifyVal,dataCell(:), 'uniformoutput',false);
mydataCell = mydataCell';
mydataCell = horzcat(mydataCell{:});

dlmwrite(sprintf('N%02d_agency_roi_data_%s.csv',length(cfg.SubVec),cfg.fileName), mydataCell,'precision', 10);
fdr_output = [P_all; double(p_masked_all)]
dlmwrite(sprintf('N%02d_agency_fdr_correct_%s.csv',length(cfg.SubVec),cfg.fileName),fdr_output,'precision', 7);
