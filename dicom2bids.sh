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
subjID=''
proj_dir=''

# Usage
print_usage() {
  printf "Example usage: sh $0 -i /path/input.nii.gz -o /path/output.nii.gz "
  echo ""
  echo "Options"
  echo "-i        Subject ID used for scanning"
  echo "-o        Subject ID used in BIDs"
  echo "-d        Project direcory"
  echo "-h        Print this help"
  exit 1
}

# get input based on flags
while getopts ':h:i:o:d:' flag; do
  case "${flag}" in
    i) scanID=${OPTARG} ;;
    o) subjID="${OPTARG}" ;;
    d) proj_dir="${OPTARG}" ;;
    h) print_usage
       exit 1 ;;
  esac
done

# Set up output folders
raw_dir=${proj_dir}raw/
raw_subj_dir=${raw_dir}${subjID}/
bids_dir=${proj_dir}bids/
bids_subj_dir=${bids_dir}${subjID}/

## set up Python environment
source /autofs/space/linen_001/users/kwokshing/tools/dicom2bids/initiate_conda.sh
source activate bidscoin_env

## print some information on display
echo "Scan ID       :   ${scanID}"
echo "Subject ID    :   ${subjID}"
echo "BIDs folder   :   ${bids_subj_dir}"

mkdir -p ${raw_subj_dir}

## get DICOM path from the Bourget
dicom_path=$( findsession ${scanID} command | sed -n 's/.*PATH   :  //p' )

echo "DICOM path    :   ${dicom_path}"

## temporarily copy dicom to local project storage
cp ${dicom_path}/* ${raw_subj_dir}/

## add .dcm extension to all file for bidscoin to work
for file in ${raw_subj_dir}/*; do 
newname=${file}.dcm
mv ${file} ${newname}
done 

## bidscoin on single subject
bidscoiner -f ${raw_dir} ${bids_dir} -p ${subjID}

## cleanup
rm -r ${raw_subj_dir}