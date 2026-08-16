function create_sdm(iSub, cfg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script to create a design matrix from a stimulation protocol in Matlab
% Works with BrainVoyager QX 2.2
% 2012-08-03 angelika.lingnau@unitn.it
% example call:
% createDesignMatrix_BVQX(1, cfg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg = config(cfg,iSub);

pathToData = sprintf('%sgroupdata/', cfg.path);
pathToLog  = sprintf('%sres/', cfg.path);

figure;
Cfg.addDeriv = 0;
Cfg.add3DMC = 1; % set to 0 if no motion correction parameters should be included (e.g. when using denoising)
Cfg.addFilter = 0;
Cfg.normalize3DMCPredictors = Cfg.add3DMC;
Cfg.normalizePredictors = 1;
Cfg.skipNVol = cfg.skipNVol;

% if Cfg.addDeriv == 1 & Cfg.add3DMC == 1
%     sdmType = 'D1_MCnotScaled'
% else if Cfg.addDeriv == 1 & Cfg.add3DMC == 0
%         sdmType = 'D1_boynton';
%     elseif Cfg.addFilter == 1
%         sdmType = 'fourier';
%     else
%         sdmType = 'boynton';
%     end
% end

if Cfg.add3DMC==1
    sdmType = 'mc';
else
    sdmType = 'no_moco';
end

%Cfg.createMDM = 1;
%Cfg.computeMultiStudyGLM = 0;

params.hshape = 'twogamma';%'twogamma';%'boynton'
params.nderiv = Cfg.addDeriv;
%params.params.ortho = 1;
%params.params.opts.norm = 1;
params.prtr = cfg.TR * 1000; % in milliseconds!
if Cfg.normalizePredictors == 1
    params.rnorm = 1;%0.5;%1;
end
params.rcond = 0;

% this is just for the figure..
if length(cfg.RunVec)==1
    a = 1; b = 1;
elseif length(cfg.RunVec)<5
    a = 2; b = 2;
elseif length(cfg.RunVec)<7
    a = 2; b = 3;
else
    a = 4; b = 5;
end


count=0;


for iRun = 1:length(cfg.RunVec);
    
    params.nvol = cfg.nVolumes(iSub,iRun)-Cfg.skipNVol;
    count=count+1;
  
    prt_name = sprintf('%sSUB%02d_%02d_%s_%s.prt', pathToLog, iSub, iRun, cfg.sessionName,cfg.Design);
  
    prt=BVQXfile([prt_name]);
	
    sdm = prt.CreateSDM(params);
    sdmName = [pathToData sprintf('SUB%02d_%02d_%s_%s_%s.sdm',  iSub, iRun,  cfg.sessionName, cfg.Design, sdmType)];
    %plot(sdm.SDMMatrix(:,1:2))

    
    if Cfg.addFilter == 1
        opts.ftype = 'fourier'; %{'fourier'; 'dct'; 'linear'}
        sdm = sdm.AddFilters(opts);
        %hfile = sdm_AddFilters(hfile, opts)
    end
    
    if Cfg.normalizePredictors == 1
        [nPts, nCol] = size(sdm.SDMMatrix);
        for i = 1 : nCol - 1
            sdm.SDMMatrix(:,i) = sdm.SDMMatrix(:,i)/max(sdm.SDMMatrix(:,i));
        end
    end
    
    %     if Cfg.addDeriv == 1
    %         sdm.SDMMatrix = [sdm.SDMMatrix(:, 1:2:prt.NrOfConditions*2) sdm.SDMMatrix(:, 2:2:prt.NrOfConditions*2)];
    %         sdm.PredictorNames =  [sdm.PredictorNames(1:2:prt.NrOfConditions*2) sdm.PredictorNames(2:2:prt.NrOfConditions*2)]
    %         sdm.PredictorColors = [sdm.PredictorColors(1:2:prt.NrOfConditions*2,:);sdm.PredictorColors(2:2:prt.NrOfConditions*2,:)];
    %     end
    
    %----------------------------------------------------------------------
    %READ IN 3DMC
    if Cfg.add3DMC == 1
        
        sdm3DMC  =xff(sprintf('%s/sub%02d/bv/SUB%02d_%02d_%s_SCCAI_3DMC.sdm', cfg.path, iSub, iSub, iRun, cfg.sessionName));
        
        %NORMALIZE 3DMC
        if Cfg.normalize3DMCPredictors == 1
            for iParam = 1 : 6
                %thisMax = max(max(sdm3DMC.SDMMatrix));
                sdm3DMC.SDMMatrix(:,iParam) = sdm3DMC.SDMMatrix(:,iParam) - sdm3DMC.SDMMatrix(1,iParam);
            end
            thisMax = max(max(sdm3DMC.SDMMatrix));
            thisMin = min(min(sdm3DMC.SDMMatrix));
            sdm3DMC.SDMMatrix = sdm3DMC.SDMMatrix/max(abs([thisMax, thisMin]));
        end
        
        
        %PUT TOGETHER NEW MATRIX
        
        sdm.NrOfPredictors = sdm.NrOfPredictors + sdm3DMC.NrOfPredictors;
        sdm.SDMMatrix = [sdm.SDMMatrix sdm3DMC.SDMMatrix];
        sdm.PredictorNames =  [sdm.PredictorNames  sdm3DMC.PredictorNames];
        sdm.PredictorColors = [sdm.PredictorColors; sdm3DMC.PredictorColors];
    end
    %----------------------------------------------------------------------
    subplot(a,b,count)
    plot(sdm.SDMMatrix);
    axis([0 cfg.nVolumes(iSub,iRun) -1.5 1.5]);
    title(prt_name);
   
    sdm.SaveAs(sdmName);
end
 fig_fn = sprintf('%s/figures/%s_SDM_%s_SUB%02d',cfg.path,cfg.Design,cfg.sessionName,iSub);
 print(fig_fn,'-djpeg','-r300');
close all;


end

