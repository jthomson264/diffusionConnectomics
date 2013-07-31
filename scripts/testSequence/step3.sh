#!/bin/bash

number=$(cat currentNumber)

let newNumber=${number}-1

echo $newNumber > currentNumber