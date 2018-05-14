#!/usr/bin/env bash

### FUNCTIONAL
# Authors: Stefano Moia & Cesar Caballero-Gaudes

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

# FWHM for smoothing (mm)
fwhm=5

# working directory # change this!
workdir=/home/nemo/Scrivania/bhg-fmri


#########
## Derived variables

# standard template
std=${workdir}/templates/MNI152_T1_${mmres}mm_brain

# folders
anat_fld=${workdir}/BIDS/sub-${subj}/anat
fmap_fld=${workdir}/BIDS/sub-${subj}/fmap
func_fld=${workdir}/BIDS/sub-${subj}/func

# filename prefixes
flprx=sub-${subj}_

# files
anat=${anat_fld}/${flprx}T2w
func=${func_fld}/sub-${subj}_task-rest_run-01_bold

## Variables

blip_for=${fmap_fld}/sub-${subj}_acq-restsbref_dir-AP_run-01_epi.nii.gz
blip_rev=${fmap_fld}/sub-${subj}_acq-restsbref_dir-PA_run-01_epi.nii.gz

######################################
######### Script starts here #########
######################################

cd ${func_fld}

######### Pt.1: Corrections  #########

## 01. Discard first trs (15 seconds)
3dcalc -a ${func}.nii.gz[20..$] -expr 'a' -prefix ${func}_dis.nii.gz

## 02. Deoblique & resample
3drefit -deoblique ${func}_dis.nii.gz
3dresample -inset ${func}_dis.nii.gz -prefix ${func}_ro.nii.gz -orient RPI

## 03. Despike
3dDespike -prefix ${func}_dsk.nii.gz ${func}_ro.nii.gz

## 04. Slice Interpolation # try quintic or heptic instead of Fourier
# For multiband, you should have a file with the slice time acquisition (sliceorder.txt)
# You can get this information from the .json associated with your acquisition
3dTshift -Fourier \
-prefix ${func}_si.nii.gz \
-tpattern @sliceorder.txt \
${func}_dsk.nii.gz

## 05. Blip (aka Topup)
# 05.1. Computing the warping to midpoint
3dQwarp -plusminus -pmNAMES Rev For \
-pblur 0.05 0.05 -blur -1 -1\
-noweight -minpatch 9 \
-source ${blip_rev} \
-base ${blip_for} \
-prefix blip_warp.nii.gz

# 05.2. Applying the warping to the functional volume
3dNwarpApply -quintic -nwarp blip_warp_For_WARP.nii.gz \
-source ${func}_si.nii.gz \
-prefix ${func}_wp.nii.gz


## 06. Motion Computation # try quintic or heptic instead of Fourier

# 06.1. Get Average Volume
3dTstat -mean -prefix ${func}_wp_mean.nii.gz ${func}_wp.nii.gz -orig_vol
# 06.2. Get Mask from it, then dilate and fill holes
3dSkullStrip -input ${func}_wp_mean.nii.gz -prefix ${func}_wp_brain.nii.gz
3dcalc -a ${func}_wp_brain.nii.gz -expr 'ispositive(a)' -prefix ${func}_wp_mask.nii.gz
3dmask_tool -input ${func}_wp_mask.nii.gz -prefix ${func}_wp_mask.nii.gz \
-overwrite \
-fill_holes -dilate_inputs 1
# 06.3. Re-extract the brain
3dcalc -a ${func}_wp.nii.gz -b ${func}_wp_mask.nii.gz -expr 'a*ispositive(b)' -prefix ${func}_wp_brain.nii.gz -overwrite
# 06.4. Compute outlier fraction
3dToutcount -mask ${func}_wp_mask.nii.gz -fraction -polort 3 -legendre ${func}_wp_brain.nii.gz > ${func}_outcount.1D
# 06.5. Get censored TRs, if at least 10% of the voxels are outliers
1deval -a ${func}_outcount.1D -expr "1-step(a-0.1)" > ${func}_outcount_cens.1D

