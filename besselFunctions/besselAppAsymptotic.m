function [approximation] = besselAppAsymptotic(nu, x, K)

  e = exp(1);
  frontTerm = (e.^(x)) ./ ((2 * pi * x).^(1/2));

  approximation = ones(size(x));

  for i = 0:(K-1)
    %  This is the order of each term.
    k = K - i;
    Z = - ((2*(nu^2)) - (2*k - 1)^2) ./ (k*x*8);

    approximation = 1 + Z.*approximation;
   

  end

  approximation = frontTerm .* approximation;

end