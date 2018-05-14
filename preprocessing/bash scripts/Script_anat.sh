#!/usr/bin/env bash

### ANATOMICAL
# Author: Stefano Moia


### To run this, you need to:
# - download "templates" and "BIDS" from the drive
# - unzip both files, mantaining the folder hierarchy
# - change the workdir


#########
## Variables

# subject
subj=01brainhack

# template resolution
mmres=2.5

# working directory # change this!
workdir=/home/nemo/Scrivania/bhg-fmri


#########
## Derived variables

# standard template
std=${workdir}/templates/MNI152_T1_${mmres}mm_brain

# folders
anat_fld=${workdir}/BIDS/sub-${subj}/anat

# filename prefixes
flprx=sub-${subj}_

# files
anat_files=( ${flprx}T1w ${flprx}acq-INV1_T1w ${flprx}acq-INV2_T1w ${flprx}T2w )


######################################
######### Script starts here #########
######################################

cd ${anat_fld}

for anat in ${anat_files[@]}
do

## 01. Deoblique & resample
3drefit -deoblique ${anat}.nii.gz
3dresample -orient RPI -inset ${anat}.nii.gz -prefix ${anat}_RPI.nii.gz

## 02. Bias Field Correction with ANTs (you don't really need it with mp2rage!)
# 02.1. Truncate (0.01) for Bias Correction # try with 0.01-0.95 (this helps skullstripping too)
ImageMath 3 ${anat}_trunc.nii.gz TruncateImageIntensity ${anat}_RPI.nii.gz 0.01 0.99 256
# 02.2. Bias Correction
N4BiasFieldCorrection -d 3 -i ${anat}_trunc.nii.gz -o ${anat}_bfc.nii.gz

if [ "${anat}" != "${flprx}T1w" ]
then
## 02. Coreg computation (try -c 5 for 5 convergence steps)
antsRegistration -d 3 -m Mattes[${flprx}T1w_bfc.nii.gz,${anat}_bfc.nii.gz,1,32,Regular,0.25] \
-o [${anat}2highres,${anat}2highres.nii.gz,highres2${anat}.nii.gz] \
-t Translation[0.1] -n Linear \
-c 10 -f 1 -s 0 -v 1

# With antsAI AND Coreg application
#antsAI -d 3 -v 1 -m Mattes[${flprx}T1w_bfc.nii.gz,${anat}_bfc.nii.gz,32,Regular,0.25] -t Rigid[0.1] -s [15,0.1] -p 0 -c 10 -o ${anat}2highres.mat
#antsApplyTransforms -d 3 -i ${anat}_bfc.nii.gz -r ${flprx}T1w_bfc.nii.gz -o ${anat}2highres.nii.gz -t ${anat}2highres.mat

fi

done

## 04. Obtain brain mask from T2w
# 04.1. SkullStrip, output original values (normally it does not)
3dSkullStrip -input ${flprx}T2w_bfc.nii.gz -prefix ${flprx}T2w_brain.nii.gz -orig_vol
# 04.2. Compute mask and re-extract brain for real values
3dcalc -a ${flprx}T2w_brain.nii.gz -expr 'ispositive(a)' -prefix ${flprx}T2w_brain_mask.nii.gz
# 04.3. Move brain mask to T1w space (should be the same)
antsApplyTransforms -d 3 -i ${flprx}T2w_brain_mask.nii.gz -r ${flprx}T1w_bfc.nii.gz \
-o mp2rage_brain_mask.nii.gz \
-t ${flprx}T2w2highres0GenericAffine.mat -n NearestNeighbor
# 04.4. Obtaining brain from mp2rage
3dcalc -a ${flprx}T1w_bfc.nii.gz -b mp2rage_brain_mask.nii.gz -expr 'a*ispositive(b)' -prefix mp2rage_brain.nii.gz -overwrite

## How to get better BET with mp2rage only?
# Little trick: skullstrip inv2 instead of T1w


## 05. Atropos (segmentation)
# 05.1. Run Atropos
Atropos -d 3 -a mp2rage_brain.nii.gz \
-o seg.nii.gz \
-x mp2rage_brain_mask.nii.gz -i kmeans[3] \
--use-partial-volume-likelihoods \
-s 1x2 -s 2x3 \
-v 1

# 05.2. Split segments
3dcalc -a seg.nii.gz -expr 'equals(a,1)' -prefix CSF.nii.gz
3dcalc -a seg.nii.gz -expr 'equals(a,3)' -prefix WM.nii.gz
#3dcalc -a seg.nii.gz -expr 'equals(a,2)' -prefix GM.nii.gz

# 05.3. Erode mask to get core
3dmask_tool -input mp2rage_brain_mask.nii.gz \
-prefix eroded_mask.nii.gz \
-fill_holes -dilate_inputs -27 -overwrite

# 05.4. Mask the CSF to get ventricles
3dcalc -a CSF.nii.gz -b eroded_mask.nii.gz -expr 'a*b' -prefix -overwrite Ventricles.nii.gz

## 06. Registration (double SyN, as more SyNs improve the registration - check BSyN)
antsRegistration -d 3 -r [${std}.nii.gz,mp2rage_brain.nii.gz,1] \
-o [highres2std,highres2std.nii.gz,std2highres.nii.gz] \
-x [${std}_mask.nii.gz, mp2rage_brain_mask.nii.gz] \
-n Linear -u 0 -w [0.005,0.995] \
-t Rigid[0.1] \
-m MI[${std}.nii.gz,mp2rage_brain.nii.gz,1,32,Regular,0.25] \
-c [1000x500x250x100,1e-6,10] \
-f 8x4x2x1 \
-s 3x2x1x0vox \
-t Affine[0.1] \
-m MI[${std}.nii.gz,mp2rage_brain.nii.gz,1,32,Regular,0.25] \
-c [1000x500x250x100,1e-6,10] \
-f 8x4x2x1 \
-s 3x2x1x0vox \
-t SyN[0.1,3,0] \
-m CC[${std}.nii.gz,mp2rage_brain.nii.gz,14] \
-c [100x70x50x20,1e-6,10] \
-f 8x4x2x1 \
-s 3x2x1x0vox \
-t SyN[0.1,3,0] \
-m CC[${std}.nii.gz,mp2rage_brain.nii.gz,1,4] \
-c [100x70x50x20,1e-6,10] \
-f 8x4x2x1 \
-s 3x2x1x0vox \
-t SyN[0.1,3,0] \
-m CC[${std}.nii.gz,mp2rage_brain.nii.gz,1,4] \
-c [100x70x50x20,1e-6,10] \
-f 8x4x2x1 \
-s 3x2x1x0vox \
-z 1 -v 1

#antsRegistrationSyN.sh -d 3 -f MNI152_T1_3mm_brain.nii.gz -x MNI152_T1_3mm_brain_mask.nii.gz -m mp2rage_brain.nii.gz -o highres2std_init_
#antsRegistrationSyN.sh -d 3 -f MNI152_T1_3mm_brain.nii.gz -x MNI152_T1_3mm_brain_mask.nii.gz -m highres2std_init_Warped.nii.gz -o highres2std_final_ -t so

######### CHECK YOUR REGISTRATION!!! ######### 