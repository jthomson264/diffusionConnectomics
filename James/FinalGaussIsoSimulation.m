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
ADC0 = 1;
%Xc0 = [1,0,0; 0,1,0;0,0,1];
Grad = 0;
ADC = ADC0;

for run = 1:600

    
for i=2:length(qvecs(:,1))
        %for DTI
    NuCalc(i,1)=S0*exp(-bvalues(i)*ADC);
    
        %for non-DTI
    %NuCalc(i,1) = exp(-bvalues(i,1)*ADC)
end

%for Gaussian
tempGrad = -((Xs - NuCalc)./sigma2s).*NuCalc;
tempGrad(1) = 0;
%for Rician
%tempGrad = ( -NuCalc./sigma2s + besseli(Xs.*NuCalc./sigma2s,1)/besseli(Xs.*NuCalc./sigma2s,0)*Xs./sigma2s ) .* NuCalc ;



Grad = 0;
for i=2:length(tempGrad)
    %for either DTI, we must multiply the gradient by -q * qtrans
        tester = -tempGrad(i) * (-bvalues(i));
        Grad = Grad + tester;
    %for non-DTI, gradient is already computed.
        
end
%Scale grad into a step:

Grad = Grad/100000;

ADC = ADC + Grad;


Grad
ADC
%clear GaussGrad
end
voxel
Grad;
ADC;

%GaussGrad
%GaussLogLikeGradient = mean(tempGaussGrad)
end

save('GaussFAovernight','FA')