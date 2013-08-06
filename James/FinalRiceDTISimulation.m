global Xs0
global qvecs
global sigmas 
global sigma2s

%generate randomly simulated voxels
JTtestSolveForIsotropic;

%generate the qvector table
getqvecs;


global Xc0




Options = optimset('TolFun',1e-10000,'TolX',1e-10000);


%FMinSearchX = fminsearch(Function,X,Options)
%FMinuncX = fminunc(Function,FMinSearchX,Options)
%FMinuncX2 = fminunc(Function,X,Options)
FA = zeros(1,length(Xs0(1,:)));
for voxel = 1:length(Xs0(1,:))
    Xs = Xs0(:,voxel);

NuCalc = zeros(length(qvecs(:,1)),1);
NuCalc(1) = S0;


    %ADC is the variable for non-DTI:
%ADC0 = 1/400;

    %Xc is the variable for DTI
Xc0 = [.8,0,0;0,.8,0;0,0,.8];
%Xc0 = [1,0,0; 0,1,0;0,0,1];
Grad = zeros(3);
Xc = Xc0;

for run = 1:60000

    
for i=2:length(qvecs(:,1))
        %for DTI
    NuCalc(i,1)=S0*exp(-(qvecs(i,:)*Xc*qvecs(i,:)'));
    
        %for non-DTI
    %NuCalc(i,1) = exp(-bvalues(i,1)*ADC)
end

%for Gaussian
%tempGrad = -((Xs - NuCalc)./sigma2s).*NuCalc;
tempGrad(1) = 0;
%for Rician
tempGrad = (( -NuCalc + ((besseli(1, Xs.*NuCalc./sigma2s )./besseli(0, Xs.*NuCalc./sigma2s )) .*Xs) )./sigma2s ).* NuCalc;
tempGrad;


Grad = zeros(3);
for i=2:length(tempGrad)
    %for either DTI, we must multiply the gradient by -q * qtrans
        tester = -tempGrad(i) * (qvecs(i,:)'*qvecs(i,:));
        tester;
        Grad = Grad + tester;
    %for non-DTI, gradient is already computed.
        
end
%Scale grad into a step:

Grad = Grad/100000;

Xc = Xc + Grad;


Grad
Xc

eigVals = eig(Xc);
FA = (1/2)^.5 * ( ((eigVals(1)-eigVals(2))^2 + (eigVals(2)-eigVals(3))^2 + (eigVals(1)-eigVals(3))^2)^.5 ) / ( (eigVals(1)^2 + eigVals(2)^2 + eigVals(3)^2)^.5);
FA
%clear GaussGrad
end
voxel
Grad;
Xc;

%GaussGrad
%GaussLogLikeGradient = mean(tempGaussGrad)
end

save('GaussFAovernight','FA')