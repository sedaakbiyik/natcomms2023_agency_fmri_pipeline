function mvpa_searchlight(cfg)

cfg = config(cfg);

%% create output folder
output_path = sprintf('%s/searchlight/%s_volume_%s_%s_rad%d',cfg.path, cfg.type, cfg.Design,cfg.classifier,abs(cfg.radius));
[SUCCESS,MESSAGE,MESSAGEID] = mkdir(output_path);

%% run MVPA for each subject
for iSub = cfg.SubVec
    
    pathToGLM = sprintf('%s/glm/SUB%02d', cfg.path,iSub);
    
    %% get data
    if strcmp(cfg.decodingType,'cross_mod')
        cfg.sessionName = 'AGENCY_video';
        cfg = config(cfg,iSub);
        ds_vid = load_dataset(cfg,iSub);
        
        cfg.sessionName = 'AGENCY_sentence';
        cfg = config(cfg,iSub);
        ds_sent = load_dataset(cfg,iSub);
    elseif strcmp(cfg.decodingType,'within_mod') %session name already specified in analysis pipeline
        cfg = config(cfg,iSub);
        [ds_all cfg]=load_dataset(cfg,iSub);
    end
    
    %% run for each classification scheme
    for iTest = 1:length(cfg.TestVec)
        
        fprintf('MVPA Sub %02d, %s\n', iSub, cfg.TestNames{cfg.TestVec(iTest)});
        
        %% specify decoding scheme
       
        if cfg.TestVec(iTest)==1 % actions vs catch (balanced decoding)
            
            decoding_ds=ds_all;
            class1_idx=ismember(decoding_ds.sa.targets,[1:12]);
            class2_idx=ismember(decoding_ds.sa.targets,[13]);
            decoding_ds.sa.targets(class1_idx)=1;
            decoding_ds.sa.targets(class2_idx)=2;
            temp =  cosmo_nfold_partitioner(decoding_ds);
            measure_args.partitions = cosmo_balance_partitions(temp, decoding_ds);
            
        elseif cfg.TestVec(iTest)==2 % ANIMATE_multiclass (3-way, individual actions treated as same category)
            decoding_ds=ds_all;
            cond_idx=find(ismember(decoding_ds.sa.targets,[1:6])); % first 6 are animate agents
            decoding_ds=cosmo_slice(decoding_ds,cond_idx,1);
            decoding_ds.sa.targets(decoding_ds.sa.targets==4)=1; %relabeling the inanimate recipient ones
            decoding_ds.sa.targets(decoding_ds.sa.targets==5)=2;
            decoding_ds.sa.targets(decoding_ds.sa.targets==6)=3;
            measure_args.partitions = cosmo_nfold_partitioner(decoding_ds);
            
        elseif cfg.TestVec(iTest)==3  % INANIMATE_multiclass (3-way, individual actions treated as same category)
            decoding_ds=ds_all;
            cond_idx=find(ismember(decoding_ds.sa.targets,[7:12]));  % last 6 are inanimate agents
            decoding_ds=cosmo_slice(decoding_ds,cond_idx,1);
            decoding_ds.sa.targets(decoding_ds.sa.targets==10)=7;  %relabeling the inanimate recipient ones
            decoding_ds.sa.targets(decoding_ds.sa.targets==11)=8;
            decoding_ds.sa.targets(decoding_ds.sa.targets==12)=9;
            measure_args.partitions = cosmo_nfold_partitioner(decoding_ds);
            
        elseif cfg.TestVec(iTest)==4  % anim_anim multiclass3 (3-way, individual actions treated as same category)
            decoding_ds=ds_all;
            cond_idx=find(ismember(decoding_ds.sa.targets,[1:3]));
            decoding_ds=cosmo_slice(decoding_ds,cond_idx,1);
            measure_args.partitions = cosmo_nfold_partitioner(decoding_ds);
            
        elseif cfg.TestVec(iTest)==5  % anim_inanim multiclass3 (3-way, individual actions treated as same category)
            decoding_ds=ds_all;
            cond_idx=find(ismember(decoding_ds.sa.targets,[4:6]));
            decoding_ds=cosmo_slice(decoding_ds,cond_idx,1);
            measure_args.partitions = cosmo_nfold_partitioner(decoding_ds);
        elseif cfg.TestVec(iTest)==6  % inanim_anim multiclass3 (3-way, individual actions treated as same category)
            decoding_ds=ds_all;
            cond_idx=find(ismember(decoding_ds.sa.targets,[7:9]));
            decoding_ds=cosmo_slice(decoding_ds,cond_idx,1);
            measure_args.partitions = cosmo_nfold_partitioner(decoding_ds);
        elseif cfg.TestVec(iTest)==7  % inanim_inanim multiclass3 (3-way, individual actions treated as same category)
            decoding_ds=ds_all;
            cond_idx=find(ismember(decoding_ds.sa.targets,[10:12]));
            decoding_ds=cosmo_slice(decoding_ds,cond_idx,1);
            measure_args.partitions = cosmo_nfold_partitioner(decoding_ds);
        elseif cfg.TestVec(iTest)==8 %cross modal three-way anim
            ds_vid.sa.cross = ones(size(ds_vid.sa.targets));
            ds_sent.sa.cross = ones(size(ds_sent.sa.targets))*2;
            ds_both = cosmo_stack({ds_vid ds_sent});
            cond_idx=find(ismember(ds_both.sa.targets,[1:6]));  % first 6 are animate agents
            ds_both=cosmo_slice(ds_both,cond_idx,1);
            ds_both.sa.targets(ds_both.sa.targets==4)=1; %relabeling the inanimate recipient ones
            ds_both.sa.targets(ds_both.sa.targets==5)=2;
            ds_both.sa.targets(ds_both.sa.targets==6)=3;
            %ds_both.sa.chunks=ds_both.sa.cross %this could be done to
            %speed up the analyses
            decoding_ds=ds_both;
            measure_args.partitions=cosmo_nchoosek_partitioner(decoding_ds,1,'cross', []);
        elseif cfg.TestVec(iTest)==9 %cross modal three-way inanim
            ds_vid.sa.cross = ones(size(ds_vid.sa.targets));
            ds_sent.sa.cross = ones(size(ds_sent.sa.targets))*2;
            ds_both = cosmo_stack({ds_vid ds_sent});
            cond_idx=find(ismember(ds_both.sa.targets,[7:12]));
            ds_both=cosmo_slice(ds_both,cond_idx,1);
            ds_both.sa.targets(ds_both.sa.targets==10)=7;
            ds_both.sa.targets(ds_both.sa.targets==11)=8;
            ds_both.sa.targets(ds_both.sa.targets==12)=9;
            %ds_both.sa.chunks=ds_both.sa.cross; %this could be done to
            %speed up the analyses
            decoding_ds=ds_both;
            measure_args.partitions=cosmo_nchoosek_partitioner(decoding_ds,1,'cross', []);
        elseif cfg.TestVec(iTest)==10 %cross animacy multiclass3 within modality
            decoding_ds=ds_all;
            cond=find(ismember(decoding_ds.sa.targets,[1:6])); %cond for agents
            ds_anim=cosmo_slice(decoding_ds,cond,1);
            cond_idx=find(ismember(decoding_ds.sa.targets,[7:12])); %cond for object events
            ds_inanim=cosmo_slice(decoding_ds,cond_idx,1);
            %labeling all hit-jump-passes  as 1 - 2 -3
            %label anim
            ds_anim.sa.targets(ds_anim.sa.targets==4)=1;
            ds_anim.sa.targets(ds_anim.sa.targets==5)=2;
            ds_anim.sa.targets(ds_anim.sa.targets==6)=3;
            
            %label inanim
            ds_inanim.sa.targets(ds_inanim.sa.targets==7)=1;
            ds_inanim.sa.targets(ds_inanim.sa.targets==8)=2;
            ds_inanim.sa.targets(ds_inanim.sa.targets==9)=3;
            ds_inanim.sa.targets(ds_inanim.sa.targets==10)=1;
            ds_inanim.sa.targets(ds_inanim.sa.targets==11)=2;
            ds_inanim.sa.targets(ds_inanim.sa.targets==12)=3;
            
            ds_anim.sa.cross = ones(size(ds_anim.sa.targets));
            ds_inanim.sa.cross = ones(size(ds_inanim.sa.targets))*2;
            ds_both = cosmo_stack({ds_anim ds_inanim});
            decoding_ds = ds_both;
            measure_args.partitions=cosmo_nchoosek_partitioner(decoding_ds,1,'cross', []);
            
        elseif cfg.TestVec(iTest)==11 %video_crossFullAnimNoAnim train anim_anim test inanim_inanim
            
            decoding_ds=ds_all;
            cond=find(ismember(decoding_ds.sa.targets,[1:3])); %anim_anim
            ds_anim_anim=cosmo_slice(decoding_ds,cond,1);
            cond_idx=find(ismember(decoding_ds.sa.targets,[10:12])); %inanim_inanim
            ds_inanim_inanim=cosmo_slice(decoding_ds,cond_idx,1);
            %change target names
            ds_inanim_inanim.sa.targets(ds_inanim_inanim.sa.targets==10)=1;
            ds_inanim_inanim.sa.targets(ds_inanim_inanim.sa.targets==11)=2;
            ds_inanim_inanim.sa.targets(ds_inanim_inanim.sa.targets==12)=3;
            ds_anim_anim.sa.cross = ones(size(ds_anim_anim.sa.targets));
            ds_inanim_inanim.sa.cross = ones(size(ds_inanim_inanim.sa.targets))*2;
            ds_both = cosmo_stack({ds_anim_anim ds_inanim_inanim});
            decoding_ds = ds_both;
            measure_args.partitions=cosmo_nchoosek_partitioner(decoding_ds,1,'cross', []);
            
        elseif cfg.TestVec(iTest)==12 %all actions for classifymat
          
            decoding_ds=ds_all;
            cond_idx=find(ismember(decoding_ds.sa.targets,[1:12]));
            decoding_ds=cosmo_slice(decoding_ds,cond_idx,1);
            measure_args.partitions = cosmo_nfold_partitioner(decoding_ds);
            
      elseif cfg.TestVec(iTest)==13 %cross modal and cross animacy
           
           chunksV = ones(size(ds_vid.sa.targets));
           chunksS = ones(size(ds_sent.sa.targets))*2;
           ds_both = cosmo_stack({ds_vid ds_sent});
           ds_both.sa.chunks = [chunksV; chunksS];
           cond_idx = find(ismember(ds_both.sa.targets,[1:12]));
           decoding_ds = cosmo_slice(ds_both, cond_idx, 1);
           
           %defining classes here
           class1_idx=ismember(decoding_ds.sa.targets, [1 4 7 10]); %hits
           class2_idx=ismember(decoding_ds.sa.targets, [2 5 8 11]); %jump overs
           class3_idx=ismember(decoding_ds.sa.targets, [3 6 9 12]); %pass bys
           train_idx=ismember(decoding_ds.sa.targets, [1:6]); %animate agent
           test_idx=ismember(decoding_ds.sa.targets, [7:12]); %object event
           
           %relabel targets to match the classes
           decoding_ds.sa.targets(class1_idx)=1;
           decoding_ds.sa.targets(class2_idx)=2;
           decoding_ds.sa.targets(class3_idx)=3;
           
           %train with animate test with inanimate vice versa
           decoding_ds.sa.cross=ones(size(decoding_ds.sa.targets));
           decoding_ds.sa.cross(train_idx) = 1; 
           decoding_ds.sa.cross(test_idx) = 2; 
           measure_args.partitions=cosmo_nchoosek_partitioner(decoding_ds,1,'cross', []);         
            
        elseif cfg.TestVec(iTest)==14 %agent actions for corrmat
            decoding_ds=ds_all;
            cond_idx=find(ismember(decoding_ds.sa.targets,[1:6]));
            decoding_ds=cosmo_slice(decoding_ds,cond_idx,1);
            measure_args.partitions = cosmo_nfold_partitioner(decoding_ds);
        
        elseif cfg.TestVec(iTest)==15 %object events for corrmat
            decoding_ds=ds_all;
            cond_idx=find(ismember(decoding_ds.sa.targets,[7:12]));
            decoding_ds=cosmo_slice(decoding_ds,cond_idx,1);
            measure_args.partitions = cosmo_nfold_partitioner(decoding_ds);
            
        elseif cfg.TestVec(iTest)==16 %hit jump cross animacy
            decoding_ds=ds_all;
            cond=find(ismember(decoding_ds.sa.targets,[1,2,4,5]));
            ds_anim=cosmo_slice(decoding_ds,cond,1);
            cond_idx=find(ismember(decoding_ds.sa.targets,[7,8,10,11]));
            ds_inanim=cosmo_slice(decoding_ds,cond_idx,1);
            
            %change target values
            ds_anim.sa.targets(ds_anim.sa.targets==4)=1;
            ds_anim.sa.targets(ds_anim.sa.targets==5)=2;
            ds_inanim.sa.targets(ds_inanim.sa.targets==7)=1;
            ds_inanim.sa.targets(ds_inanim.sa.targets==8)=2;
            ds_inanim.sa.targets(ds_inanim.sa.targets==10)=1;
            ds_inanim.sa.targets(ds_inanim.sa.targets==11)=2;
            %to be able to do the cross-decoding
            ds_anim.sa.cross = ones(size(ds_anim.sa.targets));
            ds_inanim.sa.cross = ones(size(ds_inanim.sa.targets))*2;
            %stack data
            ds_both = cosmo_stack({ds_anim ds_inanim});
            decoding_ds = ds_both;
            measure_args.partitions=cosmo_nchoosek_partitioner(decoding_ds,1,'cross', []);
      
        elseif cfg.TestVec(iTest)==17 %hit pass cross animacy
            
            decoding_ds=ds_all;
            cond=find(ismember(decoding_ds.sa.targets,[1,3,4,6]));
            ds_anim=cosmo_slice(decoding_ds,cond,1);
            cond_idx=find(ismember(decoding_ds.sa.targets,[7,9,10,12]));
            ds_inanim=cosmo_slice(decoding_ds,cond_idx,1);
            
            %change target values
            ds_anim.sa.targets(ds_anim.sa.targets==4)=1;
            ds_anim.sa.targets(ds_anim.sa.targets==6)=3;
            ds_inanim.sa.targets(ds_inanim.sa.targets==7)=1;
            ds_inanim.sa.targets(ds_inanim.sa.targets==9)=3;
            ds_inanim.sa.targets(ds_inanim.sa.targets==10)=1;
            ds_inanim.sa.targets(ds_inanim.sa.targets==12)=3;
            
            %to be able to do the cross-decoding
            ds_anim.sa.cross = ones(size(ds_anim.sa.targets));
            ds_inanim.sa.cross = ones(size(ds_inanim.sa.targets))*2;
            
            %stack data
            ds_both = cosmo_stack({ds_anim ds_inanim});
            decoding_ds = ds_both;
            measure_args.partitions=cosmo_nchoosek_partitioner(decoding_ds,1,'cross', []);    
      
        elseif cfg.TestVec(iTest)==18 %jump pass cross animacy
            decoding_ds=ds_all;
            cond=find(ismember(decoding_ds.sa.targets,[2,3,5,6]));
            ds_anim=cosmo_slice(decoding_ds,cond,1);
            cond_idx=find(ismember(decoding_ds.sa.targets,[8,9,11,12]));
            ds_inanim=cosmo_slice(decoding_ds,cond_idx,1);
            
            %change target values
            ds_anim.sa.targets(ds_anim.sa.targets==5)=2;
            ds_anim.sa.targets(ds_anim.sa.targets==6)=3;
            ds_inanim.sa.targets(ds_inanim.sa.targets==8)=2;
            ds_inanim.sa.targets(ds_inanim.sa.targets==9)=3;
            ds_inanim.sa.targets(ds_inanim.sa.targets==11)=2;
            ds_inanim.sa.targets(ds_inanim.sa.targets==12)=3;
           
            %to be able to do the cross-decoding
            ds_anim.sa.cross = ones(size(ds_anim.sa.targets));
            ds_inanim.sa.cross = ones(size(ds_inanim.sa.targets))*2;
            
            %stack data
            ds_both = cosmo_stack({ds_anim ds_inanim});
            decoding_ds = ds_both;
            measure_args.partitions=cosmo_nchoosek_partitioner(decoding_ds,1,'cross', []);   
            
        elseif cfg.TestVec(iTest)==19 % is it an agent action or an object event
            
            decoding_ds=ds_all;
            cond_idx=find(ismember(decoding_ds.sa.targets,[1:12])); % first 6 are animate agents
            decoding_ds=cosmo_slice(decoding_ds,cond_idx,1);  
            class1_idx=ismember(decoding_ds.sa.targets,[1:6]);
            class2_idx=ismember(decoding_ds.sa.targets,[7:12]);
            decoding_ds.sa.targets(class1_idx)=1;
            decoding_ds.sa.targets(class2_idx)=2;
            measure_args.partitions = cosmo_nfold_partitioner(decoding_ds);
            
        elseif cfg.TestVec(iTest)==20 % animate_crosstarget
            
            decoding_ds=ds_all;
            cond=find(ismember(decoding_ds.sa.targets,[1:3]));
            ds_anim=cosmo_slice(decoding_ds,cond,1);
            cond_idx=find(ismember(decoding_ds.sa.targets,[4:6]));
            ds_inanim=cosmo_slice(decoding_ds,cond_idx,1);
            
            ds_inanim.sa.targets(ds_inanim.sa.targets==4)=1;
            ds_inanim.sa.targets(ds_inanim.sa.targets==5)=2;
            ds_inanim.sa.targets(ds_inanim.sa.targets==6)=3;
            
            ds_anim.sa.cross = ones(size(ds_anim.sa.targets));
            ds_inanim.sa.cross = ones(size(ds_inanim.sa.targets))*2;
            ds_both = cosmo_stack({ds_anim ds_inanim});
            decoding_ds = ds_both;
            measure_args.partitions=cosmo_nchoosek_partitioner(decoding_ds,1,'cross', []);  
            
         elseif cfg.TestVec(iTest)==21 %cross modal and cross animacy jump - walk (jump-over vs pass-by)
           
           chunksV = ones(size(ds_vid.sa.targets));
           chunksS = ones(size(ds_sent.sa.targets))*2;
           ds_both = cosmo_stack({ds_vid ds_sent});
           ds_both.sa.chunks = [chunksV; chunksS];
           cond_idx = find(ismember(ds_both.sa.targets,[2,3,5,6,8,9,11,12]));
           decoding_ds = cosmo_slice(ds_both, cond_idx, 1);
           
           %defining classes here
