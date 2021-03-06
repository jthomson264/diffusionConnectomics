function [ DWI ] = addTractToDWI( DWI, btable, tract)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here
%   Define metaparameters

%   Set each line segment to represent a fascicle occupying 1% of a voxel's
%   volume.
volumeFraction = 1/3;

%   this is the diagonal of the matrix D_eff defined in 'MR Diffusion
%   Tensor Spectroscopy and Imaging', from Peter Basser, James Mattiello,
%   and Denis LeBihan in 1994.  It is from the Corpus Callosum of a cat
%   brain, and it is only a temporary measure.
%   I use 0.035 instead of the recorded 2nd and 3rd entries.
%diagonalOfEffectiveDiffusionMatrix = [0.2747, 0.0327, 0.0375];
D_eff = [0.2747, 0.035, 0.035];
D_effConstant = 10^(-5);

%  I don't understand why I have these two lines.  I'm getting rid of them.
%D_effConstant = D_effConstant/ D_eff(1);
%D_eff = D_eff / D_eff(1);
% D_eff constant was 10^-5 cm2/s
D_eff = D_eff * D_effConstant;


%   Check that things are good.
if size(btable,2) ~= 4
    error('Your btable is not Nx4.');
    %disp('Your btable is not Nx3.');
end

if size(tract,2) ~= 3
    error('Your tract is not Nx3');
end

if size(DWI.img,4) ~= size(btable,1)
    error('Your DWI q-dimension does not match your number of diffusion wave vectors in the btable.');
end
    
numberOfPoints = size(tract,1);
numberOfLines = numberOfPoints - 1;


%   We now predict the diffusion signals for each line section.
%       With a btable of 515x3, 
%       and a tract of Nx3, 
%       we produce a matrix that is 515xN, where entry i,j corresponds
%       to the predicted diffusion signal for diffusion wave vector i
%       coming from line segment j.
lines = tract(2:numberOfPoints, :) - tract(1:numberOfPoints-1,:);
%   We need, for each diffusion wave vector, the component or that vector 
%       that is in the direction of the line segment.
dotProducts = (btable(:,2:4) * lines');
dotProductsSquared = dotProducts.^2;
%   We also need the orthogonal component.  The orientation does not
%   matter, as the predicted diffusion ellipsoid is symmetric with
%   rotations about the primary axis.  That is, the 2nd and 3rd entries are
%   equal, and we can choose the orthogonal component to be c * the
%   component in ONE direction orthogonal to the primary direction.
%   Also recall that the diffusion wave vectors here have magnitude 1.
orthComponentsSquared = (1 - dotProductsSquared);
%   Now we need to multiply the orthComponentsSqured by the 2nd or 3rd
%   entry in the diffusion matrix, add them to the aligned components, and
%   multiply by the ADC.
bothComponents = D_eff(1)*dotProductsSquared + D_eff(2)*orthComponentsSquared;

signal = zeros(size(btable,1),numberOfLines);

for i = 1:size(btable,1)
    signal(i,:) = volumeFraction*exp(-btable(i,1)*bothComponents(i,:));
end

%   We now have an NqxN matrix of contributions for each line segment.
%   We need to add each of these N components to the appropriate entry
%   in the giant DWI matrix.  To do so, we need to identify the locations
%   of each line segment with voxels in the DWI.
%   For now, we do so by using the location of the middle point.  This 
%   is a temporary measure.
segmentMidpoints = (tract(1:numberOfPoints-1,:) + tract(2:numberOfPoints,:))/2;
midPointsInVoxelSpace = segmentMidpoints;
midPointsInVoxelSpace(:,1) = midPointsInVoxelSpace(:,1) / DWI.hdr.dime.pixdim(2);
midPointsInVoxelSpace(:,2) = midPointsInVoxelSpace(:,2) / DWI.hdr.dime.pixdim(3);
midPointsInVoxelSpace(:,3) = midPointsInVoxelSpace(:,3) / DWI.hdr.dime.pixdim(4);
midPointVoxels = 1 + floor(midPointsInVoxelSpace);

%   I will now proceed to do something horrible.  This will change later.
%   Look!  I took it out!  not doing anything bad!


%if [min(midPointVoxels(:,1)) < 1]
%    error('Min of X voxels is less than 1.');
%end
%if [max(midPointVoxels(:,1)) > size(DWI.img,1)]
%    error('Max of X voxels is greater than size allowed by DWI.');
%end
%
%
%if [min(midPointVoxels(:,2)) < 1]
%    error('Min of X voxels is less than 1.');
%end
%if [max(midPointVoxels(:,2)) > size(DWI.img,2)]
%    error('Max of X voxels is greater than size allowed by DWI.');
%end
%
%
%if [min(midPointVoxels(:,3)) < 1]
%    error('Min of X voxels is less than 1.');
%end
%if [max(midPointVoxels(:,3)) > size(DWI.img,3)]
%    error('Max of X voxels is greater than size allowed by DWI.');
%end
%
%
%midPointVoxels(:,1) = midPointVoxels(:,1) + min(midPointVoxels(:,1));
%midPointVoxels(:,2) = midPointVoxels(:,2) + min(midPointVoxels(:,2));
%midPointVoxels(:,3) = midPointVoxels(:,3) + min(midPointVoxels(:,3));
%min(midPointVoxels(:,2))
%min(midPointVoxels(:,3))

if [size(signal,1) ~= size(DWI.img, 4)]
    error('Dimensions of signal and DWI do not match in the q-dimension.');
end

if [size(midPointVoxels,1) ~= numberOfLines]
    error('You created midPointVoxels incorrectly.');
end


DWI.img = double(DWI.img);
xyzDimension = [size(DWI.img,1), size(DWI.img,2), size(DWI.img,3)];
for i = 1:numberOfLines
    x = midPointVoxels(i,1);
    y = midPointVoxels(i,2);
    z = midPointVoxels(i,3);
    if (all([x, y, z] <= xyzDimension) && all([x, y, z] > [0, 0, 0]))
        DWI.img(x, y, z, :) = squeeze(double(DWI.img(x, y, z, :))) + double(signal(:,i));
    end
end

end

