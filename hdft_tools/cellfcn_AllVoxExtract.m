function VX = cellfcn_AllPosExtract(C,hdr);

% Small function to grab points from all streamline positions for the
% fiber stucture C.  C is the same as tracks.fiber

X = C.points;
[vx, vy, vz] = mm2voxel(X(:,1),X(:,2),X(:,3),hdr);
VX = unique([vx vy vz],'rows');
