%  This script will do cross-validation squared error or loglikelihood 
%  for one set of metaparameterrs.
function l2loss = getL2lossForCV(fileName, spatialSigma, spectralSigma, ...
    cvProb, kApproximations, maxIteration)

depth = 1;
spatialSigma = spatialSigma;
frequencySigma = spectralSigma;
maxIteration = maxIteration;

%  An important feature of this script is how I access the neighboring
%  doxels.  I plan on getting every voxel I'm estimating nu-hat for into a
%  6xN array holding locations.  

%  Structure:
%   1.  Load in data.
%   2.  Rearrange data into a 6D array.
%   3.  Choose, from a limited band of that 6D array, to include or
%       exclude each doxel.
%   4.  Use the 6D array of inclusion/exclusion booleans to make a 6xN
%       array of the locations of each included (excluded) doxel.
%   5.  Loop through all neighboring voxels (6-deep for loop) to get 
%       sample mean, initial guess at nu-hat.
%   6.  For 1:max_iteration
%           loop through all neighboring voxels
%               update the score and the observed information
%           take a step scaled by precision
%   7.  Compute C-V error.
%

cvProb = cvProb;
%   1.  Load in the data.
load('~/data/mybrain/btab');
data = load_nii('~/data/mybrain/smalldata.nii');
load('~/Desktop/code/hdft_tools/sigs.mat');


%   2.  Reshape the data.
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
xGridDistance = xGridDistance / xGridDistance;
yGridDistance = yGridDistance / xGridDistance;
zGridDistance = zGridDistance / xGridDistance;
%  Don't need adjustment for frequency grid.  FFT forces dimensions to be
%  the same.
nx = data.hdr.dime.dim(2);
ny = data.hdr.dime.dim(3);
nz = data.hdr.dime.dim(4);
nqx = 11;
nqy = 11;
nqz = 11;

pdd = zeros(nx,ny,nz,11,11,11);
for i = 2:515    
   sigma = sigmas(i);

   qx = intBvecs(i,1);
   qy = intBvecs(i,2);
   qz = intBvecs(i,3);
   
   oppqx = intBvecs(i + 514, 1);
   oppqy = intBvecs(i + 514, 2);
   oppqz = intBvecs(i + 514, 3);
   
   %  pdd stands for padded doubled data.
   %  Wow.  I just spent 1-6 hours, depending on what you count, tracking
   %  down an error that turned out to be due to forcing the data to be
   %  singles.  My asymptotic bessel approximation returns Inf for singles,
   %  but is totally accurate for doubles.  
   pdd(:,:,:,qx, qy, qz) = double(data.img(:,:,:,i)) / double(sigma);
   pdd(:,:,:,oppqx, oppqy, oppqz) = double(data.img(:,:,:,i)) / double(sigma);
   
   %disp('Added in one scan...');    
end


%  3.  Choose inclusion/exclusion.
%includeExclude = binornd(1,cvProb, nx-2, ny-2, nz-2, nqx-2, nqy-2, nqz-2);
numberOfDoxels = (nx-2)*(ny-2)*(nz-2)*(nqy-2)*(nqx-2)*(nqz-2);
testedVoxels = randsample(1:numberOfDoxels, round(cvProb*numberOfDoxels), 0);
numberOfTestedDoxels = numel(testedVoxels);
[ix, iy, iz, iqx, iqy, iqz]  = ...
    ind2sub([nx-2, ny-2, nz-2, nqx-2, nqy-2, nqz-2],testedVoxels);
%  Note that all i* vectors are in the inner space, excluding borders.
%  So to get to doxel (3,4,5,6,7,8) you would need (4,5,6,7,8,9).

%  This is how I think we can get the x-neighbor to the left.
%testedVoxels = pdd(ix+1, otherstuff);
%rightXneighbor = pdd(ix+2, othersutt);  %done #yolo.  




%4.  Compute weights.  
%numberOfWeights = (1 + 2*depth)^6;
nv = 1 + 2*depth;
weights = zeros(nv,nv,nv,nv,nv,nv);
for jx = -depth:depth
    for jy = -depth:depth
        for jz = -depth:depth
            for jqx = -depth:depth
                for jqy = -depth:depth
                    for jqz = -depth:depth
                        spatialDistance = (jx*xGridDistance)^2 + ...
                            (jy*yGridDistance)^2 + (jz*zGridDistance)^2;
                        spectralDistance = jqx^2 + jqy^2 + jqz^2;
                        weights(jx+2,jy+2,jz+2,jqx+2,jqy+2,jqz+2) = ...
                            (2*pi*(spatialSigma*frequencySigma)^6)^(-1/2) * ...
                            exp((-1/2)*((spatialDistance / (spatialSigma^2)) + (spectralDistance / (frequencySigma^2))));
                    end
                end
            end
        end
    end
end
%  This is because we're using the center for CV.
weights(1,1,1,1,1,1) = 0;
weights = weights / sum(weights(1:numel(weights)));
%weights


