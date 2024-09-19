#! /bin/bash
#
# This is a shell script to run Tractometry on single subject
#
# Dependencies: (1)TractSeg (2)MRtrix
#
# Creator: Kwok-Shing Chan @ MGH
# kchan2@mgh.harvard.edu
#
# Date created: 26 April 2024
# Date edit:
############################################################

##############################################
## User Input/Output

subj_label=sub-ms005
DELTA_used=13 #ms

proj_dir=/autofs/cluster/connectome2/Bay8_C2/
bids_dir=${proj_dir}bids/
derivatives_dir=${bids_dir}derivatives/

# Can be any results in DWI space
SANDI_dir=${derivatives_dir}SANDI/
# can be multiple maps
params_file=( 'fneurite' 'fsoma' )

# I suggest the output to be stored in ${derivatives_dir}TractSeg/${subj_label}/
tractseg_out_dir=~/test_tractseg/derivatives/TractSeg/${subj_label}/D${DELTA_used}ms_bmax3000/
tractometry_out_dir=${tractseg_out_dir}Tractometry/

mkdir -p ${tractometry_out_dir}

##############################################
## set up conda environment and other tools for TractSeg
tractseg_script_dir=/autofs/space/linen_001/users/kwokshing/tools/connecto_survivalkit/howto_process/howto_TractSeg/
source ${tractseg_script_dir}initiate_TractSeg.sh 

##############################################
## Step 1: Compute tractometer given parameter map(s)

for fn in "${params_file[@]}"; do 

echo "-----------------------------------------------"
echo "Computing Tractometry on the parameter map: $fn"
echo "-----------------------------------------------"

in_vol=${SANDI_dir}${subj_label}/sub-05-SANDI-fit_${fn}.nii.gz
out_csv=${tractometry_out_dir}sub-05-SANDI-fit_${fn}_tractometry.csv

Tractometry -i ${tractseg_out_dir}TOM_trackings/ \
            -o ${out_csv} \
            -e ${tractseg_out_dir}endings_segmentations/ \
            -s ${in_vol} --tracking_format tck

done

echo "**********Tractometry is completed.**********"

