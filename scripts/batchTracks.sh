#!/bin/bash

#    This script processes, from original data all through .trk file, $1 (N) 
#    draws from scan $2 (prefix) using method $3 (method).

N=$1
prefix=$2
method=$3

if [ $method != 'r' -a $method != 'q' ];
then
    echo "Please enter r for rician or q for q-vector as your third argument."
fi


if [ $method == 'r' ];
then
    echo "Using the rician error model with behrens reconstruction ... "
    . ~/code/scripts/matlab_batcher.sh synthNoisedImages "'${prefix}',${N}"
    cd ~/data/r_draws/${prefix}
    . ~/code/scripts/batch.sh ~/code/scripts/src2trk.sh *.src
fi

if [ $method == 'q' ];
then
    echo "Using the diffusion wave vector resampling method ... "
    . ~/code/scripts/matlab_batcher.sh writeNewNiis "'${prefix}',${N}"
fi