Here are the instructions for how to run the segmentation codes.

FreeSurfer outputs a file called aparc.a2009s+aseg.mgz which has been converted to aparc.a2009s+aseg.nii using the "mri_convert" function.
You'll need to use this NIfTI file with the Matlab scripts in this folder.
If you DO NOT have Matlab and SPM8, please check out the FreeSurfer Wiki for further instructions to extract the ROIs.

If you DO have Matlab and SPM8, you can run the following command once the scripts are added to your Matlab path.
Do this for each individual aparc.a2009s+aseg.nii file.
The script will create 170 ROIs (~80 per hemisphere and ~5-10 subcortical structures) in NIfTI format in the working directory.
From the Matlab command line:

>> segment_fresurfer_roi('aparc.a2009s+aseg.nii')

And that's it. It should take about 1-2 minutes to full segment and name the ROIs correctly.
Once this is done, you can use your image analysis package of choice to coregister/normalize the ROIs to the appropriate image space.

As a note, only one aparc.a2009s+aseg.nii file is provided for each subject, as each set of ROIs would be the same across scans for each subject.
