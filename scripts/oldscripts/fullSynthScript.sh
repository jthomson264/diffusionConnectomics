#!/bin/bash

# Get all arguments including flags.
# Note: options must be input before arguments.
#
#
#  INPUTS to the script are:
#
#  arg1      -   the input file 
#  arg2      -   N, the number of bootstrapped samples to draw.  default=50
#  
#  OPTIONS to the script are
#

# Assume this is run from within the data folder, which will contain its own bpx folder.
N=$1

#matlab line for synth true image
matargs="'.','scan.bedpostx',2"
~/code/scripts/matlab_batcher.sh synthGroundTruthImage $matargs

# Now find the sigmas using the mask
matargs="'backgroundMask.nii','data.nii','sigmas'"
~/code/scripts/matlab_batcher.sh sigmaFromBackgroundMask $matargs

# Now generate some bootstrap draws
matargs="'data.nii',${N},'sigmas'"
~/code/scripts/matlab_batcher.sh synthNoisedImages $matargs


#  add the synthTruthImage command to the appropriate queue
#synthTruthImageCommand="synthTruthImage.sh $modelParametersDir ${originalImage}.truthImage"
#catorssh "$synthTruthImageCommand" $boss $synthTruthImage_server


#  add the move command for synthTruthImage -> synthNoisedImages
#moveTruthImageCommand="mvorscp ${originalImage}.truthImage $synthTruthImage_server '${synthNoisedImages_server} $synthNoisedImages_user"
#catorssh "$moveTruthImageCommand" $boss $synthTruthImage_server

#  add the command for finding sigma
#findSigmaCommand="findSigma.sh ${originalImage}.truthImage ${sval}"
#catorssh "$findSigmaCommand" $boss $synthNoisedImages_server

#  Add the synth image command to the synth image server
#synthNoisedImagesCommand="synthNoisedImages.sh ${originalImage}.truthImage $N ${originalImage}.sigma"
#catorssh "$synthNoisedImagesCommand" $boss $synthNoisedImages_server

#  Add the command to move all the synthed noised images to storage
#storageCommand="mvorscp ${originalImage}.synthedNoisedImages $synthNoisedImages_server ${storage_server}"
#catorssh "$storageCommand" $boss $synthNoisedImages_server
