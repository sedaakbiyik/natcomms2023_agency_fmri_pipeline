

function correct_maps(cfg)

cfg = config(cfg);

for iMap = cfg.mapVec %1:length(cfg.mapNames)
    
    fn = cfg.mapNames{iMap};
    %% load data
    fn = sprintf('%s/vmp/%s',cfg.path,fn);
    [p name ext]=fileparts(fn);
    ds=cosmo_fmri_dataset(fn,'mask',cfg.mask_name);
    
    
    SelSubVec = 1 : numel(cfg.SubVec); % CAUTION: the group VMP should contain the same subjects (no additional subjects)!
    % e.g. if cfg.SubVec = [1 2 8 20], then the maps 1-4 in the group vmp
    % should correspond to these subjects!
    
    % keep features where there is data for at least half of the subjects
    feature_msk=mean(ds.samples(SelSubVec,:)~=0,1)>.5;
    ds_subj=cosmo_slice(cosmo_slice(ds,SelSubVec),feature_msk,2);
    
    %% prepare data for statistics
    nsamples=size(ds_subj.samples,1);
    ds_subj.sa.targets=ones(nsamples,1);
    ds_subj.sa.chunks=(1:nsamples)';
       
    %% define clustering neighborhood
    nh=cosmo_cluster_neighborhood(ds_subj,'fmri',3);
    
    %% cluster size correction
    if cfg.mcc==1
        opt=struct();
        opt.niter=cfg.iter;
        opt.cluster_stat='maxsize';
        opt.p_uncorrected=cfg.MCC_init_thres;
        opt.h0_mean=0;
        
        ds_mcc_p_unc=cosmo_montecarlo_cluster_stat(ds_subj,nh,opt);
        out_fn = sprintf('%s/vmp/corrected/mcc%03g_iter%d_%s.vmp',cfg.path,cfg.MCC_init_thres,cfg.iter,name);
        cosmo_map2fmri(ds_mcc_p_unc,out_fn);
    end
    
    %% TFCE
    if cfg.tfce==1
        opt=struct();
        opt.niter=cfg.iter;
        opt.cluster_stat='tfce';
        opt.h0_mean=0;
        ds_mcc_tfce=cosmo_montecarlo_cluster_stat(ds_subj,nh,opt);
        out_fn = sprintf('%s/vmp/corrected/tfce_iter%d_%s.vmp',cfg.path,cfg.iter,name);
        cosmo_map2fmri(ds_mcc_tfce,out_fn);
    end
        
end
