function tract = makeTract(N,P,typicalAngle, randomLocation, randomStart)


tolerance = 1e-10;

numberOfSteps = binornd(N,P);
disp(int2str(numberOfSteps));

%   This is taken straight from "p1s1"
dimensions = [96, 96, 50];
sizes = [2.4062, 2.4062, 2.4000];



x0 = [0;0;0];
x1 = [1;0;0];

if randomLocation

    x = unifrnd(0,sizes(1)*dimensions(1));
    y = unifrnd(0,sizes(2)*dimensions(2));
    z = unifrnd(0,sizes(3)*dimensions(3));
    
    x0 = [x, y, z];
end


if randomStart
    
    dx = unifrnd(-1,1);
    dy = unifrnd(-1,1);
    dz = unifrnd(-1,1);
    
    dx1 = [dx, dy, dz];
    dx1 = dx1 / sqrt(dx1 * dx1');
    
    if dx1 == [0, 0, 0]
        
        dx1 = [1, 0, 0];
    
    end
    
    x1 = x0 + dx1;
    
end


dx1 = x1 - x0;

dx = dx1;
x = x1;
tract = zeros(numberOfSteps+2, 3);
tract(1:2,:) = [x0 ; x1];

for i = 1:numberOfSteps
     
   newDx = kent(dx', typicalAngle);
   newDx = newDx';
   newDx = real(newDx);
   newX = x + newDx;
   
   dx = newDx;
   x = newX;
   
   tract(i+2,:) = x';
    
end

xN = tract(numberOfSteps+2,:);
%size(xN)
%size(x0)
%xN
%x0
straightDistance = xN - x0;
straightDistance = straightDistance(1)^2 + straightDistance(2)^2 +straightDistance(3)^2;
straightDistance = sqrt(straightDistance);

disp('The distance from the origin is ');
disp(straightDistance);

disp('The distance traveled is ');
disp((numberOfSteps+1));

end
