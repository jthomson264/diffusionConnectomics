function tracks = read_trk_fast( filename )

% tracks = read_trk( filename)
% read_trk reads fiber tracks output from trackvis
% Input:
%       filename: Name of track file output from trackvis
%                 The extension of file is .trk
% Output:
%       tracks is a matlab structure.
%       It contains following fields:
%           header: is a matlab structure. It contains all header information
%                   requires to visualize fiber tracks in trackvis.
%           fiber: is a matlab cell. Each cell corresponds to a single fiber.
%                  Each fiber is a matlab structure. It contains following fields;
%                  num_points: Number of points in a fiber tracks.
%                  points    : is a num_points X 3 matrix, each row
%                              contains (x, y, z) coordinate location in
%                              mm coordinate space.
%
% For details about header fields and fileformat see:
% http://www.trackvis.org/docs/?subsect=fileformat
%
%
% Example;
%
% tracks = read_trk('hardiO10.trk');
% tracks =
%
%     header: [1x1 struct]
%      fiber: {[1x1 struct]}
%
% written by Sudhir K Pathak
% Date: March 7 2011
% for PghBC2009 competition 2009 url:http://sfcweb.lrdc.pitt.edu/pbc/2009/
% NOTE: This program reads a binary fiber tracking file output from TrackVIS in native format
% If you reading .trk file on big endian machine change fopen function:
% fid = fopen(filename ,'r', 'ieee-le');
%
% $Id: read_trk.m,v 1.1 2009/03/26 16:09:06 fissell Exp $
%
% KF 4/2011 if a track has 0 fibers currently structure field fiber is not
%	set.  I am changing that to default to a cell array of length 0
%	so tracks.fiber is always a valid field.
% KF 7/2011 changed multi-char reads from 'char=>char' to 'uint8=>char' as 
%	matlab seemed to want trailing 0 on char read
% KF 9/11 fixed bug in reading scalars, only 3 coords not 3 coords + scalars were being read
% KF 9/11 fixed bug matlab fread needed size parameter cast as double
% KF 1/12 initialized tracks.fiber with cell() call for efficiency
%


% try

tstart = clock;

fid = fopen(filename ,'r');

if fid < 0
    error(['error reading to file', filename]);
end

tracks.header.id_string                  = fread(fid,6,'char=>char');
tracks.header.dim                        = fread(fid,3,'int16=>int16');
tracks.header.voxel_size                 = fread(fid,3,'float');
tracks.header.origin                     = fread(fid,3,'float');
tracks.header.n_scalars                  = fread(fid,1,'int16=>int16');
tracks.header.scalar_name                = fread(fid,200,'uint8=>char');
tracks.header.n_properties               = fread(fid,1,'int16=>int16');
tracks.header.property_name              = fread(fid,200,'uint8=>char');
tracks.header.reserved                   = fread(fid,508,'uint8=>char');
tracks.header.voxel_order                = fread(fid,4,'uint8=>char');
tracks.header.pad2                       = fread(fid,4,'uint8=>char');
tracks.header.image_orientation_patient  = fread(fid,6,'float');
tracks.header.pad1                       = fread(fid,2,'uint8=>char');
tracks.header.invert_x                   = fread(fid,1,'uchar');
tracks.header.invert_y                   = fread(fid,1,'uchar');
tracks.header.invert_z                   = fread(fid,1,'uchar');
tracks.header.swap_xy                    = fread(fid,1,'uchar');
tracks.header.swap_yz                    = fread(fid,1,'uchar');
tracks.header.swap_zx                    = fread(fid,1,'uchar');
tracks.header.n_count                    = fread(fid,1,'int');
tracks.header.version                    = fread(fid,1,'int');
tracks.header.hdr_size                   = fread(fid,1,'int');

fprintf(1,'Reading Fiber Data ...\n');
tracks.fiber = cell(1,tracks.header.n_count);

pct = 10;
no_fibers = tracks.header.n_count;
if tracks.header.n_scalars == 0
    
    if tracks.header.n_properties == 0
        
        for i=1:no_fibers
            tracks.fiber{i}.num_points = fread(fid,1,'int');
            tracks.fiber{i}.points = fread(fid,[3,tracks.fiber{i}.num_points],'float')';
            if mod(i,floor(no_fibers/10)) ==  0
                fprintf(1,'\n%3d percent fibers processed...', pct);
                pct = pct + 10;
            end;
        end;
        
    else
        for i=1:no_fibers
            tracks.fiber{i}.num_points = fread(fid,1,'int');
            tracks.fiber{i}.points = fread(fid,[3,tracks.fiber{i}.num_points],'float')';
            tracks.fiber{i}.nproperty = fread(fid,[1,tracks.header.n_properties],'float');
            if mod(i,floor(no_fibers/10)) ==  0
                fprintf(1,'\n%3d percent fibers processed...', pct);
                pct = pct + 10;
            end;
        end;
        
    end;
    
else
    
    if tracks.header.n_properties == 0
        for i=1:no_fibers
            tracks.fiber{i}.num_points = fread(fid,1,'int');
            dummy = fread(fid,[double(3+tracks.header.n_scalars),tracks.fiber{i}.num_points],'float')';
            tracks.fiber{i}.points = dummy(:,1:3);
            tracks.fiber{i}.scalars = dummy(:,4:end);
            if mod(i,floor(no_fibers/10)) ==  0
                fprintf(1,'\n%3d percent fibers processed...', pct);
                pct = pct + 10;
            end;
        end;
        
    else
        
        for i=1:no_fibers
            tracks.fiber{i}.num_points = fread(fid,1,'int');
            dummy = fread(fid,[double(3+tracks.header.n_scalars),tracks.fiber{i}.num_points],'float')';
            tracks.fiber{i}.points = dummy(:,1:3);
            tracks.fiber{i}.scalars = dummy(:,4:end);
            tracks.fiber{i}.nproperty = fread(fid,[1,double(tracks.header.n_properties)],'float');
            if mod(i,floor(no_fibers/10)) ==  0
                fprintf(1,'\n%3d percent fibers processed...', pct);
                pct = pct + 10;
            end;
        end;
        
    end;
    
end;

fclose(fid);

fprintf(1,'\nElapsed time %s\n',etime(clock,tstart));

% catch
%     fprintf('Unable to access file %s\n', filename);
%     tracks = [];
% end;
