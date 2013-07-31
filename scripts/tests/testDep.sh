#!/bin/bash

ls -l -R -h ~/ > fake.txt
cp fake.txt fake2.txt
cp fake2.txt fake3.txt
cp fake3.txt fake4.txt
cp fake4.txt fake5.txt