%   P Foley
%   
%   This is a script to load bvecs/bvals, then generate an NIFTI.
%   After generating the NIFTI I run bedpostx on it.
%   I will only use three voxels.
%   It then reads in the bedpostx output which SHOULD be the same
%   as the input.  

%   Set directories
function itWorked = generateFakes(imageOutputDir, paramsOutputDir)

datadir = '../testbedpostx/';
maskfile = '../testbedpostx/nodif_brain_mask.nii';

%   Get bvals and bvecs
bvals = load([datadir, 'bvals']);
bvecs = load([datadir, 'bvecs']);

%   Get a legitimate s0 and legitimate mean diffusivities
ogImage = load_nii('../testLoadSaveChange/dataOG.nii');
ogImage = ogImage.img;
backgroundSignal = squeeze(double(ogImage(:,:,:,1)));
clear ogImage;

ogD = load_nii('../testbedpostx.bedpostX/mean_dsamples.nii');


%   Allocate storage for ground-truth
truth_dyads1 = zeros(96,96,50,3);
truth_dyads2 = zeros(96,96,50,3);
truth_meanf1 = zeros(96,96,50);
truth_meanf2 = zeros(96,96,50);
truth_meand = zeros(96,96,50);
truth_imageData = zeros(96,96,50,515);



%   Set up mask
mask = load_nii(maskfile);
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
    
    dyad1 = [1 ; 0; 0];
    dyad2 = [0 ; 1; 0];

    %[theta1, phi1] = dyad2angles(dyad1);
    %[theta2, phi2] = dyad2angles(dyad2);

    d = ogD.img(x,y,z);      % May want to set this to first fit d
    
    s0xyz = backgroundSignal(x,y,z);     % 
    
    % Compute each component of the signal
    firstSig = getSignal(dyad1, f1, d, bvals, bvecs);
    secondSig = getSignal(dyad2, f2, d, bvals, bvecs);
    isoSig = isotropicSignal(bvals, d, f_iso);

    % Compute the full signal
    signal = s0xyz*(firstSig + secondSig + isoSig);
    
    % Store all values to truth
    truth_dyads1(x,y,z,:) = dyad1;
    truth_dyads2(x,y,z,:) = dyad2;
    truth_meanf1(x,y,z) = f1;
    truth_meanf2(x,y,z) = f2;
    truth_meand(x,y,z) = d;
    truth_imageData(x,y,z,:) = signal;
    
end


%   Now write all necessary files to run bedpostx
truth_imageData(:,:,:,1) = backgroundSignal;
ogImage = load_nii('../testLoadSaveChange/dataOG.nii');
ogImage.img = truth_imageData;
save_nii(ogImage, [imageOutputDir, 'data.nii']);
clear truth_imageData ogImage

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

itWorked = 1;

%   Now you've saved everything.  So run bpx on it and check it.



