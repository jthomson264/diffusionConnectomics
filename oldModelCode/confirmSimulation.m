%%  P Foley 
%%
%%  This script will confirm that we got it right on the simulation study.

function [angleDyad1, angleDyad2, angleTruth, allF1, allF2, fitdiffF1, fitdiffF2, meand, fitdiffmeand]  = compareParameters(mask, fitDir, truthDir)

fitDyads1File = [fitDir, 'dyads1.nii'];
fitDyads2File = [fitDir, 'dyads2.nii'];
trueDyads1File = [truthDir, 'dyads1.nii'];
trueDyads2File = [truthDir, 'dyads2.nii'];
fitF1File = [fitDir, 'mean_f1samples.nii'];
fitF2File = [fitDir, 'mean_f2samples.nii'];
trueF1File = [truthDir, 'mean_f1samples.nii'];
trueF2File = [truthDir, 'mean_f2samples.nii'];
fitD_file = [fitDir, 'mean_dsamples.nii'];
trueD_file = [truthDir, 'mean_dsamples.nii'];

fitDyads1 = load_nii(fitDyads1File);
fitDyads2 = load_nii(fitDyads2File);
trueDyads1 = load_nii(trueDyads1File);
trueDyads2 = load_nii(trueDyads2File);

fitF1 = load_nii(fitF1File);
fitF2 = load_nii(fitF2File);
trueF1 = load_nii(trueF1File);
trueF2 = load_nii(trueF2File);

fitD = load_nii(fitD_file);
trueD = load_nii(trueD_file);

%   Set up mask
mask = mask.img;
voxelsLinearIndices = find(mask);
[x_index, y_index, z_index ]= ind2sub(size(mask),voxelsLinearIndices);
numberOfVoxels = length(voxelsLinearIndices);


%   Allocate space for comparison results
angleDyad1 = zeros(numberOfVoxels, 1);
angleDyad2 = zeros(numberOfVoxels, 1);
angleTruth = zeros(numberOfVoxels, 1);

%   Allocate space for inspection results
allF1 = zeros(numberOfVoxels, 1);
allF2 = zeros(numberOfVoxels, 1);
fitdiffF1 = zeros(numberOfVoxels, 1);
fitdiffF2 = zeros(numberOfVoxels, 1);
meand = zeros(numberOfVoxels, 1);
fitdiffmeand = zeros(numberOfVoxels, 1);


%  Loop through and check stuff
for i=1:numberOfVoxels
    
    % Orient yourself
    x = x_index(i);
    y = y_index(i);
    z = z_index(i);

   
    % Check the f1 and f2
    tf1 = trueF1.img(x,y,z);
    allF1(i) = tf1;
    tf2 = trueF2.img(x,y,z);
    allF2(i) = tf2;
    ff1 = fitF1.img(x,y,z);
    fitdiffF1(i) = tf1 - ff1;
    ff2 = fitF2.img(x,y,z);
    fitdiffF2(i) = tf2 - ff2;
    
    % Check the dyads
    td1 = squeeze(trueDyads1.img(x,y,z,:));
    td2 = squeeze(trueDyads2.img(x,y,z,:));
    fd1 = squeeze(fitDyads1.img(x,y,z,:));
    fd2 = squeeze(fitDyads2.img(x,y,z,:));
    angleDyad1(i) = acos(td1'*fd1);
    angleDyad2(i) = acos(td2'*fd2);
    angleTruth(i) = acos(td1'*td2);
    
    % Check the mean diffusivity
    td = trueD.img(x,y,z);
    meand(i) = td;
    fd = fitD.img(x,y,z);
    fitdiffmeand(i) = td - fd;
    
end

end
                         

