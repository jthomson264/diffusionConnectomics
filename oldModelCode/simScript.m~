%%  This script generates fake data, fits bpx, and compares the fits.

imageOutputDir = '../bootstrapping/draw1.bedpostx/';
paramsOutputDir = '../bootstrapping/groundTruthParameters';

if (generateFakes(imageOutputDir, paramsOutputDir)==1)
    

! cp ../testbedpostx/nodif_brain_mask.nii ../fakeSynthedImages/
! cp ../testbedpostx/bvals ../fakeSynthedImages/
! cp ../testbedpostx/bvecs ../fakeSynthedImages/


! gunzip ../fakeSynthedImages.bedpostX/*.gz

end


fitDir = '../fakeSynthedImages.bedpostX/';

[angleDyad1, angleDyad2, angleTruth, diffF1, diffF2, mddiff] = confirmSimulation(fitDir, paramsOutputDir);

