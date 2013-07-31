%   This function draws a vector from a von-mises fisher / kent
%   distribution.  It does so without using quaternions, by:
%       (A) chooseing z orthogonal to mu
%       (b) drawing a random angle distance appropriately (theta_1)
%       (c) rotating t from mu about z by theta_1
%       (d) choosing theta_2 completely randomly from 0 to 2Pi
%       (e) rotating t' from t about mu by theta_2
%
%   Now remember mu is the mean direction, kappa is the...  scale
%   parameter, so you can draw an arclength from an exponential
%   distribution and then move that length away to find a circle.  then
%   choose a random position on that circle.  This process is equivalent to
%   drawing from the kent.

function newDx = kent(mu, kappaPrime)



% Step (A) - choose z orthogonal to mu
%       get a random vector.
z = [randn(1); randn(1); randn(1)];
%       subtract its projection onto mu
z2 = z - (mu' * z)*mu;
%       make it a unit vector
z3 = z2 / sqrt((z2' * z2));

% step (B) - choose theta_1 
%   I use kappaPrime and draw from an exponential w/ parameter kappaPrime,
%       since I haven't yet related it to the exp. analytically.
%   KappaPrime here is the mu for an exponential.
D = exprnd(kappaPrime);
theta_1 = asin(D);

% Step (C) - Make t, which is mu rotated about z by theta_1
rotMat1 = rotMatAxisAngle(z3, theta_1);
t = rotMat1 * mu;

% Step (D) - choose theta_2 completely randomly.
theta_2 = unifrnd(0,2*pi);

% Step (E) - rotate t' from t about mu by theta_2
rotMat2 = rotMatAxisAngle(mu, theta_2);
tPrime = rotMat2*t;

newDx = tPrime;
newDx = real(newDx);
newDx = newDx / sqrt(newDx' * newDx);

end
