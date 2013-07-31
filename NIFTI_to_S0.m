%   This script is just to pull a data.nii and then write a dataS0.nii, 
%   taking the background signal only from the NIFTI.

data = load_nii('data.nii');

%   Tell the NIFTI it now has only one layer.
data.hdr.dime.dim(5) = 1;

%   Set the dimension units value for the now-null dimension to that of
%   another null dimension
data.hdr.dime.dim(5) = data.hdr.dime.dim(6);

%   Set the image itself to only include the first layer.
data.img = data.img(:,:,:,1);

save_nii(data, 'dataS0.nii');
