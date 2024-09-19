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
# Date edit: 8 Feb 2024
############################################################
set -e

# constructor
scanID=''
output_dir=''
isCombined=1

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

## get script directory
script_dir=$( dirname $0 )

## print some information on display
echo "Scan ID       :   ${scanID}"

## get DICOM path from the Bourget
dicom_path=$( findsession ${scanID} command | sed -n 's/.*PATH   :  //p' )

dicom_path=( $dicom_path )

## in case multiple session detected
if [ ${#dicom_path[@]} -gt 1 ] ; then

## Multiple sessions

echo "Multiple sessions are found."
findsession ${scanID} 
while true; do
    read -p "Do you want to combine all DICOM files into a single session? (yes/no) " yn
    case $yn in
        [Yy]* ) isCombined=1; break;;
        [Nn]* ) isCombined=0; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

if [ ${isCombined} -eq 1 ]; then

## in case of combining
for ((i=0;i<${#dicom_path[@]};i++)); do
echo "DICOM path    :   ${dicom_path[$i]}"
mkdir -p ${output_dir}

## copy dicom to local project storage
cp ${dicom_path[$i]}/* ${output_dir}/

done
echo "Output folder :   ${output_dir}"

else

## in case of not combining
for ((i=0;i<${#dicom_path[@]};i++)); do
output_tmp_dir=${output_dir}/ses-0$(( $i+1 ))
echo "DICOM path    :   ${dicom_path[$i]}"
echo "Output folder :   ${output_tmp_dir}"

mkdir -p ${output_tmp_dir}

## copy dicom to local project storage
cp ${dicom_path[$i]}/* ${output_tmp_dir}/

done

fi
else
## Single session

echo "DICOM path    :   ${dicom_path}"
mkdir -p ${output_dir}

## copy dicom to local project storage
cp ${dicom_path}/* ${output_dir}/

fi

## set up Python environment
source ${script_dir}/initiate_conda.sh
source activate bidscoin_env

## add .dcm extension to all file for bidscoin to work
if [ ${isCombined} -eq 1 ]; then

for file in ${output_dir}/*; do 
newname=${file}.dcm
mv ${file} ${newname}
done 

# reorganise the dicom directory
dicomsort ${output_dir}

else

for ((i=0;i<${#dicom_path[@]};i++)); do
output_tmp_dir=${output_dir}/ses-0$(( $i+1 ))

for file in ${output_tmp_dir}/*; do 
newname=${file}.dcm
mv ${file} ${newname}
done 
# reorganise the dicom directory
dicomsort ${output_tmp_dir}
done

fi

