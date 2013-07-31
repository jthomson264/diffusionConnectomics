function hdft_make_density_map(trk_file, template_file, varargin)

% function hdft_make_density_map(trk_file, template_file, varargin)
% 
% Takes a track file and makes a .nii density map
% 
% INPUT:
%     trk_file = file path to target track file (.trk)
%     template_file = template .nii file with the same space as the tracks
%     opts = optional input flags
%         FLIP_X : Flip the x-dimension (default=0)
%         FLIP_Y : Flip the x-dimension (default=1)
%         FLIP_Z : Flip the z-dimension (default=0)
%         out_file : Output file pointer (default='density_map.nii')
% 
% 
% Written by T. Verstynen, October 2010
    

FLIP_X = 0;
FLIP_Y = 1;
FLIP_Z = 0;
out_file = 'density_map.nii';

% Get variable input parameters
for v=1:2:length(varargin),
    eval(sprintf('%s = varargin{%d};',varargin{v},v+1));
end

% Grab all the fiber locations
output = hdft_allTRKxyz_extract(trk_file);

% Save as a nifti with the same dimensions as the template image
save_nii(hdft_xyz2nii(output.xyz,output.header,template_file,...
    'FLIP_X',FLIP_X,'FLIP_Y',FLIP_Y,'FLIP_Z',FLIP_Z),out_file);