function [ smoothOnePane ] = smoothOnePaneWithSolver(  )

data = load_nii('~/data/mybrain/data.nii');
load('~/data/mybrain/btab');
ricianSigmas = load('~/data/p1s1/sigmas');

%   This is for the rician solver.
N_iter = 10;

disp('Loaded NII and Btable...');
%  Now I want to just pull code from smoothFull, but rather than looping
%  over 237 million voxels, I'll carefully loop over the voxels I care
%  about.

%  Speaking of unprincipalled hacks ....
%  METAPARAMETERS:
N_SPATIAL_WINDOW = 1;
%  This kinda works.  mean(sqrt(btab)) is 62.  It worked.  Shut up.
%bscaling = 1/62;  that's smoothPanes1.

bscaling = 1/20;

frequencySigma = 1/2;
spatialSigma = 1.2;
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
localXSimilarities = (2*pi*spatialSigma^2)^(-1/2)* ...
    exp(-(localXDistances/(2*spatialSigma^2)));
localXSimilarities = localXSimilarities / sum(localXSimilarities);




%  Now I'll loop through my image range.
%  This is not production code.  So I'm doin trash like this.  I know the
%  dimensions.  Pleas forgive me, code-god.

% Here's where I set my panes.  
Qvecs = [20, 120, 300, 420];
xPane = 48;
yPane = 43;
zPane = 12;

%  Each time, I need to assign vq, vx, vy, vz.

for qIndex = 3:4
    
    vq = Qvecs(qIndex);
    localQSimilarities = qSimilarities(vq,:);
    localQSimilarities = localQSimilarities / sum(localQSimilarities);
    
    
    fullSimilarities = kron(localXSimilarities, localQSimilarities);
    disp(size(fullSimilarities));
    
    % Do xPane
    vx = xPane;
    for vy = (1 + N_SPATIAL_WINDOW):(96 - N_SPATIAL_WINDOW)
        for vz = (1 + N_SPATIAL_WINDOW):(50 - N_SPATIAL_WINDOW)

            
            %  Get the pixel values for other things.
            vxRange = (vx - N_SPATIAL_WINDOW):(vx + N_SPATIAL_WINDOW);
            vyRange = (vy - N_SPATIAL_WINDOW):(vy + N_SPATIAL_WINDOW);
            vzRange = (vz - N_SPATIAL_WINDOW):(vz + N_SPATIAL_WINDOW);
            
            allImageValuesForVoxel = double(data.img(vxRange, vyRange, vzRange, :));
            allImageValuesForVoxel = ...
                reshape(allImageValuesForVoxel, windowWidth^3, 515);
            
            
            %smoothedImageSample(vx, vy, vz, vq) = ...
            %    sum(sum(fullSimilarities .* allImageValuesForVoxel));
            
            %  I need to change these lines here.  Rather than summing the
            %  product of fullSimilarities and imageValues, I need to send
            %  fullSimilarities (as weights) and the image values, along
            %  with a vector of rician Sigmas, to the function solveForNu.
            %  First I'll make a new solveForNu that can handle weights.
            %  Did it.  Now I need to ... Hrmmmm...  Get all that good
            %  sigma ish.  Aight.
            %   So the imageValues thing is windowWidth^3 by 515.  Maybe I
            %   should make the sigmas be windowWidth^3 by 515, w/ the same
            %   sigmas for each 1:windowWidth section.
            %       It's also reaaaaly dumb to do this like this, and I
            %       don't need to be passing around such a huge matrix, as
            %       I can generate it on demand, but whatever.  Memory is
            %       currently cheap.
            sigmas = zeros(size(allImageValuesForVoxel));
           
            for sigmaIndex = 1:515
                sigmas(:,sigmaIndex) = ricianSigmas.sigmas(sigmaIndex);
            end
            
            %   Now my function is ready, and I have all the sigmas I need.
            %   So I can make all my matrices vectors and throw them into
            %   solveForNuWithWeights
            allImageValuesForVoxel = allImageValuesForVoxel(1:numel(allImageValuesForVoxel));
            sigmas = sigmas(1:numel(sigmas));
            fullSimilarities = fullSimilarities(1:numel(fullSimilarities));
            nuVector = ...
                solveForNuWithWeights(allImageValuesForVoxel, sigmas.^2, fullSimilarities, N_iter);
            smoothedImageSample(vx, vy, vz, vq) = nuVector(N_iter);
            % Do ish.
        end
    end
    disp('... completed a lateral pane ...');
    
   
end

    %  This smoothes everything inside a windowed zone and doesn't touch
    %  the borders.
    
    %  It returns a NII that has been smoothed or untouched.
    
    smoothedData = data;
    smoothedData.img = smoothedImageSample;


end