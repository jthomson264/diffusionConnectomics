%   Make a trk-writeable thing of fake tracts.

N = 100;
K = 1000;
P = 0.5;
theta = pi/30;

tracts = read_trk('smalltracks.trk');
tracts.fiber = {};

tracts.header.n_count = 0;

for i = 1:K
    
   tract = makeTract(N,P,theta, 1, 1);
   
   tracts = addTractMatrix2TractStruc(tract, tracts);
    
    
end



