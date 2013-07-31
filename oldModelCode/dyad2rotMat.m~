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


%   This rotation matrix takes you from z+ to (theta,phi)
%   We need one going from x+ to (theta, phi)
%   What is it that goes x+ to z+?
%   we have R' z = v1
x2z = [0, 0, 0; 0, 0, 0; 1, 0, 0];
R1 = [sinphi,   -cosphi,    0;
          cosphi*costheta,  sinphi*costheta, -sintheta;
          cosphi*sintheta,  sinphi*sintheta, costheta];
R = R1'*x2z;
      
      
      
      
      
