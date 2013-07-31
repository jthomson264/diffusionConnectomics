function [ data ] = synthGroundTruthImage( bedpostXinputDir, bedpostXoutputDir, N )
%This function synthesizes the data.nii for a set of bedpostx outputs.
%      N is the number of fibers fit.
%   bedpostXoutputDir must contain the following files
%           - nodif_brain_mask.nii
%           - dyads#.nii                for i = 1:N
%           - mean_dsamples.nii
%           - mean_f#famples.nii        for i = 1:N
%           - bvals
%           - bvecs
%   bedpostXinputDir must contain the input for bedpostXoutputDir
%           Crucially, it contains data.nii, from which we take the
%           background signal s0.

% Set Everything Up:
%   Load all single files
%   Load all 1:N files
%   count voxels
%   allocate storage for images

bedpostXoutputDir=[bedpostXoutputDir,'/'];
bedpostXinputDir=[bedpostXinputDir,'/'];
%   Load all single files
bvals = load([bedpostXoutputDir, 'bvals']);
bvecs = load([bedpostXoutputDir, 'bvecs']);
mean_d = load_nii([bedpostXoutputDir, 'mean_dsamples.nii']);
mask = load_nii([bedpostXoutputDir, 'nodif_brain_mask.nii']);
originalImages = load_nii([bedpostXinputDir, 'data.nii']);
background = squeeze(originalImages.img(:,:,:,1));

%   Load all 1:N files
for i=1:N
    
    i = int2str(i);
    
    dyadName = ['dyads', i];
    readDyad = ['load_nii([bedpostXoutputDir, ''dyads', i, '.nii'']);'];
    dyadLoadCommand = [dyadName, ' = ', readDyad];
    
    fName = ['f', i];
    readf = ['load_nii([bedpostXoutputDir, ''mean_f', i, 'samples.nii'']);'];
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
    
    disp(['Entering voxel # ', int2str(i)]);
    
    % Orient yourself
    x = x_index(i);
    y = y_index(i);
    z = z_index(i);
    
    disp(['Location is ', int2str(x), '  ', int2str(y), '  ', int2str(z)]);
    
    % Set fiber-neutral parameters
    d = mean_d.img(x,y,z);
    localBackgroundSignal = double(background(x,y,z));
    isotropic_f = 1;
    
    % Loop through the fibers
    for j = 1:N
        
        disp(['Working on fiber # ', int2str(j)]);
        
        %   Get the dyad
        getDyad = ['squeeze(dyads', int2str(j), '.img(x,y,z,:));'];
        eval(['dyad = ', getDyad]);
        
        %   Get the f
        getf = ['f', int2str(j), '.img(x,y,z);'];
        eval(['f = ', getf]);
        
        %   Compute the contributed signal
        signal = getSignal(dyad, f, d, bvals, bvecs);
        disp(['Length of signal is ', int2str(length(signal))]);
        
        %   Update the image and the isotropic f
        isotropic_f = isotropic_f - f;
        
        disp(['Dimensions of data are ', int2str(size(data))]);
        disp(int2str(size(data(x,y,z,:))));
        disp(int2str(size(squeeze(data(x,y,z,:)))));
        disp(int2str(length(signal)));
        data(x,y,z,:) = squeeze(data(x,y,z,:)) + signal';
    end
    
    %   Add in the isotropic signal
    isoSignal = isotropicSignal(bvals, d, isotropic_f);
    disp(['dim of isoSignal is', size(isoSignal)]);
    disp(['dim of data is ', size(data)]);

    data(x,y,z,:) = squeeze(data(x,y,z,:)) + isoSignal';
    
 
    %   Compute the full signal
    data(x,y,z,:) = localBackgroundSignal*data(x,y,z);
       
end

%   Restore the background 
data(:,:,:,1) = background;

%   Put the images in the orignal image struct and return
originalImages.img = data;
data = originalImages;

end

