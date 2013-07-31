function [ mask ] = generateRandomMask( fullMask, N )
%   Generates a random mask from another mask
%   	Input fullMask is a mask with many voxels as 1
%       The output mask makes a computationally managable sample of
%       that mask, with only approximately N voxels as 1.

%   First get the indices of the voxels in the mask
voxelLinearIndices = find(fullMask.img);
whichVoxels = randsample(voxelLinearIndices,N);

val = fullMask.img(whichVoxels(1));

fullMask.img(:,:,:) = 0;
fullMask.img(whichVoxels) = val;

mask = fullMask;

%   Now confirm we did things correctly
if (length(find(mask.img)) ~= N)
    disp('The mask is not the correct number of voxels.  ');
end


end

