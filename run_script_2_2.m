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
quaternion = normr([1 0 0 0]);
% Variations of paramters for each ellipsoid
center_stddev = 2; 
radii_stddev = 1;
rotation_stddev = pi/36;
% Take Euclidean as well
noneuclidean = 0;

addpath(genpath('.'));
load('matlab_variables/base_ellipsoid.mat');
load('matlab_variables/north.mat');
load('matlab_variables/south.mat');
load('matlab_variables/east.mat');
load('matlab_variables/west.mat');

% Build the set of tuples
n_tuples = zeros([222 25]);
for i=1:size(n_tuples,2)
    n_tuples(:,i) = PDMEllipsoidGenerator(cx,cy,cz,rx,ry,rz,quaternion, center_stddev, radii_stddev, rotation_stddev, pts2);
end

% Take the mean
mean_n_tuples = mean(n_tuples')';

% Find the non-Euclideanized set of 28x25 tuples, with its PNS
if noneuclidean == 1
    [final_28_tuples, PNS] = CPNS(n_tuples);
end
    
% The total variance, the nine principle variances, and the eigenvectors of
% both the Euclideanized and non-Euclideanized datasets.
[ total_variance, principle_variances, eigenvectors ] = formShapeSpace(n_tuples)
if noneuclidean == 1
    [ total_variancep, principle_variancesp, eigenvectorsp ] = formShapeSpace(final_28_tuples)
end

% Measure the total variance captured by both methods
non_euclidean_accuracy = sum(principle_variances)/total_variance;
if noneuclidean == 1
    euclidean_accuracy = sum(principle_variancesp)/total_variancep;
end

% Revert the nine principle eigenvectors back to their original space for
% display 
if noneuclidean == 1
    inversion = PNSe2s(eigenvectorsp(1:24,1:9),PNS);
end

% Display all of the meshes
for i=1:9
    % Display the Euclidean results
    if noneuclidean == 1
    figure
    disp3DMesh(mean_n_tuples,north,south,west,east,'black');
    disp3DMesh(mean_n_tuples + 2*sqrt(principle_variancesp(i)) * inversion(:,i),north,south,west,east,'blue');
    disp3DMesh(mean_n_tuples - 2*sqrt(principle_variancesp(i)) * inversion(:,i),north,south,west,east,'red');
    end
    
    %Display the non-Euclidean results
    figure
    disp3DMesh(mean_n_tuples,north,south,west,east,'black');
    disp3DMesh(mean_n_tuples + 2*sqrt(principle_variances(i)) * eigenvectors(:,i),north,south,west,east,'green');
    disp3DMesh(mean_n_tuples - 2*sqrt(principle_variances(i)) * eigenvectors(:,i),north,south,west,east,'cyan');
end
if noneuclidean == 1
    sprintf('Non-Euclidean accuracy: %f ... Euclidean accuracy: %f', non_euclidean_accuracy, euclidean_accuracy)
end
principle_variances/total_variance % The variances captured by the non-Euclidean eigenvectors
if noneuclidean == 1
    principle_variancesp/total_variancep % The variances captured by the Euclidean eigenvectors
end
