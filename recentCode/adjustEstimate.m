%  Pull in the estimate.
load('~/data/mybrain/nuHatUnadjusted');

%  Pull in the smallNII that you're going to change.
data = load_nii('~/data/mybrain/smalldata.nii');
nx = data.hdr.dime.dim(2);
ny = data.hdr.dime.dim(3);
nz = data.hdr.dime.dim(4);

%  Pull in bvalues and make the btable stuff.
load('~/data/mybrain/btab');
bvec = btab(:,2:4);

for i = 1:3
  bvec(:,i) = bvec(:,i) .* sqrt(btab(:,1));
end

intBvecs = [bvec; -bvec(2:515,:)];
intBvecs = intBvecs / max(max(intBvecs));

gridNumber = 5;
intBvecs = round(intBvecs*5) + 5 + 1;

%  Pull the sigma2s;
load('~/Desktop/code/hdft_tools/sigs.mat');


disp('Loaded in and prepped all data, beginning to add in scans...');

disp(size(data.img));
disp(size(nuHat));
%  Note: it stopped after printing up to 252 last time.


%  Now loop through q vectors and replace the data in data.img.
for i = 1:515

  sigma = sigmas(i);

  qx = intBvecs(i,1);
  qy = intBvecs(i,2);
  qz = intBvecs(i,3);


%  disp(i);

  %  I just need to check that the nuHat referenced was actually estimated.
  %  Remember I'm skipping the most extreme ones.
  if (qx <= 9 & qy <= 9 & qz <= 9)
    data.img(2:10,2:10,2:10,i) = squeeze(nuHat(:,:,:,qx, qy, qz)) * sigma;
  end


end

save_nii(data, '~/data/mybrain/smallNuHats.nii');
