% =========================================================================
% Analysis pipeline for:
%
%   Karakose-Akbiyik, S., Caramazza, A., & Wurm, M.F. (2023).
%   A shared neural code for the physics of actions and object events.
%   Nature Communications, 14(1), 3316.
%   https://doi.org/10.1038/s41467-023-39062-8
%
% Data: https://osf.io/h4mtp/
%
% Experiment: Two fMRI sessions (video and sentence), 25 participants.
% Conditions: 12 action conditions (agent animacy x recipient animacy x
%   action type: hit/jump-over/pass-by) + 1 catch trial condition.
%
% Requirements:
%   - BrainVoyager QX (preprocessing, GLM, VMP/VTC/SDM/MDM file I/O)
%   - CoSMoMVPA (MVPA and RSA searchlight)
%   - NeuroElf (BrainVoyager file I/O from MATLAB)
%   - libsvm (SVM classifier)
%
% Parts of this pipeline are adapted from code by Angelika Lingnau
% and Moritz Wurm.
%
% Before running: set paths in config.m
% =========================================================================

%% Create Brainvoyager formatted PRT files from experiment log files 

% cfg.sessionName = 'AGENCY_video'; % 'AGENCY_video' OR 'AGENCY_sentence'
% cfg.SubVec = [4];
% cfg.Design = 'twoPerRunwise'; % 'twoPerRunwise' for MVPA OR 'Runwise' for univariate 
% log_to_prt(cfg.SubVec, cfg);

%% Specify session
cfg.sessionName = 'AGENCY_video'; % AGENCY_sentence or AGENCY_video

%% Create first functional run for cross-session alignment

for iSub = cfg.SubVec
    create_first_run(iSub);
end

%% Preprocess functional runs
% Alignment session is determined automatically from subject parity (see preprocess_subject.m)

cfg.SubVec = 1:25;
for iSub = cfg.SubVec
    preprocess_subject(iSub);
end

%% Check preprocessing quality (tSNR)

cfg.SubVec = 1:25;
for iSub = cfg.SubVec
    compute_tsnr(iSub, cfg);
end

%% Create design matrices (SDM)

cfg.SubVec = 1:25;
for iSub = cfg.SubVec
    cfg.Design = 'Runwise'; % Runwise or twoPerRunwise
    create_sdm(iSub, cfg);
end

%% Create VTCs
% Selects the correct run for alignment based on subject parity (odd/even)

for iSub = cfg.SubVec
    create_vtc(iSub, cfg);
end

%% Smooth VTCs — 3 mm for MVPA, 8 mm for univariate

for iSub = cfg.SubVec
    cfg.smoothing = 3;
    smooth_vtc(iSub, cfg);
    cfg.smoothing = 8;
    smooth_vtc(iSub, cfg);
end

%% Create multi-study design matrices (MDM) for univariate group maps

for iSub = cfg.SubVec
    cfg.smoothing = 8;
    cfg.Design = 'Runwise';
    create_mdm(iSub, cfg);
end

%% Create group MDM

cfg.SubVec    = 1:25;
cfg.sessionName = 'AGENCY_sentence';
cfg.smoothing = 8;
cfg.Design    = 'Runwise';
create_mdm_group(cfg);

%% Compute GLM

cfg.SubVec        = 1:25;
cfg.smoothing     = 8;
cfg.singleSubject = 0; % 0 = RFX GLM (for univariate analysis)
cfg.singleRun     = 0; % 0 = single beta per condition across all runs
cfg.Design        = 'Runwise';
create_glm(cfg);

%% Univariate contrasts

cfg.SubVec      = 1:25;
cfg.smoothing   = 8;
cfg.Design      = 'Runwise';
cfg.motionCorr  = 'mc';

cfg.contrastVecs = {[-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 12], ... % catchVactions
    [ 1  1  1  1  1  1  1  1  1  1  1  1  0], ... % allactions vs baseline
    [ 1  1  1  1  1  1  0  0  0  0  0  0  0], ... % animAgentVbaseline
    [ 0  0  0  0  0  0  1  1  1  1  1  1  0], ... % inanimAgentVbaseline
    [ 1  1  1  1  1  1 -1 -1 -1 -1 -1 -1  0], ... % animVinanim_agent
    [ 0  0  0  0  0  0  1  1  1 -1 -1 -1  0], ... % inanimactions_person_presence
    [ 0  0  0  0  0  0  0  0  0  1  1  1  0], ... % objects_only
    [ 0  0  0  1  1  1 -1 -1 -1  0  0  0  0], ... % subject animacy, bodies controlled
    [ 1  1  1  0  0  0  0  0  0  0  0  0  0], ... % anim_anim
    [ 0  0  0  1  1  1  0  0  0  0  0  0  0], ... % anim_inanim
    [ 0  0  0  0  0  0  1  1  1  0  0  0  0], ... % inanim_anim
    [ 0  0  0  0  0  0  0  0  0  1  1  1  0]};    % inanim_inanim

