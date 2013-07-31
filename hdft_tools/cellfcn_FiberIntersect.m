function X = cellfcn_FiberIntersect(C,hdr,roi_xyz)

% Function to find the fiber points that intersect with an ROI
[vx, vy, vz] = mm2voxel(C.points(:,1),C.points(:,2),C.points(:,3),hdr);
%intx = prod(double(ismember([vx vy vz],roi_xyz)),2);
intx = double(ismember([vx vy vz],roi_xyz,'rows'));

if ~sum(intx)
    X = nan(2,3);
elseif sum(intx) == 1;
    % This is here to deal with a cellfun mean problem
    X = repmat(C.points(find(intx),:),2,1);
else
    X = C.points(find(intx),:);
end;