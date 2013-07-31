#!/bin/bash

trkfile=$1
sourceFile=${2-dataS0.nii}
refFile=${3-~/data/freesurfer/1/brain.nii}
regmatFile=${4-S02brain.mat}

~/code/dtk/track_transform $trkfile ${trkfile}.big.trk -src "$sourceFile" -ref $refFile -reg $regmatFile