cfg.constrastNames = {'catchVactions', 'allActions', 'animAgentVbaseline', ...
    'inanimAgent_baseline', 'animVinanim_agent', 'inanimactions_person_presence', ...
    'noHuman', 'animinanimagent_bodiescontrolled', ...
    'anim_anim', 'anim_inanim', 'inanim_anim', 'inanim_inanim'};

cfg.contrastVec   = 1:8;
cfg.singleSubject = 0;
cfg.singleRun     = 0;
compute_contrast(cfg)

%% MVPA searchlight decoding

cfg.debug        = 0;
cfg.decodingType = 'cross_mod'; % 'within_mod' OR 'cross_mod'
cfg.sessionName  = 'AGENCY_video'; % only needed for within_mod
cfg.Design       = 'twoPerRunwise';
cfg.SubVec       = 1:25;
cfg.TestVec      = [21:23];
cfg.normalize    = 1; % 1 = normalise across voxels, 2 = normalise across betas
cfg.TestNames    = {'balance_catch', 'ANIMATE_multiclass3', 'INANIMATE_multiclass3', ...
                    'anim_anim_multiclass3', 'anim_inanim_multiclass3', ...
                    'inanim_anim_multiclass3', 'inanim_inanim_multiclass3', ...
                    'crossmodal_anim_multiclass3', 'crossmodal_inanim_multiclass3', ...
                    'crossanimacy_withinmod', 'video_crossFullAnimNoAnim', 'actions_multiclass12', ...
                    'crossModalcrossAnimacy', 'agent_actions', 'object_events', ...
                    'hit_jump_crossAnimacy', 'hit_pass_crossAnimacy', 'jump_pass_crossAnimacy', ...
                    'agentORobject_2way', 'animate_crossTarget', ...
                    'jump-walk_cross_mod_animacy', 'kick-jump_cross_mod_animacy', ...
                    'kick-walk_cross_mod_animacy'};
cfg.radius      = 4; % in voxels (4 voxels = 12 mm)
cfg.classifier  = 'svm';
cfg.smoothing   = 3;
cfg.motionCorr  = 'mc';
cfg.type        = 'classify';
cfg.leaveOneOut = 0; % only relevant when cfg.type = 'corrMat'
mvpa_searchlight(cfg);

%% Create group VMP for MVPA searchlight

cfg.SubVec       = 1:25;
cfg.decodingType = 'cross_mod';
create_vmp_group(cfg);

%% Apply multiple-comparison correction

cfg.SubVec         = 1:25;
cfg.tfce           = 0;
cfg.mcc            = 1;
cfg.iter           = 10000;
cfg.MCC_init_thres = .001;
cfg.mapNames = { ...
    'classify/N25_DecodingContrasts_inanim_anim_multiclass3_inanim_inanim_multiclass3_classify_svm_twoPerRunwise_sm3mm_volume_rad4.vmp', ...
    'classify/N25_DecodingContrasts_anim_anim_multiclass3_anim_inanim_multiclass3_classify_svm_twoPerRunwise_sm3mm_volume_rad4.vmp', ...
    'classify/N25_classify_kick-jump_cross_mod_animacy_twoPerRunwise_svm_sm3mm_volume_rad4_AllSubjects_normalize1.vmp', ...
    'classify/N25_classify_AGENCY_sentence_crossanimacy_withinmod_twoPerRunwise_svm_sm3mm_volume_rad4_AllSubjects.vmp', ...
    'classify/N25_DecodingContrasts_ANIMATE_multiclass3_INANIMATE_multiclass3_classify_svm_twoPerRunwise_sm3mm_volume_rad4.vmp', ...
    'classify/N25_classify_AGENCY_video_crossanimacy_withinmod_twoPerRunwise_svm_sm3mm_volume_rad4_AllSubjects.vmp', ...
    'classify/N25_classify_AGENCY_video_jump_pass_crossAnimacy_twoPerRunwise_svm_sm3mm_volume_rad4_AllSubjects_normalize1.vmp', ...
    'classify/N25_classify_AGENCY_video_hit_pass_crossAnimacy_twoPerRunwise_svm_sm3mm_volume_rad4_AllSubjects_normalize1.vmp', ...
    'classify/N25_classify_AGENCY_video_hit_jump_crossAnimacy_twoPerRunwise_svm_sm3mm_volume_rad4_AllSubjects_normalize1.vmp', ...
    'classify/N25_classify_AGENCY_video_anim_anim_multiclass3_twoPerRunwise_svm_sm3mm_volume_rad4_AllSubjects.vmp', ...
    'classify/N25_classify_AGENCY_video_anim_inanim_multiclass3_twoPerRunwise_svm_sm3mm_volume_rad4_AllSubjects.vmp', ...
    'classify/N25_classify_AGENCY_video_inanim_anim_multiclass3_twoPerRunwise_svm_sm3mm_volume_rad4_AllSubjects.vmp', ...
    'classify/N25_classify_AGENCY_video_inanim_inanim_multiclass3_twoPerRunwise_svm_sm3mm_volume_rad4_AllSubjects.vmp', ...
    'glmRSA_searchlight/AGENCY_video_all_events_N25_within_mod_glmRSA_searchlight_4_motion_path_twoPerRunwise_sm3mm_volume_rad4.vmp', ...
    'glmRSA_searchlight/AGENCY_video_all_events_N25_within_mod_glmRSA_searchlight_2_contact_twoPerRunwise_sm3mm_volume_rad4.vmp'};
