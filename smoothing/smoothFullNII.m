function [ smoothedImageSample ] = smoothFullNII(data, btab, spatialSigma, frequencySigma, bscaling)
%  I want to use local likelihood to find locally ML parameters for rician
%  distributions for each S(q) including the base S(0) signals.
%
%  Before doing that, I'll just use straight local likelihood w/ gaussian
%  distribution assumptions (straight gaussian smoothing) using distances
%  computed w/ a euclidean distance on space and a quotient distance on the
%  diffusion wave vectors (since negative frequencies are identified).  
%
%  This is an unprincipalled hack, since I don't yet have a scientific
%  reason for choosing particular values for the sigmas, but I want to get
%  something done.





%  Speaking of unprincipalled hacks ....
%  METAPARAMETERS:
N_SPATIAL_WINDOW = 1;
%  This kinda works.  mean(sqrt(btab)) is 62.  It worked.  Shut up.
%bscaling = 1/62;
%frequencySigma = 1;
%spatialSigma = 1.2;
%  That worked alright once the bscaling was 1/62.
%  Ten seems fine.

%  This means I'll only compute ish for +/- one voxel spatially, for a
%  9x9x9 window.  Note that since the voxels are not cubes, at some point I
%  may want a window that does not have the same number of pixels in each
%  dimension.  I currently do not care and don't want to smooth that much
%  ever.



smoothedImageSample = zeros(96, 96, 50, 515);

%  This is gross, but I'm now going to straight up loop through all four
%  dimensions.  qvoxel by qvoxel.  I will compute xDistances/Similarities
%  and qSimilarities first, and then within the loop will grab
%  localImageValues and localQSimilarities.









%  The first things I'll need are pairwise spatial distances and pairwise
%  frequency distances.  I'll get the spatial distances first.
%  data.hdr.dime contains the dimensions of each pixel, in mm.
%  The vector here is [-1, xdim, ydim, zdim, ?, ?, ...]
dimensionSizes = data.hdr.dime.pixdim(2:4);
NqVectors = size(btab,1);




%  Now we'll get the diffusion wave vector distances.
%  This needs to be different from how we got spatial distances, since we
%  just get a btable with the actual positions.  We can also just store the
%  515x515 matrix, whereas I didn't want to go straight to making a
%  460800x460800 matrix, because that would be dumb.  And large. 

qDistances = zeros(size(btab,1));
% I'm gonna want the magnitude of the diffusion wave vectors, not the
% b-value, which is their square.
btab(:,1) = bscaling*sqrt(btab(:,1));

for qi = 1:size(btab,1)
   for qj = qi:size(btab,1)
       toPositive = btab(qi,2:4)*btab(qi,1) - btab(qj,2:4)*btab(qj,1);
       toNegative = btab(qi,2:4)*btab(qi,1) + btab(qj,2:4)*btab(qj,1);
       positiveDistance = toPositive*toPositive';
       negativeDistance = toNegative*toNegative';
       qiqjDistance = min(positiveDistance, negativeDistance);

       qDistances(qi, qj) = qiqjDistance;
       qDistances(qj, qi) = qiqjDistance;
   end
end


% Before I make the similarities, I'm going to want Distances.  Nah.
% There's no .. err... theoretical covariance b/w the diffusion wave vector
% ish and the spatial ish for smoothing purposes.  So I'll just tensor
% product them.
qSimilarities = (2*pi*frequencySigma^2)^(-1/2)*exp((-qDistances.^2)/(2*frequencySigma^2));

% Now forget the x stuff I did earlier.  I'm just going to start with a
% 9x9x9 window.
windowWidth = 1 + 2*N_SPATIAL_WINDOW;

localXDistances = zeros(windowWidth^3,1);

%  This is a temporary variable.
dSquared = 0;

