%  This is a test script to generate a bunch of small images using
%  smoothNii.m

start = cputime;

btab1 = load('~/data/mybrain/btab');
data1 = load_nii('~/data/mybrain/data.nii');

loaded = cputime;

sampleRange1.xRange = 20:38;
sampleRange1.yRange = 25:48;
sampleRange1.zRange = 38;
sampleRange1.qRange = [30, 150, 350, 420];

sampleRange2.xRange = 67;
sampleRange2.yRange = 50:75;
sampleRange2.zRange = 20:40;
sampleRange2.qRange = [30, 150, 350, 420];

spatialSigmas = sort(lognrnd(1/4, 3/5, 16, 1));
frequencySigmas = sort(lognrnd(0, 1, 16, 1));
bscalings = sort(lognrnd(-4, 2, 16, 1));

niiToSave = data1;
%bscaling1 = 1/62;
%spatialSigma1 = 1.2;
%frequencySigma1 = 1;

for spatialIndex = 1:16
    for frequencyIndex = 1:16
        for bscalingsIndex = 1:16
            
        spatialSigma = spatialSigmas(spatialIndex);
        frequencySigma = frequencySigmas(frequencyIndex);
        bscaling = bscalings(bscalingsIndex);
          
        disp(spatialSigma);
        disp(size(spatialSigma));
        disp(frequencySigma);
        disp(size(frequencySigma));
        disp(bscaling);
        disp(size(bscaling));

        smoothedImageSample1 = smoothNII(sampleRange1, ...
            data1, btab1, ...
            spatialSigma, frequencySigma, bscaling);

        
        smoothedImageSample2 = smoothNII(sampleRange2, ...
            data1, btab1, ...
            spatialSigma, frequencySigma, bscaling);
        
        niiName1 = ['~/data/smoothSamples/pane1.',spatialIndex,'.',frequencyIndex,'.',bscalingsIndex,'.nii'];
        niiToSave.img = smoothedImageSample1;
        save_nii(niiToSave, niiName1);

        niiName2 = ['~/data/smoothSamples/pane2.',spatialIndex,'.',frequencyIndex,'.',bscalingsIndex,'.nii'];
        niiToSave.img = smoothedImageSample2;
        save_nii(niiToSave, niiName2);
        
        end
    end
end


done = cputime;