%          class1_idx=ismember(decoding_ds.sa.targets, [1 4 7 10]); %hits
           class2_idx=ismember(decoding_ds.sa.targets, [2 5 8 11]); %jump overs
           class3_idx=ismember(decoding_ds.sa.targets, [3 6 9 12]); %pass bys
           train_idx=ismember(decoding_ds.sa.targets, [2,3,5,6]); %animate agent
           test_idx=ismember(decoding_ds.sa.targets, [8,9,11,12]); %object event
           
           %relabel targets to match the classes
%          decoding_ds.sa.targets(class1_idx)=1;
           decoding_ds.sa.targets(class2_idx)=1;
           decoding_ds.sa.targets(class3_idx)=2;
           
           %train with animate test with inanimate vice versa
           decoding_ds.sa.cross=ones(size(decoding_ds.sa.targets));
           decoding_ds.sa.cross(train_idx) = 1; 
           decoding_ds.sa.cross(test_idx) = 2; 
           measure_args.partitions=cosmo_nchoosek_partitioner(decoding_ds,1,'cross', []); 
           
          elseif cfg.TestVec(iTest)==22 %cross modal and cross animacy kick - jump
           
           chunksV = ones(size(ds_vid.sa.targets));
           chunksS = ones(size(ds_sent.sa.targets))*2;
           ds_both = cosmo_stack({ds_vid ds_sent});
           ds_both.sa.chunks = [chunksV; chunksS];
           cond_idx = find(ismember(ds_both.sa.targets,[1,2,4,5,7,8,10,11]));
           decoding_ds = cosmo_slice(ds_both, cond_idx, 1);
           
           %defining classes here
          class1_idx=ismember(decoding_ds.sa.targets, [1 4 7 10]); %hits
           class2_idx=ismember(decoding_ds.sa.targets, [2 5 8 11]); %jump overs
  %         class3_idx=ismember(decoding_ds.sa.targets, [3 6 9 12]); %pass bys
           train_idx=ismember(decoding_ds.sa.targets, [1,2,4,5]); %animate agent
           test_idx=ismember(decoding_ds.sa.targets, [7,8,10,11]); %object event
           
           %relabel targets to match the classes
