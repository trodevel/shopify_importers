#!/bin/bash

INP=$1

[[ -z $INP ]]   && echo "ERROR: input file is not given" && exit
[[ ! -f $INP ]] && echo "ERROR: input file '$INP' not found" && exit

grep -o ",https://.*\.\(png\|jpg\)" $INP | sed "s/products\/.*/products\//" | sort | uniq
