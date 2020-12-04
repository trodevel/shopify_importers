#!/bin/bash

INP=$1
DONOR=$2
OUTP=$3

[[ -z $INP ]]     && echo "ERROR: input file is not given" && exit
[[ -z $DONOR ]]   && echo "ERROR: donor file is not given" && exit
[[ -z $OUTP ]]    && echo "ERROR: output file is not given" && exit
[[ ! -f $INP ]]   && echo "ERROR: input file '$INP' not found" && exit
[[ ! -f $DONOR ]] && echo "ERROR: input file '$DONOR' not found" && exit

new_url=$( ./get_image_url_from_products_export.sh $DONOR )

[[ -z $new_url ]] && echo "ERROR: cannot find image URL in '$DONOR'" && exit

sed "s~\(,https://.*/\)\([a-zA-Z0-9_\-]*\.\(png\|jpg\)\)~${new_url}\2~" $INP > $OUTP

echo "done"
