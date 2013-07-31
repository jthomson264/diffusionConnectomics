#!/bin/bash

. ~/code/scripts/matlab_batcher.sh writeNewNiis "'p1s2',12"
. ~/code/scripts/matlab_batcher.sh writeNewNiis "'p2s1',12"
. ~/code/scripts/matlab_batcher.sh synthNoisedImages "'p1s1',12"
. ~/code/scripts/matlab_batcher.sh synthNoisedImages "'p1s2',12"
. ~/code/scripts/matlab_batcher.sh synthNoisedImages "'p2s1',12"
