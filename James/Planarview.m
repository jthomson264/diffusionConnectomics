
newMat = zeros(50,96);

%b0 is 96,96,50
b0=img(:,:,:,1);
for x=1:96
    for z=1:50
        newMat(51-z,x) = mean(b0(x,:,z));
    end
    
    
end

imagesc(newMat)