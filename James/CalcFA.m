function [ FA ] = CalcFA( eigVals )
%Passed in Eigenvals, Calculates Fractional Anisotropy

FA = (1/2)^.5 * ( ((eigVals(1)-eigVals(2))^2 + (eigVals(2)-eigVals(3))^2 + (eigVals(1)-eigVals(3))^2)^.5 ) / ( (eigVals(1)^2 + eigVals(2)^2 + eigVals(3)^2)^.5);


end

