function noReturns = showATract(angle)



tract = makeTract(1000,0.5,angle);
plot3(tract(:,1), tract(:,2), tract(:,3));


%disp('Length is');
%disp(size(tract));
noReturns = 1;


end