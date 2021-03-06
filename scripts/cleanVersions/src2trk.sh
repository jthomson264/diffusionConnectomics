#!/bin/bash

filename=$1
fibname="${filename}.gz.odf6.f3.gqi.1.2.fib.gz"

gzip $filename

command1="Z:\home\pfoley\Downloads\dsi_studio.exe --action=rec --source=${filename}.gz --method=4 --record_odf=on --odf=6"

command2="Z:\home\pfoley\Downloads\dsi_studio.exe --action=trk --source=${fibname} --method=0 --num_fibers=100000"

bothCommands="$command1 && $command2"

echo "About to run src2trk for $filename"

echo $bothCommands | wine cmd

#. ~/code/scripts/src2fib.sh $filename
#. ~/code/scripts/fib2trk.sh $fibname