%xis = pdd(2:(nx-1), 2:(ny-1), 2:(nz-1), 2:10, 2:10, 2:10);
%nuHat = zeros(nx-2, ny-2, nz-2, 9, 9, 9);
%nuHatStar = zeros(nx-2, ny-2, nz-2, 9, 9, 9);
%observedInformation = 
%  I can't access indices like this.  I'll need to go from sub2ind.
%numberOfTestedDoxels
%length(ix)
%size(pdd)

linIndices = sub2ind([11,11,11,11,11,11], ...
    ix+1, iy+1, iz+1, iqx+1, iqy+1, iqz+1);

xis = double(pdd(linIndices));
%xis(1:10)
nuHat = double(zeros(numberOfTestedDoxels,1));
%nuHat(1:10)
%bessel0 = double(nuHat);
%bessel1 = double(nuHat);
%bessel2 = double(nuHat);
nuHatStar = double(zeros(numberOfTestedDoxels, 1));
observedInformation = double(ones(numberOfTestedDoxels, 1));
xisNus = double(ones(numberOfTestedDoxels, 1));
%xisNus(1:10)

% 5  Start your loops.  Just to get sample mean.  
%weights = zeros(nv,nv,nv,nv,nv,nv);
for jx = 2+(-depth:depth)
    for jy = 2+(-depth:depth)
        for jz = 2+(-depth:depth)
            for jqx = 2+(-depth:depth)
                for jqy = 2+(-depth:depth)
                    for jqz = 2+(-depth:depth)
                        linInds = sub2ind([11,11,11,11,11,11], ...
                            ix +jx -1, ...
                            iy +jy -1, ...
                            iz + jz -1 , ...
                            iqx + jqx -1, ...
                            iqy + jqy -1, ...,
                            iqz + jqz -1);
                        xis = pdd(linInds);
                        %xis(1:10)
                        %length(xis)
                        %length(nuHat)
                        w = weights(jx,jy,jz,jqx,jqy,jqz);
                        %numel(w)
                        nuHat = nuHat + (w*xis');
                            % maybe:
                            %  sub2ind([nx-2, ..., ], jx,jy,...) is linear
                            %  index.  do that for all of them.  
                    end
                end
            end
        end
    end
end

disp('Computed the sample means.');
if any(isnan(nuHat))
    error('While computing sample means to initialize nuHat, NAs were hit.');
end




%  Run those loops, but now w/in a loop where you iterate fisher scoring.
for fisherScoringIteration = 1:maxIteration
    
    for jx = 2+(-depth:depth)
    for jy = 2+(-depth:depth)
    for jz = 2+(-depth:depth)
    for jqx = 2+(-depth:depth)
    for jqy = 2+(-depth:depth)
    for jqz = 2+(-depth:depth)
      linInds = sub2ind([11,11,11,11,11,11], ...
        ix +jx -1, ...
        iy +jy -1, ...
        iz + jz -1 , ...
        iqx + jqx -1, ...
        iqy + jqy -1, ...,
        iqz + jqz -1);
      xis = pdd(linInds);

      if any(isnan(xis))
          error('Just pulled xi values, some were NAN.');
      end
      
      w = weights(jx,jy,jz,jqx,jqy,jqz);
      if isnan(w)
          error('Pulled a weight, got a NAN');
      end
      
      
      xisNus = nuHat .* xis';
      xisNus = double(xisNus);
      if(any(isnan(xisNus)))
          error('error on nan from computing xi * nuHat');
      end
      
      %numel(xisNus)
      %%bessel0 = besselApproximation(0, xisNus, 5);
      %bessel1 = besselApproximation(1, xisNus, 5);
      %bessel2 = besselApproximation(2, xisNus, 5);
      %b0nan = any(isnan(bessel0));
      %b1nan = any(isnan(bessel1));
      %b2nan = any(isnan(bessel2));
      %if (b0nan || b1nan || b2nan)
      %    if b0nan
      %        disp('Got NAs in computation of 0th order bessel approximation.');
      %    end
      %    if b1nan
      %        disp('Got NAs in computation of 1st order bessel approximation.');
      %    end
      %    if b2nan
      %        disp('Got NAs in computation of 2nd order bessel approximation.');
      %    end
      %    error('NAs were hit in bessel function computations.');
      %end

      %  I'm deciding to stop computing bessel functions.
      %  I'm only going to compute them for the power approximations.
      
      %  Before I run this, I'm splitting the data.
      greaterThanThreshold = xisNus > 4;
      smallerThanThreshold = ~greaterThanThreshold;
      
      %  First do large inputs.
      firstRatio = asymptoticRatioApproximation(1, xisNus(greaterThanThreshold), kApproximations);
      secondRatio = asymptoticRatioApproximation(1, xisNus(greaterThanThreshold), kApproximations);
      largeInputScores = xis(greaterThanThreshold)'.*firstRatio*w;
      largeInputObservedInformation = (xis(greaterThanThreshold)'.^2).* ...
        (firstRatio.^2 - secondRatio)*2;
      
    
      %  Now do small inputs
      bessel0 = besselAppPower(0, xisNus(smallerThanThreshold), kApproximations);
      bessel1 = besselAppPower(1, xisNus(smallerThanThreshold), kApproximations);
      bessel2 = besselAppPower(2, xisNus(smallerThanThreshold), kApproximations);
      smallFirstRatio = bessel1 ./ bessel0;
      smallInputScores = xis(smallerThanThreshold)' .* (smallFirstRatio) * w;
      smallInputObservedInformation = (xis(smallerThanThreshold)'.^2).* ...
          (smallFirstRatio.^2 - (bessel2 ./ bessel0))*2;
      
      %firstRatio = ratioApproximation(1, xisNus, 5);
      %secondRatio = ratioApproximation(2, xisNus, 5);
      
      nuHatStar(greaterThanThreshold) = nuHatStar(greaterThanThreshold) + ...
          largeInputScores;
      nuHatStar(smallerThanThreshold) = nuHatStar(smallerThanThreshold) + ...
          smallInputScores;
      observedInformation(greaterThanThreshold) = ...
        observedInformation(greaterThanThreshold) + largeInputObservedInformation;
      observedInformation(smallerThanThreshold) = ...
          observedInformation(smallerThanThreshold) + smallInputObservedInformation;
      
%      nuHatStar = nuHatStar + xis'.*(firstRatio)*w;
      if (any(isnan(nuHatStar)))
          error('Hit an nan while computing the new nuHatStar');
      end
      
      if (any(isinf(nuHatStar)))
          error('Hit infinities computing new nuHatStar');
      end
      
%      observedInformation = observedInformation + ...
%        (xis'.^2) .* (firstRatio.^2 - secondRatio)*2;
      if(any(isnan(observedInformation)))
          error('error on nan in observed information');
      end
      if (any(isinf(observedInformation)))
          error('hit infinties computing new observedInformation.');
      end
      
    
    end
    end
    end
    end
    end
    end
    
    
    
    precision = observedInformation.^(-1);
    if(any(isnan(precision)))
        error('nan on precision inversion');
    end
    if (any(isinf(precision)))
        error('hit infinities on precision inversion');
    end
    
 %   precision(1:10)
    if(any(isnan(nuHat)))
        error('Some of nuHat are NAN');
    end
    if(any(isinf(nuHat)))
        error('Some of nuHat are Inf');
    end
    
    
    if (any(isnan(nuHatStar)))
        error('some of nuHatStar are NAN');
    end
    if (any(isinf(nuHatStar)))
        error('some of nuhatstar are inf');
    end
    
    
    nuHat = (1 - precision).*nuHat + precision.*nuHatStar;
    if(any(isnan(nuHat)))
        error('Got NANs on the new step forward in computing nuHat');
    end
    disp('Completed one step of fisher scoring ...');
  %  nuHat(1:10)
end




%  Now you have your estimates of Nu.
%  You can compute squared error or loglikelihood loss.
%  You should do both.
%  But remember you don't have to compute error across the entire 6D image.
%  You only need trueXis - nuHat.

%  This line is unnecessary.  What I want to do is to compute a CV error and report that.
%niiOutputName = ['~/data/mybrain/', outputName, '.nii'];
%save_nii(newData, niiOutputName);
%  You need to grab the code snippet where you load the nuHat values *
%  lambdas into newData.img.
%  disp('All data loaded and ready, now putting estimate of nuHat into NIFTI format ... ');
%  newData = data;
%  for i = 1:515%%
%
%    sigma = sigmas(i);%
%
%    qx = intBvecs(i,1);
%    qy = intBvecs(i,2);
%    qz = intBvecs(i,3);
%
%    if (qx <= 9 && qy <= 9 && qz <= 9)
%     newData.img(2:10, 2:10, 2:10,i) = squeeze(nuHat(:,:,:,qx,qy,qz)) * sigma;
%    end
%
%  end


%  Now I want to compute my CV error.
%cvError = sum(sum(sum(sum((newData.img(2:10, 2:10, 2:10, :) - data.img(2:10, 2:10, 2:10, :)).^2))))/(9*9*9*515);
%squaredError = (newData.img(2:10, 2:10, 2:10, :) - data.img(2:10, 2:10, 2:10, :)).^2;
%resultsArray(parallelIndex, 3) = cvError;
%squaredErrorArray(parallelIndex, :, :, :, :) = squaredError;

linIndices = sub2ind([11,11,11,11,11,11], ix+1, iy+1, iz+1, iqx+1, iqy+1, iqz+1);
xis = pdd(linIndices);
%  Note these are L2 errors for _ADJUSTED_ estimates.  xi and lambda, 
%  not x and nu.
squaredErrors = (xis' - nuHat).^2;
xisNus = nuHat .* xis';
%bessel1 = besselApproximation(1, xisNus, 5);
%bessel0 = besselApproximation(0, xisNus, 5);
%loglikelihood = log(xis') - (((xis'.^2) + (nuHat.^2))/2) + ...
%    (bessel1 ./ bessel0);

l2loss = sum(squaredErrors(1:numel(squaredErrors)))/numel(squaredErrors);
%llloss = sum(loglikelihood(1:numel(loglikelihood)))/numel(loglikelihood);
end
