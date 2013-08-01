function [approximation] = besselApproximation(nu, x, K)

  %  This function uses the B_k approach of the next page. 
  frontTerm = ((x / 2).^(nu)) / (gamma(1 + nu));

  %  
  lastBk = ones(size(x));
  currentBk = ones(size(x));
  currentSum = ones(size(x));
  Z = zeros(size(x));

  for i = 1:K
    
    Z = (x/2).^2;
    Z = Z ./ (i*(i+nu));

    currentBk = Z .* lastBk;
    currentSum = currentSum + currentBk;
    lastBk = currentBk;

  end

  approximation = currentSum .* frontTerm;

end