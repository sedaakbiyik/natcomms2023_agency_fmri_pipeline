function create_glm(cfg)


cfg = config(cfg);

pathToData = sprintf('%s/groupdata', cfg.path);
cfg.pathToVMP = sprintf('%s/vmp', cfg.path);

if cfg.smoothing > 0
    preprocessing = sprintf('%s_TAL_SD3DVSS%d.00mm',cfg.preproc, cfg.smoothing);
else
    preprocessing = sprintf('%s_TAL', cfg.preproc);
end

%% single subject glm
if cfg.singleSubject==1
    
    for iSub = cfg.SubVec
        cfg = config(cfg,iSub);
        
        pathToGLM = sprintf('%s/glm/SUB%02d', cfg.path,iSub);
        mkdir(pathToGLM);
        
        %% single study glm (each subject, each run)
        if cfg.singleRun == 1
            

            for iRun = cfg.RunVec
                vtcName = sprintf('%s/SUB%02d_%02d_%s_%s.vtc', pathToData, iSub, iRun, cfg.sessionName, preprocessing);
                sdmName = sprintf('%s/SUB%02d_%02d_%s_%s_%s.sdm', pathToData, iSub, iRun, cfg.sessionName, cfg.Design, cfg.motionCorr);
                glmName = sprintf('%s/SUB%02d_%02d_%s_%s_%s_sm%dmm.glm',  pathToGLM, iSub, iRun, cfg.sessionName, cfg.Design, cfg.motionCorr, cfg.smoothing);
                
                vtc = xff(vtcName);
                sdm =  xff(sdmName);
                glm = vtc.CreateGLM(sdm);
                glm.SaveAs(glmName);
                
                disp(sprintf('glm: sub %02d, funct run %02d', iSub, iRun));
                disp(sprintf('vtc: %s', vtcName));
                disp(sprintf('sdm: %s', sdmName));
                disp(sprintf('--> %s', glmName));
            end
            
            %% multi study glm (each subject, all runs per session)
        else
            
            cfg = config(cfg,iSub);
            
            mdmName = sprintf('%s/SUB%02d_%s_%s_%s_sm%dmm.mdm',  pathToData, iSub, cfg.sessionName, cfg.Design, cfg.motionCorr, cfg.smoothing);
            glmName = sprintf('%s/SUB%02d_allRuns_%s_%s_%s_sm%dmm.glm',  pathToGLM, iSub, cfg.sessionName,  cfg.Design, cfg.motionCorr, cfg.smoothing);
            if exist(mdmName)==0
                create_mdm(iSub,cfg);
            end
            mdm = xff(mdmName);
            glm = mdm.ComputeGLM;
            glm.SaveAs(glmName);
            
            disp(sprintf('mdm: %s', mdmName));
            disp(sprintf('--> %s', glmName));
            
            
           
        end
    end
    
    %% group study (RFX glm, all subjects, all runs per session)
else
    
    cfg = config(cfg);
    mdmName = sprintf('%s/N%02d_%s_%s_%s_sm%dmm.mdm',  pathToData, length(cfg.SubVec), cfg.sessionName, cfg.Design, cfg.motionCorr, cfg.smoothing);
    glmName = sprintf('%s/glm/N%02d_%s_%s_%s_sm%dmm.glm',  cfg.path, length(cfg.SubVec), cfg.sessionName, cfg.Design, cfg.motionCorr, cfg.smoothing);
    
    if exist(mdmName)==0
        create_mdm_group(cfg);
    end
    mdm = xff(mdmName);
    glm = mdm.ComputeGLM;
    glm.SaveAs(glmName);
    
    disp(sprintf('mdm: %s', mdmName));
    disp(sprintf('--> %s', glmName));
    
end
