% Matthew Leming
% Assignment 2.2, COMP 775, Fall 2014, Steve Pizer
% This program builds a non-Euclidean and a Euclidean PDM, then displays
% and compared them. The PDMs are for ellipsoids

% This requites the .mat files pts2, north, south, west, and east to run


% Ellipsoid Centers
cx = -3;
cy =  3;
cz =  5;
% Ellipsoid Radii
rx =  20;
ry =  30;
rz =  40;
% Rotation quaternion
quaternion = normr([1 -1 3 4]);
% Variations of paramters for each ellipsoid
center_stddev = sqrt(6);
radii_stddev = sqrt(mean([rx ry rz])/10);
rotation_stddev = sqrt(pi/12);

% Build the set of tuples
n_tuples = zeros([222 25]);
for i=1:size(n_tuples,2)
    n_tuples(:,i) = PDMEllipsoidGenerator(cx,cy,cz,rx,ry,rz,quaternion, center_stddev, radii_stddev, rotation_stddev, pts2);
end

% Take the mean
mean_n_tuples = mean(n_tuples')';

% Find the non-Euclideanized set of 28x25 tuples, with its PNS
[final_28_tuples, PNS] = CPNS(n_tuples);

% The total variance, the nine principle variances, and the eigenvectors of
% both the Euclideanized and non-Euclideanized datasets.
[ total_variance, principle_variances, eigenvectors ] = formShapeSpace(n_tuples)
[ total_variancep, principle_variancesp, eigenvectorsp ] = formShapeSpace(final_28_tuples)

% Measure the total variance captured by both methods
non_euclidean_accuracy = sum(principle_variances)/total_variance;
euclidean_accuracy = sum(principle_variancesp)/total_variancep;

% Revert the nine principle eigenvectors back to their original space for
% display 
inversion = PNSe2s(eigenvectorsp(1:24,1:9),PNS);

% Display all of the meshes
for i=1:9
    % Display the Euclidean results
    figure
    disp3DMesh(mean_n_tuples,north,south,west,east,'black');
    disp3DMesh(mean_n_tuples + 2*sqrt(principle_variancesp(i)) * inversion(:,i),north,south,west,east,'blue');
    disp3DMesh(mean_n_tuples - 2*sqrt(principle_variancesp(i)) * inversion(:,i),north,south,west,east,'red');
    
    %Display the non-Euclidean results
    figure
    disp3DMesh(mean_n_tuples,north,south,west,east,'black');
    disp3DMesh(mean_n_tuples + 2*sqrt(principle_variances(i)) * eigenvectors(:,i),north,south,west,east,'green');
    disp3DMesh(mean_n_tuples - 2*sqrt(principle_variances(i)) * eigenvectors(:,i),north,south,west,east,'cyan');
end

sprintf('Non-Euclidean accuracy: %f ... Euclidean accuracy: %f', non_euclidean_accuracy, euclidean_accuracy)
principle_variances/total_variance % The variances captured by the non-Euclidean eigenvectors
principle_variancesp/total_variancep % The variances captured by the Euclidean eigenvectors

