#!/bin/bash

#  This is a dir
dir=$1

echo "Running NIFTI to Source on $NIFTI with btable $btab ... "

. ~/code/scripts/matlab_batcher.sh niiToSource "'${dir}'"

echo "NIFTI converted"