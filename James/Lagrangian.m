%lambda, S (list of pixel values), qvecs list, sigmas2 list, and X(3x3)
%must be defined
%These are all established by "JTtestForIsotropic" and then "getQvecs"

dgdo = -2*lambda*((X(1,2)-X(2,1))*[0,1,0;-1,0,0;0,0,0] + (X(1,3)-X(3,1))*[0,0,1;0,0,0;-1,0,0] + (X(2,3)-X(3,2))*[0,0,0;0,0,1;0,-1,0])

v = S(i) * exp(-qvecs(i)*X*qvecs(i)')
dvdo = v*-qvecs(i)'*qvecs(i)
dLdo = - -v/sigmas2(i) * dvdo + besseli(S(i)*v/sigmas2(i))/bessel0(S(i)*v/sigmas2(i)) * S(i)/sigmas2 * dvdo

DDO = dLdo + dgdo