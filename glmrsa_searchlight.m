function glmrsa_searchlight(cfg)

cfg = config(cfg);

warning off;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

output_path = sprintf('%s/searchlight/%s_%s_rad%d',cfg.path,cfg.type,cfg.Design,abs(cfg.radius));
[SUCCESS,MESSAGE,MESSAGEID] = mkdir(output_path);

for iSub=cfg.SubVec
    
    %% Define RDMs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RDMs = create_rdms(cfg,0);
target_dsms = RDMs.mat(cfg.TestVec);

% for iTest = 1:length(cfg.TestVec)
% target_dsms{iTest} = target_dsms{iTest}(cfg.classes,cfg.classes);
% end

% test if there is collinearity
% addpath(genpath('C:\moritzwurm\matlab_toolboxes\collinearity_diagnostics'));

for iTest = 1:length(cfg.TestVec)
    X(:,iTest) = zscore(squareform(target_dsms{iTest}));
end
colldiag(X);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    disp(sprintf('RSA Sub %02d', iSub));
    
    ds = load_dataset(cfg,iSub);
    
    % select conditions
    cond_idx = find(ismember(ds.sa.targets,cfg.classes)); 
    ds=cosmo_slice(ds,cond_idx,1);
    
    % average betas across runs
    ds_ave = cosmo_fx(ds, @(x)mean(x,1),'targets');

    
    %% Define feature neighorhoods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% load/create nbrhood (= searchlight spheres).
        nbrhood_fn = sprintf('nbrhood_rad%d_%dvoxels',cfg.radius,size(ds_ave.samples,2)); % if all subjects are in the same space and use the same mask, a common file can be used
        
        if exist([nbrhood_fn '.mat'],'file')
            load (nbrhood_fn);
        else
            nbrhood=cosmo_spherical_neighborhood(ds_ave,'radius',cfg.radius);
            save(nbrhood_fn,'nbrhood');
        end
    
    
    % set measure
    measure=@cosmo_target_dsm_corr_measure;
    measure_args=struct();
    
    measure_args.glm_dsm = target_dsms;
    
    %normalize across the first dimension (after averaging across runs)
    %we demeaned, not z-scored
    cfg.normalize=1;
        if cfg.normalize>0
            measure_args.normalization ='demean'; %'zscore';
            measure_args.normalize=cfg.normalize;
        end
        
    
    % 'Spearman' requires  matlab with stats toolbox; if not present use
    % 'Pearson'
    
    if cosmo_check_external('@stats',false)
        measure_args.type='Spearman';
    else
        measure_args.type='Pearson';
        fprintf('Matlab stats toolbox not present, using %s correlation\n',...
            measure_args.type)
    end
    
    % run searchlight
    if strcmp(cfg.type,'glmRSA_leaveOneOut')
        measure_args.partitions=cosmo_nfold_partitioner(sliced_ds_conds);
        ds_rsa=cosmo_searchlight(ds,nbrhood,measure,measure_args);
    else
        ds_rsa=cosmo_searchlight(ds_ave,nbrhood,measure,measure_args);
    end
    
    % fisher transform:
    %ds_rsm_linear.samples=atanh(ds_rsm_linear.samples); 
    
    ds_rsa.sa.labels = cfg.rdmLabels(cfg.TestVec)';
    
    % Define output location
    RDMcode = strrep(num2str(cfg.TestVec), '   ', 'x' );
    RDMcode = strrep(RDMcode, '  ', 'x' );
    output_fn = sprintf('%s/%s_%s_SUB%02d_%s_%s_sm%dmm_rad%d_n%d.vmp',output_path,cfg.sessionName,cfg.type2,iSub,cfg.type,cfg.rdmLabels{cfg.TestVec},cfg.smoothing,abs(cfg.radius),cfg.normalize);

    % Store results to disc
    cosmo_map2fmri(ds_rsa, output_fn);
    
end
