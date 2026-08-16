function compute_contrast(cfg)

% cfg.singleRun=0; % only if cfg.singleSubject==0

% compute_contrast(cfg);

%% single subject glm
if cfg.singleSubject==1
    
    %% single study glm (each subject, each run)
    if cfg.singleRun == 1
        
        for iCon = cfg.contrastVec
            vmp = xff('new:vmp');
            iCount = 0;
            for iSub=cfg.SubVec
             
                cfg = config(cfg,iSub);
                pathToGLM = sprintf('%s/glm/SUB%02d', cfg.path,iSub);

                fprintf('processing Sub %02d\n',iSub);
                for iRun = cfg.RunVec
                    iCount=iCount+1;

                    glmName = sprintf('%s/SUB%02d_%02d_%s_%s_%s_sm%dmm.glm',  pathToGLM, iSub, iRun, cfg.sessionName, cfg.Design, cfg.motionCorr, cfg.smoothing);
                    if exist(glmName)==0
                        create_glm(cfg);
                    end
                    glm = xff(glmName);
                    map = glm.FFX_tMap(cfg.contrastVecs{iCon});
                    vmp.Map(iCount)= vmp.Map(1);
                    vmp.Map(iCount).VMPData= map.Map.VMPData;
                    vmp.Map(iCount).Name = sprintf('Subject SUB%02d, run: %d (%s), %s', iSub, iRun ,cfg.Design, cfg.constrastNames{iCon});
                    vmp.Map(iCount).DF1=glm.FFX_tMap.Map.DF1; %note from Seda: needed to specify these since the default DFs were problematic
                    vmp.Map(iCount).DF2=glm.FFX_tMap.Map.DF2; %note from Seda: needed to specify these since the default DFs were problematic   
                end
            end
            vmp.NrOfMaps=length(vmp.Map);
            vmp.SaveAs(sprintf('%s/vmp/univariate/N%d_singleRuns_%s_%s_%s_%s_sm%dmm.vmp',cfg.path,length(cfg.SubVec),cfg.sessionName,cfg.constrastNames{iCon},cfg.Design,cfg.motionCorr,cfg.smoothing));
        end
        
        %% multi study glm (each subject, all runs per session)
    else
        
        %% videos
        for iCon = cfg.contrastVec
            vmp = xff('new:vmp');
            for iSub=1:length(cfg.SubVec)
                cfg = config(cfg,iSub);
                pathToGLM = sprintf('%s/glm/SUB%02d', cfg.path,cfg.SubVec(iSub));
                
                glmName = sprintf('%s/SUB%02d_allRuns_%s_%s_mc_sm%dmm.glm',  pathToGLM, cfg.SubVec(iSub), cfg.sessionName, cfg.Design, cfg.smoothing);
                if exist(glmName)==0
                    create_glm(cfg);
                end
                glm = xff(glmName);
                map = glm.FFX_tMap(cfg.contrastVecs{iCon});
                vmp.Map(iSub)= vmp.Map(1);
                vmp.Map(iSub).VMPData= map.Map.VMPData;
                vmp.Map(iSub).Name = sprintf('Subject SUB%02d, all runs, %s, %s', cfg.SubVec(iSub), cfg.Design, cfg.constrastNames{iCon});
                vmp.Map(iSub).DF1=glm.FFX_tMap.Map.DF1; %note from Seda: needed to specify these since the default DFs were problematic
                vmp.Map(iSub).DF2=glm.FFX_tMap.Map.DF2; %note from Seda: needed to specify these since the default DFs were problematic    
            end
            vmp.NrOfMaps=length(vmp.Map);
            fn_out = sprintf('%s/vmp/univariate/N%d_singlesubjects_%s_%s_%s_%s_sm%dmm.vmp',cfg.path,length(cfg.SubVec),cfg.sessionName,cfg.constrastNames{iCon},cfg.Design,cfg.motionCorr,cfg.smoothing);
            disp(sprintf('computed contrast: %s',fn_out));
            vmp.SaveAs(fn_out);
        end
        
      
    end
    
    %% multi study glm (RFX, all subjects, all runs per session)
else
    
    %% 
    cfg = config(cfg);
    glmName = sprintf('%s/glm/N%02d_%s_%s_%s_sm%dmm.glm',  cfg.path, length(cfg.SubVec), cfg.sessionName, cfg.Design, cfg.motionCorr, cfg.smoothing);
    
    if exist(glmName)==0
        create_glm(cfg);
    end
    
    glm = xff(glmName);
    
    vmp = xff('new:vmp');
    
    for iCon = cfg.contrastVec
        disp(sprintf('compute contrast: %s',cfg.constrastNames{iCon}));
        map = glm.RFX_tMap(cfg.contrastVecs{iCon});
        vmp.Map(iCon)= vmp.Map(1);
        vmp.Map(iCon).VMPData= map.Map.VMPData;
        vmp.Map(iCon).Name = sprintf('N%d, %s, %s',length(cfg.SubVec), cfg.sessionName,cfg.constrastNames{iCon});
        vmp.Map(iCon).DF1=length(cfg.SubVec)-1;
        vmp.Map(iCon).DF2=0;
    end
    
    vmp.NrOfMaps=length(vmp.Map);
    vmp.SaveAs(sprintf('%s/vmp/univariate/N%d_%s_%s_contrasts_%s_sm%dmm.vmp',cfg.path,length(cfg.SubVec), cfg.sessionName,cfg.Design,cfg.motionCorr,cfg.smoothing));   
end
