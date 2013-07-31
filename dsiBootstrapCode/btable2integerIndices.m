function [ indexingMatrix ] = btable2integerIndices( btable )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
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

indexingMatrix = bvecs;

end

