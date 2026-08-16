function RDMs = create_rdms(cfg,plotFig)

cfg = config(cfg);

% animate inanimate target
RDMmat{1} = 1 - [1 1 1 0 0 0 1 1 1 0 0 0; 1 1 1 0 0 0 1 1 1 0 0 0; 1 1 1 0 0 0 1 1 1 0 0 0;...
    0 0 0 1 1 1 0 0 0 1 1 1;0 0 0 1 1 1 0 0 0 1 1 1;0 0 0 1 1 1 0 0 0 1 1 1;...
    1 1 1 0 0 0 1 1 1 0 0 0; 1 1 1 0 0 0 1 1 1 0 0 0; 1 1 1 0 0 0 1 1 1 0 0 0;...
    0 0 0 1 1 1 0 0 0 1 1 1;0 0 0 1 1 1 0 0 0 1 1 1;0 0 0 1 1 1 0 0 0 1 1 1];

RDMmat{1} = RDMmat{1}(cfg.classes,cfg.classes);

% contact (grouping hit versus jump pass)

RDMmat{2} = 1 - [1 0 0 1 0 0 1 0 0 1 0 0; 0 1 1 0 1 1 0 1 1 0 1 1; 0 1 1 0 1 1 0 1 1 0 1 1;...
    1 0 0 1 0 0 1 0 0 1 0 0; 0 1 1 0 1 1 0 1 1 0 1 1; 0 1 1 0 1 1 0 1 1 0 1 1;...
    1 0 0 1 0 0 1 0 0 1 0 0; 0 1 1 0 1 1 0 1 1 0 1 1; 0 1 1 0 1 1 0 1 1 0 1 1;...
    1 0 0 1 0 0 1 0 0 1 0 0; 0 1 1 0 1 1 0 1 1 0 1 1; 0 1 1 0 1 1 0 1 1 0 1 1];

RDMmat{2} = RDMmat{2}(cfg.classes,cfg.classes);

% agent animacy

RDMmat{3} = 1 - [1 1 1 1 1 1 0 0 0 0 0 0;1 1 1 1 1 1 0 0 0 0 0 0; 1 1 1 1 1 1 0 0 0 0 0 0;...
    1 1 1 1 1 1 0 0 0 0 0 0;1 1 1 1 1 1 0 0 0 0 0 0; 1 1 1 1 1 1 0 0 0 0 0 0;...
    0 0 0 0 0 0 1 1 1 1 1 1;0 0 0 0 0 0 1 1 1 1 1 1;0 0 0 0 0 0 1 1 1 1 1 1;...
    0 0 0 0 0 0 1 1 1 1 1 1;0 0 0 0 0 0 1 1 1 1 1 1;0 0 0 0 0 0 1 1 1 1 1 1];  %animate inanimate agent

RDMmat{3} = RDMmat{3}(cfg.classes,cfg.classes);


%motion path (grouping hit pass versus jump)

RDMmat{4} = 1 - [1 0 1 1 0 1 1 0 1 1 0 1 ;0 1 0 0 1 0 0 1 0 0 1 0; 1 0 1 1 0 1 1 0 1 1 0 1 ;...
    1 0 1 1 0 1 1 0 1 1 0 1 ;0 1 0 0 1 0 0 1 0 0 1 0; 1 0 1 1 0 1 1 0 1 1 0 1 ;...
    1 0 1 1 0 1 1 0 1 1 0 1 ;0 1 0 0 1 0 0 1 0 0 1 0; 1 0 1 1 0 1 1 0 1 1 0 1 ;...
    1 0 1 1 0 1 1 0 1 1 0 1 ;0 1 0 0 1 0 0 1 0 0 1 0; 1 0 1 1 0 1 1 0 1 1 0 1 ];

RDMmat{4} = RDMmat{4}(cfg.classes,cfg.classes);

%object relevance (grouping hit jump versus pass)

RDMmat{5} = 1 - [1 1 0 1 1 0 1 1 0 1 1 0 ;1 1 0 1 1 0 1 1 0 1 1 0; 0 0 1 0 0 1 0 0 1 0 0 1 ;...
    1 1 0 1 1 0 1 1 0 1 1 0 ;1 1 0 1 1 0 1 1 0 1 1 0; 0 0 1 0 0 1 0 0 1 0 0 1 ;...
    1 1 0 1 1 0 1 1 0 1 1 0 ;1 1 0 1 1 0 1 1 0 1 1 0; 0 0 1 0 0 1 0 0 1 0 0 1 ;...
    1 1 0 1 1 0 1 1 0 1 1 0 ;1 1 0 1 1 0 1 1 0 1 1 0; 0 0 1 0 0 1 0 0 1 0 0 1 ];

RDMmat{5} = RDMmat{5}(cfg.classes,cfg.classes);


if strcmp(cfg.type2, 'agent_actions')

    load(fullfile(cfg.opticflow_path, 'agent_ave_reset_opticflow_Vx_RDM_corrmat6.mat'));
    load(fullfile(cfg.opticflow_path, 'agent_ave_reset_opticflow_Vy_RDM_corrmat6.mat'));
    load(fullfile(cfg.opticflow_path, 'agent_ave_reset_opticflow_magnitude_RDM_corrmat6.mat'));
    load(fullfile(cfg.opticflow_path, 'agent_ave_reset_opticflow_orientation_RDM_corrmat6.mat'));

