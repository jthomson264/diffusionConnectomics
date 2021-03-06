#!/bin/bash

#  This is a script to fit a model.  Currently, the only model used is the 
#  Behrens2003/2007, run by BPX.

#  Take in inputs.
indir=$1
command={$2:-bedpostx}
commandOptions=$3

#  First, check if the model has already been fit.  Do this by searching for the 
#  output, which should have been sent to the next step.  If it has been fit,
#  leave this script, and cat the line to finishedQueue.txt
outputFile="${indir}.bedpostX"
if [ -e $outputFile ]; then
    
    # Annotate the log file.
    echo "The model fit output $outputFile was found.  fitModel completed for $indir. " >> ~/queueLog.txt
    
    # Remove this command from the queue.
    # gsub "fitModel.sh $1 ${2:-""} $3"
    # So gsub is not a real command....    

#  Next, check if the prerequisite steps have been completed.  There are none for this,
#  so this is left blank.  If there were, and they were not completed, exit the script.
#  They should complete on the next run of completeQueue on the upstream server.

#  Now, since the command has not yet run, and we are ready to run it, run the command.
$command $indir $commandOptions