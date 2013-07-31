function [ logLikelihood ] = tractLogLikelihood( tract, kappa, N, P)
%   For a binomial length, VMF curvature tract, evaluate the likelihood.
%       tract should be an Nx3 matrix of xyz points.

numberOfPoints = size(tract,1);
numberOfLines = numberOfPoints - 1;
numberOfAngles = numberOfLines - 1;

lengthLogLikelihood = log(binopdf(numberOfPoints,N,P));

tractDxs = tract(2:numberOfPoints,:) - tract(1:numberOfPoints-1,:);
sumOfDotProducts = trace(tractDxs(1:numberOfLines-1) * tractDxs(2:numberOfLines)');

angleComponent = kappa * sumOfDotProducts;
normalizationComponent = numberOfAngles * (log(kappa) - log(2*pi) - log(exp(kappa) - exp(-kappa)));

curvatureLogLikelihood = angleComponent + normalizationComponent;

logLikelihood = curvatureLogLikelihood + lengthLogLikelihood;


end

