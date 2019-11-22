#!/bin/bash -e
INDIR=$1
HOST=$2
CURDIR=$(pwd)

# Preparing zip file
SCAN_NUM=`basename $INDIR`
mv $INDIR /tmp/NIFTI
cd /tmp/NIFTI
zip ../${SCAN_NUM}.zip *.*
cd $CURDIR

# Sending data
p1="extract=true&format=NIFTI"
curl -X POST -k -u $XNAT_USER:$XNAT_PASS "$HOST/REST/experiments/$XNAT_SESSION/scans/${SCAN_NUM}/resources/NIFTI/files?$p1" -F "NIFTI/${SCAN_NUM}.zip=@/tmp/${SCAN_NUM}.zip"
rm -rf /tmp/NIFTI