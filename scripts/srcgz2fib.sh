#!/bin/bash

# This script takes a single file name for a .src file and creates a .fib file.

filename=$1

recCommand="Z:\home\pfoley\Downloads\dsi_studio.exe --action=rec --source=${filename} --mask=Z:\home\pfoley\data\p1s1\nodif_brain_mask.nii --method=4 --record_odf=on --odf=6"

echo $recCommand | wine cmd

echo $recCommand >> ${filename}.log


