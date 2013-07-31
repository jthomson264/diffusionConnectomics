function [ trk, begPts, endPts ]=trkEnds(trkName,varargin)
% Output track endpoints as 2 ascii files: beginning and end points.
% Syntax:
% [begPts, endPts]=trkEnds(trkName, varargin)
% trkName: character string giving the name of a trk file
% varargin(1): optional stem for ascii output
% varargin(2): optional orientation flag
%	if 1 > flip x and y signs to match FreeSurfer surface volume
% 	if 0 (default) > no change
% Note that if trk file is version 2, this function will attempt to
% apply the vox_to_ras matrix in the trk header to the output coordinates.
% 9/13/2011, Jeff Phillips, University of Pittsburgh

if length(varargin)==0;
	outStem=strrep(trkName,'.trk','');
    flips=0;
elseif length(varargin)==1;
	outStem=char(varargin(1));
	flips=0;
elseif length(varargin)==2;
	outStem=char(varargin(1));
	flips=cell2mat(varargin(2));
else;
	error('Too many arguments?');
end;

trk=read_trk_fast(trkName);

begPts=zeros(length(trk.fiber),3);
endPts=zeros(length(trk.fiber),3);

%if trk.header.version==2
%	for f=1:length(trk.fiber);
%		beg1=trk.header.vox_to_ras'*[trk.fiber{f}.points(1,:) 1]';
%	    	begPts(f,:)=beg1(1:3);
%		end1=trk.header.vox_to_ras'*[trk.fiber{f}.points(end,:) 1]';
%	    	endPts(f,:)=end1(1:3);
%	end
%else

if length(trk.fiber)>0;
	for f=1:length(trk.fiber);
	    begPts(f,:)=trk.fiber{f}.points(1,:);
	    endPts(f,:)=trk.fiber{f}.points(end,:);
	end
end;

%end

if flips==1
	begPts=[ -1*begPts(:,1) -1*begPts(:,2) begPts(:,3) ];
	endPts=[ -1*endPts(:,1) -1*endPts(:,2) endPts(:,3) ];
end

fname=[outStem '_begPts.txt'];

fid=fopen(fname,'w');

if size(begPts,1)>0;
	for i=1:size(begPts,1);
	    fprintf(fid, '%15.6f %15.6f %15.6f\n', begPts(i,:));
	end;
end;

fclose(fid);

fname=[outStem '_endPts.txt'];

fid=fopen(fname,'w');

if size(endPts,1)>0;
	for i=1:size(endPts,1);
	    fprintf(fid, '%15.6f %15.6f %15.6f\n', endPts(i,:));
	end;
end;

fclose(fid);
