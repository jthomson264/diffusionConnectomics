#!/bin/bash

# Get all arguments including flags.
# Note: options must be input before arguments.
#
#
#  INPUTS to the script are:
#
#  arg1      -   the input file 
#  arg2      -   N, the number of bootstrapped samples to draw.  default=50
#  arg3      -   method, the method to use for fitting the model. default=bedpostx
#  
#  OPTIONS to the script are
#
#  -s [f m a]    -  how to choose the sigma for the rician error.  
#                      * f:  fixed, using _____  (paper)
#                      * m:  mask, fitting the sigma on a mask showing a large area
#                            of non-skull, non-tissue space for each qvector.
#                      * a:  all, estimating sigma for each qvector by assuming the
#                            model's expectation is the true A at each voxel
#
#  -a ["arguments"]  - arguments to the method for fitting the model.
#                      For example: -a "-f 3 -b 5000", to set #fibers=3 and 
#                                   #burnins to 5000 for bedpostx.  
#

#this sets who is the job scheduler.  It is important for catorscp and mvorscp
boss=me

sflag=
aflag=
while getopts 's:a:' OPTION
do
    case $OPTION in
	s)    sflag=1
	    sval="$OPTARG"
	    ;;
	a)    aflag=1
	    aval="$OPTARG"
	    ;;
	?)  printf "Usage: %s: [-s sigmMethod] [-a fitModel arguments] args\n" $(basename $0) >&2
	    exit 2
	    ;;
    esac
done
shift $(($OPTIND - 1))


originalImage=$1
N=$2
method=${3:-"bedpostx"}

printf "Running bootstrap on  $originalImage \n"
printf " using method $method \n"
printf " $N  times. \n"
if [ "$sflag" ] 
then
    printf "For sigma method, using  $sval \n "
fi

if [ "$aflag" ]
then
    printf "Running fit with arguments  $aval \n "
fi


printf "The server for fitModel is $fitModel_server \n "
printf "find sigma server is $findSigma_server \n \n \n "

#  Pull the image, if necessary
moveImageCommand="mvorscp $originalImage $boss ${fitModel_server}" 
echo $moveImageCommand >> queue.txt

#  add the fitmodel command to the appropriate queue
fitModelCommand="$method $originalImage ${aval}"
catorssh "$fitModelCommand" $boss $fitModel_server

#  add the move command for fitModel -> synthTrueImage
if [ $method == "bedpostx" ]
    then modelParametersDir="${originalImage}.bedpostX"
fi

moveParametersCommand="mvorscp $modelParametersDir $fitModel_server $synthTruthImage_server $synthTrueImage_user"
catorssh "$moveParametersCommand" $boss $fitModel_server

#  add the synthTruthImage command to the appropriate queue
synthTruthImageCommand="synthTruthImage.sh $modelParametersDir ${originalImage}.truthImage"
catorssh "$synthTruthImageCommand" $boss $synthTruthImage_server


#  add the move command for synthTruthImage -> synthNoisedImages
moveTruthImageCommand="mvorscp ${originalImage}.truthImage $synthTruthImage_server '${synthNoisedImages_server} $synthNoisedImages_user"
catorssh "$moveTruthImageCommand" $boss $synthTruthImage_server

#  add the command for finding sigma
findSigmaCommand="findSigma.sh ${originalImage}.truthImage ${sval}"
catorssh "$findSigmaCommand" $boss $synthNoisedImages_server

#  Add the synth image command to the synth image server
synthNoisedImagesCommand="synthNoisedImages.sh ${originalImage}.truthImage $N ${originalImage}.sigma"
catorssh "$synthNoisedImagesCommand" $boss $synthNoisedImages_server

#  Add the command to move all the synthed noised images to storage
storageCommand="mvorscp ${originalImage}.synthedNoisedImages $synthNoisedImages_server ${storage_server}"
catorssh "$storageCommand" $boss $synthNoisedImages_server
