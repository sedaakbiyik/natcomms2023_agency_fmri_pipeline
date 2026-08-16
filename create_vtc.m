function create_vtc(iSub,cfg)

%example call:
%createVTC(1, cfg)

cfg = config(cfg,iSub);

%ID = getID(iSub);
%subID = sprintf('SUB%02d_%s', iSub, ID);
pathToData = sprintf('%s/sub%02d/bv', cfg.path,iSub);
pathToRes = sprintf('%s/groupdata', cfg.path); % directly copy to groupdata

datatype = 2; % data type of stored values ("1" - short int, "2" - float)
resolution = 3; % resolution relative to VMR, e.g. "3" - 1 voxel = 3 x 3 x 3 VMR voxels (*2)
interpolation = 1;
bbithresh= 100;

bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');
vmr = bvqx.OpenDocument(sprintf('%s/SUB%02d_MPRAGE_ISO_IIHC_aTAL.vmr', pathToData, iSub));
vmr.ExtendedTALSpaceForVTCCreation = false; % no extended bounding box for cerebellum

for iRun = cfg.RunVec
   
   fmr =  sprintf('%s/SUB%02d_%02d_%s_%s.fmr', pathToData, iSub, iRun, cfg.sessionName, cfg.preproc);
    
    
   if logical(mod(iSub,2)) %% if odd number, video first, align to video
    
    ia =   sprintf('%s/SUB%02d_01_AGENCY_video_%s-TO-SUB%02d_MPRAGE_ISO_IIHC_IA.trf', pathToData, iSub, cfg.preproc, iSub); %dont change exp name here (these are the runs for alignment)!
    fa =   sprintf('%s/SUB%02d_01_AGENCY_video_%s-TO-SUB%02d_MPRAGE_ISO_IIHC_FA.trf', pathToData, iSub, cfg.preproc, iSub); %dont change exp name here (these are the runs for alignment)!
   
   elseif   ~mod(iSub,2) %% if even number, sentence first, align to sentence
       
    ia =   sprintf('%s/SUB%02d_01_AGENCY_sentence_%s-TO-SUB%02d_MPRAGE_ISO_IIHC_IA.trf', pathToData, iSub,  cfg.preproc, iSub); %dont change exp name here (these are the runs for alignment)!
    fa =   sprintf('%s/SUB%02d_01_AGENCY_sentence_%s-TO-SUB%02d_MPRAGE_ISO_IIHC_FA.trf', pathToData, iSub, cfg.preproc, iSub); %dont change exp name here (these are the runs for alignment)!
   
   end
    
    
    acpc = sprintf('%s/SUB%02d_MPRAGE_ISO_IIHC_aACPC.trf', pathToData, iSub);
    
    tal =  sprintf('%s/SUB%02d_MPRAGE_ISO_IIHC_aACPC.tal', pathToData, iSub);
    vtc =  sprintf('%s/SUB%02d_%02d_%s_%s_TAL.vtc', pathToRes, iSub, iRun, cfg.sessionName, cfg.preproc);
    
    
    if exist(fmr)==0
        error(sprintf('file %s not existing', fmr));
    elseif exist(ia)==0
        error(sprintf('file %s not existing', ia));
    elseif exist(fa)==0
        error(sprintf('file %s not existing', fa));
    elseif exist(acpc)==0
        error(sprintf('file %s not existing', acpc));
    elseif exist(tal)==0
        error(sprintf('file %s not existing', tal));
    end
    
    success = vmr.CreateVTCInTALSpace(fmr, ia, fa, acpc, tal, vtc, datatype, resolution, interpolation, bbithresh);
end

vmr.Close;
close all;
clear all;

