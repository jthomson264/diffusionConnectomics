%   This script is going to test my function solveForIsotropic
%       1 - Get btable, sigmas, choose ADC
%       2 - Compute Nus
%       3 - Simulate the Xs
%       4 - Solve for ADC using solveForIsotropic

%   (1) - Get the btable, sigmas, ADC
load('~/data/mybrain/btab');
sigmas = load('~/data/p1s1/sigmas');
sigmas = double(sigmas.sigmas);
sigma2s = sigmas.^2;
bvalues = double(btab(2:515,1));
ADC = 1/400;


%   (2) - Compute the Nus
nus = exp(-bvalues * ADC);


%   (3) - Simulate the Xs
Xs = zeros(515,1);
Xs(1) = 1.0;
for i = 2:515
    Xs(i) = rician(nus(i), sigmas(i));
end


%   (4) - Solve for ADC usinf solveForIsotropic
[ADC, ll, nus] = solveForIsotropic(btab, sigma2s, Xs, 25);