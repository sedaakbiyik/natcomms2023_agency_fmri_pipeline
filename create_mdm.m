function create_mdm(iSub, cfg)

cfg = config(cfg,iSub);

pathToData = sprintf('%s/groupdata', cfg.path);

if cfg.smoothing > 0
    preprocessing = sprintf('%s_TAL_SD3DVSS%d.00mm',cfg.preproc, cfg.smoothing);
else
    preprocessing = sprintf('%s_TAL', cfg.preproc);
end


FileVersion = 3;
TypeOfFunctionalData = 'VTC';
RFX_GLM = 0;
PSCTransformation = 0;
zTransformation = 2;
SeparatePredictors = 0;

mdmName = sprintf('%s/SUB%02d_%s_%s_%s_sm%dmm.mdm',  pathToData, iSub, cfg.sessionName, cfg.Design, cfg.motionCorr, cfg.smoothing);

fid = fopen(mdmName,'w');

fprintf(fid,'\r\nFileVersion: %d\r\n', FileVersion);
fprintf(fid,'TypeOfFunctionalData: %s\r\n\r\n',TypeOfFunctionalData);

fprintf(fid,'RFX-GLM:              %d\r\n\r\n',RFX_GLM);

fprintf(fid,'PSCTransformation:    %d\r\n',PSCTransformation);
fprintf(fid,'zTransformation:      %d\r\n',zTransformation);
fprintf(fid,'SeparatePredictors:   %d\r\n\r\n',SeparatePredictors);

fprintf(fid,'NrOfStudies:          %d\r\n',length(cfg.RunVec));



for iRun=cfg.RunVec
    vtcName = sprintf('"%s/SUB%02d_%02d_%s_%s.vtc"', pathToData, iSub, iRun, cfg.sessionName, preprocessing);
    sdmName = sprintf('"%s/SUB%02d_%02d_%s_%s_%s.sdm"', pathToData, iSub, iRun, cfg.sessionName , cfg.Design, cfg.motionCorr);
    fprintf(fid,'%s %s\r\n',vtcName, sdmName);
end

fclose(fid);
disp(sprintf('%s done', mdmName));
