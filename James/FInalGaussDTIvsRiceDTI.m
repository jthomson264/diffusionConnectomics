global Xs0
global qvecs
global sigmas 
global sigma2s
global Xc0

%generate randomly simulated voxels
JTtestSolveForIsotropic;

%generate the qvector table
getqvecs;


%Make FA tables
FARice = zeros(1,length(Xs0(1,:)));
FAgauss = zeros(1,length(Xs0(1,:)));
LikeDTIg = zeros(515,length(Xs0(1,:)));
LikeDTIr = zeros(515,length(Xs0(1,:)));
LikeISOg = zeros(515,length(Xs0(1,:)));
LikeISOr = zeros(515,length(Xs0(1,:)));

Dr = zeros(1,length(Xs0(1,:)));
Dg = zeros(1,length(Xs0(1,:)));
ADCGraph = zeros(2,length(Xs0(1,:)))

for voxel = 1:length(Xs0(1,:))    %For each simulated voxel
    XsG = Xs0(:,voxel); %Xs is the signal values (515 of them)
    XsR = Xs0(:,voxel);
    
    
%Make Nu Tables, and set Nu(1) = S0
NuCalcG = zeros(length(qvecs(:,1)),1);
NuCalcG(1) = S0;
NuCalcGiso = zeros(length(qvecs(:,1)),1);
NuCalcGiso(1) = S0;
NuCalcR = zeros(length(qvecs(:,1)),1);
NuCalcR(1) = S0;
NuCalcRiso = zeros(length(qvecs(:,1)),1);
NuCalcRiso(1) = S0;

%Initial X value for each voxel
Xc0 = [1,0,0; 0,1,0;0,0,1];
ADCg0 = .8;
ADCr0 = .8;
%This intial X value can change thru gradient
XcG = Xc0;
XcR = Xc0;
%nonDTI
ADCg = ADCg0;
ADCr = ADCr0;

for run = 1:1500 %iteration thru gradient descent

    
for i=2:length(qvecs(:,1))

    NuCalcG(i,1)=S0*exp(-(qvecs(i,:)*XcG*qvecs(i,:)')); %Calc Nu from current X
    NuCalcR(i,1)=S0*exp(-(qvecs(i,:)*XcR*qvecs(i,:)'));
    
    %nonDTI
    NuCalcGiso(i,1)=S0*exp(-bvalues(i)*ADCg);
    NuCalcRiso(i,1)=S0*exp(-bvalues(i)*ADCr);
    
end

%Zero the gradient

%DTI
GradG = zeros(3,3);
GradR = zeros(3,3);
%nonDTI
GradGiso = 0;
GradRiso = 0;

%calculate the gradient:
%most is done here, but finished in the loop
tempGradG = -((XsG - NuCalcG)./sigma2s).*NuCalcG; 
tempGradG(1) = 0;
tempGradR = -(( -NuCalcR + ((besseli(1, XsR.*NuCalcR./sigma2s )./besseli(0, XsR.*NuCalcR./sigma2s )) .*XsR) )./sigma2s ).* NuCalcR;
tempGradR(1) = 0;
%non-DTI
tempGradGiso = -((XsG - NuCalcGiso)./sigma2s).*NuCalcGiso; 
tempGradGiso(1) = 0;
tempGradRiso = -(( -NuCalcRiso + ((besseli(1, XsR.*NuCalcRiso./sigma2s )./besseli(0, XsR.*NuCalcRiso./sigma2s )) .*XsR) )./sigma2s ).* NuCalcRiso;
tempGradRiso(1) = 0;

for i=2:length(tempGradG) 
    % sum up the individual gradients
        GradG = GradG + tempGradG(i) * (qvecs(i,:)'*qvecs(i,:));
        GradR = GradR + tempGradR(i) * (qvecs(i,:)'*qvecs(i,:));
        GradGiso = GradGiso + -tempGradGiso(i) * (-bvalues(i));
        GradRiso = GradRiso + -tempGradRiso(i) * (-bvalues(i));
end

%Scale the step:
GradG = GradG/10000 * 5;
GradR = GradR/10000 * 5;
GradGiso = GradGiso/10000 * 5;
GradRiso = GradRiso/10000 * 5;
%Step the Xc into the gradients direction
XcG = XcG + GradG;
XcR = XcR + GradR;
ADCg = ADCg + GradGiso;
ADCr = ADCr + GradRiso;

%Printouts for debugging (delete later)
GradG;
XcG;
GradR;
XcR;

end


ADCGraph(1,voxel) = ADCr;
ADCGraph(2,voxel) = ADCg;
GradRiso;
GradGiso;
GradG;
GradR;
XcG;
XcR;
eigValsG = eig(XcG);
FAgauss(voxel) = (1/2)^.5 * ( ((eigValsG(1)-eigValsG(2))^2 + (eigValsG(2)-eigValsG(3))^2 + (eigValsG(1)-eigValsG(3))^2)^.5 ) / ( (eigValsG(1)^2 + eigValsG(2)^2 + eigValsG(3)^2)^.5);
eigValsR = eig(XcR);
FARice(voxel) = (1/2)^.5 * ( ((eigValsR(1)-eigValsR(2))^2 + (eigValsR(2)-eigValsR(3))^2 + (eigValsR(1)-eigValsR(3))^2)^.5 ) / ( (eigValsR(1)^2 + eigValsR(2)^2 + eigValsR(3)^2)^.5);


LikeDTIr(:,voxel) = log( XsG./sigma2s.*exp(-(XsG.^2+NuCalcR.^2)./(2*sigma2s)).*besseli(0,XsG.*NuCalcR./sigma2s) );
LikeDTIg(:,voxel) = log( 1./((2*pi*sigma2s).^2) .* exp((-(XsG - NuCalcG).^2)./(2*sigma2s)) );
LikeISOg(:,voxel) = log( 1./((2.*pi.*sigma2s).^2) .* exp((-(XsG - NuCalcGiso).^2)./(2*sigma2s)) );
LikeISOr(:,voxel) = log( XsG./sigma2s.*exp(-(XsG.^2+NuCalcRiso.^2)./(2*sigma2s)).*besseli(0,XsG.*NuCalcRiso./sigma2s) );

Dr(voxel) = -2*sum(LikeISOr(:,voxel)) + 2*sum(LikeDTIr(:,voxel));
Dg(voxel) = -2*sum(LikeISOg(:,voxel)) + 2*sum(LikeDTIg(:,voxel));

voxel
end

save('SimulationWorkSpace108')

