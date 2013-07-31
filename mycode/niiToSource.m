function [ output_args ] = niiToSource( scanName )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

NiiName = ['~/data/', scanName, '/data.nii'];
btabName = ['~/data/', scanName, '/btab'];

data = load_nii(NiiName);
btab = load(btabName);

dimz = size(data.img);
num_images = dimz(4);


%   Make the "dimension" element
dimension = dimz(1:3);

%   Make the "voxel_size" element
voxel_size = [1 1 1];
voxel_size(1) = abs(data.hdr.hist.srow_x(1));
voxel_size(2) = abs(data.hdr.hist.srow_y(2));
voxel_size(3) = abs(data.hdr.hist.srow_z(3));

%   Make the images.
for i = 1:num_images
   
    nameNumber = i - 1;
    imName = ['image',int2str(nameNumber)];
    qscan = squeeze(data.img(:,:,:,i)); %#ok<NASGU>
    command = [imName, ' = imForSource(qscan);'];
    eval(command);
    
end


%   Make the "b_table"     element

b_table = btab';
if (size(b_table)~=[4 515]) 
    disp('Your btbale is the wrong size');
    return
end

clear data btab dimz num_images imName qscan nameNumber i command

save([NiiName, '.src'],'-V4');


end

