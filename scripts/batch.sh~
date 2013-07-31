#!/bin/bash

command=$1

shift

fileName=$1

while [ "$fileName" != "" ];
do
    echo "Running $command on $fileName"
    shift
    . $command $fileName
    echo "did it. "
    fileName=$1
done
