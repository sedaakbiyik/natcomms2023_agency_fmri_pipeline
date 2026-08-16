
%% first, create ROIs from coordinates
cfg.ROIradius = 12; % in mm
cfg.coords = {[-48, 8, 29], [-58,-23,34], [-45, -71, 6]}; 
cfg.ROInames = {'leftPMv','leftIPL','leftLPTC'};
cfg.VOIname = 'caspers_core_left_ROIs';
create_roi_from_coord(cfg);

%% first, create ROIs from coordinates
cfg.ROIradius = 12; % in mm
cfg.coords = {[50 12 27], [44 -31 41], [52, -63, 5]}; 
cfg.ROInames = {'rightPMv','rightIPL','rightLPTC'};
cfg.VOIname = 'caspers_core_right_ROIs';
create_roi_from_coord(cfg);


%% first, create ROIs from coordinates
cfg.ROIradius = 12; % in mm
cfg.coords = {[-48, 8, 29], [-58,-23,34], [-45, -71, 6], [-52,-49,11],[-18 -57 50],[-11, -78, 10],...
    [50 12 27], [44 -31 41], [52, -63, 5], [54, -40, 8], [24,-56,54], [11,-75,11]}; 
cfg.ROInames = {'leftPMv','leftIPL','leftLPTC','leftSTS','leftSPL','leftPrimaryVisual',...
    'rightPMv','rightIPL','rightLPTC','rightSTS','rightSPL','rightPrimaryVisual'};
cfg.VOIname = 'caspers_brod_all_ROIs';
create_roi_from_coord(cfg);

%% first, create ROIs from coordinates
cfg.ROIradius = 12; % in mm
cfg.coords = {[-48, 8, 29], [-58,-23,34], [-45, -71, 6], [-52,-49,11],[-18 -57 50],[-25, -21, -15],[-23,51,3],... 
     [50 12 27], [44 -31 41], [52, -63, 5], [54, -40, 8], [24,-56,54], [25 -21 -17],[22 51 6]}; 
cfg.ROInames = {'leftPMv','leftIPL','leftLPTC','leftSTS','leftSPL','leftPHC','leftmPFC'...
    'rightPMv','rightIPL','rightLPTC','rightSTS','rightSPL','rightPHC','rightmPFC'};
cfg.VOIname = 'revision_zacks_ROIs';
create_roi_from_coord(cfg);


%% first, create ROIs from coordinates
cfg.ROIradius = 12; % in mm
cfg.coords = {[-11, -78, 10], [11,-75,11]}; 
cfg.ROInames = {'left_primaryvisual','right_primaryvisual'};
cfg.VOIname = 'primary_visual_ROIs';
create_roi_from_coord(cfg);


%% Classify Only / don't forget to put the scheme name in
cfg.SubVec = [1:22];
cfg.TestNames = {'inanimanim_multiclass3','inaniminanim_multiclass3'};
cfg.TestVec = [1:2];
cfg.testTag = 'video_object_multiclass3';%'agentbysubjdecoding' 'video_animate_inanimate_multiclass3'
cfg.Design = 'twoPerRunwise';
cfg.classifier =  'svm'; % 'lda';%
cfg.smoothing=3;
cfg.gap= 3;
cfg.decodingType='within_mod';
cfg.radiusExtract=12;
cfg.radiusMVPA = 4;
cfg.type = 'classify';
cfg.sessionName='AGENCY_video'; %specify only if within_mod
cfg.ROIfile = 'rightLPTC'; % 'LH_postAnt5'; %
poi_extract_vals(cfg);

%%
cfg.demean=0;
myColorMap = round(jet(16)*255);
c=myColorMap/255;
colormap(c);
colorbar('southoutside','Ticks',[])
poi_plot_results(cfg);

%% Classify Only / don't forget to put the scheme name in
cfg.SubVec = [1:22];
cfg.TestNames = {'anim_anim', 'anim_inanim','inanim_anim','inanim_inanim'};
cfg.TestVec = [1:4];
cfg.testTag = 'video_univariate_agentbysubject';%'agentbysubjdecoding' 'video_animate_inanimate_multiclass3'
cfg.Design = 'Runwise';
cfg.smoothing=8;
cfg.radiusExtract=12;
cfg.radiusMVPA = 4;
cfg.type = 'univariate';
cfg.sessionName='AGENCY_video'; %specify only if within_mod
cfg.ROIfile = 'leftLPTC'; % 'LH_postAnt5'; %
poi_extract_vals(cfg);


