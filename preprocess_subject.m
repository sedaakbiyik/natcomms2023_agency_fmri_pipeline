function preprocess_subject(iSub)
% Preprocesses all functional runs for a subject.
% Cross-session motion correction alignment accounts for counterbalancing:
%   odd subjects started with the video session (align to AGENCY_video run 01)
%   even subjects started with the sentence session (align to AGENCY_sentence run 01)
%example call:
cfg.experimentName = 'AGENCY';
cfg = config(cfg,iSub);
pathToData = sprintf('%s/sub%02d/%s/', cfg.path,iSub,cfg.sessionName);
pathToSub = sprintf('%s/sub%02d/', cfg.path,iSub);
pathToLog  = sprintf('%s/res/', cfg.path);
%cfg.Design = 'Runwise' %or twoPerRunwise, only relevant if
%you link the protocol. we don't link the protocol so no worries
%cfg.firstDicomNr=1;
fNameVec = dir(sprintf('%s/*3mm*iso*',pathToData));
fNameVec.name

%----------------------------------

% cfg.firstDicomNr = 30;


cfg.fmr.nrSlices = 45; % cfg.nSlices;
cfg.preprocessing.sliceTimingCorrection.sliceorder = 1; % cfg.sliceOrder; % 1; % 0 ascending, 1 ascending interleaved odd-even, 2 ascending interleaved even-odd, 10 descending, 11 descending interleaved odd-even, 12 descending interleaved even-odd
cfg.preprocessing.motionCorrection.targetVolumeNumber = 1;
cfg.preprocessing.temporalHighPassFiltering.perform = 1;
cfg.preprocessing.LinearTrendRemoval.perform = 0; %CHECK! is included in motion correction (therefore not necessary)
cfg.preprocessing.motionCorrection.perform = 1;


cfg.fmr.skipVols = cfg.skipNVol;



% https://wiki.cimec.unitn.it/tiki-index.php?page=MRIBOLDfMRI#Slice_acquisition_order

% Slice order can be set in the protocol to either "Ascending", "Descending" or "Interleaved".
%
% "Ascending" means consecutive, in the order inferior->superior (foot->head) for axial
% "Descending" means consecutive, in the order superior->inferior (head->foot) for axial
% "Interleaved" means...
% ascending interleaved with even slices first, then odd slices if the number of slices acquired is even (2,4,6,8,...end; 1,3,5,7,..end-1)
% ascending interleaved with odd slices first, then even slices if the number of slices acquired is odd (1,3,5,7,...end; 2,4,6,8,..end-1),
% where the numbering is of the slices above is in position order (1 = closest to feet, 2 next closest, end is at the head)
%
% If you want to know with which acquisition scheme your images were acquired look in the text section of the DICOM header. This is in text_header.txt if you used dicom_sort_convert_main.m to sort your images to NIfTI or Analyze, otherwise in every DICOM file in your EPI time-series. Open one of these with an editor (e.g. Wordpad) and search for "### ASCCONV BEGIN ###". Not far below you will find a field called
%
% "sSliceArray.ucMode"
%
% which will have one of the following values:
%
% "0x1" which means "Ascending"
% "0x2" which means "Descending"
% "0x4" which means "Interleaved"


[~,MESSAGE,MESSAGEID] = mkdir(pathToSub, 'bv');

cfg.copyToTargetFolder = [pathToSub '/bv'];
cfg.fmr.targetFolder = [pathToSub '/bv'];

% DO THE PREPROCESSING
%----------------------------------
for i =  1:length(fNameVec) 
    
    cfg.fmr.nrOfVols = numel(dir(sprintf('%s/%s/*.dcm', pathToData, fNameVec(i).name)));

    if mod(iSub, 2) == 1
        alignSession = 'AGENCY_video';    % odd subjects: video session first
    else
        alignSession = 'AGENCY_sentence'; % even subjects: sentence session first
    end

    if i == 1 && strcmp(cfg.sessionName, alignSession)
        % first run of the first session: use as its own reference
        cfg.preprocessing.motionCorrection.targetFMR = '';
    else
        % all other runs: align to run 01 of the first session
        cfg.preprocessing.motionCorrection.targetFMR = [cfg.copyToTargetFolder '/' sprintf('SUB%02d_01_%s.fmr', iSub, alignSession)];
    end
    cfg.fmr.sourceFolder =  sprintf('%s%s', pathToData, fNameVec(i).name);
    cfg.fmr.FMRPrefix = sprintf('SUB%02d_%02d_%s', iSub, i, cfg.sessionName);
