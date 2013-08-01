%   I need a way to change my 3x1 (4D) DSI volume into a 6d volume.  
%   I want to do this just so moving b/w neighbor voxels (in the diffusion
%   wave vector space) is easier.

%   The btable has the squared magnitude in the 1st column, and then the
%   normalized diffusion wave vectors in the next three.  There are 515,
%   which is an 8x8x8 grid, along with a value at 0,0,0 and then three at
%   extremes for dx, dy, dz.  I'm going to do two things to this grid.
%   I'll zero-pad it, and I'll double the data.

%   I'm zero-padding becuase I will want to hold copies in memory by
%   grabbing a full 5d array of data one voxel over (in diffusion space).
%   This will let me smooth the data for very high b-values without
%   worrying about special cases.  I'll already have a full data set for
%   every q-vector and won't need special coding for the edge-cases.  

%   I'm doubling the data becuase the diffusion PDFs exhibit symmetry of
%   reflection across the origin.  So my signal W(x, q) = W(x, -q).  I am
%   not at all concerned about this doubling causing me to doubly weight
%   individual observations in specific local gradient descents.  The only
%   place where it will come into play is calculating degrees of freedom.
%   Otherwise, doubling the observations will just expand/fill my grid to
%   16x16x16.  Adding the zeros will make it .. 18^3 maybe.

load('~/data/mybrain/btab');
bvecs = btab(:,2:4);
for i = 1:3
    bvecs(:,i) = bvecs(:,i) .* sqrt(btab(:,1));
end

