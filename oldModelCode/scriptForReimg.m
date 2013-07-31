%% This is just a script;

clear;
tic;

dir = '../changetestbedpostxoutput/';

ii = 22;
jj = 24;
kk = 22;

ogIM = load_nii('../testLoadSaveChange/dataOG.nii');
s0 = ogIM.img(ii, jj, kk, 1);

% load the mean diffusivity at every voxel
meand = load_nii([dir, 'mean_dsamples.nii']);
dyads1 = load_nii([dir, 'dyads1.nii']);
dyads2 = load_nii([dir, 'dyads2.nii']);

meanf1 = load_nii([dir, 'mean_f1samples.nii']);
meanf2 = load_nii([dir, 'mean_f2samples.nii']);
remainingf = ones(size(meanf1.img)) - meanf1.img - meanf2.img;

bvals = load([dir, 'bvals']);
bvecs = load([dir, 'bvecs']);

%%
%%
%% from here on out, pretend you're in the foor loop
%%
%%

%% Calculate the isotropic component
constants = exp(-bvals*meand.img(ii,jj,kk));
anisotropic = remainingf(ii,jj,kk)*constants;

%% Calculate the component for fiber one
%%      Get the dotproducts
qv_1_dotprod = squeeze(dyads1.img(ii,jj,kk,:))'*bvecs;
qv_1_dotprod2 = qv_1_dotprod.*qv_1_dotprod;

%%      Get the quadratic form
quadform1 = -bvals.*qv_1_dotprod2*meand.img(ii,jj,kk);
comp1 =  meanf1.img(ii,jj,kk)*exp(quadform1);



%% Calculate the component for fiber two
%%      Get the dotproducts
qv_2_dotprod = squeeze(dyads2.img(ii,jj,kk,:))'*bvecs;
qv_2_dotprod2 = qv_2_dotprod.*qv_2_dotprod;

%%      Get the quadratic form
quadform2 = -bvals.*qv_2_dotprod2*meand.img(ii,jj,kk);
comp2 =  meanf2.img(ii,jj,kk)*exp(quadform2);


%% Calculate The Whole Thing
sig = double(s0)*(anisotropic + comp1 + comp2);
signo = sig/double(s0);
sigwak = signo/double(s0);

ogHmm = double(squeeze(ogIM.img(22,24,22,:)));
ogHm0 = double(squeeze(ogIM.img(22,24,22,1)));
ogHmratio = ogHmm/ogHm0;

plot(1:515,signo, 1:515, ogHmratio)
plot(1:515,sig, 1:515, ogHmm)

toc;