%     cfg.expinfo.PRTName =  [pathToLog sprintf('/SUB%02d_%02d_%s_%s.prt', iSub, i, cfg.sessionName,cfg.Design)];
    dicomList= dir(sprintf('%s/*.dcm',cfg.fmr.sourceFolder));
    firstDicom =dicomList(1);
    bvqx = createandpreprocess(cfg, firstDicom.name);
    clear bvqx;
    pause(4);
end
close all;
clear all;

end

function bvqx = createandpreprocess(cfg, fNameFirstDicomFile)
%function bvqx = createandpreprocess(cfg)
%%This program calls BrainVoyagerQX through its COM interface
%%to create functional projects and preprocess them.
%%The cfg structure is used to inform the program about the location of the
%%source data and target directories.
%%Further, the cfg structure can be used to modify the default settings
%last update: 2012-08-23 JS updated for BV 2.4.1 (folders are not moved anymore)
%%%MANDATORY INFORMATION
%%cfg.fmr.sourceFolder   provide path to source data
%%cfg.fmr.nrSlices
%%cfg.fmr.nrOfVols
%%cfg.fmr.FMRPrefix      provide name for the project
%%
%%OPTIONAL INFORMATION {DEFAULT VALUES}
%%
%--------------------------------------------------------------------------
% ACQUISITION PARAMETERS
%--------------------------------------------------------------------------
% cfg.fmr.sizeX                                                     [{64}]
% cfg.fmr.sizeY                                                     [{64}]
%
%--------------------------------------------------------------------------
% PROJECT CREATION PARAMETERS
%--------------------------------------------------------------------------
% cfg.fmr.skipVols                                                  [{2}]
% cfg.fmr.createAMR                                                 [0, {1}]
% cfg.copyToTargetFolder                                            []
%
%--------------------------------------------------------------------------
% DATA FORMAT PARAMETERS
%--------------------------------------------------------------------------
% cfg.fmr.fileType                                                  [{'DICOM'}, 'SIEMENS', 'GE_I', 'GE_MR', 'PHILIPS_REC', 'ANALYZE']
% cfg.fmr.byteswap                                                  [{0}, 1]
% cfg.fmr.mosaicSizeX                                               %DEFAULT calculated from image matrix size and number of slices
% cfg.fmr.mosaicSizeY                                               %DEFAULT calculated from image matrix size and number of slices
% cfg.fmr.bytesPerPixel                                             [{1}]
% cfg.fmr.nrVolsInImg                                               [{1}]
%
%--------------------------------------------------------------------------
%PREPROCESSING FLAGS
%--------------------------------------------------------------------------
%SLICE TIMING CORRECTION
% cfg.preprocessing.sliceTimingCorrection.perform                   [0, {1}]
% cfg.preprocessing.sliceTimingCorrection.sliceorder                [{depending on number of slices}]% 0 ascending, 1 ascending interleaved odd-even, 2 ascending interleaved even-odd, 10 descending, 11 descending interleaved odd-even, 12 descending interleaved even-odd
%                                                                   1 for odd number of slices
%                                                                   2 for even number of slices
% cfg.preprocessing.sliceTimingCorrection.stcInterpolationMethod    [0, {1}] %0 trilinear, 1 sinc
%
%MOTION CORRECTION
% cfg.preprocessing.motionCorrection.perform                        [0, {1}]
% cfg.preprocessing.motionCorrection.targetFMR                      []
% cfg.preprocessing.motionCorrection.targetVolumeNumber             [{1}]
% cfg.preprocessing.motionCorrection.interpolationMethod            [{1}]   %1 = trilinear
% cfg.preprocessing.motionCorrection.useFullDataSet                 [{0}, 1]% 0 = no, 1 = yes
% cfg.preprocessing.motionCorrection.maxNumberOfIterations          [{100}]
% cfg.preprocessing.motionCorrection.createMovies                   [{0}]   % 0 = no, 1 = yes
% cfg.preprocessing.motionCorrection.createExtendedLogFile          [0, {1}]% 0 = no, 1 = yes
%
%TEMPORAL FILTERING
% cfg.preprocessing.temporalHighPassFiltering.perform               [0, {1}]
% cfg.preprocessing.temporalHighPassFiltering.unit                  [{'cycles'}, 'Hz']
% cfg.preprocessing.temporalHighPassFiltering.value                 [3]     %DEFAULT: 3 cycles per run
%
% cfg.preprocessing.temporalGaussianSmoothing.perform               [{0}, 1]    %DEFAULT: no temporal smoothing
% cfg.preprocessing.temporalGaussianSmoothing.unit                  [{'s'}, 'TR']
% cfg.preprocessing.temporalGaussianSmoothing.value                 [20]    %DEFAULT if used, kernel width of 20s
%
%SPATIAL FILTERING
% cfg.preprocessing.spatialGaussianSmoothing.perform                [{0}, 1]        %DEFAULT: no spatial smoothing
% cfg.preprocessing.spatialGaussianSmoothing.unit =                 [{'mm'}, 'px']  %DEFAULT: if used 6mm
% cfg.preprocessing.spatialGaussianSmoothing.value                  [6]
%

