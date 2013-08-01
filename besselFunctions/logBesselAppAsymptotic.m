function [approximation] = logBesselAppAsymptotic(nu, x, K)

  %  This computes the log of the modified bessel function of the first kind
  % of order nu, using an asymptotic expansion of order k.

  e = exp(1);
  frontTerm = (e.^(x)) ./ ((2 * pi * x).^(1/2));

  firstTerm = x - (1/2).*log(2*pi*x);

  approximation = ones(size(x));

  for i = 0:(K-1)
    %  This is the order of each term.
    k = K - i;
    Z = - ((2*(nu^2)) - (2*k - 1)^2) ./ (k*x*8);

    approximation = 1 + Z.*approximation;
   
  end

  approximation = firstTerm + log(approximation);

end