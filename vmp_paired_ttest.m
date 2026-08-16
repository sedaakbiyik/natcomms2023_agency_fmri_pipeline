function vmp_paired_ttest(cfg)

cfg = config(cfg);
alpha=0.005;

%% load vmps
ds1 = cosmo_fmri_dataset(sprintf('%s/vmp/%s.vmp',cfg.path,cfg.vmp1),'mask', cfg.mask_name);
ds2 = cosmo_fmri_dataset(sprintf('%s/vmp/%s.vmp',cfg.path,cfg.vmp2),'mask', cfg.mask_name);

%% compute t test
    [H,P,CI,STATS]=ttest(ds1.samples(1:length(cfg.SubVec),:),ds2.samples(1:length(cfg.SubVec),:));
  
%% pu data into ds structure
    ds = cosmo_slice(ds1,1:1,1);
    ds.samples(1,:) =STATS.tstat;
        
    ds.sa.labels = {'paired t test'}; % cfg.vmp1;cfg.vmp2; cfg.vmp1;cfg.vmp2;
    vmpName = sprintf('%s/vmp/pairedTTest_%s_vs_%s.vmp',cfg.path,cfg.vmp1, cfg.vmp2);

    cosmo_map2fmri(ds,vmpName);
    
    vmp = xff(vmpName);
    
    vmp.Map(1).LUTName = '';
    vmp.Map(1).TransColorFactor = 0.7;
    vmp.Map(1).Name = ds.sa.labels{1};
    vmp.Map(1).DF1 = length(cfg.SubVec) - 1;
    vmp.Map(1).DF2 = 0;
    vmp.Map(1).LowerThreshold = tinv(1-alpha/2, length(cfg.SubVec)-1);
    vmp.Map(1).UpperThreshold = 8;
    vmp.Map(1).Type = 1;
    vmp.Save;