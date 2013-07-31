function [ done ] = showPDF( diffusionPDF )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
%   This is just to briefly look at the pdf of one voxel.

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
            s(l) = diffusionPDF(i,j,k);
            l = l+1;
        end
    end
end

scatter3(x,y,z,s);




end

