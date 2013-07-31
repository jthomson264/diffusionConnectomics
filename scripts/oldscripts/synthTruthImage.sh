#!/bin/bash

# This is a script to synthesize an image from a set of fitModel outputs.  It 
# will run after the model has been fit and the outputs transferred to the synthImage
# server.

# Take inputs
indir=$1
outdir=$2
method=${3:-bpx}
Nf=${4:-3}

# First, check if the job has already been done.  If so, cat the command to the
# finishedQueue.txt and exit the script.

# Next, check if the immediately upstream step has been completed.  If not, exit the
# script and do nothing.

# Finally, execute the command.
if [ $method != bpx ]
then echo "You are using a faulty method to synth an image from model fits" >> ~/queueErrors.txt
fi

matargs="${indir},${outdir},$Nf"
matlab_batcher.sh synthImageFromBPX $matargs