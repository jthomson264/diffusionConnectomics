function [ value ] = LoglikelihoodHandle( xx,yy,zz,xy,xz,yz )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    D = [xx,xy,xz;xy,yy,yz;xz,yz,zz];
    value = GaussianLogLikelihood(X, Xs, qvecs, sigmas);



end

