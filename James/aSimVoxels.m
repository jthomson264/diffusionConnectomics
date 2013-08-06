load('btab');
getqvecs


sigmas = load('sigmas');
sigmas = double(sigmas.sigmas);
sigma2s = sigmas.^2;
bvalues = (double(btab(1:515,1))/1000).^2;

ellipsoidalTensor = [lambda1,0,0;0,lambda23,0;0,0,lambda23];

nus = zeros(length(qvecs),1);
%   (2) - Compute the Nus
for i=1:length(qvecs)
    nus(i) = S0*exp(-qvecs(i,:) * ellipsoidalTensor * qvecs(i,:)');

end
%   (3) - Simulate the Xs
Xs0 = zeros(515,numVoxels);
Xs0(1,:) = S0;
for j = 1:numVoxels
for i = 2:515
    Xs0(i,j) = rician(nus(i), sigmas(i));
end
end
clear i j
%   (4) - Solve for ADC usinf solveForIsotropic
%[ADC, ll, nus] = solveForIsotropic(btab, sigma2s, Xs, 25);

