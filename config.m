function cfg = config(cfg,iSub)

%% ===== USER CONFIGURATION =====
% Set the paths below before running the pipeline.

% Root project directory (should contain subdirectories: glm/, vmp/, msk/, etc.)
cfg.path = '/path/to/your/project';

% Grey matter mask used to threshold maps for MVPA and correction
cfg.mask_name = '/path/to/ave_GM_mask.msk';

% BrainVoyager look-up table (LUT) file for accuracy colour maps.
% Set to '' if you do not have this file.
cfg.lut_path = '/path/to/Accuracy_colors.olt';

% Directory containing optic flow RDM .mat files (needed for create_rdms)
cfg.opticflow_path = '/path/to/ExpVideos';

% Add required toolboxes to the MATLAB path
addpath(genpath('/path/to/CoSMoMVPA'));
addpath(genpath('/path/to/NeuroElf'));
addpath(genpath('/path/to/libsvm'));
addpath(genpath(fullfile(cfg.path, 'Matlab_scripts', 'helper_functions')));
addpath(genpath(fullfile(cfg.path, 'Matlab_scripts')));

% ===== END USER CONFIGURATION =====


%% experiment name
cfg.experimentName = 'AGENCY';

%% raw data / sequence details (only needed for preprocessing)
cfg.TR = 1.5;
cfg.skipNVol = 4;
cfg.fmr.sizeX = 66;
cfg.fmr.sizeY = 66;
cfg.nVolumes = repmat([262, 262, 262, 262, 262, 262],25,1);
cfg.preproc = 'SCCAI_3DMCT_LTR_THP3c'; % needed for batch GLM file generation

%% design params
cfg.nConditions = 13;

if exist('iSub','var')
    if strcmp(cfg.sessionName,'AGENCY_video')
        if iSub==2 || iSub==3 || iSub==20
            cfg.nRuns = 5;
            cfg.RunVec=1:5;
        else
            cfg.nRuns = 4;
            cfg.RunVec=1:4;
        end
    elseif strcmp(cfg.sessionName,'AGENCY_sentence')
        if iSub==3 || iSub==8 || iSub==13
            cfg.nRuns = 4;
            cfg.RunVec=1:4;
        elseif iSub==16
            cfg.nRuns = 6;
            cfg.RunVec=1:6;
        else
            cfg.nRuns = 5;
            cfg.RunVec=1:5;
        end
    end
end

%% motion correction (included in design matrix or not)
cfg.motionCorr = 'mc'; % set to 'no_moco' to exclude motion regressors

%% conditions
% 12 action conditions (agent animacy x recipient animacy x action type)
% plus 1 catch trial condition
cfg.condLabels = {'hit_anim_anim',...
        'jumpover_anim_anim',...
        'passby_anim_anim',...
        'hit_anim_inanim',...
        'jumpover_anim_inanim',...
        'passby_anim_inanim',...
        'hit_inanim_anim',...
        'jumpover_inanim_anim',...
        'passby_inanim_anim',...
        'hit_inanim_inanim',...
        'jumpover_inanim_inanim',...
        'passby_inanim_inanim', 'catchTrials'};

cfg.conditionsCross = {'hit-kick','bounce-jump','roll-walk'};

%% RDM labels (for glmRSA)
cfg.rdmLabels = {'animateInanimate_recipient','contact','animateInanimate_agent','motion_path','recipient_relevance','magnitude','orientation'};
