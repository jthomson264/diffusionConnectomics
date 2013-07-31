function X = cellfcn_FiberSort(C,sortdim)

% Small function for sorting the fiber order

% Function to find the fiber points that intersect with an ROI
if C.points(1,sortdim) < C.points(end,sortdim);
        X.points = flipdim(C.points,1);
else
    X.points = C.points;
end;

% Save the other field too
X.num_points = C.num_points;