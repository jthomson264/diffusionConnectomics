function [ ratio ] = computePreciseBesselRatio( s, kApproximations )
%This is just to be used to do the actual computations to make the lookup
%table, which I will save.

%  8 Here seems absolutely ridiculous.  I don't think I'd ever really need
%  8.  But this is the precise version for a lookup table, and I'll only be
%  computing it once, so why not.
%kApproximations = 8;

%  I'll use different functions for different things here.  
cutoffJorts = 4;

greaterThanThreshold = s > cutoffJorts;
smallerThanThreshold = ~greaterThanThreshold;
      
%  First do large inputs.
ratio(greaterThanThreshold) = asymptoticRatioApproximation(1, s(greaterThanThreshold), kApproximations);
     
%  Then small inputs
bessel0 = besselAppPower(0, s(smallerThanThreshold), kApproximations);
bessel1 = besselAppPower(1, s(smallerThanThreshold), kApproximations);
ratio(smallerThanThreshold) = bessel1 ./ bessel0;


end

