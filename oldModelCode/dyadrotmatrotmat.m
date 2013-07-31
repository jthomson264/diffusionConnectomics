%   Find all the rotation matrices.

testR = [sinphi,   -cosphi,    zeros(96,96,50);
          cosphi.*costheta,  sinphi.*costheta, -sintheta;
          cosphi.*sintheta,  sinphi.*sintheta, costheta];
    