function [ total_variance, principle_variances, eigenvectors ] = formShapeSpace( n_tuples)
% From a number of PDMs, finds principle variances, the total variance,
% and eigenvectors for a PCA. N_tuples are simply a 222xn matrix of
% ellipsoid points.

% How many tuples are there?
N = size(n_tuples,2);
% Mean tuple
mean_n_tuples = mean(n_tuples')';

% Calculate the deviations of each tuple from the mean
n_tuples_minus_mean = zeros(size(n_tuples));
for i=1:N
   n_tuples_minus_mean(:,i) = n_tuples(:,i) - mean_n_tuples;
end

% Just keep both of these matrixes here for use in the program.
AAT = n_tuples_minus_mean  * n_tuples_minus_mean';
ATA = n_tuples_minus_mean' * n_tuples_minus_mean;

total_variance = trace((1/(N-1))* AAT);

% Find the eigenvectors and eigenvalues of the matrix. There's a bit of
% waste here, but this is the easiest setup with MATLAB's functions
[eigenvectors,eigenvalues] = eigs(AAT, N-1);
eigenvalues = eigs(ATA,24);

% Normalize the eigenvectors
eigenvectors = normc(eigenvectors);

% Find the nine principle variances
principle_variances = eigenvalues(1:9)/(N-1);
