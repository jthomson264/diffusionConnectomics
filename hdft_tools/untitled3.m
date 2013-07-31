function output = hdft_ROIcoord_extract(roi_files);

if ischar(roi_files);
    n_files = size(P,1);
    char_array = 1;
elseif iscell(roi_files);
    n_files = length(roi_files);
    char_array = 0;
else
    error('Unknown list type for files: Needs to be a character or a cell array');
end;

for f = 1:n_files;
    
    if char_array
        file = deblank(roi_files(f,:));
    else
        file = roi_files{f};
    end;
    
    [fpath, fname, fext] = fileparts(file);
    
    eval(sprintf('output.%s = hdft_ROIpos_extract(
    