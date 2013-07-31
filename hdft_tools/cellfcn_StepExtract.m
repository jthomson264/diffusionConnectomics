function X = cellfcn_StepExtract(C,point,end_start);

% Small function to grab points at a particular streamline position from the
% fiber stucture C.  C is the same as tracks.fiber

if end_start 
  pos = length(C.points)-point;
else
  pos = point+1;
end;


try 
  X = C.points(pos,:);
catch
  X = NaN(1,3);
end;

