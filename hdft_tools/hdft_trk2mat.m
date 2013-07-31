function hdft_trk2mat(trkfile);

% function output = hdft_trk2mat(file)
% 
% Takes a nifti ROI file and pulls out the xyz coordinates.  Causes
% redundancy in disk space but faster to load for regularly used, large
% track files.  Save's a .mat file in the same location as the .trk file
% but with a .mat extension
% 
% INPUT:
%     file = path to track file (.trk)
%
% OUTPUT:
%
% Written by T. Verstynen, November 2010


% Saves a .trk file as a matlab .mat file using the read_trk.m function
if nargin < 1 | isempty(trkfile)
    [name, path] = uigetfile('*.trk','Select the TRK file to convert')
    trkfile = fullfile(path, name);
end;

% Set the output file name.
[fpath, fname] = fileparts(trkfile);
outfile = fullfile(fpath,[fname '.mat']);

% Load the tracks
tracks = read_trk(trkfile);

% Save the .mat file
save(outfile,'tracks');
