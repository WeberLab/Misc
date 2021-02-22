# Misc

Please contribute miscellaneous scripts to the WeberLab here.

## FD.r

FD.r is a Framewise displacement Rscript.  
All you have to do to run this is type `FD.r prefiltered_func_data_mcf.par`  
, where prefiltered_func_data_mcf.par is a six column file that contains information on translation and rotation.  
Rotation is assumed to be in radians, and on a 50mm sphere

## regfilt_comp.sh

This simple bash script will read a file named `labels` and will regress out the components listed at the bottom between the square brackets.  
It input file is expected to be `filtered_func_data.nii.gz` and the output file is `filtered_func_data_clean.nii.gz`  
