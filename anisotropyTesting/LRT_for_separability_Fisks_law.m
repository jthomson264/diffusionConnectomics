%  This script does the LRT for whether or not the radial and angular parts
%  of the signal are separable using the Fisk's law model.

%   Read in the data.
btable = load('~/data/p1s1/btab');
bvecs = btable(:,2:4);
N.vecs = size(bvecs, 2);
%uniqueBvecs = unique(round(10*bvecs),'rows');
%n.unique.bvecs = size(uniqueBvecs,1);
bvals = btable(:,1);
sigmas = load('~/data/p1s1/sigmas.mat');
sigmas = sigmas.sigmas;
sigma2s = sigmas.^2;
data = load_untouch_nii('~/data/p1s1/data.nii');

%   The images are 96 by 96 by 50, so I'm just choosing one voxel in the
%   middle.
testVoxels = data.img(47:49,47:49,24:26,:);
middleVoxel = squeeze(data.img(48,48,25,:));
%bvals = repmat(bvals, 9, 1);
%sigmas = repmat(sigmas, 9, 1);
%bvecs = repmat(bvecs, 9, 1);


%   Now I will initialize the parameters of the model.
lambda = 1;
angularComponent = 2*middleVoxel;
%angularComponents = repmat(angularComponent, 9, 1);
angularComponent = double(angularComponent);

Nu = angularComponent .* exp(-bvals * lambda);

xNuSigma2 = middleVoxel .* Nu ./ sigma2s;

besselRatio = besseli(1, xNuSigma2) / bessli(0, xNuSigma2);

%   Now I will compute the initial loglikelihood gradient
dNu.dLambda = -angularComponent .* bvals * exp(- bvals * lambda);
dNu.dAngularComponents = exp(- bvals * lambda);
dEl.dLambda = - ((Nu / sigma2s) .* dNu.dLambda) + (testVoxel / sigma2s) * dNu.dLambda * besselRatio;

