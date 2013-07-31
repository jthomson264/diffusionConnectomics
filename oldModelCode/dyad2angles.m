function [ theta, phi ] = dyad2angles( dyad )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
theta = acos(dyad(3));

sintheta = sin(theta);
costheta = cos(theta);

sinphi = dyad(2)/sin(theta);
cosphi = dyad(1)/sin(theta);

phi = angle(cosphi + i*sinphi);


end

