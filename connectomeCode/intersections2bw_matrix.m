function [ bw_matrix, names ] = intersections2bw_matrix( intersectionObject )
%
%   An intersectionObject is the output returned by hdft_endpoint_overlap,
%   containing an array of N structs, each with the ROI name and a .beg and
%   .end indicating on the unit interval the value for the mask label for
%   the tract.  The labels would be binary, but become reals when
%   translated into the lower resolution DTI space after merging with other
%   voxels in FLIRT.
%
%   This function computes a sparse matrix of the number of connections b/w
%   each named region.

%   N is the number of ROIs
N = length(intersectionObject);

%   bw_matrix is the matrix of bandwidths
bw_matrix = zeros(N,N);

%   names is a cell array of string labels for the ROIs
names = {};

for i = 1:N
   
    names = [names ; intersectionObject(i).ROI];
    
    ibeg = intersectionObject(i).intersect.beg;
    iend = intersectionObject(i).intersect.end;
    
    for j = (i+1):N
        
       jbeg = intersectionObject(j).intersect.beg;
       jend = intersectionObject(j).intersect.end;
        
       bw_matrix(i,j) = ibeg'*jend + jbeg'*iend;
       bw_matrix(j,i) = bw_matrix(i,j);
       
    end
    
end


end

