# howto_reconall

Due to the absent of body coil, we cannot enable `Prescan normalize` in the MPRAGE sequence. Therefore, the signal intensity of the MPRAGE image is strongly influenced by the coil sensitivity. This can cause issue when we process the anatomical image using the Freesurfer's `recon-all` function.

## 1. Brain extraction fails

The most common issue (>40% of all datasets) we (I) encountered is the failure of brain extraction step, either large portion of the brain being removal, or parts of the skull remains, resulting in incorrect output of cortical surface reconstruction.

This issue can be solved by replacing the `recon-all` skull stripping output by the `Synthstrip` mask as part of the `recon-all` processing

```bash
subject=sub-001
freesurfer_dir=/project/Freesurfer/
# autorecon1
input_nii=${subject}_T1w.nii.gz
recon-all -i ${input_nii} -s ${subject} -sd ${freesurfer_dir} -autorecon1

# Use mri_synthstrip for brain extraction
input_nii=${freesurfer_dir}${subject}/mri/T1.mgz
output_nii=${freesurfer_dir}${subject}/mri/brainmask.mgz
mri_synthstrip -i ${input_nii} -o ${output_nii}

# continue recon-all
recon-all -autorecon2 -autorecon3 -s ${subject} -sd ${freesurfer_dir}
```
