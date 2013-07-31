#!/bin/bash

# This script takes a single file name for a .src file and creates a .fib file.

scanName=$1

filename=~/data/${scanName}/data.nii.src

gzip $filename

recCommand="Z:\home\pfoley\Downloads\dsi_studio.exe --action=rec --source=${filename}.gz --mask=Z:\home\pfoley\data\${scanName}\nodif_brain_mask.nii --method=4 --record_odf=on --odf=6"

echo $recCommand | wine cmd

echo $recCommand >> ${filename}.log


