function create_mdm_group(cfg)

cfg = config(cfg);

pathToData = sprintf('%s/groupdata', cfg.path);


if cfg.smoothing > 0
    preprocessing = sprintf('%s_TAL_SD3DVSS%d.00mm',cfg.preproc, cfg.smoothing);
else
    preprocessing = sprintf('%s_TAL', cfg.preproc);
end

FileVersion = 3;
TypeOfFunctionalData = 'VTC';
RFX_GLM = 1; % 1= random effects (for group), 0: fixed effects
PSCTransformation = 1; 
zTransformation = 0; 
SeparatePredictors = 2; 

NrOfStudies = 0;
for iSub=cfg.SubVec
cfg = config(cfg, iSub);

    NrOfStudies = NrOfStudies + length(cfg.RunVec);
end

mdmName = sprintf('%s/N%02d_%s_%s_%s_sm%dmm.mdm',  pathToData, length(cfg.SubVec), cfg.sessionName , cfg.Design, cfg.motionCorr, cfg.smoothing);

fid = fopen(mdmName,'w');

fprintf(fid,'\r\nFileVersion: %d\r\n', FileVersion);
fprintf(fid,'TypeOfFunctionalData: %s\r\n\r\n',TypeOfFunctionalData);

fprintf(fid,'RFX-GLM:              %d\r\n\r\n',RFX_GLM);

fprintf(fid,'PSCTransformation:    %d\r\n',PSCTransformation);
fprintf(fid,'zTransformation:      %d\r\n',zTransformation);
fprintf(fid,'SeparatePredictors:   %d\r\n\r\n',SeparatePredictors);

fprintf(fid,'NrOfStudies:          %d\r\n',NrOfStudies);


% 
for iSub=cfg.SubVec
    cfg = config(cfg,iSub);
    for iRun=cfg.RunVec
    vtcName = sprintf('"%s/SUB%02d_%02d_%s_%s.vtc"', pathToData, iSub, iRun, cfg.sessionName, preprocessing);
    sdmName = sprintf('"%s/SUB%02d_%02d_%s_%s_%s.sdm"', pathToData, iSub, iRun, cfg.sessionName , cfg.Design, cfg.motionCorr);
    fprintf(fid,'%s %s\r\n',vtcName, sdmName);
    end
end

fclose(fid);
disp(sprintf('%s done', mdmName));
