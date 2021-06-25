#!/bin/bash

#DTI pipeline using fsl: topup, eddy, and dtifit
#User needs to first convert dti raw data from the scanner to nifti: dcm2nii -o . *
#User needs to submit the name of the raw data nifti: .nii.gz, .bval, and .bvec files
#User needs to also submit the name of an opposite phase b0 file (also .nii.gz)

#usage: fsldti_pipeline data (.nii.gz .bval and .bvec file base name) b0oppositephase.nii.gz

if [ $# -lt 2 ]; then
    # TODO: print usage
    echo "This script requires two arguments:
First: basename for main dti (no suffix - .nii.gz .bval .bvec)
Second: dti of opposite phase with suffix (.nii.gz)

Example:
dtipipeline.sh main_data opposite_phase_data.nii.gz"
    exit 1
fi

dataname=$1
oppositephasename=$2

#check if DTI data is even or uneven. If uneven, we are going to cut off the bottom slice
echo "checking if images are even Z sliced. Otherwise cutting off bottom slice"

dim1=$(fslhd $dataname.nii.gz | grep -w dim1 | awk '{print $2}')
dim2=$(fslhd $dataname.nii.gz | grep -w dim2 | awk '{print $2}')
dim3=$(fslhd $dataname.nii.gz | grep -w dim3 | awk '{print $2}')
numdirections=$(fslhd $dataname.nii.gz | grep -w dim4 | awk '{print $2}')

if [ $((dim3%2)) -eq 0 ];
then
	echo "even";
else
	echo "odd: cutting off bottom slice";
	newdim=$(expr $dim3 - 1)
	fslroi $dataname.nii.gz $dataname.nii.gz 0 $dim1 0 $dim2 1 $newdim
	fslroi $oppositephasename $oppositephasename 0 $dim1 0 $dim2 1 $newdim
fi

echo "fslroi"
fslroi $dataname.nii.gz b0samephaseA 0 1
fslroi $oppositephasename b0oppositephasename 0 1

echo "fslmerge"
fslmerge -t DTI_b0sonly b0samephaseA.nii.gz b0oppositephasename.nii.gz

printf "0 1 0 0.1\n0 -1 0 0.1" > acqparams.txt

echo "topup"
topup --imain=DTI_b0sonly.nii.gz --datain=acqparams.txt --config=b02b0.cnf --out=DTI_b0sonly_topup

echo "applytopup"
applytopup --imain=$dataname --inindex=1 --datain=acqparams.txt --topup=DTI_b0sonly_topup --out=DTI_topupapplied --method=jac

echo "bet"
bet DTI_topupapplied.nii.gz DTI_topupapplied_brain -R -m

#echo "matlab"
#matlab -nodesktop -r "bvecs = load('$dataname.bvec'); figure('position',[100 100 500 500]); plot3(bvecs(1,:),bvecs(2,:),bvecs(3,:),'*r'); axis([-1 1 -1 1 -1 1]); axis vis3d; rotate3d; view(-58,0); saveas(gcf,'3dBvals.png'); quit"

indx=""
for ((i=1; i<=$numdirections; i+=1)); do indx="$indx 1"; done
echo $indx > index.txt

echo "eddy"
#eddy_openmp --imain=$dataname --mask=DTI_topupapplied_brain_mask.nii.gz --acqp=acqparams.txt --index=index.txt --bvecs=$dataname.bvec --bvals=$dataname.bval --topup=DTI_b0sonly_topup --repol --out=eddy_corrected_data #note: --repol doesn't work in every version :(

eddy_cuda --imain=$dataname.nii.gz --mask=DTI_topupapplied_brain_mask.nii.gz --acqp=acqparams.txt --index=index.txt --bvecs=$dataname.bvec --bvals=$dataname.bval --topup=DTI_b0sonly_topup --niter=8 --fwhm=10,8,4,2,0,0,0,0 --repol --out=eddy_corrected_data --mporder=6 --s2v_niter=5 --s2v_lambda=1 --s2v_interp=trilinear

echo "dtifit"
dtifit -k eddy_corrected_data -o dtifit -m DTI_topupapplied_brain_mask.nii.gz -r $dataname.bvec -b $dataname.bval


echo "dtifit"
dtifit -k eddy_corrected_data -o dtifit -m DTI_topupapplied_brain_mask.nii.gz -r $dataname.bvec -b $dataname.bval
