#! /bin/bash
#
# This is a shell script to run TractSeg on single subject
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
DELTA_used=13         # Target diffusion time, in ms

proj_dir=/autofs/cluster/connectome2/Bay8_C2/
bids_dir=${proj_dir}bids/
derivatives_dir=${bids_dir}derivatives/

# I suggest the output to be stored in ${derivatives_dir}TractSeg/${subj_label}/
tractseg_out_dir=~/test_tractseg/derivatives/TractSeg/${subj_label}/D${DELTA_used}ms/
output_prefix=${tractseg_out_dir}${subj_label}_D-${DELTA_used}

mkdir -p ${tractseg_out_dir}

##############################################
## set up conda environment and other tools for TractSeg
tractseg_script_dir=/autofs/space/linen_001/users/kwokshing/tools/dwi/TractSeg_mgh/
source ${tractseg_script_dir}initiate_TractSeg.sh 

##############################################
## Step 1: data from get 1 diffusion time only
# A new dwi.nii.gz file, bval and bvec text files will be created

echo "----------------------------------------------------------------"
echo "Step 1: Extract a single diffusion time data: D=${DELTA_used}ms"
echo "----------------------------------------------------------------"

# Input from preprocessed DWI
dwi_nii=${derivatives_dir}processed_dwi/${subj_label}/${subj_label}_dwi.nii.gz
bval_txt=${derivatives_dir}processed_dwi/${subj_label}/${subj_label}.bval
bvec_txt=${derivatives_dir}processed_dwi/${subj_label}/${subj_label}.bvec
DELTA_txt=${derivatives_dir}processed_dwi/${subj_label}/${subj_label}.diffusionTime

# Option 1: use b<=3000
bmax=3000
tractseg_out_dir=~/test_tractseg/derivatives/TractSeg/${subj_label}/D${DELTA_used}ms_bmax${bmax}/ # create a new directoyr for b<=3000 results
output_prefix=${tractseg_out_dir}${subj_label}_D-${DELTA_used}_bmax-${bmax}
matlab -nodesktop -nojvm -nodisplay -r "addpath('${tractseg_script_dir}'),extract_dwi_given_delta('${dwi_nii}','${bval_txt}','${bvec_txt}','${DELTA_txt}',${DELTA_used},'${output_prefix}',${bmax}),quit"
# # Option 2: use all b-values
# matlab -nodesktop -nojvm -nodisplay -r "addpath('${tractseg_script_dir}'),extract_dwi_given_delta('${dwi_nii}','${bval_txt}','${bvec_txt}','${DELTA_txt}',${DELTA_used},'${output_prefix}'),quit"

##############################################
## Step 2: TractSeg

# Input from Step 1 and preprocessed DWI
dwi_nii=${output_prefix}_dwi.nii.gz
bval_txt=${output_prefix}.bval
bvec_txt=${output_prefix}.bvec
mask_nii=${derivatives_dir}processed_dwi/${subj_label}/${subj_label}_brain_mask.nii.gz

# STEP 2.1: Generate PEAKS and binary tract segmentation maps
echo "-----------------------------------------------------------"
echo "Step 2.1: Generate PEAKS and binary tract segmentation maps"
echo "-----------------------------------------------------------"
TractSeg -i ${dwi_nii} --brain_mask ${mask_nii} -o ${tractseg_out_dir} \
    --raw_diffusion_input --csd_type csd_msmt \
    --bvals ${bval_txt} --bvecs ${bvec_txt} --keep_intermediate_files --output_type tract_segmentation

# STEP 2.2: Generate tract end ROIs
echo "---------------------------------"
echo "Step 2.2: Generate tract end ROIs"
echo "---------------------------------"
TractSeg -i ${tractseg_out_dir}peaks.nii.gz -o ${tractseg_out_dir} --output_type endings_segmentation

# STEP 2.3: Generate tract-orientation maps prior within the segmented maps
echo "-------------------------------------------------------------------------"
echo "Step 2.3: Generate tract-orientation maps prior within the segmented maps"
echo "-------------------------------------------------------------------------"
TractSeg -i ${tractseg_out_dir}peaks.nii.gz -o ${tractseg_out_dir} --output_type TOM 

# STEP 2.4: Perform the actual tractography within the tract-masks
echo "----------------------------------------------------------------"
echo "Step 2.4: Perform the actual tractography within the tract-masks"
echo "----------------------------------------------------------------"
Tracking -i ${tractseg_out_dir}peaks.nii.gz -o ${tractseg_out_dir} --tracking_format tck --nr_fibers 2000

echo "**********TractSeg is completed.**********"

## (Optional) clean up
rm ${dwi_nii}
