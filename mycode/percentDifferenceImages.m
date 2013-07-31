function [ worked ] = percentDifferenceImages(file1, file2, maskfile, outfilename)

mask = load_nii(maskfile);
mask = mask.img;

im1 = load_nii(file1);
im2 = load_nii(file2);
im1 = im1.img;
im2 = im2.img;

% Now identify which voxels are on in this mask.
maskVoxels = find(mask);

numImages = size(im1);
numImages = numImages(4);

curIm1 = im1(:,:,:,1);
curIm2 = im2(:,:,:,2);

percentDiffs = zeros(numImages,1);

for i = 1:numImages
    
    curIm1 = 1+im1(:,:,:,i);
    curIm2 = 1+im2(:,:,:,i);

    curIm1 = curIm1(maskVoxels);
    curIm2 = curIm2(maskVoxels);
    %m1 = mean(curIm1);    
    
    diffs = curIm1 - curIm2;
    pdiffs = diffs ./ curIm1;
    pdiffs = abs(pdiffs);
        
    percentDiffs(i) = mean(pdiffs);
    
end

fig = figure;
plot(percentDiffs);
saveas(fig, outfilename, 'png')

worked = 1;
end
