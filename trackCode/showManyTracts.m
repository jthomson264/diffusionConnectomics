function allTracts = showManyTracts(N,P,angle)

tract1 = makeTract(N,P,angle, true, true);
tracts = tract1;
hold on;

for i = 1:100
    
   newTract = makeTract(N,P,angle, true, true);
   plot3(newTract(:,1), newTract(:,2), newTract(:,3));
   %tracts = [tract1 ; newTract];
    
    
end


%plot3(tracts(:,1), tracts(:,2), tracts(:,3));

allTracts = 1;


end