currentTime = now;
%cfg.fmr.targetFolder = cfg.fmr.sourceFolder; %HAVE TO DO THIS BECAUSE OF BUG

%--------------------------------------------------------------------------
%ACQUISITION PARAMETERS
%--------------------------------------------------------------------------
if ~isfield(cfg.fmr, 'sizeX'), cfg.fmr.sizeX = 64; capmsg('Matrix Size X = 64'); else end; %DEFAULT MATRIX SIZE 64 x 64
if ~isfield(cfg.fmr, 'sizeY'), cfg.fmr.sizeY = 64; capmsg('Matrix Size Y = 64'); else end;

%--------------------------------------------------------------------------
%PROJECT CREATION PARAMETERS
%--------------------------------------------------------------------------
if ~isfield(cfg.fmr, 'skipVols'), cfg.fmr.skipVols = 2; capmsg('SKIPPING 2 VOLUMES'); else end;
if ~isfield(cfg.fmr, 'createAMR'), cfg.fmr.createAMR = 1; capmsg('CREATE INPLANE PSEUDO-ANATOMICAL IMAGE'); else end;
if ~isfield(cfg, 'copyToTargetFolder'), cfg.copyToTargetFolder = []; else end;

%--------------------------------------------------------------------------
%DATA FORMAT PARAMETERS
%--------------------------------------------------------------------------
if ~isfield(cfg.fmr, 'fileType'), cfg.fmr.fileType = 'DICOM'; capmsg('DATA FORMAT IS DICOM'); else end;
if ~isfield(cfg.fmr, 'byteswap'), cfg.fmr.byteswap = 0; capmsg('NO BYTE SWAP'); else end;
if ~isfield(cfg.fmr, 'mosaicSizeX'), cfg.fmr.mosaicSizeX = ceil(sqrt(cfg.fmr.nrSlices))* cfg.fmr.sizeX; capmsg(sprintf('mosaicSizeX = %d', cfg.fmr.mosaicSizeX)); else end; %MOSAIC PACKS SLICES IN A SQUARE MATRIX
if ~isfield(cfg.fmr, 'mosaicSizeY'), cfg.fmr.mosaicSizeY = ceil(sqrt(cfg.fmr.nrSlices))* cfg.fmr.sizeY; capmsg(sprintf('mosaicSizeY = %d', cfg.fmr.mosaicSizeY)); else end; %THIS ALGORITHM MAY FAIL FOR NON-SQUARE ACQUISITION MATRICES
if ~isfield(cfg.fmr, 'bytesPerPixel'), cfg.fmr.bytesPerPixel = 1; capmsg('BYTES PER PIXEL = 1'); else end;
if ~isfield(cfg.fmr, 'nrVolsInImg'), cfg.fmr.nrVolsInImg = 1; capmsg('VOLUMES IN IMAGE = 1'); else end;

