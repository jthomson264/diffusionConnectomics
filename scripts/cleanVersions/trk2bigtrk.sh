#!/bin/bash

trkfile=$1

~/code/dtk/track_transform $trkfile ${trkfile}.big.trk -src dataS0.nii -ref freesurfer/1/brain.nii -reg s02brain.mat

