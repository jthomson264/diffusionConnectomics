function tract = makeTract(N,P,typicalAngle)


N = 100;
P = 0.5;


numberOfSteps = binornd(N,P);


x0 = [0;0;0];
x1 = [1;0;0];

dx1 = x1 - x0;
%previousDx = dx1;
%previousX = x1;



typicalAngle = pi/60;


dx = dx1;
x = x1;
tract = zeros(numberOfSteps+2, 3);
tract(1:2,:) = [x0' ; x1'];

for i = 1:numberOfSteps
    
   newDx = kent(dx, typicalAngle);
   newX = x + newDx;
   
   dx = newDx;
   x = newX;
   
   tract(i+2) = x';
    
    
    
end

end
