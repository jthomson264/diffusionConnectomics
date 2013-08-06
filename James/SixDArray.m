%Makes a 6d array

%cvProb = cvProb;
%   1.  Load in the data.
%load('~/data/mybrain/btab');
%data = load_nii('~/data/mybrain/smalldata.nii');
%load('~/Desktop/code/hdft_tools/sigs.mat');
load('btab');
data = load_nii('data.nii');
load('sigs.mat');
%reduce the size of the data
newImg = data.img(40:50,40:50,20:30,:);
data.img = newImg;

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
nx = 11 %data.hdr.dime.dim(2);
ny = 11 %data.hdr.dime.dim(3);
nz = 11 %data.hdr.dime.dim(4);
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
