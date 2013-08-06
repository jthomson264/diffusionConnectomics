function [ DTINuTable ] = DTICalcNu( Xs, Tensor, sigma2s )
%Given a tensor, S0, and qvecs
for i=2:length(qvecs(:,1))

    NuCalcDTIgauss(i,1)=S0*exp(-(qvecs(i,:)*GaussTensor*qvecs(i,:)')); %Calc Nu from current X
    NuCalcDTIrice(i,1)=S0*exp(-(qvecs(i,:)*RiceTensor*qvecs(i,:)'));
    
    %nonDTI
    NuCalcISOgauss(i,1)=S0*exp(-bvalues(i)*ADCgauss);
    NuCalcISOrice(i,1)=S0*exp(-bvalues(i)*ADCrice);
    
end
end

