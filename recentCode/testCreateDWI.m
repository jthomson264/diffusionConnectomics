%   This script is going to make one big DSI, full-size, just to test that
%   I can do it.  I'll have only one tract, and I want to be able to
%   recover it w/ DSI Studio.

tracts = read_trk('smalltracks.trk');
data = load_nii('~/data/mybrain/data.nii');
load('~/data/mybrain/btab');
disp('All data loaded ...');

%   Now clear out the DWI.
data.img(:,:,:,1) = 0;
data.img(:,:,:,2:515) = 0;      %   This won't remain zero anywhere, as I'll be adding tons of isotropic signal.

%   First make a single tract.
oneTract = makeTract(1000, 0.5, pi/20, true, true);

%   Add it to your tracts struct
tracts.header.n_count = 0;
tracts.fiber = {};                          % (emptying it.)
tracts = addTractMatrix2TractStruc(oneTract, tracts);
disp('Tracts struct created ...');

%   I think I've already checked the header for tracts, and it matches just
%   fine.


%   So now I create the new DWI.
newDWI = createDWIfromTracts(data, btab, tracts);