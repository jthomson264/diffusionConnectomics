function [ sigma ] = getSigma( datafile, brainfile, skullfile )
%getSigma obtains the paramater sigma for the rician distribution 
%   for a given image.  Sigma is a row vector of sigmas, one for 
%   every b-value.  The value for s0 is 0.  Mask should be a mask
%   of strictly empty regions.

%   Find the voxels in the mask.
brain = load_nii(brainfile);
skull = load_nii(skullfile);
brrain = brain;

brain = brain.img;
skull = skull.img;


%   The masks we input into this algorithm are automatically generated
%   using BET2.  We use the command
%   $ bet2 data.nii outfile -m -s -f .05
%   Please see http://www.fmrib.ox.ac.uk/fsl/bet2/index.html#bet 
%   for details.   This creates a very liberal mask, outfile.nii, and a 
%   mask of the skull, outfileskull.  This automates the process of 
%   generating a background mask, except for the task of avoiding the eyes
%   and neck.  To do this, we discard the bottom half of the image.

numZ_planes = size(brain);
numZ_planes = numZ_planes(3);
z_aboveEyes = floor(numZ_planes/2);

%   Now we construct the background mask.
backgroundMask = zeros(size(brain));
backgroundMask = backgroundMask + (brain < 1) + (skull < 1);

%   Now done with skull and brain, we can clear some memory.
clear brain skull;
backgroundMask(:,:,1:z_aboveEyes) = 0;
backgroundMask = (backgroundMask ~= 0);

brrain.img = backgroundMask;
save_nii(brrain, 'thismaskmasks.nii');

data = load_nii(datafile);
data = data.img;



%   Now we take the average by summing legitimate voxels and dividing by
%   the number of voxels in our mask.

numVoxels = length(find(backgroundMask));

numImages = size(data);
numImages = numImages(4);
sigma = zeros(numImages,1);

for i = 1:numImages;
    dicom = squeeze(data(:,:,:,i));
    sampleMean = sum(dicom(backgroundMask))/numVoxels;
    sigma(i) = sampleMean*sqrt(2)/sqrt(pi);  
end

% We now return the sigma vector.

% No we don't.   Now we write the sigma.
save('sigmaFile', 'sigma');

end
