% Matthew Leming
% Assignment 2.4, COMP 775, Fall 2014, Steve Pizer
% This script forms a shape space of an ellipsoid, then outputs an image of
% another ellipsoid, then uses active shape modelling to fit a point
% density model to that ellipsoid image.

%%% PARAMETERS %%%

% Ellipsoid Centers
cx = 64;
cy = 64;
cz = 64;
% Ellipsoid Radii
rx =  20;
ry =  20;
rz =  20;
% Rotation quaternion
quaternion = normr([1 0 0 0]);
% Variations of paramters for each ellipsoid
center_stddev = 2; 
radii_stddev = 1;
rotation_stddev = pi/36;

% The sum of the absolute differences between two PDMs is below this, then
% the ASM is considered converged
convergence_factor = 2;
% Use to limit the number of iterations that the ASM goes through. Set to
% -1 if the number should be unlimited.
iteration_limit = -1;

% 0 is black ellipsoid on white background, 1 is reverse
polarity = 1;

% Load variables and functions
addpath(genpath('.'));
load('matlab_variables/base_ellipsoid.mat');
load('matlab_variables/north.mat');
load('matlab_variables/south.mat');
load('matlab_variables/east.mat');
load('matlab_variables/west.mat');

%% SCRIPT TO RUN PROGRAM %%%

% Generate the ellipsoid image
 image = outputEllipsoidQuaternionRotate( cx, cy, cz, rx, ry, rz, quaternion, '', polarity);
% Gaussian smooth and noise
%image = smooth3(image, 'gaussian', 3, min([rx ry rz])/2);
%image = imnoise(image, 'gaussian', 0, 0.01);
% Write the image
%writeMETA(image,'test_cases/testA');

% Used for a rough visual of the actual image on the display
actual_pdm = PDMEllipsoidGenerator(cx - 64, cy - 64, cz - 64, rx, ry, rz, quaternion, 0, 0, 0, pts2);

% The initial PDM, and the one on which the shape space is taken
pts3 = PDMEllipsoidGenerator(0, 0, 0, 10, 10, 10, [1 0 0 0], 0, 0, 0, pts2);

% Generate the shape space from the initial PDM
n_tuples = zeros([222 25]);
for i=1:size(n_tuples,2)
    n_tuples(:,i) = PDMEllipsoidGenerator(0,0,0,10,10,10,quaternion, center_stddev, radii_stddev, rotation_stddev, pts2);
end
[ total_variance, principle_variances, eigenvectors ] = formShapeSpace(n_tuples);

% Blur the image and take its gradient
 smooth_image = smooth3(image,'gaussian',[9 9 9],11);
[Fx, Fy, Fz] = gradient(smooth_image);

% The first two iterations of the PDMs are carried out here. This record
% keeping is used to compare the changes in each PDM every iteration, so
% that we know when to stop
previous_iteration_PDM = ASMEllipsoid(Fx, Fy, Fz, eigenvectors(:,1:9), principle_variances/total_variance, pts3, [64 64 64], polarity, north, south, east, west,0);
current_iteration_PDM = ASMEllipsoid(Fx, Fy, Fz, eigenvectors(:,1:9), principle_variances/total_variance, previous_iteration_PDM, [64 64 64], polarity, north, south, east, west,0);

k = 1;
% The iterations stop when the sum of the absolute values of the
% differences between the iterations is less than a certain number
iterations = 1;
while sum((previous_iteration_PDM - current_iteration_PDM).^2) > convergence_factor %*iterations/100 || iteration_limit ~= -1
     iterations = iterations + 1;
% To stop the program if it takes too long
     if iterations > iteration_limit && iteration_limit ~= -1
         break;
     end
    previous_iteration_PDM = current_iteration_PDM;
    current_iteration_PDM = ASMEllipsoid(Fx, Fy, Fz, eigenvectors(:,1:9), principle_variances/total_variance, current_iteration_PDM, [64 64 64], polarity, north, south, east, west,0);
end

% Display, estimation of parameters for the fit PDM, and dice comparison
iterations
figure;
disp3DMesh(pts3,north,south,east,west,'red');
disp3DMesh(current_iteration_PDM,north,south,east,west,'green');
disp3DMesh(actual_pdm,north,south,east,west,'blue');
[ncx,ncy,ncz,nrx,nry,nrz,nrot] = parameterDeterminer(current_iteration_PDM);
estim_image = outputEllipsoidQuaternionRotate( round(ncx) + 64, round(ncy) + 64, round(ncz) + 64, nrx, nry, nrz, nrot, '', polarity);
dice_comparison = diceComp(estim_image, image)