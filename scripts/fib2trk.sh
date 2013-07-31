#!/bin/bash

filename=$1

wineCommand="Z:\home\pfoley\Downloads\dsi_studio.exe --action=trk --source=${filename} --method=0 --fiber_count=100000 --output=${filename}.trk"

echo $wineCommand | wine cmd

echo $wineCommand >> ${filename}.log

