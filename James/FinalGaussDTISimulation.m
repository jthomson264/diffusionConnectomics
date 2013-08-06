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
Xc0 = [1,0,0; 0,1,0;0,0,1];
%Xc0 = [1,0,0; 0,1,0;0,0,1];
Grad = zeros(3,3);
Xc = Xc0;

for run = 1:600

    
for i=2:length(qvecs(:,1))
        %for DTI
    NuCalc(i,1)=S0*exp(-(qvecs(i,:)*Xc*qvecs(i,:)'));
    
        %for non-DTI
    %NuCalc(i,1) = exp(-bvalues(i,1)*ADC)
end

%for Gaussian
tempGrad = -((Xs - NuCalc)./sigma2s).*NuCalc;
tempGrad(1) = 0;
%for Rician
%tempGrad = ( -NuCalc./sigma2s + besseli(Xs.*NuCalc./sigma2s,1)/besseli(Xs.*NuCalc./sigma2s,0)*Xs./sigma2s ) .* NuCalc ;



Grad = zeros(3,3);
for i=2:length(tempGrad)
    %for either DTI, we must multiply the gradient by -q * qtrans
        tester = tempGrad(i) * (qvecs(i,:)'*qvecs(i,:));
        Grad = Grad + tempGrad(i) * (qvecs(i,:)'*qvecs(i,:));
        if tester(1,1) < 0
            'negative val';
        end
        if tester(2,2) < 0
            '2nd';
        end
        if tester(3,3) < 0 
            '3rd val';
        end
    %for non-DTI, gradient is already computed.
        
end
%Scale grad into a step:

Grad = Grad/10000;

Xc(1,1) = Xc(1,1) + Grad(1,1);
Xc(2,2) = Xc(2,2) + Grad(2,2);
Xc(3,3) = Xc(3,3) + Grad(3,3);

Xc(1,2) = Xc(1,2) + Grad(1,2);
Xc(1,3) = Xc(1,3) + Grad(1,3);
Xc(2,3) = Xc(2,3) + Grad(2,3);

Xc(2,1) = Xc(1,2);
Xc(3,1) = Xc(1,3);
Xc(3,2) = Xc(2,3);
Grad
Xc
%clear GaussGrad
end

Grad
Xc;
eigVals = eig(Xc);
FA(voxel) = (1/2)^.5 * ( ((eigVals(1)-eigVals(2))^2 + (eigVals(2)-eigVals(3))^2 + (eigVals(1)-eigVals(3))^2)^.5 ) / ( (eigVals(1)^2 + eigVals(2)^2 + eigVals(3)^2)^.5);
%GaussGrad
%GaussLogLikeGradient = mean(tempGaussGrad)
end
FA
save('FAsimul','FA');