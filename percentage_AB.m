function [ percentage ] = percentage_AB( trkfile, roi1file, roi2file )
%UNTITLED Summary of this function goes here, 
%   Detailed explanation goes here

roi1 = hdft_ROIpos_extract(roi1file);
roi2 = hdft_ROIpos_extract(roi2file);
trks = hdft_endpoint_extract(trkfile);

% Walk through start
N_fibers = trks.header.n_count;
works = zeros(N_fibers,1);

for i = 1:N_fibers
    % Pull a fiber
    tmp_fiberEND = trks.end_xyz(i,:);
    tmp_fiberSTART = trks.beg_xyz(i,:);

    % Update works
    if roiContainsPoint(tmp_fiberEND, roi1)
        if roiContainsPoint(tmp_fiberSTART, roi2)
            works(i) = 1;
        end
    end

    if roiContainsPoint(tmp_fiberEND, roi2)
        if roiContainsPoint(tmp_fiberSTART, roi1)
           works(i) = 1; 
        end
    end

end


percentage = (sum(works)/N_fibers);

end