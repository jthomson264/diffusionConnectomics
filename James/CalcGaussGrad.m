function [ GaussGrad ] = CalcGaussGrad( XSignal, NuCalc, sigma2s )
%CalcGaussGrad calculates the a vector of Gaussian gradients 515x1

GaussGrad = -((XSignal - NuCalc)./sigma2s).*NuCalc;
GaussGrad(1) = 0;

end

