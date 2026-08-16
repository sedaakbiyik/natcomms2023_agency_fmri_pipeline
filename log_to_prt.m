function [prt] = log_to_prt(SubVec, cfg)
%modified: MW 2013-05-13

cfg = config(cfg);

cfg.skipNVol = 4;
cfg.nConditions = 13;
cfg.nBlocksPerRun = 4;
cfg.nRepetitionsPerBlock = 2;
cfg.nRepetitionsPerCondition = cfg.nBlocksPerRun*cfg.nRepetitionsPerBlock;
cfg.AlwaysOverwrite=1; % 1=don't ask to overwrite files

chunkType = cfg.Design; %'Runwise';%'twoPerRunWise'

if strcmp(chunkType,'trialwise')
    nChunks=cfg.nRepetitionsPerCondition;
elseif strcmp(chunkType,'twoPerRunwise') % the order then is: cond1_1-2, cond2_1-2,...
    nChunks=2;
elseif strcmp(chunkType,'Runwise')
    nChunks=1;
else
    warning('define chunkType: Runwise, twoPerRunwise');
end

nPred=nChunks*cfg.nConditions;

if strcmp(chunkType,'collapsed')
    condNames = {'hit',...
        'jumpover',...
        'passby',...
        'catch_trial'};
else
    condNames = {'hit_anim_anim',...
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
        'passby_inanim_inanim',...
        'catch_trial'};
end

iPred=0;
for iCond=1:cfg.nConditions
    for iChunk=1:nChunks
        iPred=iPred+1;
        predNames{iPred}= sprintf('%s_%d',condNames{iCond},iChunk);
    end
end


%----------------------------------------------------------------
%ASSIGN COLOR CODE
for i=1:nPred
    cmap(i,:) = [randi([0 255],1) randi([0 255],1) randi([0 255],1)];
end
% trial codes:          0  --> baseline
%                       1  --> warm up
%                       2  --> cool down
%                       3  --> hit_anim_anim
%                       4  --> jumpover_anim_anim
%                       5  --> passby_anim_anim
%                       6  --> hit_anim_inanim
%                       7  --> jumpover_anim_inanim
%                       8  --> passby_anim_inanim
%                       9  --> hit_inanim_anim
%                       10  --> jumpover_inanim_anim
%                       11  --> passby_inanim_anim
%                       12  --> hit_inanim_inanim
%                       13  --> jumpover_inanim_inanim
%                       14  --> passby_inanim_inanim
%                       15  --> catch

if strcmp(chunkType,'blockDes')
    codeVec = [0 1];
    cfg.durSec = 54; % duration of event in seconds
    predNames = {'block'};
elseif strcmp(chunkType,'acrossObj')
    codeVec = [3:25];
    cfg.durSec = 2; % duration of event in seconds
else
    codeVec = [3:15];
    cfg.durSec = 2; % duration of event in seconds
end

