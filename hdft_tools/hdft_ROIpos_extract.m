function output = hdft_ROIpos_extract(file, varargin);

% function output = hdft_ROIpos_extract(file, optlabel, optvalue);
% 
% Takes a nifti ROI file and pulls out the xyz coordinates
% 
% INPUT:
%     file = file path to target image
%     opts = optional input flags
%         FLIP_X : Flip the x-dimension (default=0)
%         FLIP_Y : Flip the x-dimension (default=1)
%         FLIP_Z : Flip the z-dimension (default=0)
% 
% OUTPUT:
%     output.xyz = Nx3 array of ROI voxel positions
%     output.hdr = Nifti header from (load_nii.m)
% 
% Written by T. Verstynen, October 2010
    
    
% Flags for flipping the matrix if needed
FLIP_X = 0;  % Right now there appears to be be an x-flip problem
FLIP_Y = 0;
FLIP_Z = 0;

% Get variable input parameters
for v=1:2:length(varargin),
    eval(sprintf('%s = varargin{%d};',varargin{v},v+1));
end

% Grab the file
nii = load_untouch_nii(file);

% Estimate the flipping needed in each dimension
if FLIP_X
   nii.img = flipdim(nii.img,1);
end

if FLIP_Y
   nii.img = flipdim(nii.img,2);
end

if FLIP_Z
  nii.img = flipdim(nii.img,3);
end

% Extract the coordinates
indx = find(nii.img(:));

% Convert to index values to subscripts
[x, y, z] = ind2sub(size(nii.img),indx);

% Store with traditional output file structure
output.xyz = [x, y, z];
output.header = nii.hdr;