%--------------------------------------------------------------------------
%PREPROCESSING FLAGS
%--------------------------------------------------------------------------
if ~isfield(cfg, 'preprocessing'), cfg.preprocessing = []; else end;
%SLICE TIMING CORRECTION
if ~isfield(cfg.preprocessing, 'sliceTimingCorrection'), cfg.preprocessing.sliceTimingCorrection = []; else end;
if ~isfield(cfg.preprocessing.sliceTimingCorrection, 'sliceorder'), if isEven(cfg.fmr.nrSlices), cfg.preprocessing.sliceTimingCorrection.sliceorder = 2; else cfg.preprocessing.sliceTimingCorrection.sliceorder = 1; end; else end; % 0 ascending, 1 ascending interleaved odd-even, 2 ascending interleaved even-odd, 10 descending, 11 descending interleaved odd-even, 12 descending interleaved even-odd
if ~isfield(cfg.preprocessing.sliceTimingCorrection, 'perform'), cfg.preprocessing.sliceTimingCorrection.perform = 1; else end;
if ~isfield(cfg.preprocessing.sliceTimingCorrection, 'stcInterpolationMethod'), cfg.preprocessing.sliceTimingCorrection.stcInterpolationMethod = 1; else end; %0 trilinear, 1 sinc

%MOTION CORRECTION
if ~isfield(cfg.preprocessing, 'motionCorrection'), cfg.preprocessing.motionCorrection = []; else end;
if ~isfield(cfg.preprocessing.motionCorrection, 'perform'), cfg.preprocessing.motionCorrection.perform = 1; else end;
%I am still suspicious of using motion correction for coregistration in BV
%since I have observed oscillatory moco parameters with it. It looks as if
%this algorithm has problems converging when distances are large
if ~isfield(cfg.preprocessing.motionCorrection, 'targetFMR'), cfg.preprocessing.motionCorrection.targetFMR = ''; else end; %'AL_r01.fmr'; %USE RUN 1 AS REFERENCE FOR MOCO, SUBJECT TO CHANGE
if ~isfield(cfg.preprocessing.motionCorrection, 'targetVolumeNumber'), cfg.preprocessing.motionCorrection.targetVolumeNumber = 1; else end;%
if ~isfield(cfg.preprocessing.motionCorrection, 'interpolationMethod'), cfg.preprocessing.motionCorrection.interpolationMethod = 1; else end;%1 = trilinear
if ~isfield(cfg.preprocessing.motionCorrection, 'useFullDataSet'), cfg.preprocessing.motionCorrection.useFullDataSet = 0; else end;% 0 = no, 1 = yes
if ~isfield(cfg.preprocessing.motionCorrection, 'maxNumberOfIterations'), cfg.preprocessing.motionCorrection.maxNumberOfIterations = 100; else end;
if ~isfield(cfg.preprocessing.motionCorrection, 'createMovies'), cfg.preprocessing.motionCorrection.createMovies = 0; else end;% 0 = no, 1 = yes
if ~isfield(cfg.preprocessing.motionCorrection, 'createExtendedLogFile'), cfg.preprocessing.motionCorrection.createExtendedLogFile = 1; else end;% 0 = no, 1 = yes

%TEMPORAL FILTERING
if ~isfield(cfg.preprocessing, 'temporalHighPassFiltering'), cfg.preprocessing.temporalHighPassFiltering = []; else end;
if ~isfield(cfg.preprocessing.temporalHighPassFiltering, 'perform'), cfg.preprocessing.temporalHighPassFiltering.perform = 1; else end;
if ~isfield(cfg.preprocessing.temporalHighPassFiltering, 'unit'), cfg.preprocessing.temporalHighPassFiltering.unit = 'cycles'; else end;%'cycles', or 'Hz'
if ~isfield(cfg.preprocessing.temporalHighPassFiltering, 'value'), cfg.preprocessing.temporalHighPassFiltering.value = 3; else end; %DEFAULT: 3 cycles per run

if ~isfield(cfg.preprocessing, 'temporalGaussianSmoothing'), cfg.preprocessing.temporalGaussianSmoothing = []; else end;
if ~isfield(cfg.preprocessing.temporalGaussianSmoothing, 'perform'), cfg.preprocessing.temporalGaussianSmoothing.perform = 0; else end;
if ~isfield(cfg.preprocessing.temporalGaussianSmoothing, 'unit'), cfg.preprocessing.temporalGaussianSmoothing.unit = 's'; else end;%'s' or 'TR'
if ~isfield(cfg.preprocessing.temporalGaussianSmoothing, 'value'), cfg.preprocessing.temporalGaussianSmoothing.value = 20; else end;

