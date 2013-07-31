#!/bin/bash

#  This takes a single file from src to src.gz to fib.gz

fileName=$1

gzip $fileName

cd

command="../../../Downloads/dsi_studio.exe --action=rec --source=${fileName}.gz --method=4 --record_odf=on --odf=6"

echo $command | wine cmd
