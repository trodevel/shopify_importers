#!/bin/bash

#
# Generate Latest Merged List for Shopify Import.
#
# Copyright (C) 2021 Dr. Sergey Kolevatov
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

LIST_DIR=$1
DONOR=$2
VENDOR=$3
FACTOR=$4

[[ -z $LIST_DIR ]] && echo "ERROR: LIST_DIR is not given" && exit
[[ -z $DONOR ]]    && echo "ERROR: DONOR is not given" && exit
[[ -z $VENDOR ]]   && echo "ERROR: VENDOR is not given" && exit
[[ -z $FACTOR ]]   && echo "ERROR: FACTOR is not given" && exit

[[ ! -d $LIST_DIR ]] && echo "ERROR: directory $LIST_DIR is not found" && exit
[[ ! -f $DONOR ]]    && echo "ERROR: donor file $DONOR is not found" && exit

FL=${LIST_DIR}/products_

ls $FL* 2>/dev/null 1>/dev/null
res=$?

#echo "DEBUG: res = $res"

[[ $res -ne 0 ]] && echo "ERROR: cannon find files in $FL" && exit

FLS=$( ls $FL* 2>/dev/null | tail -2 )

NUM=$( echo $FLS | wc -w )

[[ $NUM -ne 2 ]] && echo "ERROR: not enough files - files expected 2, got $NUM" && exit

FL_A=$( echo $FLS | awk '{print $1;}' )
FL_B=$( echo $FLS | awk '{print $2;}' )

echo $FL_A
echo $FL_B

T_A=${FL_A##*/}
ROOT_A="${T_A%.*}"
CONVERTED_A="${LIST_DIR}/converted_${ROOT_A}.csv"
CONVERTED_IMGS_A="${LIST_DIR}/converted_${ROOT_A}_imgs.csv"

T_B=${FL_B##*/}
ROOT_B="${T_B%.*}"
CONVERTED_B="${LIST_DIR}/converted_${ROOT_B}.csv"
CONVERTED_IMGS_B="${LIST_DIR}/converted_${ROOT_B}_imgs.csv"

DIFF_A_B="diff_converted_${ROOT_B}.csv"

#echo "DEBUG: MERGED_A_B = $MERGED_A_B"


if [[ ! -f $CONVERTED_A ]]
then
    echo "INFO: converted file $CONVERTED_A not found, converting now"
    ./convert_products_to_shopify.pl $FL_A $CONVERTED_A $VENDOR $FACTOR -r
else
    echo "INFO: converted file $CONVERTED_A found"
fi

if [[ ! -f $CONVERTED_IMGS_A ]]
then
    echo "INFO: converted file with images $CONVERTED_IMGS_A not found, converting now"
    ./replace_image_urls.sh $CONVERTED_A $DONOR $CONVERTED_IMGS_A
else
    echo "INFO: converted file with images $CONVERTED_IMGS_A found"
fi

echo "INFO: converting file $CONVERTED_B"
./convert_products_to_shopify.pl $FL_B $CONVERTED_B $VENDOR $FACTOR -r

echo "INFO: converted file with images $CONVERTED_IMGS_B"
./replace_image_urls.sh $CONVERTED_B $DONOR $CONVERTED_IMGS_B

echo "INFO: merging lists"
./merge_products_lists.pl $CONVERTED_IMGS_A $CONVERTED_B $DIFF_A_B -d

echo "INFO: done, $DIFF_A_B"
