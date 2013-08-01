%   This is a second take on testSolveForIsotropic
%   I'm not going to bother at all with the real bvalues or the real
%   sigmas.  It will be entirely simulated just to make sure my function
%   does what I think it should.

%   It will be like multiple shell data.
signalToNoise = 2;
typicalNu = 5;
ADC = 1;
bvalue1 = -log(typicalNu) / ADC;

%   I have no idea what these will be, I just know they'll be positive.
%   I'm going to get a spread using exponential w/ 
otherBvalues = exprnd(bvalue1, 10, 1);
allBvalues = [bvalue1;  otherBvalues];


%   For each bvalue I'll take N observations.
N = 20;
allBValuesForXs = repmat(allBvalues, N, 1);

%   Now I have all the bvalues I need.  
Nus = exp(-allBValuesForXs * ADC);
sigmas = Nus / signalToNoise;
sigma2s = sigmas.^2;

Xs = zeros(11*N, 1);
for i = 1:(11*N)
    Xs(i) = rician(Nus(i), sigmas(i));
end

%   I just need to generate a dummy btable.
%   Now I have everything I need.
[ADC, ll, nus] = solveIsotropicWithBvals(allBValuesForXs, sigma2s, Xs, 25);

disp(['Real ADC is ', ADC]);
