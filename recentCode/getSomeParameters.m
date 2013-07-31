%   This script will get me some reasonmable parameters for the
%   createDWIfromTracts stuff.

data = load_nii('~/data/mybrain/data.nii');
load('~/data/mybrain/btab');
bvals = btab(:,1);
brain = double(data.img);

for qIndex = 2:515
    brain(:,:,:,qIndex) = brain(:,:,:,qIndex) ./ brain(:,:,:,1);
end

%   Now I have all my E = s(q)/s(0)s.  I want to know y = c*exp(bd) using
%   bvals.

%   Let's exclude non-brain regions.
brain = brain(30:50,30:50,20:40,:);
logBrain = log(brain);

%  Now logBrain should be lb = log(c) -bval*ADC.  I just need to fit a
%  linear model.  To do this I should get all my data in one vector.  I
%  just need to repeat the bvals appropriately.
numberOfVoxels = numel(brain)/size(brain,4);
%   Gross I'll just do this manually.
allBValues = zeros(numberOfVoxels,1);


allValues = logBrain(1:numel(logBrain));
sampleMean = mean(allValues);
for i = 1:515
    startIndex = 1 + (i-1)*numberOfVoxels;
    endIndex = i*numberOfVoxels;
    allBValues(startIndex:endIndex) = bvals(i);
end