xVectorIndex = 1;
for xi = -N_SPATIAL_WINDOW:N_SPATIAL_WINDOW
    for xj = -N_SPATIAL_WINDOW:N_SPATIAL_WINDOW
        for xk = -N_SPATIAL_WINDOW:N_SPATIAL_WINDOW
            
            dSquared = dSquared + (abs(xi)*dimensionSizes(1))^2;
            dSquared = dSquared + (abs(xj)*dimensionSizes(2))^2;
            dSquared = dSquared + (abs(xk)*dimensionSizes(3))^2;
            
            localXDistances(xVectorIndex) = dSquared;
            
            xVectorIndex = xVectorIndex + 1;
            dSquared = 0;
        end
    end
end




%  Now I have a vector, localXDistances, that I can turn into a similarity
%  vector.  I'll then multiply it w/ the qSimilarity vector to smooth over
%  both spaces.
localXSimilarities = (2*pi*spatialSigma^2)^(-1/2)*exp(-(localXDistances/(2*spatialSigma^2)));





%  Now I'll loop through my image range.
%  This is not production code.  So I'm doin trash like this.  I know the
%  dimensions.  Pleas forgive me, code-god.
qindex = 1;
for vq = 1:515
    xindex = 1;
    for vx = 1:96
        yindex = 1;
        for vy = 1:96
            zindex = 1;
            for vz = 1:50


localQSimilarities = qSimilarities(vq,:);

%qSimilarities = qSimilarities(1:numel(qSimilarities));
%qSimilarities = qSimilarities / sum(qSimilarities);
localQSimilarities = localQSimilarities / sum(localQSimilarities);
localXSimilarities = localXSimilarities / sum(localXSimilarities);


fullSimilarities = kron(localXSimilarities, localQSimilarities);

% Cool.  Now we've got what we need, and just need to, for every voxel,
% multiply the right matrix of image values against this matrix of
% similarities.  This is going to be very slow.  (Selecting all the voxels
% like I'm about to).


%localXValues = zeros(windowWidth^3,NqVectors);
xVectorIndex = 1;
allImageValuesForVoxel = zeros(windowWidth^3, NqVectors);
for xi = (vx - N_SPATIAL_WINDOW):(vx + N_SPATIAL_WINDOW)
    for xj = (vy - N_SPATIAL_WINDOW):(vy + N_SPATIAL_WINDOW)
        for xk = (vz - N_SPATIAL_WINDOW):(vz + N_SPATIAL_WINDOW)
              %  Fairly confident this will work.
            %localXDistances(xVectorIndex) = data.img(xi,xj,xk); 
            if (1 <= xi && xi <= 96) && (1 <= xj && xj <= 96) && (1 <= xk && xk <= 50)
                allImageValuesForVoxel(xVectorIndex, :) = data.img(xi, xj, xk, :);
            else
                allImageValuesForVoxel(xVectorIndex, :) = 0;
            end
            xVectorIndex = xVectorIndex + 1;
        end
    end
end


%  Instead, I could do:
%xRange = (vx - N_SPATIAL_WINDOW):(vx + N_SPATIAL_WINDOW);
%yRange = (vy - N_SPATIAL_WINDOW):(vy + N_SPATIAL_WINDOW);
%zRange = (vz - N_SPATIAL_WINDOW):(vz + N_SPATIAL_WINDOW);
%localXValues = data.img(xRange, yRange, zRange,:);


%  I now have, for one voxel, the 27x515 matrices fullSimilarities and
%  allImageValuesForVoxel.  I just need to matrix dot product them to get
%  my new, smoothed image value.
%disp('size of allImageValuesForVoxel is ');
%disp(size(allImageValuesForVoxel));
%disp('size of fullSimilarities is ');
%disp(size(fullSimilarities));
%disp('size of smoothedImageSample is ');
%disp(size(smoothedImageSample));

%  Ah.  Problem is I don't want to put it in vx, vy, vz, vq, I need to get
%  indices from 1 to Nx, etc...
smoothedImageSample(xindex, yindex, zindex, qindex) = sum(sum(allImageValuesForVoxel .* fullSimilarities));

            zindex = zindex + 1;
            end
        yindex = yindex + 1;
        end
    xindex = xindex + 1;
    end
qindex = qindex + 1;
end



end