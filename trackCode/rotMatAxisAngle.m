function Mat = rotMatAxisAngle( axisVector , angleTheta )

    
tensorProduct = kron(axisVector', axisVector);
crossProduct = [0, -axisVector(3), axisVector(2); axisVector(3), 0, -axisVector(1); -axisVector(2), axisVector(1), 0];

Mat = eye(3)*cos(angleTheta) + crossProduct*sin(angleTheta) + tensorProduct*(1-cos(angleTheta));

end