%   P Foley
%    
function data = synthImageFromScratch(dyad, spaceDir, paramsOutputDir, imageOutputDir, mask)

%   Get bvals and bvecs
bvals = load([spaceDir, 'bvals']);
bvecs = load([spaceDir, 'bvecs']);


%   Allocate storage for ground-truth
truth_dyads1 = zeros(96,96,50,3);
truth_dyads2 = zeros(96,96,50,3);
truth_meanf1 = zeros(96,96,50);
truth_meanf2 = zeros(96,96,50);
truth_meand = zeros(96,96,50);
truth_imageData = zeros(96,96,50,515);



%   Set up mask
mask = mask.img;
voxelsLinearIndices = find(mask);
[x_index, y_index, z_index ]= ind2sub(size(mask),voxelsLinearIndices);
numberOfVoxels = length(voxelsLinearIndices);

%   Loop through voxels in mask and generate ground truth
for i=1:numberOfVoxels
    
    % Orient yourself
    x = x_index(i);
    y = y_index(i);
    z = z_index(i);
    
    % Set all input parameters
    f1 = 0.7;
    f2 = 0;
    f_iso = 1 - (f1 + f2);
    
    dyad1 = dyad;
    dyad2 = [0 ; 1; 0];

    % These are typical values. 
    d = 0.00005;
    s0 = 100;
    
    
    % Compute each component of the signal
    firstSig = getSignal(dyad1, f1, d, bvals, bvecs);
    secondSig = getSignal(dyad2, f2, d, bvals, bvecs);
    isoSig = isotropicSignal(bvals, d, f_iso);

    % Compute the full signal
    signal = s0*(firstSig + secondSig + isoSig);
    
    % Store all values to truth
    truth_dyads1(x,y,z,:) = dyad1;
    truth_dyads2(x,y,z,:) = dyad2;
    truth_meanf1(x,y,z) = f1;
    truth_meanf2(x,y,z) = f2;
    truth_meand(x,y,z) = d;
    truth_imageData(x,y,z,:) = signal;

    % Ensure we did it right
%if (sum((truth_dyads1(x,y,z,:) ~= dyad1)) > 0)
%    disp('You did not store the dyads correctly.');
%end
%if (sum((truth_dyads2(x,y,z,:) ~= dyad2)) > 0)
%disp('You did not store the dyads correctly.');
%end
%if (truth_meanf1(x,y,z) ~= f1)
%disp('You did not store the mean f correctly.');
%end
%if (truth_dyads(x,y,z) ~= f2)
%disp('You did not store the mean f correctly.');
%end
%if (truth_meand(x,y,z) ~= d)
%disp('You did not store the mean d correctly.');
%end
%if (sum((squeeze(truth_ImageData(x,y,z,:)) ~= signal)) > 0)
%disp('You did not store the image correctly.');
%end



end


%   Now write all necessary files to run bedpostx
ogImage = load_nii('../testbedpostx/data.nii');
ogImage.img = truth_imageData;
save_nii(ogImage, [imageOutputDir, 'data.nii']);
clear ogImage

dyadsTemplate = load_nii('../testbedpostx.bedpostX/dyads1.nii');
dyadsTemplate.img = truth_dyads1;
save_nii(dyadsTemplate, [paramsOutputDir, 'dyads1.nii']);
dyadsTemplate.img = truth_dyads2;
save_nii(dyadsTemplate,  [paramsOutputDir, 'dyads2.nii']);
clear dyadsTemplate dyads1 dyads2;

meanfTemplate = load_nii('../testbedpostx.bedpostX/mean_f1samples.nii');
meanfTemplate.img = truth_meanf1;
save_nii(meanfTemplate, [paramsOutputDir, 'mean_f1samples.nii']);
meanfTemplate.img = truth_meanf2;
save_nii(meanfTemplate, [paramsOutputDir, 'mean_f2samples.nii']);
clear meanfTemplate meanf1 meanf2

meanDtemplate = load_nii('../testbedpostx.bedpostX/mean_dsamples.nii');
meanDtemplate.img = truth_meand;
save_nii(meanDtemplate, [paramsOutputDir, 'mean_dsamples.nii']);

data = truth_imageData;

%   Now you've saved everything.  So run bpx on it and check it.