for iSub=SubVec
    cfg = config(cfg,iSub);
    
    for iRun=cfg.RunVec
        logName  = sprintf('%s/res/%s_SUB%02d_RUN%02d.mat', cfg.path, cfg.sessionName, iSub, iRun);
        prt.name = sprintf('%s/res/SUB%02d_%02d_%s_%s.prt', cfg.path, iSub, iRun, cfg.sessionName, chunkType);
        
        % GET THE DATA
        load(logName);
        nTrials = length(ExpInfo.TrialInfo);
        
        for i = 1 : nTrials
            
            t (i) = ExpInfo.TrialOnset(i); % the trial start
            
            %the specification below for subjects 1 & 2 in the video since their TRD files and log files had issues
            %in the code. so I extract the action code by using objects etc.
            %the remaining subjects didn't have that issue.
            
            if iSub<3 && strcmp(cfg.sessionName,'AGENCY_video')
                agent (i,:) = ExpInfo.TrialInfo(i).trial.all{1, 1}(4);
                obj(i) = ExpInfo.TrialInfo(i).trial.all{1, 1}(5); %
                O=obj(i);
                
                if isfield(ExpInfo.TrialInfo(i).trial,'stimulus')
                    D=str2double(ExpInfo.TrialInfo(i).trial.stimulus(4));
                else
                    D=30; %creating this just so it won't create a problem for D in the next loop
                end
                
                if (D==1) && (O==1||O==2)
                    ID(i)=3; %kick anim
                elseif (D==2) && (O==1||O==2)
                    ID(i)=4; %jumpover anim
                elseif (D==3) && (O==1||O==2)
                    ID(i)=5; %pass by anim
                elseif (D==1) && (O==3||O==4)
                    ID(i)=6; %kick inanim
                elseif (D==2) && (O==3||O==4)
                    ID(i)=7; %jump over inanim
                elseif (D==3) && (O==3||O==4)
                    ID(i)=8; %passby inanim
                elseif (D==4) && (O==1||O==2)
                    ID(i)=9; %hit anim
                elseif (D==5) && (O==1||O==2)
                    ID(i)=10; %bounce over anim
                elseif (D==6) && (O==1||O==2)
                    ID(i)=11; %passby anim
                elseif (D==4) && (O==3||O==4)
                    ID(i)=12; %hit inanim
                elseif (D==5) && (O==3||O==4)
                    ID(i)=13; %bounceover inanim
                elseif (D==6) && (O==3||O==4)
                    ID(i)=14; %rollby inanim
                end
                
                if ExpInfo.TrialInfo(i).trial.code==0
                    ID(i)=0;
                elseif ExpInfo.TrialInfo(i).trial.code==15
                    ID(i)=15;
                end
                
            else % videos & sentences without issues
                ID(i) = ExpInfo.TrialInfo(i).trial.code; % the trial info
                agent (i,:) = ExpInfo.TrialInfo(i).trial.all{1, 1}(4);
                obj(i) = ExpInfo.TrialInfo(i).trial.all{1, 1}(5); %
                O=obj(i);
            end
            
        end
        
        
        % WRITE PRT
        %-------------------------------------------------------
        
        prt.Experiment=cfg.experimentName;
        prt.NrOfConditions = nPred;
        for iPred=1:nPred
            prt.Condition{iPred}.name=predNames{iPred};
        end
        
        % MAKE A DAT STRUCTURE (nConditions, nRepetionsPerCondition)
        for i = 1 : length(codeVec)
            if isempty(find(ID==codeVec(i)));
                disp(sprintf('no trials of condition %d', i));
                dat{i}.tStart = [];
            else
                dat{i}.tStart = (t(find(ID==codeVec(i))) - (cfg.skipNVol * cfg.TR)) * 1000;
                if strcmp(chunkType,'twoPerRunwise')
                    dat{i}.preceedingCond = ID((find(ID==codeVec(i)))-1);
                end
            end
            
        end
        
        
        % NOW PUT TOGETHER TRIALS FOR EACH PREDICTOR, EVENT DURATION, AND COLOR
        iPred=0;
        for iCond=1:cfg.nConditions
            condReal=length(find(ID==codeVec(iCond)));
            condRealRep=1:condReal;
            t_odd=rem(condRealRep,2)~=0;
            namber_odd=condRealRep(t_odd);
            namber_even=condRealRep(~t_odd);
            Vec{1}=namber_odd; %creating two vectors for odd-numbered and even-numbered reps of the same condition
            Vec{2}=namber_even;
            for iChunk=1:nChunks
                iPred=iPred+1;
                if strcmp(chunkType,'twoPerRunwise')
                    chunkOrderVec=Vec{iChunk}(:)';
                    prt.Condition{iPred}.estart=round(dat{iCond}.tStart(chunkOrderVec));
                elseif strcmp(chunkType,'Runwise')
                    %                   chunkStart=cfg.nRepetitionsPerCondition/nChunks*iChunk - cfg.nRepetitionsPerCondition/nChunks + 1;
                    %                   chunkStop=chunkStart + cfg.nRepetitionsPerCondition/nChunks-1;
                    chunkOrderVec=condRealRep';
                    prt.Condition{iPred}.estart = round(dat{iCond}.tStart(chunkOrderVec));
                end
                
                prt.Condition{iPred}.eend = round(prt.Condition{iPred}.estart + (cfg.durSec * 1000)); %REQUIRES msec resolution
                prt.Condition{iPred}.ntpts = length(prt.Condition{iPred}.estart);
                prt.Condition{iPred}.color = cmap(iPred,:);
            end
        end
        prt = bv_prt_write(prt, cfg);
    end
