#!/bin/bash

package=$1
recipient=$2

command='scp '$package' pfoley@'$recipient':~/'

echo $command >> queue.txt