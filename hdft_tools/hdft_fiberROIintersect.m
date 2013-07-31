function output = hdft_fiberROIintersect(track_file, roi_coords_object, varargin)

% function output = hdft_endpoint_extract(trackfile, roi_object, optlabel, optvalue);
% 
% Takes a nifti ROI file and pulls out the xyz coordinates
% 
% INPUT:
%     file = path to track file (.trk or .mat)
%     roi_object = position output from hdft_ROIpos_extract.m
%     opts = optional input flags
%       DOSORT : Sort the fibers to all point in the same direction
%       (requires that SORTDIM also be set; DEFAULT = 0);
%
%       SORTDIM : Dimension to sort the fiber orientatin by (1=x,2=y,3=z[DEFAULT])
%
%       SUMMARY_TYPE : way to get the xyz fiber position.  Options are
%       'mean' (mean fiber position in the ROI; DEFAULT), 'median' (median fiber
%       position within the ROI), 'first' (first point the fiber intersects
%       with the ROI), and 'last' (last point of the fiber within the ROI).
%           NOTE: For 'first' and 'last', it is recommended that the fibers
%           are sorted first.
%
% OUTPUT:
%     output.xyz = Nx3 array of fiber positions (in mm space)
%     output.hdr = .trk file header
%
% Written by T. Verstynen, October 2010
    
DOSORT       = 0; % Do a sort so the penetration point is the same (DEFAULT = 1);
SORTDIM      = 3; % Dimension to sort the fiber orientatin by (1=x,2=y,3=z[DEFAULT])
SUMMARY_TYPE = 'mean'; % 'mean', 'median','first', 'last';

% Get variable input parameters
for v=1:2:length(varargin),
    eval(sprintf('%s = varargin{%d};',varargin{v},v+1));
end

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

% Setup the other inputs to be cells arrays as well
for f = 1:length(trk.fiber);
    hdr{f} = trk.header;
    xyz{f} = roi_coords_object.xyz;
end;

if DOSORT
  sort_dim = num2cell(ones(size(trk.fiber))*SORTDIM);
  trk.fiber = cellfun(@cellfcn_FiberSort, trk.fiber, sort_dim,'UniformOutput',0);
end;
  
% Store the track header
output.header = trk.header;

% Find all intersection points.
intersect_xyz = cellfun(@cellfcn_FiberIntersect, trk.fiber,hdr,xyz,'UniformOutput',0);

switch SUMMARY_TYPE
    case 'mean'
        output.xyz = cell2mat(cellfun(@mean,intersect_xyz','UniformOutput',0));
    case 'median'
        output.xyz = cell2mat(cellfun(@median,intersect_xyz','UniformOutput',0));
    case 'first'
          step_input = num2cell(zeros(size(trk.fiber)));
          begstarts  = num2cell(zeros(size(trk.fiber)));
          % Grab the beginning fibers
          output.xyz = cell2mat(cellfun(@cellfcn_GetFiberEnd, ...
			   intersect_xyz, begstarts,...
			   'UniformOutput',0)');
    case 'last'
          step_input = num2cell(zeros(size(trk.fiber)));
          endstarts  = num2cell(ones(size(trk.fiber)));
          % Grab the end fibers
          output.xyz = cell2mat(cellfun(@cellfcn_GetFiberEnd, ...
			   intersect_xyz, endstarts,...
			   'UniformOutput',0)');
    otherwise
        error(sprintf('%s is an unknown summary method', SUMMARY_TYPE));
end;

% Thens save number of points that intersect with said ROI
N = cell2mat(cellfun(@size,intersect_xyz','UniformOutput',0));
output.N = N(:,1);

