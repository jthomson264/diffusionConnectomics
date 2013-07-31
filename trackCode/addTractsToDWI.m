function [ DWI ] = addTractsToDWI( DWI, btable, tracts)
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here


if (~all(DWI.hdr.dime.dim(2:4) == tracts.header.dim'))
    error('The dimensions of your DWI and tracts do not match.');
end

if (~all(DWI.hdr.dime.pixdim(2:4) == tracts.header.voxel_size'))
    error('The sizes of voxels in your DWI and tracts do not match.');
end



for i = 1:tracts.header.n_count
    DWI = addTractToDWI(DWI, btable, tracts.fiber{i}.points);
end


end

