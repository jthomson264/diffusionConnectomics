#!/bin/bash

# Get all arguments including flags.
# Note: options must be input before arguments.
#
#
#  This is to be run after bootstrap.sh
#
#  Once a bootstrap draw has been made, either from the classical bootstrap on q-vectors, or from
#  the rician error bootstrap (reconstructed in this case with the Behrens 2003/2007 model), this
#  script will take the .nii and the btable 
#

#  First, make the SRC file from the btab and nii
matargs=