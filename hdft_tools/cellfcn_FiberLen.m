function X = cellfcn_FiberLen(C);

% Small function to find the average length of fibers
% cell sturcture C
%         C is the same as tracks.fiber

% Note: Consider compiling this routine to save time

% Grab the fiber points
fiber = C.points;
X = sqrt(sum(sum(diff(fiber)).^2));

  
