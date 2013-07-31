function X = cellfcn_GetFiberEnd(xyz,end_start);

% Simpler function to get the fiber tips from xyz coordinate data

if end_start 
  X = xyz(1,:);
else
  X = xyz(end,:);
end;

