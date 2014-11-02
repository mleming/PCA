% Matthew Leming
% Assignment 2.3, COMP 775, Fall 2014, Steve Pizer
% This script builds a PDM and an ellipsoid shape space, then outputs an
% image of an ellipsoid and fits a PDM to it via Active Shape Modelling.
% This requires the .mat files pts2, north, south, west, and east to run

%%% PARAMETERS %%%
%Use Euclidean or non-Euclidean shape space
Euclidean = 0;
% Ellipsoid Centers
cx = 65;
cy = 70;
cz = 65;
% Ellipsoid Radii
rx =  50;
ry =  50;
rz =  50;
% Rotation quaternion
quaternion = normr([1 0 0 0]);
% Variations of paramters for each ellipsoid
center_stddev = 2;
radii_stddev = 1;
rotation_stddev = pi/36;

% The sum of the absolute differences between two PDMs is below this, then
% the ASM is considered converged
convergence_factor = 20;
% Use to limit the number of iterations that the ASM goes through. Set to
% -1 if the number should be unlimited.
iteration_limit = -1;

% 0 is black ellipsoid on white background, 1 is reverse
polarity = 1;

%%% SCRIPT TO RUN PROGRAM %%%

% Generate the ellipsoid image
image = outputEllipsoidQuaternionRotate( cx, cy, cz, rx, ry, rz, quaternion, '', polarity);

% Used for a rough visual of the actual image on the display
actual_pdm = PDMEllipsoidGenerator(cx - 64, cy - 64, cz - 64, rx, ry, rz, quaternion, 0, 0, 0, pts2);

% The initial PDM, and the one on which the shape space is taken
pts3 = PDMEllipsoidGenerator(0, 0, 0, 5, 5, 5, [1 0 0 0], 0, 0, 0, pts2);

% Generate the shape space from the initial PDM
n_tuples = zeros([222 25]);
for i=1:size(n_tuples,2)
    n_tuples(:,i) = PDMEllipsoidGenerator(0,0,0,10,10,10,quaternion, center_stddev, radii_stddev, rotation_stddev, pts2);
end
if Euclidean == 1
    [final_28_tuples, PNS] = CPNS(n_tuples);
    [ total_variance, principle_variances, eigenvectorsp ] = formShapeSpace(final_28_tuples);
    eigenvectors = normc(PNSe2s(eigenvectorsp(1:24,1:9),PNS));
else
    [ total_variance, principle_variances, eigenvectors ] = formShapeSpace(n_tuples);
end

% Blur the image and take its gradient
smooth_image = smooth3(image,'gaussian',[11 11 11],10);
[Fx, Fy, Fz] = gradient(smooth_image);

% The first two iterations of the PDMs are carried out here. This record
% keeping is used to compare the changes in each PDM every iteration, so
% that we know when to stop
previous_iteration_PDM = ASMEllipsoid(Fx, Fy, Fz, eigenvectors(:,1:9), principle_variances/total_variance, pts3, [64 64 64], 1, north, south, east, west);
current_iteration_PDM = ASMEllipsoid(Fx, Fy, Fz, eigenvectors(:,1:9), principle_variances/total_variance, previous_iteration_PDM, [64 64 64], 1, north, south, east, west);

k = 1;
% The iterations stop when the sum of the absolute values of the
% differences between the iterations is less than a certain number
iterations = 1;
while abs(sum(abs(previous_iteration_PDM - current_iteration_PDM))) > convergence_factor
     iterations = iterations + 1;
% To stop the program if it takes too long
     if iterations > iteration_limit && iteration_limit ~= -1
         break;
     end
    previous_iteration_PDM = current_iteration_PDM;
    current_iteration_PDM = ASMEllipsoid(Fx, Fy, Fz, eigenvectors(:,1:9), principle_variances/total_variance, current_iteration_PDM, [64 64 64], 1, north, south, east, west);
    abs(sum(abs(previous_iteration_PDM - current_iteration_PDM)))
end
iterations

disp3DMesh(pts3,north,south,east,west,'red');
disp3DMesh(current_iteration_PDM,north,south,east,west,'green');
disp3DMesh(actual_pdm,north,south,east,west,'blue');
