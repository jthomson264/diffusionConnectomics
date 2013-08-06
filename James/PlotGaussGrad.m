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
X = [.000008,0,0; 0,.000008,0;0,0,.000008];
%GaussianLogLikelihood(X, Xs, qvecs, sigmas)
Function = @GaussianLogLikelihood;

%X0 = [X,Xs,qvecs,sigmas]

Options = optimset('TolFun',1e-10000,'TolX',1e-10000);


%FMinSearchX = fminsearch(Function,X,Options)
%FMinuncX = fminunc(Function,FMinSearchX,Options)
%FMinuncX2 = fminunc(Function,X,Options)

Xs = Xs(:,1)
Xc = X;
Scalc = zeros(length(qvecs(:,1)),1);
GaussGrad = zeros(3,3);

numruns = 15
GradPlot = zeros(numruns,2);


for run = 1:numruns
for i=2:length(qvecs(:,1))
    Scalc(i,1)=exp(-(qvecs(i,:)*Xc*qvecs(i,:)'));
end

%Scalc = exp(-diag(qvecs*Xc*(qvecs')));
%Scalc;

tempGaussGrad = ((Xs - Scalc).*Scalc./sigmas);
GaussGrad = [0,0,0;0,0,0;0,0,0];
for i=2:length(tempGaussGrad)
    if run==1
        GaussGrad = GaussGrad + (tempGaussGrad(i) * (qvecs(i,:)'*qvecs(i,:)))/515;
    end
        
end
run
GradPlot(run,1) = Xc(1,1);
GradPlot(run,2) = GaussGrad(1,1);
Xc(1,1) = Xc(1,1) + .000000000001;
Xc(2,2) = Xc(2,2) + .000000000001;
Xc(3,3) = Xc(3,3) + .000000000001;

Xc(1,2) = 0;
Xc(1,3) = 0;
Xc(2,3) = 0;

Xc(2,1) = Xc(1,2);
Xc(3,1) = Xc(1,3);
Xc(3,2) = Xc(2,3);

GaussGrad
Xc
clear GaussGrad
end

plot(log(log(-GradPlot(:,2))))

%GaussGrad
%GaussLogLikeGradient = mean(tempGaussGrad)
    
