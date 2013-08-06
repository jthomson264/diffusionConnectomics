global Xs
global qvecs
global sigmas 


%generate randomly simulated voxels
JTtestSolveForIsotropic

%generate the qvector table
getqvecs

    
%Likelihood Function Handle


global Xs
global qvecs
global sigmas
%X = [.00008,0,0; 0,.00008,0;0,0,.00008];
X = [800,0,0; 0,800,0;0,0,800]
%GaussianLogLikelihood(X, Xs, qvecs, sigmas)
Function = @GaussianLogLikelihood;

%X0 = [X,Xs,qvecs,sigmas]

Options = optimset('TolFun',1e-10000,'TolX',1e-10000);


%FMinSearchX = fminsearch(Function,X,Options)
%FMinuncX = fminunc(Function,FMinSearchX,Options)
%FMinuncX2 = fminunc(Function,X,Options)

Xs = Xs(:,1);
Xc = X;
NuCalc = zeros(length(qvecs(:,1)),1);
GaussGrad = zeros(3,3);
for run = 1:2

    
for i=2:length(qvecs(:,1))
    NuCalc(i,1)=exp(-(qvecs(i,:)*Xc*qvecs(i,:)'));
end
tempGaussGrad = ((Xs - NuCalc).*NuCalc./sigmas);
GaussGrad = [0,0,0;0,0,0;0,0,0];



for i=2:length(tempGaussGrad)
    if run==1
        GaussGrad = GaussGrad + (tempGaussGrad(i) * (qvecs(i,:)'*qvecs(i,:)))/10140000;
    end
    if run < 3
        GaussGrad = GaussGrad + (tempGaussGrad(i) * (qvecs(i,:)'*qvecs(i,:)))/101400;
    else
        GaussGrad = GaussGrad + (tempGaussGrad(i) * (qvecs(i,:)'*qvecs(i,:)))/1014;
    end
    if run > 6
        GaussGrad = GaussGrad + (tempGaussGrad(i) * (qvecs(i,:)'*qvecs(i,:)))*1;
    end
    if run > 8
        GaussGrad = GaussGrad + (tempGaussGrad(i) * (qvecs(i,:)'*qvecs(i,:)))*10^10;
    end
    if run > 12
        GaussGrad = GaussGrad + (tempGaussGrad(i) * (qvecs(i,:)'*qvecs(i,:)))*10^20;
    end
    if run > 20
        GaussGrad = GaussGrad + (tempGaussGrad(i) * (qvecs(i,:)'*qvecs(i,:)))*10^23;
    end
    if run > 30
        GaussGrad = GaussGrad + (tempGaussGrad(i) * (qvecs(i,:)'*qvecs(i,:)))*10^25;
    end;
    if run > 50
        GaussGrad = GaussGrad + (tempGaussGrad(i) * (qvecs(i,:)'*qvecs(i,:)))*10^27;
    end
    
        
        
end


Xc(1,1) = Xc(1,1) + GaussGrad(1,1);
Xc(2,2) = Xc(2,2) + GaussGrad(2,2);
Xc(3,3) = Xc(3,3) + GaussGrad(3,3);

Xc(1,2) = Xc(1,2) + GaussGrad(1,2);
Xc(1,3) = Xc(1,3) + GaussGrad(1,3);
Xc(2,3) = Xc(2,3) + GaussGrad(2,3);

Xc(2,1) = Xc(1,2);
Xc(3,1) = Xc(1,3);
Xc(3,2) = Xc(2,3);
GaussGrad
Xc;

%clear GaussGrad
end

GaussGrad
Xc
eigVals = eig(Xc);
FA = (1/2)^.5 * ( ((eigVals(1)-eigVals(2))^2 + (eigVals(2)-eigVals(3))^2 + (eigVals(1)-eigVals(3))^2)^.5 ) / ( (eigVals(1)^2 + eigVals(2)^2 + eigVals(3)^2)^.5)
%GaussGrad
%GaussLogLikeGradient = mean(tempGaussGrad)
    