# You can plot them with:
# 1dplot ${func}_outcount.1D ${func}_outcount_cens.1D
# This is already a quality check per se: if you have no censored volume, then the scan is good!


# 06.5. Find the index of the volume with less outlier, pay attention to \'!
minindex=`3dTstat -argmin -prefix - ${func}_outcount.1D\'`
# check this ovals = `1d_tool.py -index_to_run_tr $minindex`
# 06.6. Extract volume
#3dcalc -a ${func}_wp_brain.nii.gz["$minindex"] -expr 'a' -prefix example_func.nii.gz
3dcalc -a ${func}_wp_brain.nii.gz[`echo ${minindex}`] -expr 'a' -prefix example_func.nii.gz

# 06.7. Compute motion and save all the parameters
3dvolreg -base example_func.nii.gz \
-prefix ${func}_mc.nii.gz \
-1Dfile ${func}_motion.1D \
-dfile ${func}_mc.1D -1Dmatrix_save ${func}_mc.aff12.1D \
-Fourier -zpad 4 \
${func}_wp.nii.gz

# 06.9. Compute temporal SNR map: tSNR = avg(x)/std(x)
3dTstat -mean -prefix ${func}_mc_mean.nii.gz ${func}_mc.nii.gz
3dTstat -stdev -prefix ${func}_mc_std.nii.gz ${func}_mc.nii.gz
3dcalc -a ${func}_mc_mean.nii.gz -b ${func}_mc_std.nii.gz -expr 'a/b' -prefix ${func}_mc_tSNR.nii.gz

# 06.10 Compute Displacement Time Course based on Euclidean norm of derivative of realignment parameters
# This is similar to Framewise Displacement
1d_tool.py -infile ${func}_motion.1D -show_censor_count -censor_prev_TR -censor_motion 0.3 motion_${subj}

# You can plot them with:
# 1dplot ${func}_motion.1D
# 1dplot motion_01brainhack_enorm.1D motion_01brainhack_censor.1D


######### Pt.2: Norm Comp    #########


## 07. Normalisation computation # Pay attention to inversion!

# 07.1. Register anat to func # DON'T WARP
antsRegistration -d 3 -r [example_func.nii.gz,${anat}_brain.nii.gz,1] \
-o [${anat}2func,${anat}2func.nii.gz,${anat_fld}func2T2w.nii.gz] \
-x [${func}_brain_mask.nii.gz, NULL] \
-n Linear -u 0 -w [0.005,0.995] \
-t Rigid[0.1] \
-m MI[example_func.nii.gz,${anat}_brain.nii.gz,1,32,Regular,0.25] \
-c [1000x500x250x100,1e-6,10] \
-f 8x4x2x1 \
-s 3x2x1x0vox \
-t Affine[0.1] \
-m MI[example_func.nii.gz,${anat}_brain.nii.gz,1,32,Regular,0.25] \
-c [1000x500x250x100,1e-6,10] \
-f 8x4x2x1 \
-s 3x2x1x0vox \
-z 1 -v 1

# 07.2. register func to mni 
antsApplyTransforms -d 3 -i example_func.nii.gz -r ${std} \
-o func2std.nii.gz \
-n Linear \
-t ${anat_fld}/highres2std1Warp.nii.gz \
-t ${anat_fld}/highres2std0GenericAffine.mat \
-t ${anat}2highres0GenericAffine.mat \
-t [${anat}2func0GenericAffine.mat,1]

# 07.3. register mni to func
antsApplyTransforms -d 3 -i ${std} -r example_func.nii.gz \
-o std2func.nii.gz \
-n Linear \
-t ${anat}2func0GenericAffine.mat \
-t [${anat}2highres0GenericAffine.mat,1] \
-t [${anat_fld}/highres2std0GenericAffine.mat,1] \
-t [${anat_fld}/highres2std1Warp.nii.gz,1]

