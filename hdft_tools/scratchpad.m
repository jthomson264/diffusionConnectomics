fib_file = '/data/QualityTests/code_dev_bin/data/20090203_M027Y_32channel2_03.src.gz.odf8.f3.gqi.1.2.fib.gz';
seed_file = '/data/QualityTests/code_dev_bin/data/ODF_mask.nii';
roi1_file = '/data/QualityTests/code_dev_bin/data/rinf_frontal_Triangular.nii';
roi2_file = '/data/QualityTests/code_dev_bin/data/intersect_ROI_from_mricron.nii';
roi_files = {roi1_file, roi2_file};
out_file = 'test1.trk';

dsi_studio_track(fib_file,seed_file,out_file,'roi',roi_files,'track_count',10000)
