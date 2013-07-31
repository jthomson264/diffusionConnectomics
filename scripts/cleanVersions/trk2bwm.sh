#!/bin/bash

filename=$1

. ~/code/scripts/matlab_batcher.sh writeBWMfromTRK "'${filename}'"

echo "Converted the tracts file to a bandwidth matrix ... "