function [ smoothedData ] = smoothNii( dataFile, btabFile, spatialBandwidth, spectralBandwidth )
%This runs the smoother as implemented in getL2Loss



depth = 1;
maxIteration = 4;                       % Fisher Scoring Iterations
kApproximations = 4;                    %  Bessel function approximation iterations.
frequencySigma = spectralBandwidth;
spatialSigma = spatialBandwidth;



%  Mask is 0 if excluded, 1 if included.
mask = load_nii('~/data/mybrain/mask.nii');

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

%cvProb = cvProb;
%   1.  Load in the data.
cvProb = 1;
load(btabFile);
data = load_nii(dataFile);
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
%  This is because we're using the center for LOOCV.
%  weights(1,1,1,1,1,1) = 0;
weights = weights / sum(weights(1:numel(weights)));



linIndices = sub2ind([11,11,11,11,11,11], ...
    ix+1, iy+1, iz+1, iqx+1, iqy+1, iqz+1);

xis = double(pdd(linIndices));
nuHat = double(zeros(numberOfTestedDoxels,1));

nuHatStar = double(zeros(numberOfTestedDoxels, 1));
observedInformation = double(ones(numberOfTestedDoxels, 1));
xisNus = double(ones(numberOfTestedDoxels, 1));

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
                        w = weights(jx,jy,jz,jqx,jqy,jqz);
                        nuHat = nuHat + ((w*xis').^2) - 2*w^2;
                          
                    end
                end
            end
        end
    end
end

% We've now computed all the summed squared xis, less twice the rician
% variance.  The conventional appraoch's estimate is the maximum of the
% root of this sum and 0. 
nuHat = max(0,nuHat);
nuHat = sqrt(nuHat);

%  If the conventional approach's estimate is 0, this is the global minimum
%  of the loglikelihood.  See Sijbers 2002.  If this is the case, we avoid
%  doing any computations after this step.  This is important, as we will
%  later be dividing by Nu.
nuHatIsZero = nuHat == 0;
notZero = ~nuHatIsZero;


disp('Computed the sample means.');
if any(isnan(nuHat))
    error('While computing sample means to initialize nuHat, NAs were hit.');
end




%  Run those loops, but now w/in a loop where you iterate fisher scoring.
for fisherScoringIteration = 1:maxIteration
    
    disp('Entering new fisher scoring iteration...');
    
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
      %  Before I run this, I'm splitting the data.
      greaterThanThreshold = xisNus > 4;
      smallerThanThreshold = ~greaterThanThreshold;
      large = (greaterThanThreshold & notZero);
      small = (smallerThanThreshold & notZero);
      
      %  First do large inputs.
      ratioForLarges = asymptoticRatioApproximation(1, xisNus(large), kApproximations);
      % Using the recurrence relation for derivatives, we found we do not
      % need to compute the 2nd order bessel function.  We are now using a
      % different form for the observed information.
      %secondRatio = asymptoticRatioApproximation(1, xisNus(greaterThanThreshold), kApproximations);
      gammaLarge = xis(large)'.* ratioForLarges*w;  % I thought the score was different...
                                    %  The sigma is unnecessary as we're
                                    %  using xi and lambda rather than x
                                    %  and nu.  That's why that's off.  But
                                    %  where is the -nu/sigma2 term?  here,
                                    %  the - lambda..
      informationLarge = w*(-1 + xis(large)'.^2 - (gammaLarge ./ nuHat(large)) - gammaLarge.^2);

    
      %  Now do small inputs
      bessel0 = besselAppPower(0, xisNus(small), kApproximations);
      bessel1 = besselAppPower(1, xisNus(small), kApproximations);
      ratioForSmalls = bessel1 ./ bessel0;
      if (any(isnan(ratioForSmalls)))
          error('hit NAs on small inputs bessel ratio');
      end

      gammaSmalls = xis(small)' .* ratioForSmalls * w;
      informationSmalls = w*(-1 + xis(small)'.^2 - (gammaSmalls ./ nuHat(small)) - gammaSmalls.^2 );
      nuHatStar(large) = nuHatStar(large) + gammaLarge;
      nuHatStar(small) = nuHatStar(small) + gammaSmalls;
      observedInformation(large) = observedInformation(large) + informationLarge;
      observedInformation(small) = observedInformation(small) + informationSmalls;
      
      if (any(isnan(nuHatStar)))
          error('Hit an nan while computing the new nuHatStar');
      end
      
      if (any(isinf(nuHatStar)))
          error('Hit infinities computing new nuHatStar');
      end
      
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
    
    
    
    precision = observedInformation(large | small).^(-1);
  
    disp('Checking if we have produced any NAs...');
    if(any(isnan(precision)))
        error('nan on precision inversion');
    end
    if (any(isinf(precision)))
        error('hit infinities on precision inversion');
    end
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
    disp('No NAs computed.  updating Nu estimates for Fisher scoring iteration');
    
    nuHat(notZero) = (1 - precision).*nuHat(notZero) + precision.*nuHatStar(notZero);
    xisNus = nuHat .* xis';
    if(any(isnan(nuHat)))
        error('Got NANs on the new step forward in computing nuHat');
    end
    disp('Completed one step of fisher scoring ...');
end




linIndices = sub2ind([11,11,11,11,11,11], ix+1, iy+1, iz+1, iqx+1, iqy+1, iqz+1);
xis = pdd(linIndices);
squaredErrors = (xis' - nuHat).^2;

l2loss = sum(squaredErrors(1:numel(squaredErrors)))/numel(squaredErrors);

disp('Now looping through in order to change format of computed estimates...');


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
   %  pdd(:,:,:,qx, qy, qz) = double(data.img(:,:,:,i)) / double(sigma);
   %  pdd(:,:,:,oppqx, oppqy, oppqz) = double(data.img(:,:,:,i)) / double(sigma);
   
   data.img(:,:,:,i) = nuHat(:,:,:,qx, qy, qz);
   
end


end

