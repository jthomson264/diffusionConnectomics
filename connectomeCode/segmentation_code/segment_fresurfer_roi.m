function segment_fresurfer_roi(atlas_nifti, varargin);

% function segment_fresurfer_roi(atlas_nifti, opt_label, opt_value);
%
% INPUTS:
%   atlas_nift: the aparc.a2009s+aseg.nii file (use mri_convert if not in
%   nifit form)
%
% OPTIONS:
%   list_file: text file with region labels and roi number id's (default:
%   'relevant_label_list.txt' in code directory.
%
% Written by: T Verstynen (Dr. Badass) June, 2011

list_file = 'relevant_label_list.txt';

% Get variable input parameters
for v=1:2:length(varargin),
    eval(sprintf('%s = varargin{%d};',varargin{v},v+1));
end

D = dload(list_file);
roi_separator(atlas_nifti,D.Num, D.ID);