function output=hdft_allTRKxyz_extract(trk_file)

% function output=hdft_allTRKxyz_extract(trk_file)
% 
% Gets all the point coordinates from a track file
% 
% INPUT:
%     trk_file = file path to target track file (.trk) or a track structure
%     itself (from read_trk.m) 
% 
% OUTPUT:
%     output.xyz = Nx3 array of ROI voxel positions
%     output.hdr = Track header from track file
%
% Written by T. Verstynen, October 2010

% Load the track file (matris or otherwise)
if ~isstruct(trk_file);
  trk = read_trk(trk_file);
else
  trk = trk_file; clear trk_file;
end;

output.header = trk.header;
output.xyz = cell2mat(cellfun(@cellfcn_AllPosExtract,trk.fiber,'UniformOutput',0)');