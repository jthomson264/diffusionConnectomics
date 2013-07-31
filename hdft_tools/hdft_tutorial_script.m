
% First the relevant pointers
trk_file = 'data/DSI/Arcuate.trk';
roi1_file  = 'data/DSI/intersect_ROI_from_mricron.nii'
roi2_file = 'data/DSI/rinf_frontal_Triangular.nii';

% Step 1: Extract fiber endpionts
%    Grab the fiber endpoints only (no steps back) and sort based on their
%    z-dimension
fiber_output = hdft_endpoint_extract(trk_file,'steps',0,'SORTDIM',3);

% Step 2: Extract the ROI enpoints (individual file first)
%    Right now the tracks are all in radiological space (origin problem).
%    so I flip the output in the z-direction
roi1_output = hdft_ROIpos_extract(roi1_file,'FLIP_X',1);

% Step 3: Do Step 2 for a group of ROIS
rois = {roi1_file, roi2_file};
all_roi_output = hdft_ROIpos_summary(rois, 'FLIP_X', 1);

% Step 4: Find the intersetion of the tracks per- ROI and save as a nifti
roi1_pos = hdft_fiberROIintersect(trk_file, roi1_output, ...
    'SUMMARY_TYPE','mean','DOSORT',0,'SORTDIM',2);
save_nii(hdft_xyz2nii(roi1_pos.xyz,roi1_pos.header,roi1_file,'FLIP_Y',1),'roi1_test.nii');

% Step 5: Repeat the same for the start and endpoints of the fiber
save_nii(hdft_xyz2nii(fiber_output.beg_xyz,...
    fiber_output.header,roi1_file,'FLIP_Y',1),'begpoint_test.nii');

save_nii(hdft_xyz2nii(fiber_output.end_xyz,...
    fiber_output.header,roi1_file,'FLIP_Y',1),'endpoint_test.nii');

% Step 6: Save the density map of the track file, use the first ROI as the
% template image
hdft_make_density_map(trk_file, roi1_file,'out_file','example_density_map.nii','FLIP_X',1);

% Step 7: Summarize the track data
summary = hdft_track_summary(trk_file);

% Next on the docket:
% 1) Functional activitation linking: BE GENERAL!
% 2) Endpoint termination test port