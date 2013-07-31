function [ finished ] = sigmaFromBackgroundMask( maskFile, originalScanFile, sigmaOutFile)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
mask = load_nii(maskFile);
mask = mask.img;
inds = find(mask);
N_voxels = length(inds);

scan = load_nii(originalScanFile);
scan = scan.img;
scan = double(scan);
dimScan = size(scan);
numBvals = dimScan(4);


sigmas = ones(numBvals,1);

for q = 1:numBvals

curScan = squeeze(scan(:,:,:,q));
curScanBackground = curScan(inds);

%sumScan = sum(curScan(inds));
%sumScan2 = sum(curScan2(inds));
%scanVariance = sumScan2 - (sumScan^2);

sigmas(q) = std(curScanBackground);

end



save(sigmaOutFile, 'sigmas');

finished = 1;
end

