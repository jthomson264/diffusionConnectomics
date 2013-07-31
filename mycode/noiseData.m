function [ noisedData ] = noiseData( datafile, sigma )
%noiseData 
%   This function takes in a NIFTI, data, and a row vector of sigmas,
%   sigma.  It noises the image data with the rician distribution using the
%   parameters A = data(x,y,z,i) and sigma = sigma(i).

data = load_nii(datafile);

end

