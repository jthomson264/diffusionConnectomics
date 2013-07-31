function roi_separator(roi_img, region_indx_list, region_name_list);

V = spm_vol(roi_img);
XYZ = spm_read_vols(V);
cats = unique(region_indx_list);

for c = 1:length(cats);
    
    % Select a single ROIs
    nXYZ = zeros(size(XYZ));
    nXYZ(find(XYZ(:)==cats(c)))=1;
    
    % Make new header
    nV = V;
    
    [fpath, fname] = fileparts(nV.fname);
    
    if isempty(region_name_list) | nargin < 3
      nV.fname = fullfile(fpath,[fname sprintf('_roi%0.3o.nii',cats(c))]);
    else
      nV.fname = fullfile(fpath,[fname sprintf('_roi-%s.nii', ...
					       region_name_list{c})]);;
    end;
      
    spm_write_vol(nV, nXYZ);
end;
