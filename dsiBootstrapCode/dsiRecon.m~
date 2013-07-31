% Thanks Jiaying Zhang for sharing this DSI code
% the dimension of data used here is n*1, and n refers to the number of 
% images, including the image of b0 .
% the dimension of odf_vertices used here is 642*3.
% the dimension of q table is n*3.
% Note that your q table loaded here is the same as the mgh_dsi_q.txt.


% !!!!!!!!!1  I am not right now using the Hanning Filter.   !!!!!!!!!
% Hanning filter
%hanning_filter=zeros(size(b_table,1),1);% b_table is 203*4,515*4 etc
%for i=1:n
%    hanning_filter(i,1)=0.5*(1.0+cos(2.0*pi*sqrt(sum(q(i,:).*q(i,:)))/16));
%end
% the signal after hanning filter
%value=s.*hanning_filter;   %s, n*1, the modulus of the signal
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%q=load('mgh_dsi_q.txt');
% The download link for this file in at the bottom of this page

% to get the q space index
%q=q+9;

%   Those two bits are replaced with:

%   First load the btable.  This is b-value followed by b-vector.
btable = load('btab');
%   Pull out just the vector.
bvecs = btable(:,2:4);
%   Now multiply each dimension by the root of the b-value, so the vectors
%   are aligned in space correctly.
bvecs(:,1) = sqrt(btable(:,1)) .* bvecs(:,1);
bvecs(:,2) = sqrt(btable(:,1)) .* bvecs(:,2);
bvecs(:,3) = sqrt(btable(:,1)) .* bvecs(:,3);
%   We now want the bvecs to give us integer indices
bvecs = bvecs / max(max(bvecs));
%   Note the arbitrary five.  You need to find the appropriate number for
%   your DSI scan parameters.  Look at size(round(unique(bvecs*x))) and you
%   should have the size be 2x+1 for a DSI grid.
gridNumber = 5;
bvecs = round(bvecs*gridNumber) + gridNumber + 1;
dimNumber = 2*gridNumber + 1;

% To value sq
sq=zeros(dimNumber, dimNumber, dimNumber);
for i=1:n
    sq(q(i,1),q(i,2),q(i,3))=value(i);
end



Pr=fftshift(abs(real(fftn(fftshift(sq),[dimNumber,dimNumber,dimNumber]))));



%   The following bit is just to plot the pdf.
N = 11^3;
x = zeros(N,1);
y = zeros(N,1);
z = zeros(N,1);
s = zeros(N,1);
l = 1;

%   Now I want to plot the pdf.
for i = 1:11
    for j = 1:11
        for k = 1:11
            x(l) = i;
            y(l) = j;
            z(l) = k;
            s(l) = Pr(i,j,k);
            l = l+1;
        end
    end
end

scatter3(x,y,z,s);






%To calculate PDF of each voxel
Pr=fftshift(abs(real(fftn(fftshift(sq),[dimNumber,dimNumber,dimNumber]))));