if ~isfield(cfg.preprocessing, 'spatialGaussianSmoothing'), cfg.preprocessing.spatialGaussianSmoothing = []; else end;
if ~isfield(cfg.preprocessing.spatialGaussianSmoothing, 'perform'), cfg.preprocessing.spatialGaussianSmoothing.perform = 0; else end;
if ~isfield(cfg.preprocessing.spatialGaussianSmoothing, 'value'), cfg.preprocessing.spatialGaussianSmoothing.value = 6; else end;
if ~isfield(cfg.preprocessing.spatialGaussianSmoothing, 'unit'), cfg.preprocessing.spatialGaussianSmoothing.unit = 'mm'; else end;%'mm' or 'px'

%--------------------------------------------------------------------------
%startup BrainVoyager
%--------------------------------------------------------------------------
%bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXInterface');
bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1')
bvqx.ResizeWindow(1900, 600);
bvqx.ShowLogTab;

%currentDirectory = cd;


%----------------------------------------------------------------------
%CREATE FMR
%----------------------------------------------------------------------
%FILL IN RUN SPECIFIC INFO
cfg.fmr.stcPrefix = cfg.fmr.FMRPrefix;
%cd(cfg.fmr.sourceFolder)

%fname = sprintf('%s-%04d-0001-00001.dcm', subjectName, runNum);
%fName = dir('*00001.dcm');
%cfg.fmr.firstFileName = fullfile(cfg.fmr.sourceFolder, 'Image0001.dcm');

%cfg.fmr.firstFileName = fullfile(cfg.fmr.sourceFolder, fName.name); %FOR DATA FROM REGENSBURG SCANNER
cfg.fmr.firstFileName = fullfile(cfg.fmr.sourceFolder, fNameFirstDicomFile); %FOR DATA FROM REGENSBURG SCANNER
cfg.fmr.targetName = fullfile(cfg.fmr.targetFolder, [cfg.fmr.FMRPrefix, '.fmr']);

% if i==1
% cfg.preprocessing.motionCorrection.targetFMR = cfg.targetName; %USE RUN 1 AS REFERENCE FOR MOCO, SUBJECT TO CHANGE
% end

%CREATE PROJECT
hFMR = fmr_create(bvqx, cfg);

% %LINK PROTOCOL
% if exist(cfg.expinfo.PRTName, 'file')
%     %copy protocol to local directory in order to avoid absolute paths to be
%     %stored in the fMR
%     cmdstr = sprintf('!copy %s %s', cfg.expinfo.PRTName, cfg.fmr.sourceFolder);
%     eval(cmdstr)
%     [PATHSTR,NAME,EXT,VERSN] = fileparts(cfg.expinfo.PRTName);
%     bvqx.PrintToLog(sprintf('// LINKING PROTOCOL %s', [NAME, EXT]));
%     hFMR.LinkStimulationProtocol([NAME, EXT]);
% else
%     fprintf(1, 'Cannot link protocol file %s/n', cfg.expinfo.PRTName);
% end

%SAVE PROJECT
hFMR.Save;

%CLOSE PROJECT
hFMR.Close;

%KEEP IN MIND LATEST STEP
LatestFile = cfg.fmr.targetName;


%----------------------------------------------------------------------
%PREPROCESS
%----------------------------------------------------------------------
%SliceTimeCorrection
if cfg.preprocessing.sliceTimingCorrection.perform
    hFMR = bvqx.OpenDocument(LatestFile);
    success = fmr_stc(bvqx, hFMR, cfg.preprocessing.sliceTimingCorrection);
    LatestFile = hFMR.FileNameOfPreprocessdFMR;
    hFMR.Close;
end

%MotionCorrection
if cfg.preprocessing.motionCorrection.perform
    hFMR = bvqx.OpenDocument(LatestFile);
    success = fmr_moco(bvqx, hFMR, cfg.preprocessing.motionCorrection);
    LatestFile = hFMR.FileNameOfPreprocessdFMR;
    hFMR.Close;
end

%TemporalHighPassFiltering
if cfg.preprocessing.temporalHighPassFiltering.perform
    hFMR = bvqx.OpenDocument(LatestFile);
    success = fmr_temporalHighPass(bvqx, hFMR, cfg.preprocessing.temporalHighPassFiltering);
    LatestFile = hFMR.FileNameOfPreprocessdFMR;
    hFMR.Close;
