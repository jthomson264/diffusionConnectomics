%   Create the rotation matrices from dyads
%
%   internal function
function R = dyad2rotMat(dyad)

theta = acos(dyad(3));

sintheta = sin(theta);
costheta = cos(theta);

sinphi = dyad(2)/sin(theta);
cosphi = dyad(1)/sin(theta);

phi = angle(cosphi + i*sinphi);

R = [sinphi,   -cosphi,    0;
          cosphi*costheta,  sinphi*costheta, -sintheta;
          cosphi*sintheta,  sinphi*sintheta, costheta];
      
