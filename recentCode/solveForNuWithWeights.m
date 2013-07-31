function [ nus ] = solveForNuWithWeights( X, sigma2s, weights, iter )
%Given a vector of image values (X) and the rician variances (sigma2s), 
%   this function will solve for the true amplitude nu.

initialNu = sum(weights .* X);

nu = initialNu;
nus = zeros(iter,1);

for i = 1:iter
    
    nus(i) = nu;
    
    xNuOverSigma2s = X .* nu ./ sigma2s;
    besselRatio = besseli(1, xNuOverSigma2s) ./ besseli(0, xNuOverSigma2s);
    gradient = (1./sigma2s).*(besselRatio .* X - nu);

    nu = nu + sum(gradient.*weights);

end

