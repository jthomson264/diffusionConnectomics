function [x y z] = voxel2mm(vx, vy, vz, track_hdr)

% [x y z] = voxel2mm(vx, vy, vz, track_hdr)
% voxel2mm converts voxel coodinate of a voxel in a volume
% to its millimeter coordinate w.r.t underlying image volume
% 
% Example:
% 
% [x y z] = voxel2mm(49, 89, 39, track_hdr)
% 
% NOTE: This is matlab based indexing i.e., Indexing start with 1 insted of
%       0.

%
% $Id: voxel2mm.m,v 1.2 2009/03/26 18:56:04 skpathak Exp $
%


x = vx * track_hdr.voxel_size(1) + 1;
y = vy * track_hdr.voxel_size(2) + 1;
z = vz * track_hdr.voxel_size(3) + 1;