end

%Temporal Smoothing
if cfg.preprocessing.temporalGaussianSmoothing.perform
    hFMR = bvqx.OpenDocument(LatestFile);
    success = fmr_temporalGaussianSmoothing(bvqx, hFMR, cfg.preprocessing.temporalGaussianSmoothing);
    LatestFile = hFMR.FileNameOfPreprocessdFMR;
    hFMR.Close;
end

%SpatialFiltering
if cfg.preprocessing.spatialGaussianSmoothing.perform
    hFMR = bvqx.OpenDocument(LatestFile);
    success = fmr_spatialGaussianSmoothing(bvqx, hFMR, cfg.preprocessing.spatialGaussianSmoothing);
    LatestFile = hFMR.FileNameOfPreprocessdFMR;
    hFMR.Close;
end


%---------------------------
%LinearTrendRemoval
if cfg.preprocessing.LinearTrendRemoval.perform
    hFMR = bvqx.OpenDocument(LatestFile);
    success = fmr_linearTrendRemoval(bvqx, hFMR, cfg.preprocessing.LinearTrendRemoval);
    LatestFile = hFMR.FileNameOfPreprocessdFMR;
    hFMR.Close;
end

%---------------------------

%
% %MOVE ALL CREATED DATA TO TARGET DIRECTORY
% if ~isempty(cfg.copyToTargetFolder)
% %     d = dir;
% %     %OLDER MATLAB VERSIONS DO NOT HAVE THIS FIELD
% %     if ~isfield(d, 'datenum')
% %         for i = 1:length(d)
% %             d(i).datenum = datenum(d(i).date);
% %         end
% %     end
% %
% %     cases = find([d.datenum] > currentTime);
% %     for i = 1:length(cases)
% %         cmdstr = sprintf('!move /Y "%s" "%s"', d(cases(i)).name, cfg.copyToTargetFolder);
% %         fprintf(1, '%s/n', cmdstr);
% %         eval(cmdstr)
% %     end
%     d = dir;
%     pat =  '.dcm';
%     count = 0;
%     for i = 1 : length(d)
%         if isempty (regexp(d(i).name, pat))
%             count = count + 1;
%             cases(count) = i;
%         end
%     end
%     cases(1:2) = [];
%     for i = 1:length(cases)
%         cmdstr = sprintf('!move /Y "%s" "%s"', d(cases(i)).name, cfg.copyToTargetFolder);
%         fprintf(1, '%s/n', cmdstr);
%         eval(cmdstr)
%     end
%
%
% end
%cd(currentDirectory)
end


function hFMR = fmr_create(bvqx, cfg)
%CreateProjectMosaicFMR = handle CreateProjectMosaicFMR(handle, string, string, int32, int32, bool, int32, string, bool, int32, int32, int32, string, int32, int32, int32)

bvqx.PrintToLog('// CREATING FMR PROJECT:')
dump_struct(bvqx, cfg.fmr);

fprintf(1, 'CREATING %s ... ', cfg.fmr.targetName);

%CHECK FOR SUCCESS AND GO INTO ERROR HANDLING
%bvqx.SetCurrentDirectory(cfg.fmr.sourceFolder); %AVOID CRASH

%CHECK FOR SUCCESS AND GO INTO ERROR HANDLING
hFMR = bvqx.CreateProjectMosaicFMR(...
    cfg.fmr.fileType, cfg.fmr.firstFileName, cfg.fmr.nrOfVols, cfg.fmr.skipVols,...
    cfg.fmr.createAMR, cfg.fmr.nrSlices, cfg.fmr.stcPrefix, cfg.fmr.byteswap,...
    cfg.fmr.mosaicSizeX, cfg.fmr.mosaicSizeY, cfg.fmr.bytesPerPixel, cfg.fmr.targetFolder,...
    cfg.fmr.nrVolsInImg, cfg.fmr.sizeX, cfg.fmr.sizeY);



bvqx.PrintToLog('')

fprintf(1, 'SAVING ... ');
hFMR.SaveAs(cfg.fmr.targetName);

