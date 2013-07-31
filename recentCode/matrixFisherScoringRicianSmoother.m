%%  this script is going to do smoothing using gradient descent on matrices
%   for a general DSI image.

load('~/data/mybrain/btab');
data = load_nii('~/data/mybrain/smalldata.nii');

%   Prepare bvecs.
bvec = btab(:,2:4);
for i = 1:3
    bvec(:,i) = bvec(:,i) .* sqrt(btab(:,1));
end

intBvecs = [bvec; -bvec(2:515,:)];
intBvecs = intBvecs / max(max(intBvecs));

gridNumber = 5;
intBvecs = round(intBvecs*5) + 5 + 1;

%  Pull sigma2s
load('~/Desktop/code/hdft_tools/sigs.mat');



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
   paddedDoubledData(:,:,:,oppqx, oppqy, oppqz) = data.img(:,:,:,i) / sigma;
   
   disp('Added in one scan...');
    
end


%   Now I have my awesome huge giant array of doubled and zero-padded data.
%   Cool.  Time to do shit.

%   We're going to start with a very small window.  For the very simplest
%   first approach, I'm not even using gaussian gradient descent.  This
%   isn't even a 3x3x3 gaussian kernel spatially.  It's +/- one doxel in
%   each direction.


Xs = paddedDoubledData(2:(nx-1), 2:(ny-1), 2:(nz-1), 2:10, 2:10, 2:10);
nuHat = Xs;
%neighborXs = zeros(nx-2, ny-2, nz-2, 9, 9, 9);
%score = zeros(nx-2, ny-2, nz-2, 9, 9, 9);
nuHatStar = zeros(nx-2, ny-2, nz-2, 9,9,9);
observedInformation = zeros(nx-2, ny-2, nz -2, 9, 9, 9);

maxIter = 5;
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




while (iterations <= maxIter)
  iterations = iterations + 1;
  
  disp(['Beginning iteration ', iterations]);

  nuHatStar(:,:,:,:,:,:) = 0;
  observedInformation(:,:,:,:,:,:) = 1;

  disp('reset score and information');

  weights = 1/13;
  for i = 1:13

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

    bess0 = besseli(0, XsNus);
    disp( ' ... ... first bessel computed ');
    bess1 = besseli(1, XsNus);
    disp( ' ... ... second bessel computed');
    bess2 = besseli(2, XsNus);
    disp( ' ... ... third bessel computed');

    nuHatStar = nuHatStar + Xs .* (bess1 ./ bess0) ...
	* weights;
    observedInformation = observedInformation + ...
	((Xs.^2) .* ((bess1.^2) - (bess0.*bess1)) ./ (bess0.^2)) ...
	* weights;

    disp('updated the score and observed information');

    end
    
    precision = observedInformation.^(-1) ;
    disp(' ... precision computed ');
    nuHat = ((1 - precision) .* nuHat) + (precision .* nuHatStar);
    disp(' ... new estimate for nu computed ');

    

end


%  This should give me an image nuHat.

%  I still need to put nuHat into NIFTI format.


%  I also need to multiply by sigma to get the actual nus.  Mine are adjusted
%  and are really the lambda values.






