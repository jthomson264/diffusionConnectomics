#!/bin/bash

fibFile=$1
startNum=$2
endNum=$3
byNum=$4

for (( i=$startNum; i<=$endNum; i=i+$byNum ))
do
    echo "I am not waiting for anything.  This is dangerous."
    . ~/code/scripts/fib2Ntrk.sh $fibFile $i
    sleep 40
done

echo "Good work, senor Bash."