# 07.4. Register Physio masks to func # USE NN function, they're masks!
antsApplyTransforms -d 3 -i ../anat/WM.nii.gz -r example_func.nii.gz \
-o WM_native.nii.gz \
-n NearestNeighbor \
-t ${anat}2func0GenericAffine.mat \
-t [${anat}2highres0GenericAffine.mat,1] 

antsApplyTransforms -d 3 -i ../anat/CSF.nii.gz -r example_func.nii.gz \
-o CSF_native.nii.gz \
-n NearestNeighbor \
-t ${anat}2func0GenericAffine.mat \
-t [${anat}2highres0GenericAffine.mat,1] 

antsApplyTransforms -d 3 -i ../anat/Ventricles.nii.gz -r example_func.nii.gz \
-o Ventricles_native.nii.gz \
-n NearestNeighbor \
-t ${anat}2func0GenericAffine.mat \
-t [${anat}2highres0GenericAffine.mat,1] 

# 07.5. Select Ventricles only
# At this point, your Ventricles_native has more than the ventricles.
# Luckily, most of the rest will disappear if you find clusters and select only the "big ones"
# You need to tune the number of voxels (-NN2 nn), based on your resolution
3dclust -prefix Ventricles_only.nii.gz \
-nosum -quiet -no_1Dformat \
0 30 Ventricles_native.nii.gz


######### Pt.3: Nuis Comp    #########

## 08. Motion
# 08.1. Demean motion parameters
1d_tool.py -infile ${func}_motion.1D \
-demean -write ${func}_motion_demean.1D

# 08.2. Derivate motion parameters
1d_tool.py -infile ${func}_motion.1D \
-derivative -demean -write ${func}_motion_deriv.1D


# 08.3 Combine multiple censor files
1deval -a motion_${subj}_censor.1D -b ${func}_outcount_cens.1D \
-expr "a*b" > censor_${subj}_combined_2.1D
# 08.4. Obtain the non-censored volumes in AFNI indexing
ktrs=$(1d_tool.py -infile censor_${subj}_combined_2.1D -show_trs_uncensored encoded)

## 09. CompCorr
# 09.1. Detrend data pre-CompCorr
#3dTproject -input sub-01brainhack_task-rest_run-01_bold_mc.nii.gz -polort 3 ${func}_motion_demean.1D and -ortvec ${func}_motion_deriv.1D -censor censor_${subj}_combined_2.1D -cenmode ZERO -prefix ${func}_mc_4CompCor.nii.gz
3dTproject -input ${func}_mc.nii.gz \
-prefix ${func}_mc_4CompCor.nii.gz \
-polort 3 -ort ${func}_motion_demean.1D ${func}_motion_deriv.1D \
-censor censor_${subj}_combined_2.1D -cenmode ZERO
# 09.2. Obtaining the components
3dpc -mask WM_native.nii.gz -pcsave 5 -prefix roi_WM \
${func}_mc_4CompCor.nii.gz"[${ktrs}]"
1d_tool.py -censor_fill_parent censor_${subj}_combined_2.1D \
-infile roi_WM_vec.1D -write roi_pc_01_WMe_noc.1D

3dpc -mask Ventricles_only.nii.gz -pcsave 5 -prefix roi_Ventricles \
${func}_mc_4CompCor.nii.gz"[${ktrs}]"
1d_tool.py -censor_fill_parent censor_${subj}_combined_2.1D \
-infile roi_Ventricles_vec.1D -write roi_pc_02_CSFe_noc.1D


######### Pt.4: Smoothing    #########

## 10. Blur (Smoothing)
3dBlurInMask -input ${func}_mc.nii.gz \
-mask ${func}_wp_mask.nii.gz \
-prefix ${func}_smth.nii.gz \
-preserve -FWHM ${fwhm}

######### Pt.5: Nuis Regress #########

