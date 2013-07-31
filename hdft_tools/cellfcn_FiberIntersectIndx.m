function X = cellfcn_FiberIntersectIndx(C,hdr,roi_xyz)

% Function to find the fiber points that intersect with an ROI
[vx, vy, vz] = mm2voxel(C.points(:,1),C.points(:,2),C.points(:,3),hdr);
%intx = prod(double(ismember([vx vy vz],roi_xyz)),2);
intx = double(ismember([vx vy vz],roi_xyz,'rows'));

if ~sum(intx)
    X = 0;
else
    X = 1;
end;