% %CHECK FOR SUCCESS AND GO INTO ERROR HANDLING
% [PATHSTR,NAME,EXT,VERSN] = fileparts(cfg.fmr.targetName);
% hFMR.SaveAs(NAME);

%CHECK FOR SUCCESS AND GO INTO ERROR HANDLING
%bvqx.SetCurrentDirectory(cfg.fmr.targetFolder);

fprintf(1, 'DONE\n');
end

function success = fmr_stc(bvqx, hFMR, cfg)
bvqx.PrintToLog('// PERFORMING SLICE TIME CORRECTION:')
dump_struct(bvqx, cfg);

%CHECK FOR SUCCESS AND GO INTO ERROR HANDLING
success = hFMR.CorrectSliceTiming(cfg.sliceorder, cfg.stcInterpolationMethod);
bvqx.PrintToLog('')
end

function success = fmr_moco(bvqx, hFMR, cfg)
bvqx.PrintToLog('// APPLYING MOTION CORRECTION:')
dump_struct(bvqx, cfg)

if isempty(cfg.targetFMR)
    success = hFMR.CorrectMotionEx(cfg.targetVolumeNumber, cfg.interpolationMethod, cfg.useFullDataSet, cfg.maxNumberOfIterations, cfg.createMovies, cfg.createExtendedLogFile);
else
    %CHECK WHETHER TARGET FMR EXISTS
    bvqx.PrintToLog(sprintf('// USING %s AS REFERENCE', cfg.targetFMR));
    %CHECK FOR SUCCESS
    success = hFMR.CorrectMotionTargetVolumeInOtherRunEx(cfg.targetFMR, cfg.targetVolumeNumber, cfg.interpolationMethod, cfg.useFullDataSet, cfg.maxNumberOfIterations, cfg.createMovies, cfg.createExtendedLogFile);
end
end

function success = fmr_temporalHighPass(bvqx, hFMR, cfg)
bvqx.PrintToLog('// PERFORMING TEMPORAL HIGHPASS FILTERING:')
dump_struct(bvqx, cfg);

%CHECK FOR SUCCESS AND GO INTO ERROR HANDLING
success = hFMR.TemporalHighPassFilter(cfg.value, cfg.unit);
bvqx.PrintToLog('')
end

function success = fmr_temporalGaussianSmoothing(bvqx, hFMR, cfg)
bvqx.PrintToLog('// PERFORMING TEMPORAL GAUSSIAN SMOOTHING:')
dump_struct(bvqx, cfg);

%CHECK FOR SUCCESS AND GO INTO ERROR HANDLING
success = hFMR.TemporalGaussianSmoothing(cfg.value, cfg.unit);
bvqx.PrintToLog('')
end

function success = fmr_spatialGaussianSmoothing(bvqx, hFMR, cfg)
bvqx.PrintToLog('// PERFORMING SPATIAL GAUSSIAN SMOOTHING:')
dump_struct(bvqx, cfg);

%CHECK FOR SUCCESS AND GO INTO ERROR HANDLING
success = hFMR.SpatialGaussianSmoothing(cfg.value, cfg.unit);
bvqx.PrintToLog('')
end

function success = fmr_linearTrendRemoval(bvqx, hFMR, cfg)
bvqx.PrintToLog('// PERFORMING LINEAR TREND REMOVAL:')
dump_struct(bvqx, cfg);

%CHECK FOR SUCCESS AND GO INTO ERROR HANDLING
success = fFMR.LinearTrendRemoval;
bvqx.PrintToLog('')
end

function dump_struct(bvqx, astruct)
fn = fieldnames(astruct);
for i = 1:length(fn)
    afieldname = sprintf('%s: ', fn{i});
    fieldcontent = astruct.(fn{i});
    switch class(fieldcontent)
        case 'char'
            %fieldcontent = fieldcontent;
        case 'double'
            fieldcontent = num2str(fieldcontent);
    end
    str{i} = [afieldname, fieldcontent];
end

for i = 1:length(str)
    bvqx.PrintToLog(['// ', str{i}]);
end
end

%THIS FUNCTION INFORMS THE USER WHENEVER SOME DEFAULT VALUE IS SET
function capmsg(strMsg)
fprintf(1, 'SETTING DEFAULT VALUE: %s/n', strMsg)
end

function bIsEven = isEven(aNumber)
bIsEven = fix(aNumber/2) == aNumber/2;
end