cfg.mapVec = 1:2;
correct_maps(cfg);

%% Decoding contrasts — pairwise map comparisons within group

cfg.SubVec          = 1:25;
cfg.decodingContrast = 'decodingComparison';
cfg.decodingType    = 'within_mod';
cfg.comparisonNames = {'anim_anim_multiclass3', 'anim_inanim_multiclass3';
    'inanim_anim_multiclass3', 'inanim_inanim_multiclass3'}';
cfg.comparisonVec   = [1 2];
cfg.classifier      = 'svm';
cfg.Design          = 'twoPerRunwise';
cfg.type            = 'classify';
cfg.smoothing       = 3;
cfg.radius          = 4;
decoding_contrast(cfg);

%% Save ROI data from maps
% Common settings — override specific fields in the blocks below as needed
cfg.SubVec       = 1:25;
cfg.analysisName = 'MVPA_multiclass';
cfg.type         = 'classify';
cfg.VOIname      = 'caspers_brod_all_ROIs_spherical_12mm';
cfg.VOInamer     = 'caspers_brod_all_ROIs_spherical_12mm_';
cfg.ROImask      = {'leftPMv','leftIPL','leftLPTC','leftSTS','leftSPL','leftPrimaryVisual', ...
                    'rightPMv','rightIPL','rightLPTC','rightSTS','rightSPL','rightPrimaryVisual'};
cfg.ROIVec       = 1:12;

% Video session: animate vs inanimate agent
cfg.mapNames = {'N25_classify_AGENCY_video_ANIMATE_multiclass3_twoPerRunwise_svm_sm3mm_volume_rad4_AllSubjects.vmp', ...
    'N25_classify_AGENCY_video_INANIMATE_multiclass3_twoPerRunwise_svm_sm3mm_volume_rad4_AllSubjects.vmp'};
cfg.fileName = 'n25_caspers_all_video_animate_inanimate';
cfg.mapVec   = 1:2;
roi_save_from_maps(cfg)

% Video session: within-modality crossanimacy
cfg.mapNames = {'N25_classify_AGENCY_video_crossanimacy_withinmod_twoPerRunwise_svm_sm3mm_volume_rad4_AllSubjects.vmp'};
cfg.fileName = 'n25_caspers_all_video_crossanimacy';
cfg.mapVec   = 1;
roi_save_from_maps(cfg)

%% GLM RSA searchlight

cfg.SubVec      = 1:25;
cfg.radius      = 4;
cfg.classifier  = 'svm';
cfg.sessionName = 'AGENCY_video';
cfg.rdmLabels   = {'animateInanimate_recipient','contact','animateInanimate_agent', ...
                   'motion_path','recipient_relevance','magnitude','orientation'};
cfg.smoothing   = 3;
cfg.customMask  = 0;
cfg.Design      = 'twoPerRunwise';
cfg.type        = 'glmRSA_searchlight';
cfg.classes     = 1:12;
cfg.type2       = 'all_events';
cfg.TestVec     = [1:4];
glmrsa_searchlight(cfg);

%% Create group VMP for GLM RSA searchlight

cfg.type         = 'glmRSA_searchlight';
cfg.normalize    = 1;
cfg.decodingType = 'within_mod';
cfg.TestVec      = [1:4];
cfg.type2        = 'all_events';
create_vmp_group(cfg);

%% Paired t-test between univariate VMP maps

cfg.SubVec = 1:25;
cfg.vmp1   = 'N25_classify_AGENCY_video_ANIMATE_multiclass3_Runwise_svm_sm3mm_volume_rad4_AllSubjects';
cfg.vmp2   = 'N25_classify_AGENCY_video_INANIMATE_multiclass3_Runwise_svm_sm3mm_volume_rad4_AllSubjects';
vmp_paired_ttest(cfg);
