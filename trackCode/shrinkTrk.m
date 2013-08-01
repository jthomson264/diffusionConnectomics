function [ written ] = shrinkTrk( trackfile )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

trks = hdft_endpoint_extract(trackfile);

N_tracks = trks.header.n_count;

newN_tracks = floor(N_tracks/10);

trks.header.n_count = newN_tracks;

trks.beg_xyz = trks.beg_xyz(1:newN_tracks,:);
trks.end_xyz = trks.end_xyz(1:newN_tracks,:);

write_trk(trks, 'smallTracks1.trk');

written=1;

end

