function smooth_vtc(iSub, cfg)

cfg = config(cfg,iSub);

pathToGroupdata = sprintf('%s/groupdata/', cfg.path);

%select talairach vmr project
%[fileTal pathName] = uigetfile('*.vmr', 'Select the talairach vmr project');
fileTal = sprintf('SUB%02d_MPRAGE_ISO_IIHC_aTAL.vmr', iSub);

% create COM server to BrainVoyager
bvqx=actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');

%Open talairach vmr project
tal_vmr = bvqx.OpenDocument([pathToGroupdata fileTal]);


vtc=tal_vmr.FileNameOfCurrentVTC;

if(isempty(vtc))
    %Retrieve the vtc files                             
    vtcstruct = dir([pathToGroupdata sprintf('SUB%02d_*_%s_%s_TAL.vtc',iSub, cfg.sessionName, cfg.preproc)]);
    
    nRun = size(vtcstruct);
    
  
    for i=cfg.RunVec %i=1:nRun
        tal_vmr.LinkVTC([pathToGroupdata vtcstruct(i).name]);
        %now smooth VT Cwith a large kernel of 10mm:
        tal_vmr.SpatialGaussianSmoothing(cfg.smoothing,'mm');%FWHM value and unit(ÿmmÿ or ÿvxÿ)
        
        bvqx.PrintToLog(['Name of spatially smoothed VTC file:' tal_vmr.FileNameOfCurrentVTC]);
        
        
    end
    disp(sprintf('Sub %02d finished',iSub));
else
    disp(sprintf('cant find files for Sub %02d',iSub));
end
 
