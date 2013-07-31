function output = hdft_endpoint_overlap(trk_file, roi_files, varargin);

% function output = hdft_endpoint_overlap(track_file,roi_file_list, optlabel, optvalue);
% 
% Takes a list of nifti files and pulls out the non-zero xyz coordinates
% 
% INPUT:
%     track_file = path to track file (.trk or .mat) or the track structure
%     roi_file_list = cell or char array of file pointers
%     opts = optional input flags
%         FLIP_X : Flip the x-dimension (default=1)
%         FLIP_Y : Flip the x-dimension (default=0)
%         FLIP_Z : Flip the z-dimension (default=0)
%         SORTDIM: Dimension to sort the fiber data before categorizing.
%                   X=1, Y=2, Z=3, None=0;
%         steps : Rrange of samples to estimate from track end (DEFAULT = 0:4)
%                 NOTE: value must start with 0 meaning no steps. 
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

DOSORT = 0;
SORTDIM = 0;
steps = 0:2;

% Get variable input parameters
for v=1:2:length(varargin),
    eval(sprintf('%s = varargin{%d};',varargin{v},v+1));
end

% Load the track file (matris or otherwise)
if ~isstruct(trk_file);
    [fpath, fname, fext] = fileparts(trk_file);
    switch fext
        case '.trk'
            trk = read_trk(trk_file);
        case '.mat'
            load(trk_file);
        otherwise
            error('Unknown track file type');
    end;            
else
  trk = trk_file; clear trk_file;
end;
% Go through either a single ROI file pointer or an array
if ischar(roi_files);
    n_files = size(roi_files,1);
    char_array = 1;
elseif iscell(roi_files);
    n_files = length(roi_files);
    char_array = 0;
else
    error('Unknown list type for files: Needs to be a character or a cell array');
end;

% Extract out the fiber dimensions
fiber_out = hdft_endpoint_extract(trk,'SORTDIM',SORTDIM,'steps',steps);

% Loop through for each file
for f = 1:n_files;

    if char_array
        file = deblank(roi_files(f,:));
        roi_out = hdft_ROIpos_extract(file,'FLIP_X',FLIP_X,'FLIP_Y',FLIP_Y,...
            'FLIP_Z',FLIP_Z);
        [fpath, fname, fext] = fileparts(file);
    else
        if isstruct(roi_files{f});
            roi_out = roi_files{f};
            fname = sprintf('ROI%d',f);
        else
            file = roi_files{f};
            roi_out = hdft_ROIpos_extract(file,'FLIP_X',FLIP_X,'FLIP_Y',FLIP_Y,...
            'FLIP_Z',FLIP_Z);
            [fpath, fname, fext] = fileparts(file);
        end;
    end;
    
    output(f).ROI = fname;
    
    for s = 1:size(fiber_out.beg_xyz,3);
        b_xyz = squeeze(fiber_out.beg_xyz(:,:,s));
        [bvx, bvy, bvz] = mm2voxel(b_xyz(:,1),b_xyz(:,2),b_xyz(:,3),fiber_out.header);
        output(f).intersect(s).beg = prod(single(ismember([bvx bvy bvz],roi_out.xyz,'rows')),2);
        
        e_xyz = squeeze(fiber_out.end_xyz(:,:,s));
        [evx, evy, evz] = mm2voxel(e_xyz(:,1),e_xyz(:,2),e_xyz(:,3),fiber_out.header);
        output(f).intersect(s).end = prod(single(ismember([evx evy evz],roi_out.xyz,'rows')),2);
    end;

end;

    