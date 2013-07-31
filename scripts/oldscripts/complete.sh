#!/bin/bash

#  This script reads in commands from queue.txt, and then executes them.
#  I need to build in the ability to check if the task was actually completed, either 
#  by     (A) making the tasks calls to scripts that first check completion, then, 
#             if necessary, run a task;
#  or     (B) checking completion here.  Or creating a second queue of completion
#             checks.
# 
#  I believe (A) is the better option, but for now I will not incorporate error-checks.

filename=$1
outputfile=$2

cat $filename | while read f; do
    # complete the line.
    $f
    # and add it to the completed queue
    echo $f >> $outputfile
done
