%  This is a script to test my power series expansion approximation of the modified 
%  bessel function of the first kind.

%  It's going to walk through orders 0, 1, 2, and then generate some ricians (with 
%  sigma forced at one, like my xi and lambda variables), and test how the real bessel
%  differs from my approximation for their product.


%  I'm going to store MSEs in a nu * approxOrder * amplitude table.

Nsim = 25;

results = zeros(2, 10, 10);

for nu = 0:2

  for approxOrder = 1:10

    for amplitude = 1:10

      riciansXi = ones(Nsim,1);
      riciansLambda = amplitude;

      for i = 1:Nsim
	riciansXi(i) = rician(amplitude, 1);
	riciansLambda = amplitude;
      end

      %  Now I have my xi and my lambda.
      x = riciansLambda * riciansXi;
    
      trueBessel = besseli(nu, x);
      apprBessel = besselApproximations(nu, x, approxOrder+2);
      squaredErrors = (trueBessel - apprBessel).^2;
      
      squaredError = mean(squaredErrors(1:numel(squaredErrors)));

      results((nu+1), approxOrder, amplitude) = squaredError;;
      disp(['Computed results for order ', nu, ' amplitude ', amplitude, ' and approximation order ', approxOrder]);
    end
    end

end