%  This script is going to run through a few ranges for bessel functions
%  to compute which function gets the better approx.

xs = (1:5000)/10;
nus = 0:2;
K = 5;

powerResults = zeros(5000, 3);
asymptoticResults = zeros(5000, 3);

for i = 1:5000
  for j = 1:3
    trueBessel = besseli(j-1, i/10);
    powerBessel = besselAppPower(j-1, i/10, K);
    asymptoticBessel = besselAppAsymptotic(j-1, i/10, K);

    powerError = (trueBessel - powerBessel)^2;
    asymptoticError = (trueBessel - asymptoticBessel)^2;

    powerResults(i, j) = powerError;
    asymptoticResults(i, j) = asymptoticError;

  end
end
