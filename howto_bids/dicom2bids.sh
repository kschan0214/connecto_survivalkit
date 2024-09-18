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
isKeepRaw=0

# Usage
print_usage() {
  printf "Example usage: sh $0 -i /path/input.nii.gz -o /path/output.nii.gz "
  echo ""
  echo "Options"
  echo "-i        Subject ID used for scanning"
  echo "-o        Subject ID used in BIDs"
  echo "-d        Project direcory"
  echo "-k        (Optional) '0': Do not keep the DICOM data in raw/; '1': keep the DICOM data in raw/ (default='0')"
  echo "-h        Print this help"
  exit 1
}

# get input based on flags
while getopts ':hi:o:d:k:' flag; do
  case "${flag}" in
    i) scanID=${OPTARG} ;;
    o) subjID="${OPTARG}" ;;
    d) proj_dir="${OPTARG}" ;;
    k) isKeepRaw="${OPTARG}" ;;
    h) print_usage
       exit 1 ;;
  esac
done

## Set up output folders
raw_dir=${proj_dir}raw/
raw_subj_dir=${raw_dir}${subjID}/
bids_dir=${proj_dir}bids/
bids_subj_dir=${bids_dir}${subjID}/

## get script directory
script_dir=$( dirname $0 )

## set up Python environment
source ${script_dir}/initiate_conda.sh
source activate bidscoin_env

## print some information on display
echo "Subject ID    :   ${subjID}"

## Temporarily copy DICOM to local project folder
sh ${script_dir}/copy_to_local.sh -i ${scanID} -o ${raw_subj_dir}

## bidscoin on single subject
bidscoiner -f ${raw_dir} ${bids_dir} -p ${subjID}

## cleanup
if [ ${isKeepRaw} -eq 0 ]; then
rm -r ${raw_subj_dir}
fi