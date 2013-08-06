global Xs0
global qvecs
global sigma2s
global Xc0
global btab
%ADJUSTABLE VALUES
numGradIteration = 1500;
lambda1 = .84;
lambda23 = ((.84*3)-lambda1)/2;   %This assignment to Lambda 2 and 3 makes the total value equal to 2.52
numVoxels = 1;

S0 = 25; % 25 is a good value. If this is too high, our matlab built-in bessel functions give NaN and inf



%generate randomly simulated voxels
aSimVoxels



%Make Empty Tables for data collection
FArice = zeros(1,length(Xs0(1,:))); %FA for Rician
FAgauss = zeros(1,length(Xs0(1,:))); %FA for Gaussian
LikeDTIgauss = zeros(515,length(Xs0(1,:))); %The likelihood of the g DTI
LikeDTIrice = zeros(515,length(Xs0(1,:))); %The likelihood of the r DTI
LikeISOgauss = zeros(515,length(Xs0(1,:))); %The likelihood of the isog model
LikeISOrice = zeros(515,length(Xs0(1,:))); %The likelihood of the isor model
LikeRatioDparamRice = zeros(1,length(Xs0(1,:))); %Likelihood D parameter (used in Chi-Sq)
LikeRatioDParamGauss = zeros(1,length(Xs0(1,:))); %Likelihood D parameter (used in Chi-Sq)

ADCGraph = zeros(2,length(Xs0(1,:))); %This is used to record the final value of the ADC in the isotropic models; typically the gaussian ADC will be WAY lower than it should be.

%Initial values, to prepare for grad descent.
Xc0 = [1,0,0; 0,1,0;0,0,1];
ADCg0 = .8;
ADCr0 = .8;

for voxel = 1:length(Xs0(1,:))    %iterate through each simulated voxel
    SimulatedXSignal = Xs0(:,voxel); %Xs is the signal values (515 of them)
    
    
    %Make Nu Tables, and set Nu(1) = S0
    NuCalcDTIgauss = zeros(length(qvecs(:,1)),1);
    NuCalcDTIgauss(1) = S0;
    NuCalcISOgauss = zeros(length(qvecs(:,1)),1);
    NuCalcISOgauss(1) = S0;
    NuCalcDTIrice = zeros(length(qvecs(:,1)),1);
    NuCalcDTIrice(1) = S0;
    NuCalcISOrice = zeros(length(qvecs(:,1)),1);
    NuCalcISOrice(1) = S0;
    
    
    %Initiate our values to the initial conditions
    GaussTensor = Xc0;% <- X is our DTI matrix
    RiceTensor = Xc0;
    ADCgauss = ADCg0;% <- ADC is our isotropic ADC value
    ADCrice = ADCr0;
    
    for run = 1:numGradIteration %iteration thru gradient descent
        %Calculate Nus, given our current thetas (tensors and ADCs)
        NuCalcDTIgauss = S0*exp(-diag(qvecs*GaussTensor*qvecs'));
        NuCalcDTIrice = S0*exp(-diag(qvecs*RiceTensor*qvecs'));
        NuCalcISOgauss = S0 * exp(-bvalues*ADCgauss);
        NuCalcISOrice = S0 * exp(-bvalues*ADCrice);
        

        %calculate the gradient:
        tempGradGDTI = CalcGaussGrad( SimulatedXSignal, NuCalcDTIgauss, sigma2s);
        tempGradRDTI = CalcRiceGrad( SimulatedXSignal, NuCalcDTIrice, sigma2s);
        tempGradGISO = CalcGaussGrad( SimulatedXSignal, NuCalcISOgauss, sigma2s);
        tempGradRISO = CalcRiceGrad( SimulatedXSignal, NuCalcISOrice, sigma2s);
        
        %Zero DTI gradients, to prepare for summing through array
        GradDTIgauss = zeros(3,3);
        GradDTIrice = zeros(3,3);
        for i=2:length(tempGradGDTI)
            % sum up the individual gradients
            GradDTIgauss = GradDTIgauss + tempGradGDTI(i) * (qvecs(i,:)'*qvecs(i,:));
            GradDTIrice = GradDTIrice + tempGradRDTI(i) * (qvecs(i,:)'*qvecs(i,:));
        end
        GradISOgauss = sum(-tempGradGISO.* (-bvalues));
        GradISOrice = sum(-tempGradRISO .* (-bvalues));
        
        %Scale the step:
        StepDTIgauss = GradDTIgauss/10000 * 5;
        StepDTIrice = GradDTIrice/10000 * 5;
        StepISOgauss = GradISOgauss/10000 * 5;
        StepISOrice = GradISOrice/10000 * 5;
        
        %Step the Xc
        GaussTensor = GaussTensor + StepDTIgauss;
        RiceTensor = RiceTensor + StepDTIrice;
        ADCgauss = ADCgauss + StepISOgauss;
        ADCrice = ADCrice + StepISOrice;
    end
    
    %Record our data into the tables, because gradient descent is done!
    ADCGraph(1,voxel) = ADCrice;
    ADCGraph(2,voxel) = ADCgauss;
    FAgauss(voxel) = CalcFA(eig(GaussTensor));
    FArice(voxel) = CalcFA(eig(RiceTensor));
    LikeDTIrice(:,voxel) = log( SimulatedXSignal./sigma2s.*exp(-(SimulatedXSignal.^2+NuCalcDTIrice.^2)./(2*sigma2s)).*besseli(0,SimulatedXSignal.*NuCalcDTIrice./sigma2s) );
    LikeDTIgauss(:,voxel) = log( 1./((2*pi*sigma2s).^2) .* exp((-(SimulatedXSignal - NuCalcISOgauss).^2)./(2*sigma2s)) );
    LikeISOgauss(:,voxel) = log( 1./((2.*pi.*sigma2s).^2) .* exp((-(SimulatedXSignal - NuCalcISOgauss).^2)./(2*sigma2s)) );
    LikeISOrice(:,voxel) = log( SimulatedXSignal./sigma2s.*exp(-(SimulatedXSignal.^2+NuCalcISOrice.^2)./(2*sigma2s)).*besseli(0,SimulatedXSignal.*NuCalcISOrice./sigma2s) );
    LikeRatioDparamRice(voxel) = -2*sum(LikeISOrice(:,voxel)) + 2*sum(LikeDTIrice(:,voxel));
    LikeRatioDParamGauss(voxel) = -2*sum(LikeISOgauss(:,voxel)) + 2*sum(LikeDTIgauss(:,voxel));
    
    
    %Optional Printouts for debug/running
    GradISOrice;
    GradISOgauss;
    GradDTIgauss;
    GradDTIrice;
    GaussTensor;
    RiceTensor;
    voxel
end

save('SimulationWorkSpace108')

