#!/bin/bash

numTrks=400

#  This script randomly chooses values for the inputs to DSI_studio and then
#  runs tractographies, recording the input parameters in a log file.
#  
#  I still need to research experimental design, but until then, I will be
#  running this to get some baseline data.  I'll be using uniform distributions
#  on reasonable-to-me inputs for each.

#  Here are the input ranges

#  Step Size
#    steo size is on the scale of a minimeter 
min_step_size=0.5
max_step_size=2.0

#  Turning Angle  .NO LONGER DOES ANYTHING.
#    turning_angle specifies the maximum turning angle from one step to the next
min_turning_angle=5
max_turning_angle=90

#  Interpolation Angle
#    interpo_angle specifies the maximum turning angle from one step to the next
min_interpo_angle=5
max_interpo_angle=90

#  Fractional Anisotropy Threshold
#    Asked Frank.  His example online 
min_fa_threshold=1
max_fa_threshold=3

#  Smoothing
#    smothing determines the linear mixing of previous direction with the 
#    current direction.  0 means no smoothing at all, 1 means a lot.
#    From Frank, "smoothing value 0.2, each subsequent direction has 0.2 weighting contributed from the previous moving direction and 0.8 contributed from the income direction
min_smoothing=0
max_smoothin=1.0

#  MINIMUM LENGTH (confirmed "ok" w/ Frank)
min_min_length=0.01
max_min_length=1.00

#  MAXIMUM LENGTH (confirmed "ok" w/ Frank)
min_max_length=350
max_max_length=1000

#   NOW RUN EVERYTHING

for (( i=1; i<=$numTrks; i++ ))
do
    echo "Doin som ISHHHHhhhhh"
    random_step_size=
    random_interpo_angle=
    random_fa_threshold=
    random_smoothing=
    random_min_length=
    random_max_length=
done