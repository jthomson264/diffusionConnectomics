function [ signal ] = getSignal( dyad, f, d, bvals, bvecs )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

% Comput the dotproducts
qv_dotprod = dyad'*bvecs;
qv_dotprod2 = qv_dotprod.*qv_dotprod;

% Compute the exponential
quadform = bvals.*qv_dotprod2*d;
signal =  f*exp(-quadform);


end

