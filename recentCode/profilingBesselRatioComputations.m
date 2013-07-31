%  This script is going to compare times for computing bessel function
%  ratios.

%profile on

% Initialize Xs
X = 0 : 0.001 : 500;

%  Use my own function
Ymycomputations4 = computePreciseBesselRatio(X, 4);
Ymycomputations8 = computePreciseBesselRatio(X, 8);

%  Use their function
Ymatlab = (besseli(1, X) ./ besseli(0, X));

%  Use a lookup table
Ylookup = fixpt_interp1(X, Ymatlab, X, sfix(8), 1, sfix(8), 1, 'Nearest');


smallerX = 500*randn(10000);
smallYmine = computePreciseBesselRatio(smallerX, 4);
smallYMats = (besseli(1, smallerX) ./ besseli(0, smallerX));
smallYsearch = fixpt_interp1(X, Ymatlab, smallerX, sfix(8), 1, sfix(8), 1, 'Nearest');

%profile off;