function output = hdft_endpoint_extract(trk_file, varargin);

% function output = hdft_endpoint_extract(file, optlabel, optvalue);
% 
% Takes a nifti ROI file and pulls out the xyz coordinates
% 
% INPUT:
%     file = path to track file (.trk or .mat)
%     opts = optional input flags
%         steps : Rrange of samples to estimate from track end (DEFAULT = 0:4)
%                 NOTE: value must start with 0 meaning no steps. 
%         SORTDIM : Dimension in which to align fibers (so they all start
%         and end at the same place (0=none[DEFAULT], 1=x, 2=y, 3=x)
%
% OUTPUT:
%     output.beg_xyz = Nx3xS array of fiber positions at the beginning of
%                       the fiber
%     output.end_xyz = Nx3xS array of fiber positions at the end of
%                       the fiber
%     output.header  = header structure from the track file
%
% Written by T. Verstynen, October 2010
    

steps = 0:4; % How many steps out to extract the endpoints
SORTDIM= 0;  % Which dimension to organize the fibers by

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

if SORTDIM > 0
  sort_dim = num2cell(ones(size(trk.fiber))*SORTDIM);
  trk.fiber = cellfun(@cellfcn_FiberSort, trk.fiber, sort_dim,'UniformOutput',0);
end;
    
% Loop through for each step back from the endpoints
for s = 1:length(steps)

  step_input = num2cell(ones(size(trk.fiber))*steps(s));
  endstarts  = num2cell(ones(size(trk.fiber)));
  begstarts  = num2cell(zeros(size(trk.fiber)));
  
  % Grab the beginning Fibers
  xyz_b = cell2mat(cellfun(@cellfcn_StepExtract, ...
			   trk.fiber, step_input,...
			   begstarts,...
			   'UniformOutput',0)');
  
  % Grab the end Fibers
  xyz_e = cell2mat(cellfun(@cellfcn_StepExtract, ...
			   trk.fiber, step_input,...
			   endstarts,...
			   'UniformOutput',0)');  

  % Store the output
  output.beg_xyz(:,:,s) = xyz_b;
  output.end_xyz(:,:,s) = xyz_e;
end;

% Get rid of the excess dimensions if only looking at the endpoints
if s == 1;
    output.beg_xyz = squeeze(output.beg_xyz);
    output.end_xyz = squeeze(output.end_xyz);
end;

% Store the track header
output.header = trk.header;	
