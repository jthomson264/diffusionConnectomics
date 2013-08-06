%   This script is going to test my function solveForIsotropic
%       1 - Get btable, sigmas, choose ADC
%       2 - Compute Nus
%       3 - Simulate the Xs
%       4 - Solve for ADC using solveForIsotropic

%   (1) - Get the btable, sigmas, ADC
load('btab');
getqvecs
global sigmas
global sigma2s
global bvalues
global Xs0


sigmas = load('sigmas');
sigmas = double(sigmas.sigmas);
sigma2s = sigmas.^2;
bvalues = (double(btab(1:515,1))/1000).^2;
L1 = 1.08;
L2 = .72
ADC = [L1,0,0;0,L2,0;0,0,L2];
S0 = 25;
nus = zeros(length(qvecs),1);
%   (2) - Compute the Nus
for i=1:length(qvecs)
    nus(i) = S0*exp(-qvecs(i,:) * ADC * qvecs(i,:)');

end
%   (3) - Simulate the Xs
Xs0 = zeros(515,3);
Xs0(1,:) = S0;
for j = 1:length(Xs0(1,:))
for i = 2:515
    Xs0(i,j) = rician(nus(i), sigmas(i));
end
end
clear i j
%   (4) - Solve for ADC usinf solveForIsotropic
%[ADC, ll, nus] = solveForIsotropic(btab, sigma2s, Xs, 25);