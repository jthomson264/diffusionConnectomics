#!/bin/bash

inputSourceFile=$1

echo "running reconstruction on $inputSourceFile ..."
. ~/code/scripts/src2fib.sh $inputSourceFile
echo "sleeping for two hundred seconds ... "
sleep 200
fibfile=${inputSourceFile}.gz.odf6.f3.gqi.1.2.fib.gz
inputSourceFile=${inputSourceFile}.gz

echo "running tractography on $fibfile ... "
. ~/code/scripts/fib2trk.sh $fibfile
echo "sleeping for two hundred more seconds ... "
sleep 200
trkfile=${fibfile}.trk

echo "applying affine transformation to $trkfile ... "
. ~/code/scripts/trk2bigtrk.sh $trkfile
bigtrkfile=${trkfile}.big.trk
echo "sleeping one minute ... "
sleep 60

echo "generating bandwidth matrix from $bigtrkfile ... "
. ~/code/scripts/trk2bwm.sh $bigtrkfile
bwmfile=${bigtrkfile}.bw_matrix.csv

echo "clearing input files ... "
#rm $inputSourceFile
#rm $fibfile
#rm $trkfile
