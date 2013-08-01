function [ approximation ] = asymptoticRatioApproximation(nu, xs, K)
%  This function computes the ratio of modified bessel functions of 
%  the first kind, of the I_nu / I_0 ratio.  

   denominator = ones(size(xs));
   numerator = ones(size(xs));
 
  for i = 0:(K-1)
    %  This is the order of each term.
    k = K - i;
    Znum = - ((4*(nu^2)) - (2*k - 1)^2) ./ (k*xs*8);
    Zden = ((2*k -1)^2) ./ (k*xs*8);
    
%    approximation = 1 + Z.*approximation;
    numerator = 1 + Znum.*numerator;
    denominator = 1 + Zden.*denominator;
    
  end

  approximation = numerator ./ denominator;
  
end

