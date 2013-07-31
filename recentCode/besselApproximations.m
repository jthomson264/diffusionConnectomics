function [approximation] = besselApproximation(order, x, approxOrder)

  %%  This function computes approximations of the modified bessel function of the
  %%  first kind.  The approximations are taken from
  %%  www.mhtlab.uwaterloo.ca/courses/me755/web_chap4.pdf
  %%


  %%  We use the power series expansion.  An asymptotic form is available that we eschew
  %%  becuase it requires large x.
  
  %firstTerm = (1 ./ gamma(1 + order)) .* ((x/2).^order);
  %secondTerm = zeros(size(x));

  approximation = ones(size(x));

%  approximation

  for i = 1:(approxOrder - 1)
   
    
 
    %  Start with the highest order Z term first.
    %  The approximation is firstTerm * (1 + Z1*(1 + Z2*(1 + Z3*(......))...)
    k = approxOrder - i;
    
%    disp(['The order term is ']);
%    k

    Zterm = ((x / 2).^2 ) ./ ((k*(k + order)));
    
    

    approximation = ones(size(x)) + approximation.*Zterm;



  end

%  disp('adding in gamma');
  %  Now add in the gamma function part. 
  approximation = approximation .* ((x/2).^order) ./ gamma(1 + order);

end
