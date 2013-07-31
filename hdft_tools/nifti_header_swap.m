function nifti_header_swap(source_file, template_file);

% function nifti_header_swap(source_file, template_file);
%
% Replaces the header information of one nifti file with the information
% from another (presumably matched) nifti file
%
% INPUTS:
%    source_file = pointer to the .nii file to be fixed
%    template_file = pointer to the .nii file with the correct header
%
% WARNING: The source_file gets overwritten in this process.  
%
% Written by T. Verstynen, November 2010

src_nii = load_nii(source_file);
template_nii = load_nii(template_file);

% Now swap the headers for the output
template_nii.img = src_nii.img;

% Get the fileparts for saving
save_nii(template_nii, source_file);
