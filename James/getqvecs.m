qlengths = btab(:,1);
qunitvecs = btab(:,2:4);

qvecs = zeros(length(qlengths),3);
for i = 1:length(qlengths)
    qvecs(i,1:3) = qlengths(i)/1000.*qunitvecs(i,:);
end
    
