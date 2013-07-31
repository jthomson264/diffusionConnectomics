function [ tracts ] = addTractMatrix2TractStruct( tract, tracts )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

dimFibers = size(tracts.fiber);
numberOfFibers = dimFibers(2);

dimPoints = size(tract);
numberOfPoints = dimPoints(1);

%   Update the header.  This is the only change necessary.
tracts.header.n_count = tracts.header.n_count + 1;

%   Fill in the tract.
tracts.fiber{numberOfFibers+1}.num_points = numberOfPoints;
tracts.fiber{numberOfFibers+1}.points = tract;


end

