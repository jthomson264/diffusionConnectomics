#!/bin/bash
./bootstrap.config

# This is a script to synthesize noised images.

# Take inputs.
truthImageFile=$1
N=$2
sigmaFile=$3

# Check if the job is already done.  If so, cat the command to finishedQueue.txt and
# exit the script.  Otherwise, continute.


# Check if the immediately upstream job has been completed.  If not, exit.


# Complete the command.
matargs="${truthImageFile},${N},${sigmaFile}"
matlab_batcher synthNoisedImages $matargs
