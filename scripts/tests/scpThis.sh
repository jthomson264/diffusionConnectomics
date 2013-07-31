#!/bin/bash

package=$1
recipient=$2

scp $package 'pfoley@'$recipient':~/'
