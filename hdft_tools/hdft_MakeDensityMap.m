function nii = hdft_MakeDensityMap(track_file, nii_file, indx, varargin);

% function nii = hdft_MakeDensityMap(track_file, nii_file, indx, varargin);

% Default flipping options
FLIP_X = 0;  % Appears that right now the tracks are flipped in x
FLIP_Y = 0;  
FLIP_Z = 0;

% Get variable input parameters
for v=1:2:length(varargin),
    eval(sprintf('%s = varargin{%d};',varargin{v},v+1));
end;

% Put in switch if it's been converted to a matlab file
if isstruct(track_file);
    trk = track_file; clear track_file;
else
    [fpath, fname, fext] = fileparts(track_file);
    switch fext
        case '.mat'
            load(track_file);
        case '.trk'
            trk = read_trk(track_file);
        otherwise
            error('Unknown track file type');
    end;
end;

if nargin < 3 | isempty(indx);
    indx = 1:length(trk.fiber);
end;

% Grab the nifti file
nii = load_untouch_nii(nii_file);

% Check dimensions
if sum(size(nii.img)'-double(trk.header.dim))
    error('Matrix dimensions must agree to write voxels');
end;


hdrs = num2cell(repmat(trk.header,1,length(indx)));
xyz = cell2mat(cellfun(@cellfcn_AllVoxExtract,trk.fiber(indx),hdrs,'UniformOutput',0)');

% Convert to voxel space
good_vals = ~isnan(xyz(:,1));
voxel_vals = xyz(good_vals,:);

% Setup the new image matrix
img = NaN(size(nii.img));

% Determine the slice boundaries
edges = {1:trk.header.dim(1) 1:trk.header.dim(2)};

% loop per slice;
rel_slices = unique(voxel_vals(:,3));

if ~rel_slices(1) & rel_slices(end)<size(img,3);
    rel_slices = rel_slices+1;
elseif ~rel_slices(1)
    rel_slices = rel_slices(2:end);
end;

for s = 1:length(rel_slices);
    slice_num = rel_slices(s);    
    vox_indx = find(voxel_vals(:,3)==slice_num);
    img(:,:,slice_num) = hist3(voxel_vals(vox_indx,1:2),edges);
end;

% Flip if requested
if FLIP_X
    img = flipdim(img,1);
end;

if FLIP_Y
    img = flipdim(img,2);
end;

if FLIP_Z
    img = flipdim(img,3);
end;

% Then give the output
nii.img = img;
