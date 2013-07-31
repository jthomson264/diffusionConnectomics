%   Make a fake signal and recover it.

N = 100;
fx = (1:N)/N;
fy = (1:N)/N;
[gridX, gridY] = meshgrid(fx,fy);

component1 = exp(-2*pi*sqrt(-1)*(10*gridX + 2*gridY));
component2 = exp(-2*pi*sqrt(-1)*(25*gridX + 25*gridY));
component3 = exp(-2*pi*sqrt(-1)*(3*gridX + 13*gridY));

realSignal = component1 + 4.2*component2 + (1/2)*component3;

NN = N*N;
K = 200;
R = randsample(NN,K);

%   Form observations
Y = realSignal(R) + normrnd(0,sigma,K,1);

%   Form measurement matrix
gridX = gridX(1:NN);
gridY = gridY(1:NN);
%   Take only the samples
gridX = gridX(R);
gridY = gridY(R);

RPhiPsi = zeros(K,B);
disp('Really making measurement matrix now');
PsiRow = zeros(b1,b2);
for i = 1:K
    for omegaX = 1:b1
        for omegaY = 1:b2
            PsiRow(omegaX,omegaY) = exp(-2*pi*sqrt(-1)*((omegaX-1)*gridX(i)  +(omegaY-1)*gridY(i)));
        end
    end
    RPhiPsi(i,:) = PsiRow(1:B);
end;
disp('Done with measurement matrix.'); 
RPhiPsi = orth(RPhiPsi')';

x0 = RPhiPsi'*y;

% take epsilon a little bigger than sigma*sqrt(K)
epsilon =  sigma*sqrt(K)*sqrt(1 + 2*sqrt(2)/sqrt(K));
          
disp('Time to conquer some crazy shit.');
tic
xp = l1eq_pd(x0, RPhiPsi, [], y, 1e-3);
%xp = l1qc_logbarrier(x0, RPhiPsi, [], y, epsilon, 1e-3);
toc
disp('You are the winner.');


disp('Now reconstructing the image.');
%   NOW reconstruct the image, going backwards.
[reconGridX, reconGridY] = meshgrid(fx,fy);
newImage = zeros(size(reconGridX));
for omegaX = 1:b1
    for omegaY = 1:b2
        %   If this component is not zero
        if (xp(sub2ind([b1,b2],[omegaX,omegaY]))~=0)
           %  Compute it and add it.
           newImage = newImage + exp(-2*pi*sqrt(-1)*(omegaX*reconGridX + omegaY*reconGridY));
        end
    end
end

disp('Now you have a new image.  Its called newImage');

image = image + min(min(image));
newImage = real(newImage);
newImage = newImage + min(min(newImage));
image = image / max(max(image));
newImage = newImage / max(max(newImage)) ;
image = 255*image;
newImage = 255*newImage;
image = uint8(image);
newImage = uint8(newImage);


subplot(1,2,1)
imshow(image);
subplot(1,2,2)
imshow(real(newImage));

