function [ diffusionPDF ] = DSI( DWI, btable, smoothDWI )
%   This function computes the DSI reconstruction of the
%       PDF using
%           DWI        - Diffusion-weighted Image Data
%           btable     - the btable

%   First create the integer locations of the diffusion wave vectors,
%   to be used as indices in an array on which we compute the
%   Fourier transform.
%   Pull out just the vectors from the btable.
bvecs = btable(:,2:4);
%   Now multiply each dimension by the root of the b-value, so the vectors
%   are aligned in space correctly.
bvecs(:,1) = sqrt(btable(:,1)) .* bvecs(:,1);
bvecs(:,2) = sqrt(btable(:,1)) .* bvecs(:,2);
bvecs(:,3) = sqrt(btable(:,1)) .* bvecs(:,3);
%   We now want the bvecs to give us integer indices
bvecs = bvecs / max(max(bvecs));
%   Note the arbitrary five.  You need to find the appropriate number for
%   your DSI scan parameters.  Look at size(round(unique(bvecs*x))) and you
%   should have the size be 2x+1 for a DSI grid.
gridNumber = 5;
bvecs = round(bvecs*gridNumber) + gridNumber + 1;
dimNumber = 2*gridNumber + 1;

%   Now I'll make the gaussian blur filter to apply for smoothing.
%   It depends on the distance b/w q-vecs.
numQs = size(btable,1);
qvecDistances = zeros(numQs, numQs);
for i = 1:numQs
    for j = 1:numQs
            %   Compute square distances.
            qvecDistances(i,j) = (sum( (bvecs(i,:) - bvecs(j,:)).^2 ));
    end
end
%   This is ... arbitrary.  But I know the typical distance will be around
%   2ish right now, as I've set the grid to be integers.  So this can't be
%   toooo off.
blurKernelSigma = 2;
%   These distances are already squared.
BlurMatrix = exp(-qvecDistances/(2*blurKernelSigma^2));
for i = 1:numQs
    BlurMatrix(i,:) = BlurMatrix(i,:) ./ sum(BlurMatrix(i,:));
end


%   You could implement tensor mult here if you want to be slick.
%if smoothDWI
%    DWI = single(DWI) * BlurMatrix;
%end


% To value sq
%   I am about to do a bad thing, which is loop through
%   the non-qvector dimensions of the image.  I am sorry.

imageX = size(DWI, 1);
imageY = size(DWI, 2);
imageZ = size(DWI, 3);
imageQ = size(DWI, 4);

if [imageQ ~= size(btable, 1)]
    disp('Your btable and DWI set do not match.');
end

%   Now allocating a nuffing ginormous bunt of an array.
diffusionPDF = zeros(imageX, imageY, imageZ, dimNumber, dimNumber, dimNumber);


%   So sorry.
for ix = 1:imageX
    for iy = 1:imageY
        for iz = 1:imageZ
            sq=zeros(dimNumber, dimNumber, dimNumber);
            currentVoxelImage = squeeze(DWI(ix,iy,iz,:));
            if smoothDWI
                currentVoxelImage = BlurMatrix * double(currentVoxelImage);
            end
            for iq=1:imageQ
                sq(bvecs(iq,1),bvecs(iq,2),bvecs(iq,3))=currentVoxelImage(iq);
            end

            diffusionPDF(ix, iy, iz, :, :, :) = fftshift(abs(real(fftn(fftshift(sq),[dimNumber,dimNumber,dimNumber]))));
        end
    end
end


end

