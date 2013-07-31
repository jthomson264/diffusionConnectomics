%  This will have a time go through power and asymptotic approximations.  
%  I want to check if looping and using an if statement dramatically
%  slows down computation.


%x = 3*ones(10000,30);
%x(:,15:30) = 5;

x = normrnd(4,1,1000,20);

disp('Starting loop through stuff');

%for i = 1:numel(x)
%  if x(i) < 4
%    y(i) = besselAppPower(0, x(i), 5);
%  else
%    y(i) = besselAppAsymptotic(0, x(i), 5);
%  end
%end

disp('done.')


disp('starting matrix comp');

powApps = besselAppPower(0, x, 5);
assApps = besselAppAsymptotic(0, x, 5);
big = x > 4;
appr = (big.*assApps) + ((1-big).*powApps);

disp('done.');