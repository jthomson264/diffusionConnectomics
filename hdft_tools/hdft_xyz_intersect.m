function intx = hdft_xyz_intersect(fiber_xyz,roi_xyz,hdr);

% Function to find the fiber points that intersect with an ROI
[vx, vy, vz] = mm2voxel(fiber_xyz(:,1),fiber_xyz(:,2),fiber_xyz(:,3),hdr);
%intx = prod(double(ismember([vx vy vz],roi_xyz)),2);
intx = double(ismember([vx vy vz],roi_xyz,'rows'));