end
function prt = bv_prt_write(prt, varargin)
%function prt = bv_prt_write(prt, varargin)
%Writes a Brainvoager protocol file (.prt) based on the input structure prt
%which must contain the following fields:
%.name (the full name of the protocol file to be created)
%.NrOfConditions
%.Condition{:} (cell array of conditions, each one containing the fields
%               name, ntpts, estart, eend, color)
%SEE ALSO bv_read_prt.m
%Jens.Schwarzbach@form.unitn.it 20071121
%al 2011-11-19 added parametric weights

if ~isfield(prt, 'FileVersion'), prt.FileVersion = 2; end
if ~isfield(prt, 'ResolutionOfTime'), prt.ResolutionOfTime = 'msec'; end
if ~isfield(prt, 'Experiment'), prt.Experiment = '<none>'; end
if ~isfield(prt, 'BackgroundColor'), prt.BackgroundColor = [0 , 0, 0]; end
if ~isfield(prt, 'TextColor'), prt.TextColor = [255, 255, 255]; end
if ~isfield(prt, 'TimeCourseColor'), prt.TimeCourseColor = [255, 255, 255]; end
if ~isfield(prt, 'TimeCourseThick'), prt.TimeCourseThick = 2; end
if ~isfield(prt, 'ReferenceFuncColor'), prt.ReferenceFuncColor = [0, 255, 0]; end
if ~isfield(prt, 'ReferenceFuncThick'), prt.ReferenceFuncThick = 1; end

if ~isfield(prt, 'ParametricWeights'), prt.ParametricWeights = 0; end


cfg = [];
if ~isempty(varargin)
    cfg = varargin{1};
end
if ~isfield(cfg, 'CreateEmptyCondition'), cfg.CreateEmptyCondition = 0; end
if ~isfield(cfg, 'AlwaysOverwrite'), cfg.AlwaysOverwrite = 0; end



%CHECK FOR EXISTENCE OF OUTPUT FILE
if ~cfg.AlwaysOverwrite
    if exist(prt.name, 'file') == 2
        msg = sprintf('File %s already exists. Overwrite?', prt.name);
        ButtonName=questdlg(msg, 'Warning', 'Yes','No','No');
        if strcmp(ButtonName, 'No')
            prt = [];
            return
        end
    end
end


