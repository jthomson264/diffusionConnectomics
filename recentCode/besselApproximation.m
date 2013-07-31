%  Holder function that chooses b/w the power expansion and the asymptotic
%  approximation for bessel approximations.

function [approximation] = besselApproximation(nu, xs, k)

  greaterThanCutoff = xs > 4;
  if any(isnan(greaterThanCutoff))
      error('Hit NANs while thresholding for power v asymptotic approximation.');
  end
  
  %  I realize I'm doubling the number of approximations I need to do.
  %  I could loop through or do something sparse, but I don't want to now.
  powerApproximations = besselAppPower(nu, xs, k);
  asymptoticApproximations = besselAppAsymptotic(nu, xs, k);
  naInPower = any(isnan(powerApproximations));
  naInAsymptotic = any(isnan(asymptoticApproximations));
  if (naInPower || naInAsymptotic)
      if naInPower
          disp('Power approximation failed.');
      end
      if naInAsymptotic
          disp('Asymptotic approximation failed.');
      end
      error('Failed besselApproximation by hitting NAs.');
  end
  
  if any(isnan(powerApproximations))
      error('NAs found in powerApproximations.');
  end
  if any(isnan(asymptoticApproximations))
      error('NAs found in asymptoticApproximations.');
  end
  
  
  
  usePower = (1 - greaterThanCutoff);
  useAsymptotic = greaterThanCutoff * 1.0;
  if any(isnan(usePower))
      error('usePower has NAs.');
  end
  if any(isnan(useAsymptotic))
      error('useAsymptotic has NAs.');
  end
  powerComponents = powerApproximations .* usePower;
  asymptoticComponents = asymptoticApproximations .* useAsymptotic;
  if any(isnan(powerComponents))
      error('powerComponents contains NANs.');
  end
  if any(isnan(asymptoticComponents))
      disp('xs 1 through 20');
      xs(1:20)
      disp('asymptoticApproximations 1 through 20');
      asymptoticApproximations(1:20)
      disp('useAsymptotic 1 through 20');
      useAsymptotic(1:20)
      disp('asymptoticComponents 1 through 20');
      asymptoticComponents(1:20)
      error('asymptoticComponents contains NANs.');
  end
  
  approximation = powerComponents + asymptoticComponents;
  if any(isnan(approximation))
      error('approximation by summing powerCOmponents and asymptoticComponents contains NANs.');
  end
  
  %approximation = (greaterThanCutoff .* asymptoticApproximations) ...
  %    + ((1 - greaterThanCutoff) .* powerApproximations);
  %if any(isnan(approximation))
  %    disp('Size of greaterThanCutoff is ')
  %    size(greaterThanCutoff)
  %    disp('Size of powApp and asyApp is')
  %    size(asymptoticApproximations)
  %    size(powerApproximations)
  %    error('Got NAs while computing approximation in besselApproximation.');
  %end

end