#! #! /bin/bash
#
# This is a shell script for converting single subject DICOM data from 
# Bourget at the Martinos Center to BIDs 
#
# Dependencies: (1)Bidscoin
#
# Creator: Kwok-Shing Chan @ MGH
# kchan2@mgh.harvard.edu
#
# Date created: 3 Feb 2024
# Date edit:
############################################################
set -e

# constructor
scanID=''
output_dir=''

# Usage
print_usage() {
  printf "Example usage: sh $0 -i /path/input.nii.gz -o /path/output.nii.gz "
  echo ""
  echo "Options"
  echo "-i        Subject ID used for scanning"
  echo "-o        Output directory"
  echo "-h        Print this help"
  exit 1
}

# get input based on flags
while getopts ':h:i:o:d:' flag; do
  case "${flag}" in
    i) scanID=${OPTARG} ;;
    o) output_dir="${OPTARG}" ;;
    h) print_usage
       exit 1 ;;
  esac
done

## print some information on display
echo "Scan ID       :   ${scanID}"
echo "Output folder :   ${output_dir}"

mkdir -p ${output_dir}

## get DICOM path from the Bourget
dicom_path=$( findsession ${scanID} command | sed -n 's/.*PATH   :  //p' )

echo "DICOM path    :   ${dicom_path}"

## copy dicom to local project storage
cp ${dicom_path}/* ${output_dir}/

## add .dcm extension to all file for bidscoin to work
for file in ${output_dir}/*; do 
newname=${file}.dcm
mv ${file} ${newname}
done 

