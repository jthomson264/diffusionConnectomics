function [ finished ] = synthNoisedImagesDSI(prefix, N_images)
%This function synthesizes N_images sets of DICOMs (or .niis) 
%   using truthImageFile as A and Sigma as the sigmas for each bval
%   when generating rician noise.  

truthImageFile=['~/data/', prefix, '/dsiTruth.nii'];
sigmaFile = ['~/data/', prefix, '/sigmas.mat'];
bfile = ['~/data/', prefix, '/btab'];

truth = load_nii(truthImageFile);
tmpImage = truth.img;

sigmas = load(sigmaFile);
sigmas = sigmas.sigmas;

btab = load(bfile);


for image_index = 1:N_images

    % Make the first image and write it to file.
    
    % The fourth index is the bval.
    % Noise every bval according to the sigma.
    
    dimImageSet = size(truth.img);
    N_qvecs = dimImageSet(4);
    
    for b_index = 2:N_qvecs
        
        prmessage = ['b index is ', int2str(b_index)];
        disp(prmessage);
        % Start at 2 so as to not noise S0
        b_img = squeeze(truth.img(:,:,:,b_index));
        inds = 1:(numel(b_img));
        
        sigma = sigmas(b_index);
        noised_b_img = rician(b_img(inds)',sigma);
        noised_b_img = reshape(noised_b_img, size(b_img));
        
        tmpImage(:,:,:,b_index) = noised_b_img;
        
        
        
    end
    
    % Having just created a fully noised .nii, write it to file.
    fileName = ['~/data/', prefix, '/DSIdraw', int2str(image_index), '.nii'];
    niiToWrite = truth;
    niiToWrite.img = tmpImage;
    save_nii(niiToWrite, fileName);
    
    
    % Now it's time to make the src file.
    writeSourceFromNii(niiToWrite, btab, prefix, image_index, 'r_draws')
    
    removeNiiCommand = ['rm ', fileName];
    system(removeNiiCommand);
    
    srcName = ['~/data/', prefix, '/DSIdraw', int2str(image_index), '.src'];
    run_src_2_bwm_command = ['. ~/code/scripts/src2bwm.sh ', srcName];
    system(run_src_2_bwm_command);
    
    
    
end




finished=1;
    
end

