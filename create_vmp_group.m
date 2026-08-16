function create_vmp_group(cfg)

cfg = config(cfg);
alpha=0.05;

cfg.pathToVMP = sprintf('%s/vmp/%s', cfg.path,cfg.type);
[SUCCESS,MESSAGE,MESSAGEID] = mkdir(cfg.pathToVMP);


if ~isempty(strfind(cfg.type,'classify'))
    TestNames=cfg.TestNames;
    cfg.pathToSearchlight = sprintf('%s/searchlight/%s_volume_%s_%s_rad%d',cfg.path,cfg.type,cfg.Design,cfg.classifier, abs(cfg.radius));
elseif ~isempty(strfind(cfg.type,'glmRSA_searchlight'))
    %     cfg.pathToSearchlight = sprintf('%s/searchlight/glmRSA_searchlight_volume_%s_rad%d',cfg.path,cfg.Design,abs(cfg.radius))
    cfg.pathToSearchlight = sprintf('%s/searchlight/%s_%s_rad%d',cfg.path,cfg.type,cfg.Design,abs(cfg.radius));
end


%% create a vmp with all subjects
vmp = xff('new:vmp'); % xff('../templateMNI.vmp');
vmpAll = xff('new:vmp'); % xff('../templateMNI.vmp');

if strcmp(cfg.type, 'classify')
    
    for iTest=1:length(cfg.TestVec)
        for iSub=1:length(cfg.SubVec)
            
            if strcmp(cfg.decodingType,'cross_mod')
                vmpSub = xff(sprintf('%s/SUB%02d_%s_%s_%s_sm%dmm_rad%d.vmp',cfg.pathToSearchlight,cfg.SubVec(iSub),cfg.decodingType,cfg.TestNames{cfg.TestVec(iTest)},cfg.classifier, cfg.smoothing,abs(cfg.radius)));
            elseif strcmp(cfg.decodingType,'within_mod')
                vmpSub = xff(sprintf('%s/SUB%02d_%s_%s_%s_sm%dmm_rad%d.vmp',cfg.pathToSearchlight,cfg.SubVec(iSub),cfg.sessionName,cfg.TestNames{cfg.TestVec(iTest)},cfg.classifier, cfg.smoothing,abs(cfg.radius)));
                
            end
            
            vmp.Map(iSub)=vmpSub.Map;
            SubMaps(iSub,:,:,:)=vmp.Map(iSub).VMPData;
            
            if cfg.TestVec(iTest) == 1  %multiclass 2-way
                vmp.Map(iSub).VMPData=vmp.Map(iSub).VMPData-1/2;
                vmp.Map(iSub).LowerThreshold=0;
                vmp.Map(iSub).UpperThreshold=0.3;
  
            elseif  cfg.TestVec(iTest) > 1 && cfg.TestVec(iTest) < 12 %multiclass 3-way
                vmp.Map(iSub).VMPData=vmp.Map(iSub).VMPData-1/3;
                vmp.Map(iSub).LowerThreshold=0;
                vmp.Map(iSub).UpperThreshold=0.2;
            elseif cfg.TestVec(iTest)== 13  || cfg.TestVec(iTest) == 20 % multiclass 3 way
                vmp.Map(iSub).VMPData=vmp.Map(iSub).VMPData-1/3;
                vmp.Map(iSub).LowerThreshold=0;
                vmp.Map(iSub).UpperThreshold=0.2;
            elseif  cfg.TestVec(iTest) > 15 && cfg.TestVec(iTest) < 20 % multiclass 2 way
                vmp.Map(iSub).VMPData=vmp.Map(iSub).VMPData-1/2;
                vmp.Map(iSub).LowerThreshold=0;
                vmp.Map(iSub).UpperThreshold=0.3;
            elseif  cfg.TestVec(iTest) > 20  % multiclass 2 way
                vmp.Map(iSub).VMPData=vmp.Map(iSub).VMPData-1/2;
                vmp.Map(iSub).LowerThreshold=0;
                vmp.Map(iSub).UpperThreshold=0.3;
            end
            
            % some parameters
            if strcmp(cfg.decodingType,'within_mod')
                vmp.Map(iSub).Name = sprintf('Subject SUB%02d: %s %s', cfg.SubVec(iSub), cfg.sessionName, cfg.TestNames{cfg.TestVec(iTest)});
            elseif strcmp(cfg.decodingType,'cross_mod')
                vmp.Map(iSub).Name = sprintf('Subject SUB%02d: %s', cfg.SubVec(iSub),cfg.TestNames{cfg.TestVec(iTest)});
            end
            vmp.Map(iSub).LUTName = cfg.lut_path;
            vmp.Map(iSub).UseRGBColor=0;
            vmp.Map(iSub).TransColorFactor = 0.7;
            
        end
        
        
        % one sample t test
        % compute mean
        vmp.Map(length(cfg.SubVec)+1)= vmpSub.Map;
        vmp.Map(length(cfg.SubVec)+1).VMPData=squeeze(mean(SubMaps,1))*100;
        vmp.Map(length(cfg.SubVec)+1).Name = sprintf('mean: %s', cfg.TestNames{cfg.TestVec(iTest)});
        
        if  cfg.TestVec(iTest) == 1 %multiclass 2-way
            vmp.Map(length(cfg.SubVec)+1).LowerThreshold=50;
            vmp.Map(length(cfg.SubVec)+1).UpperThreshold=80;
        elseif  cfg.TestVec(iTest) > 1 && cfg.TestVec(iTest) < 12 % multiclass 3 way
            vmp.Map(length(cfg.SubVec)+1).LowerThreshold=33.33;
            vmp.Map(length(cfg.SubVec)+1).UpperThreshold=50;
        elseif  cfg.TestVec(iTest) > 15 && cfg.TestVec(iTest) < 20 % multiclass 2 way
            vmp.Map(length(cfg.SubVec)+1).LowerThreshold=50;
            vmp.Map(length(cfg.SubVec)+1).UpperThreshold=80;
        elseif cfg.TestVec(iTest)== 13 || cfg.TestVec(iTest) == 20% multiclass 3 way
            vmp.Map(length(cfg.SubVec)+1).LowerThreshold=33.33;
            vmp.Map(length(cfg.SubVec)+1).UpperThreshold=50;
        elseif  cfg.TestVec(iTest) > 20 % multiclass 2 way
            vmp.Map(length(cfg.SubVec)+1).LowerThreshold=50;
            vmp.Map(length(cfg.SubVec)+1).UpperThreshold=80;
            
        end
        
        vmp.Map(length(cfg.SubVec)+1).LUTName = cfg.lut_path;
        vmp.Map(length(cfg.SubVec)+1).TransColorFactor = 0.7;
        
        vmp.Map(length(cfg.SubVec)+2)= vmpSub.Map;
        
        if cfg.TestVec(iTest) == 1  %2 classes (catch vs non-catch etc)
            [H,P,CI,STATS]=ttest(SubMaps,0.5,0.05,'right',1);
        elseif cfg.TestVec(iTest) > 1 && cfg.TestVec(iTest) < 12 % multiclass 3 way
            [H,P,CI,STATS]=ttest(SubMaps,1/3,0.05,'right',1);
        elseif cfg.TestVec(iTest)== 13 || cfg.TestVec(iTest) == 20% multiclass 3 way
            [H,P,CI,STATS]=ttest(SubMaps,1/3,0.05,'right',1);
        elseif  cfg.TestVec(iTest) > 15 && cfg.TestVec(iTest) < 20  % multiclass 2 way
            [H,P,CI,STATS]=ttest(SubMaps,0.5,0.05,'right',1);
        elseif  cfg.TestVec(iTest)> 20 % multiclass 2 way
            [H,P,CI,STATS]=ttest(SubMaps,0.5,0.05,'right',1);

        end
        
        vmp.Map(length(cfg.SubVec)+2).VMPData=squeeze(STATS.tstat);
        vmp.Map(length(cfg.SubVec)+2).Name = sprintf('p: %s', cfg.TestNames{cfg.TestVec(iTest)});
        vmp.Map(length(cfg.SubVec)+2).DF1=length(cfg.SubVec)-1;
        vmp.Map(length(cfg.SubVec)+2).DF2=0;
        vmp.Map(length(cfg.SubVec)+2).LowerThreshold=tinv(1-alpha/2,length(cfg.SubVec)-1);
        vmp.Map(length(cfg.SubVec)+2).UpperThreshold=8;
        vmp.NrOfMaps=length(vmp.Map);
        
        % save
        
        if strcmp(cfg.decodingType,'within_mod')
            vmpName = sprintf('%s/N%d_%s_%s_%s_%s_%s_sm%dmm_volume_rad%d_AllSubjects.vmp',cfg.pathToVMP,length(cfg.SubVec),cfg.type,cfg.sessionName,cfg.TestNames{cfg.TestVec(iTest)},cfg.Design,cfg.classifier, cfg.smoothing,abs(cfg.radius));
        elseif strcmp(cfg.decodingType,'cross_mod')
            vmpName = sprintf('%s/N%d_%s_%s_%s_%s_sm%dmm_volume_rad%d_AllSubjects.vmp',cfg.pathToVMP,length(cfg.SubVec),cfg.type,cfg.TestNames{cfg.TestVec(iTest)},cfg.Design,cfg.classifier, cfg.smoothing,abs(cfg.radius));
        end
        
        vmp.Saveas(vmpName);
        
        vmpAll.Map(iTest) = vmp.Map(length(cfg.SubVec)+2);
        vmpAll.Map(iTest+length(cfg.TestVec)) = vmp.Map(length(cfg.SubVec)+1);
    end
    
    