## 11. Nuisance regression
# 11.1. Prepare the regressor matrix (don't run it! #x1D_stop)
3dDeconvolve -input ${func}_smth.nii.gz \
-censor censor_${subj}_combined_2.1D \
-ortvec roi_pc_01_WMe_noc.1D ROI.PC.WMe \
-ortvec roi_pc_02_CSFe_noc.1D ROI.PC.CSFe \
-polort 3 -float \
-num_stimts 12 \
-stim_file 1 ${func}_motion_demean.1D'[0]' -stim_base 1 -stim_label 1 roll_01 \
-stim_file 2 ${func}_motion_demean.1D'[1]' -stim_base 2 -stim_label 2 pitch_01 \
-stim_file 3 ${func}_motion_demean.1D'[2]' -stim_base 3 -stim_label 3 yaw_01 \
-stim_file 4 ${func}_motion_demean.1D'[3]' -stim_base 4 -stim_label 4 dS_01 \
-stim_file 5 ${func}_motion_demean.1D'[4]' -stim_base 5 -stim_label 5 dL_01 \
-stim_file 6 ${func}_motion_demean.1D'[5]' -stim_base 6 -stim_label 6 dP_01 \
-stim_file 7 ${func}_motion_deriv.1D'[0]' -stim_base 7 -stim_label 7 roll_02 \
-stim_file 8 ${func}_motion_deriv.1D'[1]' -stim_base 8 -stim_label 8 pitch_02 \
-stim_file 9 ${func}_motion_deriv.1D'[2]' -stim_base 9 -stim_label 9 yaw_02 \
-stim_file 10 ${func}_motion_deriv.1D'[3]' -stim_base 10 -stim_label 10 dS_02 \
-stim_file 11 ${func}_motion_deriv.1D'[4]' -stim_base 11 -stim_label 11 dL_02 \
-stim_file 12 ${func}_motion_deriv.1D'[5]' -stim_base 12 -stim_label 12 dP_02 \
-fout -tout -x1D nuis_reg_mat.1D -xjpeg nuis_reg_mat.jpg \
-x1D_uncensored nuis_reg_uncensored_mat.1D \
-fitts ${func}_fitts.nii.gz \
-errts ${func}_errts.nii.gz \
-x1D_stop \
-bucket ${func}_allparams.nii.gz

# 11.2. Actually regress.
3dTproject -polort 0 -input ${func}_smth.nii.gz \
-censor censor_${subj}_combined_2.1D -cenmode ZERO \
-ort nuis_reg_uncensored_mat.1D -prefix ${func}_pp.nii.gz

# 11.3. Compute temporal SNR map after denoising
3dTstat -mean -prefix ${func}_pp_mean.nii.gz ${func}_smth.nii.gz
3dTstat -stdev -prefix ${func}_pp_std.nii.gz ${func}_pp.nii.gz
3dcalc -a ${func}_pp_mean.nii.gz -b ${func}_pp_std.nii.gz -expr 'a/b' -prefix ${func}_pp_tSNR.nii.gz

# 11.4. Compute and store GCOR (global correlation average)
# (sum of squares of global mean of unit errts)
3dTnorm -norm2 -prefix ${func}_errts2.nii.gz ${func}_pp.nii.gz
3dmaskave -quiet -mask ${func}_wp_mask.nii.gz ${func}_errts2.nii.gz              \
          > gmean.errts.unit.1D
3dTstat -sos -prefix - gmean.errts.unit.1D\' > out.gcor.1D
echo "GCOR = `cat out.gcor.1D`"


######### Pt.6: Normalise    #########
# We'll skip it. But try to write it! The command is antsApplyTransforms, the input file is ${func}_pp.nii.gz

#########    !!!END OF PREPROC!!!    ######### 
######### CHECK YOUR REGISTRATION!!! #########


### For "fun": try to run melodicICA:
# melodic -i ${func}_pp.nii.gz -o ICA -d 30 --report --Oall