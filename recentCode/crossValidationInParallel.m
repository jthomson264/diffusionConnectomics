%  This script runs a bunch of CV simulations in parallel.

nSimulations = 200;
results = zeros(nSimulations, 3);

parfor i=1:nSimulations
    spatialSigma = lognrnd(0,1/5);
    spectralSigma = lognrnd(0,1/8);
    cvProb = 1;
    kApproximations = 5;
    kFisherScoring = 2;
    
    results(i, :) = [spatialSigma, spectralSigma, ...
        getL2lossForCV(...
        'smalldata', ...
        spatialSigma, ...
        spectralSigma, ...
        cvProb, ...
        kApproximations, ...
        kFisherScoring)];
    
end
    