else

    load(fullfile(cfg.opticflow_path, 'object_ave_reset_opticflow_Vx_RDM_corrmat6.mat'));
    load(fullfile(cfg.opticflow_path, 'object_ave_reset_opticflow_Vy_RDM_corrmat6.mat'));
    load(fullfile(cfg.opticflow_path, 'object_ave_reset_opticflow_magnitude_RDM_corrmat6.mat'));
    load(fullfile(cfg.opticflow_path, 'object_ave_reset_opticflow_orientation_RDM_corrmat6.mat'));

end
%
magRDMcollapsed = (magRDMcollapsed+magRDMcollapsed.')/2;
orRDMcollapsed =(orRDMcollapsed+orRDMcollapsed.')/2;
RDMmat{6} = magRDMcollapsed - diag(diag(magRDMcollapsed))  ; %magnitudeOpticFlow
RDMmat{7} = orRDMcollapsed - diag(diag(orRDMcollapsed)) ; %orientationOpticFlow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

labels = cfg.rdmLabels;

RDMs.labels = labels;
for i =  1:length(RDMmat)
    RDMs.mat(i) = RDMmat(i);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% test for correlations between sessions and models
if plotFig==1
    
    figure(1);
    if strcmp(cfg.type2, 'agent_actions')
        
        % plot models
        for i =  1:length(RDMmat)
            subplot(2,4,i);
            imagesc(RDMmat{i});
            title(labels{i},'fontsize', 10);
            colormap(autumn);
            set(gca,'xtick',1:6);
            set(gca,'ytick',1:6);
            set(gca,'xticklabel',{'hit anim anim',...
                'jumpover anim anim',...
                'passby anim anim',...
                'hit anim inanim',...
                'jumpover anim inanim',...
                'passby anim inanim'});
            set(gca,'yticklabel',{'hit anim anim',...
                'jumpover anim anim',...
                'passby anim anim',...
                'hit anim inanim',...
                'jumpover anim inanim',...
                'passby anim inanim'})
            xtickangle(45);
            set(gca,'ticklength',[0 0]);
        end
    elseif strcmp(cfg.type2, 'object_events')
                for i =  1:length(RDMmat)

        subplot(2,4,i);
        imagesc(RDMmat{i});
        title(labels{i},'fontsize', 10);
        colormap(autumn);
        set(gca,'xtick',1:6);
        set(gca,'ytick',1:6);
        
        set(gca,'xticklabel',{'hit inanim anim',...
            'jumpover inanim anim',...
            'passby inanim anim',...
            'hit inanim inanim',...
            'jumpover inanim inanim',...
            'passby inanim inanim'});
        set(gca,'yticklabel',{'hit inanim anim',...
            'jumpover inanim anim',...
            'passby inanim anim',...
            'hit inanim inanim',...
            'jumpover inanim inanim',...
            'passby inanim inanim'});
           xtickangle(45);
            set(gca,'ticklength',[0 0]);
        end
    end
    set(gcf, 'Position', [1, 1, 1200, 1200])
    set(gcf, 'PaperPosition', [0 0 10 10]); %x_width=10cm y_width=15cm
    fig_fn = sprintf('../figures/AGENCY_video_models%d_%s',length(RDMmat), cfg.type2);
    print(fig_fn,'-djpeg','-r300');
    
    % mask out within category similarities / note 03262021 not needed
    %     msk = logical(zeros(8,8));
    %     ones_idx = [3 4 5 6 7 8 11 12 13 14 15 16 21 22 23 24 29 30 31 32 39 40 47 48];
    %     msk(ones_idx)=1;
    %
    
    %% correlate models
    maskOutWithinCatCorrelations = 0;
    for i1 = 1:length(RDMmat)
        for i2 = 1:length(RDMmat)
            if maskOutWithinCatCorrelations==0
                [corrMat(i1,i2) p(i1,i2)] = corr(squareform(RDMmat{i1})', squareform(RDMmat{i2})');
                X(:,i1) = zscore(squareform(RDMmat{i1}));
            else
                [corrMat(i1,i2) p(i1,i2)] = corr(RDMmat{i1}(msk), RDMmat{i2}(msk));
                X(:,i1) = zscore(RDMmat{i1}(msk));
            end
        end
    end
    figure(2);
    
    
    %% video models / ask Moritz,what do these refer to?
    idx = [1:7];
    
    
    imagesc(corrMat(idx,idx));
    set(gca,'xtick',[]);
    set(gca,'ytick',1:length(idx));
    %set(gca,'xticklabel',labels(idx));
    set(gca,'yticklabel',labels(idx));
    set(gca,'ticklength',[0 0]);
    colorbar;
    caxis([-1 1])
    colormap(redblue);
    
    set(gcf, 'Position', [1, 1, 900, 800])
    set(gcf, 'PaperPosition', [0 0 10 10]); %x_width=10cm y_width=15cm
    fig_fn = sprintf('../figures/AGENCY_video_models_corr%d',length(idx));
    print(fig_fn,'-djpeg','-r300');
    
end



function c = redblue(m)
%   REDBLUE(M), is an M-by-3 matrix that defines a colormap.
if nargin < 1, m = size(get(gcf,'colormap'),1); end

if (mod(m,2) == 0)
    % From [0 0 1] to [1 1 1], then [1 1 1] to [1 0 0];
    m1 = m*0.5;
    r = (0:m1-1)'/max(m1-1,1);
    g = r;
    r = [r; ones(m1,1)];
    g = [g; flipud(g)];
    b = flipud(r);
else
    % From [0 0 1] to [1 1 1] to [1 0 0];
    m1 = floor(m*0.5);
    r = (0:m1-1)'/max(m1,1);
    g = r;
    r = [r; ones(m1+1,1)];
    g = [g; 1; flipud(g)];
    b = flipud(r);
end

c = [r g b] * 0.9;

