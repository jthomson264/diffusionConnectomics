function nii = hdft_xyz2nii(xyz, trk_hdr, nii_file, varargin);

% Default flipping options
FLIP_X = 1;  % Appears that right now the tracks are flipped in x
FLIP_Y = 0;  
FLIP_Z = 0;

% Get variable input parameters
for v=1:2:length(varargin),
    eval(sprintf('%s = varargin{%d};',varargin{v},v+1));
end;

% Grab the nifti file
nii = load_nii(nii_file);

% Check dimensions
if sum(size(nii.img)'-double(trk_hdr.dim))
    error('Matrix dimensions must agree to write voxels');
end;

% Convert to voxel space
[vx, vy, vz] = mm2voxel(xyz(:,1),xyz(:,2),xyz(:,3),trk_hdr);
good_vals = ~isnan(vx);
voxel_vals = [vx(good_vals) vy(good_vals) vz(good_vals)];

% Setup the new image matrix
img = NaN(size(nii.img));

% Determine the slice boundaries
edges = {1:trk_hdr.dim(1) 1:trk_hdr.dim(2)};

% loop per slice;
rel_slices = unique(voxel_vals(:,3));


for s = 1:length(rel_slices);
    slice_num = rel_slices(s);    
    indx = find(voxel_vals(:,3)==slice_num);
    img(:,:,slice_num) = hist3(voxel_vals(indx,1:2),edges);
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