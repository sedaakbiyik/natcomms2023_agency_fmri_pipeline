function create_roi_from_coord(cfg)
% cfg.coords are provided as cells


cfg = config(cfg);

pathToMSK = sprintf('%s/msk', cfg.path);
[SUCCESS,MESSAGE,MESSAGEID] = mkdir(pathToMSK);

sphericalVoiName = fullfile(cfg.path, sprintf('ROI/%s_spherical_%dmm.voi', cfg.VOIname,cfg.ROIradius));

% make sphere around voxel
sphCoords = makeSphere(cfg.ROIradius);

% create a new voi file
newVoi =xff('new:voi'); %  xff('../templateMNI.voi'); %
for iVoi = 1:length(cfg.coords)
    if iVoi>1 
        newVoi.VOI(iVoi)=newVoi.VOI(1);
    end
    nVoxels = size(sphCoords, 1);
    newVoi.VOI(iVoi).NrOfVoxels = nVoxels;
    newVoi.VOI(iVoi).Voxels = repmat(cfg.coords{iVoi}, [nVoxels, 1]) + sphCoords;
    newVoi.VOI(iVoi).Name = cfg.ROInames{iVoi};
    newVoi.VOI(iVoi).Color = [0 0 255];
end
newVoi.NrOfVOIs=length(cfg.coords);
%newVoi.SaveAs(sphericalVoiName); % save it for checking in BV etc

% make masks (these are needed for COSMO)
vmp = xff('new:vmp'); % vmp = xff('../templateMNI.vmp'); %
bbox = vmp.BoundingBox;

for iROI = 1:length(newVoi.VOI)
    ROIname = newVoi.VOI(iROI).Name;
    sphericalMSKName = fullfile(pathToMSK, sprintf('%s_spherical_%dmm_%s.msk', cfg.VOIname,cfg.ROIradius, ROIname)); %PICK YOUR OWN NAME
    mask = newVoi.CreateMSK(bbox,iROI);
    fprintf(1, 'Creating %s ...\n', sphericalMSKName);
    mask.SaveAs(sphericalMSKName);
end

newVoi.ClearObject;
newVoi = [];




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



