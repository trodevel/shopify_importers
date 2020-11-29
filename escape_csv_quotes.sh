#!/bin/bash

INP=$1
OUTP=$2

[[ -z $INP ]]  && echo "ERROR: input file name is missing" && exit
[[ -z $OUTP ]] && echo "ERROR: output file name is missing" && exit

sed 's/"/""/g' $INP |
    awk -F";" '{ printf "%s;\"%s\";%s;%s;%s;%s;%s;%s;\n", $1, $2, $3, $4, $5, $6, $7, $8; }' > $OUTP
