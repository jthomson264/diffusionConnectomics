function [ RiceGrad ] = CalcRiceGrad( XSignal, NuCalc, sigma2s )
%Calcs Rician Gradient given Nus, Xs, and Sigmas
    RiceGrad =  -(( -NuCalc + ((besseli(1, XSignal.*NuCalc./sigma2s )./besseli(0, XSignal.*NuCalce./sigma2s )) .*XSignal) )./sigma2s ).* NuCalc;
    RiceGrad(1) = 0;

end

