function [ contains ] = roiContainsPoint( tractPoint, roiPoints )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
sizeRoi = size(roiPoints.xyz);
N_Roi = sizeRoi(1);
clear sizeRoi;

tract_x = tractPoint(1);
tract_y = tractPoint(2);
tract_z = tractPoint(3);

contains = 0;

for i = 1:N_Roi
    % Pull a roipoint
    tmp_roiPoint = roiPoints.xyz(i,:);
        
    tmp_roiX = tmp_roiPoint(1);
    tmp_roiY = tmp_roiPoint(2);
    tmp_roiZ = tmp_roiPoint(3);
    
    if (tract_x <= tmp_roiX + 1) && (tract_x >= tmp_roiX)
       
        if (tract_y <= tmp_roiY + 1) && (tract_y >= tmp_roiY)
           
            if (tract_z <= tmp_roiZ + 1) && (tract_z >= tmp_roiZ)
               
                contains=1;
                
            end
            
        end
        
    end
    
    
end


end

