%This function synthesizes the data.nii for a set of bedpostx outputs.
%      N is the number of fibers fit.
%   name.bedpostX/ contains the following files
%           - nodif_brain_mask.nii
%           - dyads#.nii                for i = 1:N
%           - mean_dsamples.nii
%           - mean_f#famples.nii        for i = 1:N
%           - bvals
%           - bvecs
%   The current directory contains the input to bpx for the same run. 
%           Crucially, it contains data.nii, from which we take the
%           background signal s0.

						  %currently, N is two
N=2;

% Set Everything Up:
%   Load all single files
%   Load all 1:N files
%   count voxels
%   allocate storage for images

%  First cd and load files for the bpx output
!cd *.bedpostX
							      
%   Load all single files
bvals = load('bvals');
bvecs = load('bvecs');
mean_d = load_nii('mean_dsamples.nii');
mask = load_nii('nodif_brain_mask.nii');

% go back up and load the input files
!cd ../
originalImages = load_nii('data.nii');
background = squeeze(originalImages.img(:,:,:,1));

% go back down and get more
!cd *.bedpostX

%   Load all 1:N files
for i=1:N
    
    i = int2str(i);
    
    dyadName = ['dyads', i];
    readDyad = ['load_nii([''dyads', i, '.nii'']);'];
    dyadLoadCommand = [dyadName, ' = ', readDyad];
    
    fName = ['f', i];
    readf = ['load_nii([''mean_f', i, 'samples.nii'']);'];
    fLoadCommand = [fName, ' = ', readf];
    
    eval(dyadLoadCommand);
    eval(fLoadCommand);    
    
end
    

%   Count voxels
voxelsLinearIndices = find(mask.img);
[x_index, y_index, z_index ]= ind2sub(size(mask.img),voxelsLinearIndices);
numberOfVoxels = length(voxelsLinearIndices);


%   Allocate storage for the images
data = zeros(96,96,50,515);


%   Loop through voxels in mask and synthesize the ground truth images
for i = 1:numberOfVoxels
    
    % Orient yourself
    x = x_index(i);
    y = y_index(i);
    z = z_index(i);
    
    
    % Set fiber-neutral parameters
    d = mean_d.img(x,y,z);
    localBackgroundSignal = double(background(x,y,z));
    isotropic_f = 1;
    
    % Loop through the fibers
    for j = 1:N
        
        %   Get the dyad
        getDyad = ['squeeze(dyads', int2str(j), '.img(x,y,z,:));'];
        eval(['dyad = ', getDyad]);
        
        %   Get the f
        getf = ['f', int2str(j), '.img(x,y,z);'];
        eval(['f = ', getf]);
        
        %   Compute the contributed signal
        signal = getSignal(dyad, f, d, bvals, bvecs);
        
        %   Update the image and the isotropic f
        isotropic_f = isotropic_f - f;
        
        data(x,y,z,:) = squeeze(data(x,y,z,:)) + signal';
    end
    
    %   Add in the isotropic signal
    isoSignal = isotropicSignal(bvals, d, isotropic_f);

    data(x,y,z,:) = squeeze(data(x,y,z,:)) + isoSignal';
    
 
    %   Compute the full signal
    data(x,y,z,:) = localBackgroundSignal*data(x,y,z);
       
end

%   Restore the background 
data(:,:,:,1) = background;

%   Put the images in the orignal image struct and return
originalImages.img = data;
data = originalImages;

% now write to file
!cd ../

save_nii(data, 'groundTruth.nii');

