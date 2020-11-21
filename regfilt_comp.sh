#! /bin/bash

components=$(awk 'NR>1{print $1}' RS=[ FS=] labels)
echo "removing components ${components} from filtered_func_data and creating file filtered_func_data_clean"
fsl_regfilt -i filtered_func_data.nii.gz -d filtered_func_data.ica/melodic_mix -o filtered_func_data_clean.nii.gz -f "${components}"
