#!/bin/bash

number=$(cat currentNumber)

let newNumber=number*number

sleep 20

echo $newNumber > currentNumber
