function [ ADC, logLikelihood, Nus ] = solveIsotropic( btab, sigma2s, Xs, N_iter)
%   This function solves for the parameters of an isotropic DTI model using
%       DSI data and known rician sigmas.  It uses gradient descent, as
%       described in the pdf 'testsForAnisotropy'
%       
%       solveIsotropic is my 2nd attempt after doing some math better.


%   First reformat any data.
bvalues = double(btab(2:size(Xs,1),1));            %  I believe these are correct and I don't need to square them.
DWIvalues = double(Xs(2:size(Xs,1)));   %  Skip the first, which is the S0 signal.
DWIratios = DWIvalues ./ double(Xs(1));
sigma2s = double(sigma2s(2:size(Xs,1)));


%   Now initialize your guesses for c, ADC, and the vector of Nus.
%       The estimate for your Nus is completely determined by your C0 ADC0
%       and the input values.
ADC = mean(-log(DWIratios) ./ bvalues);
Nus = exp(-bvalues * ADC);

ADC

%   Now start gradient descenting.
for iter = 1:N_iter
    
   %    I first need to compute the gradient of the loglikelihood w/r/t nu
   %    and then the gradient of nu w/r/t the ADC.
   xNuOverSigma2s = DWIratios .* Nus ./ sigma2s;
   bNuOverSigma2s = bvalues .* Nus ./ sigma2s;
   besselRatios = besseli(1, xNuOverSigma2s) ./ besseli(0, xNuOverSigma2s);

   %dElldNu = (1./sigma2s) .* (-Nus + besselRatios.*DWIratios);
   %dNudADC = -bvalues .* Nus;
   
   %dElldADC = mean(dElldNu .* dNudADC);
   dElldADC = mean(bNuOverSigma2s .* (Nus - besselRatios.*DWIratios));
   
   dElldADC
   
   %    Now you can update everything.
   ADC = ADC + dElldADC;
   Nus = exp(-bvalues * ADC);
   ADC
   
    
    
end


%  Now I need to return ADC, logLikelihood, and Nus.  Nus and ADC are set,
%  so I just need to compute the logLikelihood.
logLikelihood = sum(log(DWIratios) - log(sigma2s) - ...
    ((DWIratios.^2 + Nus.^2)./(2.*sigma2s)) + ...
    log(besseli(0, DWIratios.* Nus ./ sigma2s)));

end

