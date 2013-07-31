function [ DWI ] = createDWIfromTracts( DWI, btable, tracts)
%  This is a dumb function to create a DWI from tracts alone.
%  I am doing several very very simple things to avoid having to really
%  deal with a model for S0 and for isotropic diffusion.  In this function:
%       *  S0 is a constant everywhere.  It will start as 1, but I may
%       change it so it looks more like a typical DSI S0.
%       *  Isotropic diffusion is the same everywhere, occuring in volume
%       fraction f of each voxel, where f = 1 - N*C, for the N tracts
%       passing through a voxel each with volume component C.  I am not
%       caring about how much of the voxel they actually pass through.
%       That all ough to wash out.
%       *  Whenever possible, I'm going to use values taken from a typical
%       DSI scan, just to get DSI_Studio to run on my synthetic image.

volumeFraction = 1/3;
ADC = 2.5e-4;                    % No idea where to put this.
isotropicConstant = 100;

if (~all(DWI.hdr.dime.dim(2:4) == tracts.header.dim'))
    error('The dimensions of your DWI and tracts do not match.');
end

if (~all(DWI.hdr.dime.pixdim(2:4) == tracts.header.voxel_size'))
    %  This is where I cheat on my tracts.  I'm just changing their voxel
    %  size.  Sup.
    tracts.header.voxel_size = DWI.hdr.dime.pixdim(2:4)';
    %error('The sizes of voxels in your DWI and tracts do not match.');
end

%  Now create an empty array for all spatial voxels in which you'll store
%  tract counts.
tractCounts = zeros(size(DWI.img,1),size(DWI.img,2),size(DWI.img,3));


for i = 1:tracts.header.n_count
    [DWI, tractCounts] = addTractToDWIandCount(DWI, btable, tracts.fiber{i}.points, tractCounts);
end
disp('Added the anisotropic signal...');


%   Having added all the signal coming from the tracts, I'm now going to
%   compute f for each voxel and add the isotropic component.
isotropicVolumeFraction = 1 - volumeFraction*tractCounts;

%  For the isotropic signal component, I only need b value and ADC.
bvalues = btable(:,1);
%isotropicSignals = isotropicConstant * exp(-bvalues * ADC);     % This is Nqx1

%  I was going to use kron(isotropicVolumeFraction, isotropicSignals), but 
%       kron is defined only for 2-D arrays.  Dumb.  So I'll do this:
for i = 1:515
    isotropicSignalForQvec = isotropicVolumeFraction * isotropicConstant .* exp(-bvalues(i) * ADC);
    %   Note that now I don't have to set my S0 to 1, as this sets it to 
    %   my isotropicConstant automatically.
    DWI.img(:,:,:,i) = DWI.img(:,:,:,i) + isotropicSignalForQvec;
end

%fullIsotropicSignal = kron(isotropicVolumeFraction, isotropicSignals);
%DWI.img = DWI.img + fullIsotropicSignal;

disp('Added the isotropic signal...');


end
