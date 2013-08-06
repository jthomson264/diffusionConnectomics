JTtestSolveForIsotropic
nii = load_nii('data.nii')
for i= 1:size(Xs(:,1))
    nii.img(1,1,1,i) = double(Xs(i,1))
end