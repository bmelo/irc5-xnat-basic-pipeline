#!/bin/bash -e
INDIR=$1

ANAT=($INDIR/*.nii.gz)
pydeface $ANAT
rm $ANAT
FNAME=${ANAT%.nii.*}
mv ${FNAME}.json ${FNAME}_defaced.json