elseif ~isempty(strfind(cfg.type,'glmRSA_searchlight'))
    
    RDMcode = strrep(num2str(cfg.TestVec), '   ', 'x' );
    RDMcode = strrep(RDMcode, '  ', 'x' );
    
    for iSub=1:length(cfg.SubVec)
        
        vmpSub = xff(sprintf('%s/%s_%s_SUB%02d_%s_%s_sm%dmm_rad%d_n%d.vmp',cfg.pathToSearchlight,cfg.sessionName,cfg.type2,cfg.SubVec(iSub),cfg.type,cfg.rdmLabels{cfg.TestVec},cfg.smoothing,abs(cfg.radius),cfg.normalize));
        for iTest=1:length(vmpSub.Map)
            allMaps{iSub}{iTest}=vmpSub.Map(iTest).VMPData;
        end
        
        SubMaps(iSub,:,:,:)= vmpSub.Map.VMPData;
    end
    
    betaNames=cfg.rdmLabels;
    betaVec=cfg.TestVec;%[2 4 6:12];
    
    for iTest=1:length(vmpSub.Map)
        
        for iSub=1:length(cfg.SubVec)
            vmp.Map(iSub)=vmpSub.Map(1);
            vmp.Map(iSub).VMPData=allMaps{iSub}{iTest};
            vmp.Map(iSub).LowerThreshold=0.2;
            vmp.Map(iSub).UpperThreshold=0.4;
            vmp.Map(iSub).TransColorFactor = 0.8;
            % some parameters
            vmp.Map(iSub).Name = sprintf('Subject SUB%02d: %s, %s', cfg.SubVec(iSub), betaNames{betaVec(iTest)}, RDMcode);
            
            TTESTMAP(iSub,:,:,:) = vmp.Map(iSub).VMPData;
            
        end
        
        
        vmp.Map(length(cfg.SubVec)+1)= vmpSub.Map;
        vmp.Map(length(cfg.SubVec)+1).VMPData = squeeze(mean(SubMaps,1));
        vmp.Map(length(cfg.SubVec)+1).Name = sprintf('mean: %s', cfg.rdmLabels{cfg.TestVec});
        [H,P,CI,STATS] = ttest(SubMaps,0,'Tail','right');
        vmp.Map(length(cfg.SubVec)+2)= vmpSub.Map;
        vmp.Map(length(cfg.SubVec)+2).VMPData=squeeze(STATS.tstat);
        vmp.Map(length(cfg.SubVec)+2).Name = sprintf('p: %s', cfg.rdmLabels{cfg.TestVec});
        vmp.Map(length(cfg.SubVec)+2).DF1=length(cfg.SubVec)-1;
        vmp.Map(length(cfg.SubVec)+2).DF2=0;
        vmp.Map(length(cfg.SubVec)+2).LowerThreshold=tinv(1-0.01/2,length(cfg.SubVec)-1);
        vmp.Map(length(cfg.SubVec)+2).UpperThreshold=8;
        
        fprintf('compute GLM RSA VMP for %s\n',betaNames{betaVec(iTest)});
        vmpName = sprintf('%s/%s_%s_N%d_%s_%s_%s_%s_%s_sm%dmm_volume_rad%d.vmp',cfg.pathToVMP,cfg.sessionName,cfg.type2,length(cfg.SubVec),cfg.decodingType, cfg.type,RDMcode,betaNames{betaVec(iTest)},cfg.Design,cfg.smoothing,abs(cfg.radius));
        vmp.Saveas(vmpName);
    end
    
    
    
end



