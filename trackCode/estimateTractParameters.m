function [ thetaMean, Nmean] = estimateTractParameters( tracts )
%   Takes a tracts struct (courtesty of Tim, Sudhir, LRDC people)
%       and returns an estimate of the curvature and length parameters

%   Here theta is the typical angle, N and P are binomial parameters.

numberOfFibers = size(tracts.fiber);
numberOfFibers = numberOfFibers(2);
numberOfPoints = 0;
sumOfAbsThetas = 0;

%averageCurvatures = zeros(numberOfFibers,1);

for i=1:numberOfFibers
   
   pointsInThisFiber = tracts.fiber{i}.num_points;
   numberOfPoints = numberOfPoints + pointsInThisFiber;
   
   firstPoint = tracts.fiber{i}.points(1,:);
   secondPoint = tracts.fiber{i}.points(2,:);
   thirdPoint = tracts.fiber{i}.points(3,:);   
   
   for j = 3:(pointsInThisFiber-1)
       

       firstVector = secondPoint - firstPoint;
       secondVector = thirdPoint - secondPoint;
       
       theta = acos(firstVector * secondVector');
       sumOfAbsThetas = sumOfAbsThetas + abs(theta);
       
       firstPoint = secondPoint;
       secondPoint = thirdPoint;
       thirdPoint = tracts.fiber{i}.points((j+1),:);
       
       
   end
   
    
end


averageNumberOfPoints = numberOfPoints / numberOfFibers;

numberOfAngles = numberOfPoints - 2*numberOfFibers;
averageAbsAngle = sumOfAbsThetas / numberOfAngles;

thetaMean = averageAbsAngle;
Nmean = averageNumberOfPoints;

end

