function [IMG, hdr]=dicom_mosaic_loader(dicom_files);

if iscell(dicom_files);
    n_files = length(dicom_files);
elseif isstr(dicom_files);
    n_files = size(dicom_files,1);
else
    error('Unknown file list type');
end;

for f = 1:n_files
    if iscell(dicom_files);
        file = dicom_files{f};
    else
        file = deblank(dicom_files(f,:));
    end;

    % Load the dicom image and hdr
    X = dicomread(file);
    hdr{f} = dicominfo(file);

    % Image dimensions and data
    %-------------------------------------------------------------------
    nc = hdr.Columns;
    nr = hdr.Rows;
    
    acq_mat = hdr.AcquisitionMatrix;
    phase_dim = acq_mat(1);
    readout_dim = acq_mat(end);
    
    n_c_img = nc / phase_dim;
    n_r_img = nr / readout_dim;
        
    encode_indx = 1;
    
    for c = 1:n_c_img
        for r = 1:n_r_img;
            matindx(1,:) = phase_dim*(c-1)+1:phase_dim*c;
            matindx(2,:) = readout_dim*(r-1)+1:readout_dim*r;
            
            if length(find(X(matindx(1,:),matindx(2,:))));
                IMG(:,:,encode_indx,f) = X(matindx(1,:),matindx(2,:));
                encode_indx = encode_indx+1;
            end;
        end
    end;
end;
            
            
        
    