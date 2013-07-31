function output = hdft_ROIpos_summary(roi_files, varargin);

% function output = hdft_ROIpos_summary(roi_file_list, optlabel, optvalue);
% 
% Takes a list of nifti files and pulls out the non-zero xyz coordinates
% 
% INPUT:
%     roi_files = cell or char array of file pointers
%     opts = optional input flags
%         FLIP_X : Flip the x-dimension (default=0)
%         FLIP_Y : Flip the x-dimension (default=1)
%         FLIP_Z : Flip the z-dimension (default=0)
% 
% OUTPUT:
%     output.ROINAME.xyz = Nx3 array of ROI voxel positions
%     output.ROINAME.hdr = Nifti header from (load_nii.m)
% 
% Written by T. Verstynen, October 2010

   
% Flags for flipping the matrix if needed
FLIP_X = 0;
FLIP_Y = 0;
FLIP_Z = 0;

% Get variable input parameters
for v=1:2:length(varargin),
    eval(sprintf('%s = varargin{%d};',varargin{v},v+1));
end

if ischar(roi_files);
    n_files = size(roi_files,1);
    char_array = 1;
elseif iscell(roi_files);
    n_files = length(roi_files);
    char_array = 0;
else
    error('Unknown list type for files: Needs to be a character or a cell array');
end;

% Loop through for each file
for f = 1:n_files;
    
    if char_array
        file = deblank(roi_files(f,:));
    else
        file = roi_files{f};
    end;
    
    [fpath, fname, fext] = fileparts(file);

    % Store as output based on the file name    
    eval(sprintf('output.%s = hdft_ROIpos_extract(file, \''FLIP_X\'', FLIP_X, \''FLIP_Y\'', FLIP_Y,\''FLIP_Z\'', FLIP_Z);',...
        fname));
end;

    