%          decoding_ds.sa.targets(class1_idx)=1;
           decoding_ds.sa.targets(class1_idx)=1;
           decoding_ds.sa.targets(class2_idx)=2;
           
           %train with animate test with inanimate vice versa
           decoding_ds.sa.cross=ones(size(decoding_ds.sa.targets));
           decoding_ds.sa.cross(train_idx) = 1; 
           decoding_ds.sa.cross(test_idx) = 2; 
           measure_args.partitions=cosmo_nchoosek_partitioner(decoding_ds,1,'cross', []);  
           
          elseif cfg.TestVec(iTest)==23 %cross modal and cross animacy kick - walk
           
           chunksV = ones(size(ds_vid.sa.targets));
           chunksS = ones(size(ds_sent.sa.targets))*2;
           ds_both = cosmo_stack({ds_vid ds_sent});
           ds_both.sa.chunks = [chunksV; chunksS];
           cond_idx = find(ismember(ds_both.sa.targets,[1,3,4,6,7,9,10,12]));
           decoding_ds = cosmo_slice(ds_both, cond_idx, 1);
           
           %defining classes here
          class1_idx=ismember(decoding_ds.sa.targets, [1 4 7 10]); %hits
         %  class2_idx=ismember(decoding_ds.sa.targets, [2 5 8 11]); %jump overs
          class2_idx=ismember(decoding_ds.sa.targets, [3 6 9 12]); %pass bys
           train_idx=ismember(decoding_ds.sa.targets, [1,3,4,6]); %animate agent
           test_idx=ismember(decoding_ds.sa.targets, [7,9,10,12]); %object event
           
           %relabel targets to match the classes
