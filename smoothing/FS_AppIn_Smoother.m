%%  this script is going to do smoothing using gradient descent on matrices
%   for a general DSI image.

%%  Stands for FisherScoring-BesselApproximation-Smoother

function [done] = smoothScript(outputName, spacePrecision, frequencyPrecision, maxIterations, N_experiments);


%  Fixed values for smoother order.
k = 2;
switchToAsymptotic = 4;

fileName = ['~/Desktop/data/', outputName, '.mat']

%  Here we set the metaparameters.
bscaling = 1/62;
spatialSigma = 1.2;
frequencySigma = 1;
qGridDistance = 1;
%maxIterations = 1;
%N_experiments = 5;

%  I'm going to need gridDistances.
load('~/data/mybrain/btab');
data = load_nii('~/data/mybrain/smalldata.nii')
%  Pull sigma2s
load('~/Desktop/code/hdft_tools/sigs.mat');
%   Prepare bvecs.
bvec = btab(:,2:4);
for i = 1:3
    bvec(:,i) = bvec(:,i) .* sqrt(btab(:,1));
end

intBvecs = [bvec; -bvec(2:515,:)];
intBvecs = intBvecs / max(max(intBvecs));

gridNumber = 5;
intBvecs = round(intBvecs*5) + 5 + 1;


xGridDistance = data.hdr.dime.pixdim(2);
yGridDistance = data.hdr.dime.pixdim(3);
zGridDistance = data.hdr.dime.pixdim(4);


%   I'm pulling these so I can test on small sub-images.
nx = data.hdr.dime.dim(2);
ny = data.hdr.dime.dim(3);
nz = data.hdr.dime.dim(4);






paddedDoubledData = zeros(nx,ny,nz,11,11,11);


%  Here' I'm going to prep the indices matrix, which tells me where to pull
%  the neighboring voxels from.  

%   Now I need to put the data into the paddedDoubledData.
for i = 2:515
    
   sigma = sigmas(i);

   qx = intBvecs(i,1);
   qy = intBvecs(i,2);
   qz = intBvecs(i,3);
   
   oppqx = intBvecs(i + 514, 1);
   oppqy = intBvecs(i + 514, 2);
   oppqz = intBvecs(i + 514, 3);
   
   paddedDoubledData(:,:,:,qx, qy, qz) = single(data.img(:,:,:,i)) / sigma;
   paddedDoubledData(:,:,:,oppqx, oppqy, oppqz) = single(data.img(:,:,:,i)) / sigma;
   
   disp('Added in one scan...');
    
end


%   Now I have my awesome huge giant array of doubled and zero-padded data.
%   Cool.  Time to do shit.

%   We're going to start with a very small window.  For the very simplest
%   first approach, I'm not even using gaussian gradient descent.  This
%   isn't even a 3x3x3 gaussian kernel spatially.  It's +/- one doxel in
%   each direction.



%neighborXs = zeros(nx-2, ny-2, nz-2, 9, 9, 9);
%score = zeros(nx-2, ny-2, nz-2, 9, 9, 9);
nuHatStar = zeros(nx-2, ny-2, nz-2, 9,9,9);
observedInformation = zeros(nx-2, ny-2, nz -2, 9, 9, 9);

maxIter = maxIterations;
iterations = 0;



startX = 2;
startY = 2;
startZ = 2;
startQx = 2;
startQy = 2;
startQz = 2;

stopX = nx - 1;
stopY = ny - 1;
stopZ = nz - 1;
stopQx = 10;
stopQy = 10;
stopQz = 10;




%  Here I can officially start my loop.

resultsArray = zeros(N_experiments, 3);
weightsArray = zeros(N_experiments, 13);
squaredErrorArray = zeros(N_experiments, 9,9,9,515);