%% GLM RSA Extract Values
cfg.SubVec = [1:22];
cfg.gap= 3;
cfg.TestNames = {'animateInanimate_recipient', 'contact', 'animateInanimate_agent'};
cfg.TestVec = [1:2];
cfg.testTag = 'video glmRSA_objectevents';
cfg.Design = 'twoPerRunwise';
cfg.classifier =  'svm'; % 'lda';%
cfg.smoothing=3;
cfg.decodingType='within_mod';
cfg.classes = [7:12];
cfg.radiusExtract=12;
cfg.radius= 4;
cfg.type= 'glmRSA_searchlight';
cfg.type2 = 'object_events';
cfg.sessionName='AGENCY_video'; %specify only if within_mod
cfg.ROIfile = 'leftLPTC2'; % 'LH_postAnt5'; %
poi_extract_vals(cfg);
%%
myColorMap = round(jet(16)*255);
cfg.TestVec=1:2;
cfg.demean=0;
c=myColorMap/255;
colormap(c);
colorbar('southoutside','Ticks',[])
poi_plot_results(cfg);

%% first, create ROIs from coordinates
cfg.ROIradius = 12; % in mm
cfg.coords = {[50, -52, 6], [19, -59, 61],[-19, -59, 61], [40, -40, -16]}; %LPTC, STS and SPL coordinates came from animate decoding peaks
cfg.ROInames = {'rightpSTS','rightSPL','lefttSPL', 'rightFFG'};
cfg.VOIname = 'agency_effect_ROIs';
create_roi_from_coord(cfg);

%% first, create ROIs from coordinates
cfg.ROIradius = 12; % in mm
cfg.coords = {[-48, 8, 29], [-26, -1, 51],[-34,-41,48], [-58,-23,34], [-52, -49, 11],[-45, -71, 6]}; %LPTC, STS and SPL coordinates came from animate decoding peaks
cfg.ROInames = {'leftIFG','leftpremotor','leftSPL', 'leftIPL', 'leftLPTC','leftV5'};
cfg.VOIname = 'caspers_left_ROIs';
create_roi_from_coord(cfg);


%% first, create ROIs from coordinates
cfg.ROIradius = 12; % in mm
cfg.coords = {[-18, -57, 50], [24, -56, 54],[46,-38,-15], [51,-37,-1]}; %LPTC, STS and SPL coordinates came from animate decoding peaks
cfg.ROInames = {'leftSPL','rightSPL','rightFFG', 'rightpSTS'};
cfg.VOIname = 'bioimage_suite_rois';
create_roi_from_coord(cfg);



%% first, create ROIs from coordinates
cfg.ROIradius = 4; % in mm
cfg.coords = {[-41 -72 -15],[-49 -55 4]}; %LPTC, STS and SPL coordinates came from animate decoding peaks
cfg.ROInames = {'ventral_left_LPTC','dorsal_left_LPTC'};
cfg.VOIname = 'agency_video';
create_roi_from_coord(cfg);

%% Moritz nat com conjunction ROIs
cfg.ROIradius = 12; % in mm
cfg.coords = {[-45, -43, 10],[-39,-7,37],[-24, -58, 40],[-42, 8, 22]}; %LPTC, STS and SPL coordinates came from animate decoding peaks
cfg.ROInames = {'sent_leftLPTC', 'sent_leftpreMotor','sent_leftIPS','sent_leftIFG'};
% cfg.coords = {[-55, -40, 1], [-45,25,14],[-42 7 -23],[-44,6,31],[-6,-84,8], [9,-84,8]};
% cfg.ROInames = {'pMTG', 'leftIFG','leftATL','leftpremotor','leftprimVisual','rightprimVisual'};
cfg.VOIname = 'agencyROIs_Moritz';
create_roi_from_coord(cfg);

%% first, create ROIs from coordinates
cfg.ROIradius = 12; % in mm
cfg.coords = {[-54 -61 4],[-45 -55 1],[-54,2,31],[-27, -58, 43]}; %LPTC, STS and SPL coordinates came from animate decoding peaks
cfg.ROInames = {'crossLPTC','sent_leftLPTC', 'sent_leftpreMotor','sent_leftIPS'};
% cfg.coords = {[-55, -40, 1], [-45,25,14],[-42 7 -23],[-44,6,31],[-6,-84,8], [9,-84,8]};
% cfg.ROInames = {'pMTG', 'leftIFG','leftATL','leftpremotor','leftprimVisual','rightprimVisual'};
cfg.VOIname = 'agencyROIs_sent';
create_roi_from_coord(cfg);
%% first, create ROIs from coordinates
cfg.ROIradius = 6; % in mm
cfg.coords = {[-50 -46 8]}; %LPTC, STS and SPL coordinates came from animate decoding peaks
cfg.ROInames = {'sent_left_peak'};
% cfg.coords = {[-55, -40, 1], [-45,25,14],[-42 7 -23],[-44,6,31],[-6,-84,8], [9,-84,8]};
% cfg.ROInames = {'pMTG', 'leftIFG','leftATL','leftpremotor','leftprimVisual','rightprimVisual'};
cfg.VOIname = 'agencyROIs_sanity';
create_roi_from_coord(cfg);
