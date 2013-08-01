% Junk script.  I want to smooth over diffusion wave vector distances and I
% need to pick a good bandwidth.  this is going to let me set bandwidths
% and then see the distribution of how many q-vecs it takes to hit an
% energy of x%.

%  Nah f that.  This is slightly easier.  I'm going to choose an N and then
%  see, for each sigma, what % is caught w/ that N for each qvec.

N_q = 9;
N_to_drop = 515-N_q;
sigma = 1;

percentageForNQ = zeros(515,1);
qSimilarities = (2*pi*sigma^2)^(-1/2)*exp((-qDistances.^2)/(2*sigma^2));
for row_i = 1:size(qSimilarities,1)
    sims = sort(qSimilarities(row_i,:));
    
    sumSimsForNQ = sum(sims(515-N_to_drop : 515));
    totalSims = sum(sims(1:515));
    
    percentageForNQ(row_i) = sumSimsForNQ / totalSims;
end
