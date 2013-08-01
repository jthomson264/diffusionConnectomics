%   This script tests my solveForNu script.

%   First just do it a million times.
N = 100;
M = 100;
iter = 100;
realNu = 10;
realNus = realNu*ones(N,1);
sigma2s = 2*realNus;       % #supbro
sigmas = sqrt(2*realNus);

sigma2 = 2*realNu;
sigma = sqrt(2*realNu);

solvedNus = zeros(M,iter);

for i = 1:M
    Xs = rician(realNus, sigma);
    solvedNus(i,:) = solveForNu(Xs, sigma2s, iter);
end
