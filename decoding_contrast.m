function decoding_contrast(cfg)

cfg.type = 'classify';
cfg = config(cfg);
cfg.pathToVMP = fullfile(cfg.path, 'vmp', 'classify');

alpha=0.05;
vmp = xff('new:vmp');

Comparisons = cfg.comparisonNames;
for iTest=1:length(cfg.comparisonVec)

        if strcmp(cfg.decodingType,'within_mod')

    t1VMP = xff(sprintf('%s/N%d_%s_%s_%s_%s_%s_sm%dmm_volume_rad%d_AllSubjects.vmp', cfg.pathToVMP, length(cfg.SubVec),cfg.type,cfg.sessionName, Comparisons{1,cfg.comparisonVec(iTest)},cfg.Design,cfg.classifier, cfg.smoothing,abs(cfg.radius)));
    t2VMP = xff(sprintf('%s/N%d_%s_%s_%s_%s_%s_sm%dmm_volume_rad%d_AllSubjects.vmp', cfg.pathToVMP, length(cfg.SubVec),cfg.type,cfg.sessionName,Comparisons{2,cfg.comparisonVec(iTest)},cfg.Design,cfg.classifier,cfg.smoothing,abs(cfg.radius)));
       elseif strcmp(cfg.decodingType,'cross_mod')
    
    t1VMP = xff(sprintf('%s/N%d_%s_%s_%s_%s_sm%dmm_volume_rad%d_AllSubjects.vmp', cfg.pathToVMP, length(cfg.SubVec),cfg.type,Comparisons{1,cfg.comparisonVec(iTest)},cfg.Design,cfg.classifier, cfg.smoothing,abs(cfg.radius)));
    t2VMP = xff(sprintf('%s/N%d_%s_%s_%s_%s_sm%dmm_volume_rad%d_AllSubjects.vmp', cfg.pathToVMP, length(cfg.SubVec),cfg.type,Comparisons{2,cfg.comparisonVec(iTest)},cfg.Design,cfg.classifier,cfg.smoothing,abs(cfg.radius)));
    
        end
    for t1Sub=1:(length(t1VMP.Map)-2)
        t1SubMaps(t1Sub,:,:,:)= t1VMP.Map(t1Sub).VMPData;
    end
    
    for t2Sub=1:(length(t2VMP.Map)-2)
        t2SubMaps(t2Sub,:,:,:)=t2VMP.Map(t2Sub).VMPData;
    end
    
    
    for iSub=1:(length(t1VMP.Map)-2)
    
    vmp.Map(iSub)=t1VMP.Map(iSub); %is this only for silly reasons?
    vmp.Map(iSub).VMPData =  t1VMP.Map(iSub).VMPData - t2VMP.Map(iSub).VMPData;
    vmp.Map(iSub).Name = sprintf('Subject %02d - %s - %s', iSub, Comparisons{1,cfg.comparisonVec(iTest)}, Comparisons{2,cfg.comparisonVec(iTest)});
    vmp.Map(iSub).LUTName = cfg.lut_path;

    end
    
    [H,P,CI,STATS]=ttest(t1SubMaps, t2SubMaps); %paired t-test
    vmp.Map(length(t1VMP.Map)-1)= t1VMP.Map(iSub);
    vmp.Map(length(t1VMP.Map)-1).VMPData=squeeze(STATS.tstat);
    vmp.Map(length(t1VMP.Map)-1).Name = sprintf('p: N%d %s%s Decoding Accuracy Contrast', length(cfg.SubVec), Comparisons{1,cfg.comparisonVec(iTest)}, Comparisons{2,cfg.comparisonVec(iTest)});
    vmp.Map(length(t1VMP.Map)-1).DF1=((length(t1VMP.Map)-2)-1);
    vmp.Map(length(t1VMP.Map)-1).DF2=0;
    vmp.Map(length(t1VMP.Map)-1).LowerThreshold=tinv(1-alpha/2,vmp.Map(iTest).DF1);
    vmp.Map(length(t1VMP.Map)-1).UpperThreshold=8;
    vmp.Map(length(t1VMP.Map)-1).LUTName = cfg.lut_path;

    vmpName = sprintf('%s/N%d_DecodingContrasts_%s_%s_%s_%s_%s_sm%dmm_volume_rad%d.vmp',cfg.pathToVMP, length(cfg.SubVec), Comparisons{1,cfg.comparisonVec(iTest)}, Comparisons{2,cfg.comparisonVec(iTest)}, cfg.type,cfg.classifier,cfg.Design,cfg.smoothing,abs(cfg.radius));
    vmp.NrOfMaps=length(vmp.Map);
    vmp.Saveas(vmpName);
end




