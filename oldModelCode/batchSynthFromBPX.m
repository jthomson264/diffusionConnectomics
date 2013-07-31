function [ win ] = batchSynthFromBPX()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

datanii = synthImageFromBPX('', 'scan.3.bedpostX/', 3);

save_nii(datanii, 'groundTruth.3.nii');

win=1;

end

