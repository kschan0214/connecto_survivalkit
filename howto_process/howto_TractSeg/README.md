# howto_TractSeg

This document is for people who want to use TractSeg for their analysis in our group.

I have set up the conda environment to use [TractSeg](https://github.com/MIC-DKFZ/TractSeg) in our server.

You can initiate TractSeg using my shell script:

```bash
source /autofs/space/linen_001/users/kwokshing/tools/connecto_survivalkit/howto_process/howto_TractSeg/initiate_TractSeg.sh
```

which will activate the virtual environment in where TractSeg is installed.

I also provide two examples scripts here to demonstrate it usage in our server setup:

1. [run_example_01_tractseg_subject.sh](run_example_01_tractseg_subject.sh) shows the usage of tract segmentation

2. [run_example_02_tractometry_subject.sh](run_example_02_tractometry_subject.sh) shows the usage of running Tractometer

You can use [mrview](https://mrtrix.readthedocs.io/en/dev/reference/commands/mrview.html) to view the reconstructed tracts. To run `mrview` on our server:

```bash
singularity run -B /run -B /autofs/ /autofs/cluster/pubsw/2/pubsw/Linux2-2.3-x86_64/packages/mrtrix/3.0.3/MRtrix3.sif mrview
```
