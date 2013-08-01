%  Quick function to test a single value for bessel apps.
function [done] = testB(nu, x, k)

  truebessel = besseli(nu, x)
  powB = besselAppPower(nu, x, k)
  assB = besselAppAsymptotic(nu, x, k)


end