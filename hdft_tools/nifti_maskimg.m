function nifti_maskimg(source_file, mask_file);

% function nifti_maskimg(source_file, mask_file);
%
% Masks one image file with the non-zero values in a mask file.
%
% INPUTS:
%    source_file = pointer to the .nii file to be masked
%    mask_file   = pointer to the .nii mask file
%
% Saves a new file with a 'msk-' prefix in the same directory as the
% source_file
%
% Written by T. Verstynen, November 2010

src_nii = load_nii(source_file);
mask_nii = load_nii(mask_file);

% ROI indx
indx = find(mask_nii.img(:)>0);

new_img = zeros(size(src_nii.img));
new_img(indx) = src_nii.img(indx);
src_nii.img = new_img;

% Get the fileparts for saving
[fpath, fname, fext] = fileparts(source_file);

% Save the output
save_nii(src_nii, fullfile(fpath,['msk-' fname fext]));