for parallelIndex  = 1:N_experiments
  %parallelIndex = 1;

  Xs = paddedDoubledData(2:(nx-1), 2:(ny-1), 2:(nz-1), 2:10, 2:10, 2:10);
  nuHat = Xs;


  %  Generate metaparameters
  spatialSigma = lognrnd(0, 1/spacePrecision);
  frequencySigma = lognrnd(0, 1/frequencyPrecision);


  resultsArray(parallelIndex, 1) = spatialSigma;
  resultsArray(parallelIndex, 2) = frequencySigma;

  %  I need to design the weights vector now.
  %weights = 1;
  %  These need to go within the loop through parameters.
  xWeight = (2*pi)^(-1/2) * exp(-(1/spatialSigma)* (xGridDistance^2 / (2*spatialSigma^2)));
  yWeight = (2*pi)^(-1/2) * exp(-(1/spatialSigma)* (yGridDistance^2 / (2*spatialSigma^2)));
  zWeight = (2*pi)^(-1/2) * exp(-(1/spatialSigma)* (zGridDistance^2 / (2*spatialSigma^2)));
  qWeight = (2*pi)^(-1/2) * exp(-(1/frequencySigma)* (qGridDistance^2 / (2*frequencySigma^2)));
  centerWeight = (2*pi)^(-1/2);

  weights = [ ...
	   xWeight, xWeight, ...
	   yWeight, yWeight, ...
	   zWeight, zWeight, ...
	   qWeight, qWeight, qWeight, qWeight, qWeight, qWeight, ...
	   centerWeight];
  weights = weights / sum(weights);
  weightsArray(parallelIndex, :) = weights;






  while (iterations <= maxIter)
    iterations = iterations + 1;
  
    disp(['Beginning iteration ', iterations]);

    nuHatStar(:,:,:,:,:,:) = 0;
    observedInformation(:,:,:,:,:,:) = 1;

    disp('reset score and information');

    %weights = 1/13;
    for i = 1:13

      weight = weights(i);

      %indices = [0, 0, 0, 0, 0, 0];
      %  I'm just going to manually generate this for now.
      %  I already have start & stop for all dimensions.  I only need
      %  the offsets now.
      xOffset = (-1)^(i) * (i == 1 | i == 2);
      yOffset = (-1)^(i) * (i == 3 | i == 4);
      zOffset = (-1)^(i) * (i == 5 | i == 6);
      qxOffset = (-1)^(i) * (i == 7 | i == 8);
      qyOffset = (-1)^(i) * (i == 9 | i == 10);
      qzOffset = (-1)^(i) * (i == 11 | 1 == 12);
    
      %  Note that the offset at i = 13 will automatically be zero.

      xa = startX + xOffset;
      xb = stopX + xOffset;
    
      ya = startY + yOffset;
      yb = stopY + yOffset;

      za = startZ + zOffset;
      zb = stopZ + zOffset;

      qxa = startQx + qxOffset;
      qxb = stopQx + qxOffset;

      qya = startQy + qyOffset;
      qyb = stopQy + qyOffset;

      qza = startQz + qzOffset;
      qzb = stopQz + qzOffset;


   
      disp(' adding score and information for one neighbor');

      Xs = paddedDoubledData(xa:xb, ya:yb, za:zb, qxa:qxb, qya:qyb, qza:qzb);
      XsNus = Xs .* nuHat;

      disp( ' ... ... some preliminaries computed');

      bess0 = besselApproximation(0, XsNus, k);
      disp( ' ... ... first bessel computed ');
      bess1 = besselApproximation(1, XsNus, k);
      disp( ' ... ... second bessel computed');
      bess2 = besselApproximation(2, XsNus, k);
      disp( ' ... ... third bessel computed');

      nuHatStar = nuHatStar + Xs .* (bess1 ./ bess0) ...
	* weight;
      observedInformation = observedInformation + ...
	((Xs.^2) .* ((bess1.^2) - (bess0.*bess2)) ./ (bess0.^2)) ...
	* weight;

      disp('updated the score and observed information');

    end  %  This closes the loop through neighbors (i)
    

    precision = observedInformation.^(-1) ;
    disp(' ... precision computed ');
    nuHat = ((1 - precision) .* nuHat) + (precision .* nuHatStar);
    disp(' ... new estimate for nu computed ');
    
  end  %  This closes the loop through iterations


  %  This should give me an image nuHat.

  %  I still need to put nuHat into NIFTI format.
  %  I also need to multiply by sigma to get the actual nus.  Mine are adjusted
  %  and are really the lambda values.
  %  Both are those things are done here:
  disp('All data loaded and ready, now putting estimate of nuHat into NIFTI format ... ');
  newData = data;
  for i = 1:515

    sigma = sigmas(i);

    qx = intBvecs(i,1);
    qy = intBvecs(i,2);
    qz = intBvecs(i,3);

    if (qx <= 9 & qy <= 9 & qz <= 9)
      newData.img(2:10, 2:10, 2:10,i) = squeeze(nuHat(:,:,:,qx,qy,qz)) * sigma;
    end

  end


  %  This line is unnecessary.  What I want to do is to compute a CV error and report that.
  niiOutputName = ['~/data/mybrain/', outputName, '.nii'];
  save_nii(newData, niiOutputName);


  %  Now I want to compute my CV error.
  cvError = sum(sum(sum(sum((newData.img(2:10, 2:10, 2:10, :) - data.img(2:10, 2:10, 2:10, :)).^2))))/(9*9*9*515);
  squaredError = (newData.img(2:10, 2:10, 2:10, :) - data.img(2:10, 2:10, 2:10, :)).^2;
  resultsArray(parallelIndex, 3) = cvError;
  squaredErrorArray(parallelIndex, :, :, :, :) = squaredError;

  %  You should do this saving OUTSIDE the experiments loop.


  %  This ends the loop through N_experiments
end

save(outputName, 'resultsArray', 'weightsArray', 'squaredErrorArray');
done = 1;

end