%CREATE AN EXTRA CONDITION FROM EMPTY ENTRIES
if cfg.CreateEmptyCondition
    switch strtok(prt.ResolutionOfTime)
        case 'msec'
            tres = 1000*cfg.TR;
        case 'volumes'
            tres = 1;
    end
    bl.vec = zeros(cfg.VolumesInRun*tres, 1);
    
    %CREATE A CONDITION FROM ALL EMPTY TIMEPOINTS
    estart = [];
    eend = [];
    for c = 1: prt.NrOfConditions
        estart = [estart(:); prt.Condition{c}.estart(:)];
        eend = [eend(:); prt.Condition{c}.eend(:)];
        for t = 1:length(estart)
            bl.vec(estart(t):eend(t)) = 1;
        end
    end
    cases = find(diff(bl.vec) ~= 0);
    iStart = 1;
    prt.Condition{c+1}.estart = [];
    prt.Condition{c+1}.eend = [];
    prt.Condition{c+1}.name = 'EMPTY';
    prt.Condition{c+1}.color = [128, 128, 128];
    for i = 1:length(cases)
        if bl.vec(cases(i)) == 0
            %LAST tpt of empty condition
            iEnd = cases(i);
            prt.Condition{c+1}.estart = vertcat(prt.Condition{c+1}.estart, iStart);
            prt.Condition{c+1}.eend = vertcat(prt.Condition{c+1}.eend, iEnd);
        else
            %LAST tpt of full condition
            iStart = cases(i) + 1;
        end
    end
    iStart = cases(end) + 1;
    iEnd = length(bl.vec);
    prt.Condition{c+1}.estart = vertcat(prt.Condition{c+1}.estart, iStart);
    prt.Condition{c+1}.eend = vertcat(prt.Condition{c+1}.eend, iEnd);
    
    prt.Condition{c+1}.ntpts = length(prt.Condition{c+1}.estart);
    prt.NrOfConditions = c + 1;
end

%WRITE PROTOCOL FILE
fid = fopen(prt.name, 'wt');
if fid == -1
    msg = sprintf('The file %s cannot be opened.', prt.name);
    errordlg(msg, 'FileOpen Error', 1);
    return
end

fprintf(1, 'WRITING %s ...', prt.name)

%[dummy, prt.FileVersion] = fscanf(fid, '%s %d', 1);
fprintf(fid, '\n');
fprintf(fid, 'FileVersion:         %d\n\n', prt.FileVersion);
fprintf(fid, 'ResolutionOfTime: %s\n\n', prt.ResolutionOfTime);
fprintf(fid, 'Experiment: %s\n\n', prt.Experiment);
fprintf(fid, 'BackgroundColor:     %3d %3d %3d\n', prt.BackgroundColor);
fprintf(fid, 'TextColor:           %3d %3d %3d\n\n', prt.TextColor);
fprintf(fid, 'TimeCourseColor:     %3d %3d %3d\n', prt.TimeCourseColor);
fprintf(fid, 'TimeCourseThick:         %d\n', prt.TimeCourseThick);
fprintf(fid, 'ReferenceFuncColor:  %3d %3d %3d\n', prt.ReferenceFuncColor);
fprintf(fid, 'ReferenceFuncThick:         %d\n\n', prt.ReferenceFuncThick);

if prt.ParametricWeights == 1
    fprintf(fid, 'ParametricWeights:         %d\n\n', prt.ParametricWeights);
end
fprintf(fid, 'NrOfConditions:         %d\n\n', prt.NrOfConditions);

%LOOP THROUGH CONDITIONS
for c = 1:prt.NrOfConditions
    fprintf(fid, '%s\n', prt.Condition{c}.name);
    fprintf(fid, '%d\n', prt.Condition{c}.ntpts);
    if prt.Condition{c}.ntpts == 0
        %EMPTY CONDITIONS PRODUCE A WARNING BUT ARE NEVERTHELESS WRITTEN TO
        %FILE BECAUSE THEY MAY BE NEEDED FOR GLM
        fprintf(1, '\nWARNING! Condition ''%s'' in file ''%s'' is empty.', prt.Condition{c}.name, prt.name);
    end
    for t = 1:prt.Condition{c}.ntpts
        if prt.ParametricWeights == 0
            fprintf(fid, '%8d %8d\n', round(prt.Condition{c}.estart(t)), round(prt.Condition{c}.eend(t)));
        else
            fprintf(fid, '%8d %8d %3d\n', round(prt.Condition{c}.estart(t)), round(prt.Condition{c}.eend(t)), prt.Condition{c}.parametricWeight);
        end
    end
    fprintf(fid, 'Color:  %3d %3d %3d\n\n', prt.Condition{c}.color);
    
    
end
fclose( fid);
fprintf(1, '\nDONE\n');

