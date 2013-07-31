function summary = hdft_track_summary(trk_file,varargin);

% function summary = hdft_track_summary(file,varargin);
% 
% Takes a nifti ROI file and pulls out the xyz coordinates
% 
% INPUT:
%     file = path to track file (.trk or .mat) or track structure
%     opts = optional input flags
%         SORTDIM : Dimension in which to align fibers (so they all start
%         and end at the same place (0=none, 1=x, 2=y, 3=x[default]);
%         SAVE_POINTS : Flag for whether or not to save the raw position
%         information.  Default=1, but can cause for extremely large file
%         sizes with large track files.  If set to 0, then the *_xyz fields
%         are not returned in the summary output
%
% OUTPUT:
%   summary.fiber_lens = Nx1 array of fiber lengths (in mm);
%   summary.mean_fiber_len = mean fiber length (in mm);
%   summary.var_fiber_len  = variance of fiber lengths (in mm);
%   summary.endpt_xyz      = Nx3 array of fiber endpoint locations
%   summary.endpt_mean     = 1x3 array of mean endpoint location
%   summary.endpt_cov      = 3x3 array of the covariance of endpoint locations
%   summary.begpt_xyz      = Nx3 array of fiber start locations
%   summary.begpt_mean     = 1x3 array of mean start location
%   summary.begpt_cov      = 3x3 array of the covariance of start locations
%
% Written by T. Verstynen, October 2010

SAVE_POINTS = 1;
SORTDIM = 3; % Sort the tracks for summarizing

% Get variable input parameters
for v=1:2:length(varargin),
    eval(sprintf('%s = varargin{%d};',varargin{v},v+1));
end

% Load the track file (matris or otherwise)
if ~isstruct(trk_file);
  trk = read_trk(trk_file);
else
  trk = trk_file; clear trk_file;
end;

% Store header info
summary.header = trk.header;

% Get fiber length info
summary.fiber_lens = cellfun(@cellfcn_FiberLen,trk.fiber);
summary.mean_fiber_len = nanmean(summary.fiber_lens);
summary.var_fiber_len  = nanvar(summary.fiber_lens);

% Get the enpoint info
tmp = hdft_endpoint_extract(trk,'steps',0,'SORTDIM', SORTDIM);
summary.endpt_mean = mean(tmp.end_xyz);
summary.endpt_cov  = cov(tmp.end_xyz);
summary.begpt_mean = mean(tmp.beg_xyz);
summary.begpt_cov  = cov(tmp.beg_xyz);

if SAVE_POINTS
    summary.endpt_xyz = tmp.end_xyz;
    summary.begpt_xyz = tmp.beg_xyz;
end;

