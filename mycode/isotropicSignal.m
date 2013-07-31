function [ isoSignal ] = isotropicSignal( bvals, d, f )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

constants = exp(-bvals*d);
isoSignal = f*constants;


end

