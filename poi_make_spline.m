function poi_make_spline(cfg)
% computes "pearl chain ROIs" along a spline based on anchor points (see
% Konkle % Caramazza, 2013). Requires:
% - POIs in single file (with several anchor points per poi from anterior to posterior)
% - a flattened srf
% - a folded srf
cfg = config(cfg);

addpath(genpath('C:\Users\cnlab\Documents\MATLAB\spline_interpolate-toolbox'));
% addpath(genpath('C:\Users\cnlab\Documents\MATLAB\NeuroElf_v10_5153\NeuroElf_v10_5153\@neuroelf\private'))
% addpath(genpath('C:\moritzwurm\BVQXtools_v08d_new'));


radius = cfg.radius; %6; 
sphCoords = makeSphere(radius); nVoxels = size(sphCoords, 1);

gap=cfg.gap;%3; % mm gap between centers of POIs

vmp=xff('new:vmp'); bbox = vmp.BoundingBox;

    
    if strfind(cfg.ROIfile, 'LH')
        hemi='LH';
    else
        hemi='RH';
    end
    
    % load the flat srf (which reduces one dimension --> 2d; easier to compute
    % spline
    srf = xff(sprintf('%s/ROI/groupSRF/GroupAligned_foldedMesh_%s_NEW_flat_dc.srf',cfg.path,hemi));
    
    %% rotate srf to avoid problems with splines bounded along y axis
%     if strfind(cfg.ROIfile, 'LH')
%     [xRot yRot]=rotate(srf.VertexCoordinate(:,1),srf.VertexCoordinate(:,2),45);
%     else
%     [xRot yRot]=rotate(srf.VertexCoordinate(:,1),srf.VertexCoordinate(:,2),100);    
%     end
%     
%     srf.VertexCoordinate=[xRot yRot srf.VertexCoordinate(:,3)];
    
    % load poi with POIs that consist of anchor points (no line of vertices)
    poi = xff(sprintf('%s/ROI/PathOfInterest/%s.poi',cfg.path,cfg.ROIfile));
    %NewPoi=poi.Copy; % for new pois
    
    
    
    for iPOI =1:2 %cfg.ROIVec;%1:length(poi.POI)
        
        ROIname = poi.POI(iPOI).Name;
        
        % get the anchor points of a POI
        anchorpoints = srf.VertexCoordinate(poi.POI(iPOI).Vertices,1:2);
        
        % compute spline interpolation
        resolution=0.1;
        x = anchorpoints(:,1);
        y = anchorpoints(:,2);
        
        xx = min(x):resolution:max(x);
        yy = spline(x,y,xx);

        % check if looks ok
        plot(x,y,'o',xx,yy,'*')
        
        % compute length of spline
        dx = xx(1 : end-1) - xx(2 : end);
        dy = yy(1 : end-1) - yy(2 : end);
        d = sum(sqrt(dx.^2 + dy.^2));
        
        % create new positions on spline
        nPoints=round(d/gap+1);
        
        pt = interparc(nPoints,xx,yy,'spline');
        plot(x,y,'r*',pt(:,1),pt(:,2),'b-o',xx,yy,'--')
        
        % find vertices closest to points
        %T=delaunayn(srf.VertexCoordinate(:,1:2)); % triangulation
        %k = dsearchn(srf.VertexCoordinate(:,1:2),T,pt);
        k = knnsearch(srf.VertexCoordinate(:,1:2),pt);
        
        % get system coordinates of points in folded surface 
        srfFolded = xff(sprintf('%s/ROI/groupSRF/GroupAligned_foldedMesh_%s_SUB01_18.srf',cfg.path,hemi));

        crd = srfFolded.VertexCoordinate(k,:);
        % convert to TAL
        crdTAL = round(bvcoordconv(crd(1:end,:), 'bvi2tal', bbox));
        
        %% correct erroneous coordinates
        
        % detect outliers
meann = mean(crdTAL(:,1));
stdd = std(crdTAL(:,1));
I = bsxfun(@gt, abs(bsxfun(@minus, crdTAL(:,1), meann)), 2*stdd);
find(I==1)

        if strcmp(ROIname,'evc2sts_LH')
            n1 = 11; % first damaged vertex coord
            n2 = 15; % last damaged vertex coord
            newPoints = interparc(length(n1:n2)+1,[crdTAL(n1-1,1);crdTAL(n2+1,1)], [crdTAL(n1-1,2);crdTAL(n2+1,2)],[crdTAL(n1-1,3);crdTAL(n2+1,3)],'spline');
            for iVertex = n1:n2
                crdTAL(iVertex,:) = round(newPoints(iVertex-n1+2,:));
            end
        elseif strcmp(ROIname,'vent2med_LH')
        %    crdTAL(14,:) = round((crdTAL(13,:)+crdTAL(15,:))/2);
        end
        

        % make colors
        myColorMap = round(jet(size(crdTAL,1))*255);
        
        
        % create new VOI file
        newVoi = xff('new:voi');
        newVoi.NrOfVois = size(crdTAL,1);
        nVoxels = size(sphCoords, 1);
        for iVoi = 1:size(crdTAL,1)
            newVoi.VOI(iVoi).NrOfVoxels = nVoxels;
            newVoi.VOI(iVoi).Voxels = repmat(crdTAL(iVoi,:), [nVoxels, 1]) + sphCoords;
            newVoi.VOI(iVoi).Name = sprintf('%s_from_anterior_to_posterior_%d', ROIname, iVoi);
            newVoi.VOI(iVoi).Color = myColorMap(iVoi,:);
        end
        
        % save
        VoiName=sprintf('%s/ROI/PathOfInterest/%s_rad%d_spacing%d.voi',cfg.path,ROIname, radius, gap);
        disp(sprintf('Creating %s ...', VoiName));
        newVoi.SaveAs(VoiName);
        
        % create new POI file
        Controlpoi = xff('new:poi');
        Controlpoi.POI.Vertices = k;
        Controlpoi.POI.Color =[0 1 0];
        Controlpoi.SaveAs(sprintf('%s/ROI/PathOfInterest/test_%s.poi',cfg.path,ROIname));

        
        nbrhood = createVertexListSphere(k,radius,cfg);
        
        newPoi = xff('new:poi');
        for iPoi = 1:size(crdTAL,1)
            if iPoi>1
                newPoi.POI(iPoi) = newPoi.POI(1);
            end
            newPoi.POI(iPoi).Vertices = nbrhood{iPoi};
            newPoi.POI(iPoi).NrOfVertices = length(nbrhood{iPoi});
            newPoi.POI(iPoi).Name = sprintf('from anterior to posterior: %d', iPoi);
            newPoi.POI(iPoi).Color = myColorMap(iPoi,:);
           
        end
        
        newPoi.NrOfPOIs = length(newPoi.POI);
        
        % save
        PoiName=sprintf('%s/ROI/PathOfInterest/%s_rad%d_spacing%d.poi',cfg.path,ROIname, radius, gap);
        disp(sprintf('Creating %s ...', PoiName));
        newPoi.SaveAs(PoiName);
        
    end
    
   

function sphCoords = makeSphere(r)
i=0;
sphCoords = [];
for x=-r:r
    for y=-r:r
        for z = -r:r
            if sqrt(x^2 + y^2 + z^2)<=r
                i = i+1;
                sphCoords(i, :) = [x, y, z];
            end
        end
    end
end

function nbrhood = createVertexListSphere(k,radius,cfg)

SPHsrf=BVQXfile(sprintf('%s/ROI/groupSRF/STANDARD_SPH.srf',cfg.path));
SPHcrd = SPHsrf.VertexCoordinate;
clear SPHsrf;

% search neighbors for each vertex
disp(sprintf('...searching neighboring vertices with radius=%02dmm for vertex nr:      ',radius));
count=1;
for iVertex = k'
    disp(sprintf('\b\b\b\b\b\b%05d', iVertex));
    % compute euclidean distances between center vertex to all other vertices
    d = sqrt(sum([SPHcrd(:, 1) - SPHcrd(iVertex,1), SPHcrd(:, 2) - SPHcrd(iVertex,2), SPHcrd(:, 3) - SPHcrd(iVertex,3)] .^ 2, 2)) ;
    % get all vertices within radius of interest
    neighbors = find(d <= radius);
    nbrhood{count}= neighbors;
    count=count+1;
end
