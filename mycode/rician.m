function [ R ] = rician( A, sigma )
%Returns a vector of rician noise using A and sigma.

A = double(A);
sigma = double(sigma);

n = length(A);

% First draw from a poisson distribution with parameter
%   lambda = A^2 / 2 Sigma^2
lambda = (A.^2) / (2 * sigma^2);
P = poissrnd(lambda, n, 1);

% Now draw from a chi-squared distribution with 2P + 2 
% degrees of freedom.

x = chi2rnd((2*P + 2), n, 1);

% Set R to sigma * sqrt(x) and the result is a rician (rice) r.v. with the
% desired parameters.

R = sigma * sqrt(x);

end

