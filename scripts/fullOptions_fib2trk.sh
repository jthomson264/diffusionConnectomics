#!/bin/bash

filename=$1
outputAppend=$2
fibercount=$3

stepSize=$4
interpoAngle=$5
faThreshold=$6
smoothing=$7
minLength=$8
maxLength=$9

wineCommand="Z:\home\pfoley\Downloads\dsi_studio.exe --action=trk --source=${filename} --method=0 --fiber_count=100000 --step_size=${stepSize} --interpo_angle=${interpoAngle} --fa_threshold=${faThreshold} --smoothing=${smoothing} --min_length=${minLength} --max_length=${maxLength} --output=${filename}.${outputAppend}.trk"

echo $wineCommand | wine cmd

echo $wineCommand >> ${filename}.log

