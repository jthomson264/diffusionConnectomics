#!/bin/bash

number=$(cat currentNumber)
let newNumber=number*number

echo $newNumber > currentNumber
