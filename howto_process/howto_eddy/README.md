# howto_eddy

The FSL webpage of [eddy](https://web.mit.edu/fsl_v5.0.10/fsl/doc/wiki/eddy(2f)UsersGuide.html) is the main source of information if you are trying to optimise the eddy parameters. Here, I just wanted to provide some tips and tricks that are not documented on the webpage.

## 1. Applying eddy parameters to another dataset

There are several scenarios you may want to apply the eddy parameters estimated from one dataset on another dataset. One example is that eddy may work better in one case but not the other. This can actually be done though it is not mentioned on the webpage. To demonstrate how this works, let's say we have two datasets that have the same eddy current and motion effects:

(1) DWI.nii.gz and,  
(2) DWI_copy.nii.gz.

It could be that, for example, DWI.nii.gz is the original copy and DWI_copy.nii.gz is a denoised copy.

Let's say we want to estimate the eddy parameters from (1) and then apply the results on (2). We can first run eddy as usual:

```bash
eddy_cuda10.2 --imain=DWI.nii.gz \
    --mask=nodiff_brain_mask.nii.gz \
    --acqp=acquisition_parameter.txt \
    --index=index.txt \
    --bvecs=bvec \
    --bvals=bval \
    --topup=topup_hifi_res \
    --out=DWI_eddy \
    --verbose 
```

which will give us two main eddy output

- DWI_eddy.eddy_parameters, and
- DWI_eddy.eddy_movement_over_time (if slice-to-volume correction is enabled)

To apply these two results to (2), we can run

```bash
eddy_cuda10.2 --imain=DWI_copy.nii.gz \
    --mask=nodiff_brain_mask.nii.gz \
    --acqp=acquisition_parameter.txt \
    --index=index.txt \
    --bvecs=bvec \
    --bvals=bval \
    --topup=topup_hifi_res \
    --out=DWI_copy_eddy \
    --niter=0 \
    --s2v_niter=0 \
    --init=DWI_eddy.eddy_parameters \
    --init_s2v=DWI_eddy.eddy_movement_over_time \
    --verbose 
```

By setting the ``--niter`` and ``--s2v_niter`` flags to zero, eddy will apply the initial transformation matrices without re-estimating the parameters.