%          decoding_ds.sa.targets(class1_idx)=1;
           decoding_ds.sa.targets(class1_idx)=1;
           decoding_ds.sa.targets(class2_idx)=2;
           
           %train with animate test with inanimate vice versa
           decoding_ds.sa.cross=ones(size(decoding_ds.sa.targets));
           decoding_ds.sa.cross(train_idx) = 1; 
           decoding_ds.sa.cross(test_idx) = 2; 
           measure_args.partitions=cosmo_nchoosek_partitioner(decoding_ds,1,'cross', []); 
         
        end
        
        
        % debug?
        if cfg.debug==1
            decoding_ds=cosmo_slice(decoding_ds,1:2000,2); % decrease size of dataset to speed up the analysis
        end
        
        % MVPA method
        if strcmp(cfg.type,'corr')
            measure = @cosmo_correlation_measure;
        elseif strcmp(cfg.type,'classify') || strcmp(cfg.type,'classifyMat')
            if strcmp(cfg.classifier,'lda')
                measure_args.classifier = @cosmo_classify_lda;
                measure = @cosmo_crossvalidation_measure;
        elseif strcmp(cfg.classifier,'svm')
                measure_args.classifier = @cosmo_classify_svm;
                measure = @cosmo_crossvalidation_measure;
            end
        end
        
        %         if cfg.normalize==1
        %             measure_args.normalization ='demean'; %'zscore';
        %         end
        
        %Modified by Moritz - seda implemented 03232021
        
        if cfg.normalize>0
            measure_args.normalization ='demean'; %'zscore';
            measure_args.normalize=cfg.normalize;
        end
        
        %% load/create nbrhood (= searchlight spheres).
        nbrhood_fn = sprintf('nbrhood_rad%d_%dvoxels',cfg.radius,size(decoding_ds.samples,2)); % if all subjects are in the same space and use the same mask, a common file can be used
        
        if exist([nbrhood_fn '.mat'],'file')
            load (nbrhood_fn);
        else
            nbrhood=cosmo_spherical_neighborhood(decoding_ds,'radius',cfg.radius);
            save(nbrhood_fn,'nbrhood');
        end
        
        %% run decoding
        if strcmp(cfg.type,'classify') || strcmp(cfg.type,'corr')
            lda_results = cosmo_searchlight(decoding_ds,nbrhood,measure,measure_args);
            if strcmp(cfg.decodingType,'cross_mod')
                output_fn = sprintf('%s/SUB%02d_%s_%s_%s_sm%dmm_rad%d.vmp',output_path,iSub,cfg.decodingType, cfg.TestNames{cfg.TestVec(iTest)},cfg.classifier,cfg.smoothing,abs(cfg.radius));
            elseif strcmp(cfg.decodingType,'within_mod')
                output_fn = sprintf('%s/SUB%02d_%s_%s_%s_sm%dmm_rad%d.vmp',output_path,iSub,cfg.sessionName, cfg.TestNames{cfg.TestVec(iTest)},cfg.classifier,cfg.smoothing,abs(cfg.radius));
            end
            cosmo_map2fmri(lda_results, output_fn);
            adjustVMP(output_fn,0,1);
        elseif strcmp(cfg.type,'classifyMat') % compute confusion matrix, e.g. for subsequent RSA
            measure_args.output = 'winner_predictions'; % confusion matrix
            lda_results = cosmo_searchlight(decoding_ds,nbrhood,measure,measure_args);
            confusionMat=cosmo_confusion_matrix(lda_results);
            
            
           if strcmp(cfg.decodingType,'cross_mod')
               output_fn = sprintf('%s/SUB%02d_%s_sm%dmm_volume_%s_rad%d.mat',output_path, iSub,cfg.TestNames{cfg.TestVec(iTest)}, cfg.smoothing,cfg.classifier,abs(cfg.radius));

           else
               output_fn = sprintf('%s/%s_SUB%02d_%s_sm%dmm_volume_%s_rad%d.mat',output_path,cfg.sessionName, iSub,cfg.TestNames{cfg.TestVec(iTest)}, cfg.smoothing,cfg.classifier,abs(cfg.radius));
           end
           
            save(output_fn, 'confusionMat');
            
        elseif strcmp(cfg.type,'corrMat')
            if cfg.leaveOneOut==1
                ds_cross = decoding_ds;
            else
                ds_ave1 = cosmo_fx(decoding_ds, @(x)mean(x,1),'targets');
                ds_ave2 = cosmo_fx(decoding_ds, @(x)mean(x,1),'targets');
                % define different chunks
                ds_ave1.sa.chunks = ones(size(ds_ave1.sa.targets));
                ds_ave2.sa.chunks = ones(size(ds_ave2.sa.targets))*2;
                % put together
                ds_cross = cosmo_stack({ds_ave1, ds_ave2});
            end
            
            % set measure
            measure=@cosmo_correlation_measure;
            measure_args=struct();
            measure_args.output = 'correlation';
            
            % 'Spearman' requires  matlab with stats toolbox; if not present use
            % 'Pearson'
            if cosmo_check_external('@stats',false)
                measure_args.type='Spearman';
            else
                measure_args.type='Pearson';
                fprintf('Matlab stats toolbox not present, using %s correlation\n',...
                    measure_args.type)
            end
            
            if cfg.normalize>0
                measure_args.normalization = 'demean';
                measure_args.normalize = cfg.normalize;
            end
            partitions=cosmo_nfold_partitioner(ds_cross);
            
            
            % run searchlight
            cfg.random_perm = 0;
            if cfg.random_perm == 1
                perm = 'nullMaps';
                for iPerm =1:100
                    randomized_targets=cosmo_randomize_targets(ds_cross); % shuffle the targets
                    ds_cross.sa.targets=randomized_targets; % put the shuffled targets in the dataset
                    temp = cosmo_searchlight(ds_cross,nbrhood,measure,measure_args,'partitions',partitions);
                    lda_results{iPerm}=temp;
                end
                output_fn = sprintf('%s/SUB%02d_%s_sm%dmm_volume_%s_rad%d_perm.mat',output_path,iSub,cfg.TestNames{cfg.TestVec(iTest)},cfg.smoothing,cfg.classifier,abs(cfg.radius));
                save(output_fn,'lda_results');
            else
                ds_raw=cosmo_searchlight(ds_cross,nbrhood,measure,measure_args,'partitions',partitions);
                output_fn = sprintf('%s/%s_SUB%02d_%s_%s_sm%dmm_volume_%s_rad%d.mat',output_path,cfg.sessionName,iSub,cfg.TestNames{cfg.TestVec(iTest)},cfg.type,cfg.smoothing,cfg.classifier,abs(cfg.radius));
                save(output_fn,'ds_raw');
            end
            
        end
        
    end
    
end
end