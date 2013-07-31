#!/bin/bash

filename=$1
n_tracks=$2

wineCommand="Z:\home\pfoley\Downloads\dsi_studio.exe --action=trk --source=${filename} --method=0 --seed_count=${n_tracks} --output=${filename}.${n_tracks}.trk"

echo $wineCommand | wine cmd

echo $wineCommand >> ${filename}.log

