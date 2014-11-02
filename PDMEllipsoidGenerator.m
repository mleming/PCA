function new_pts_xyz = PDMEllipsoidGenerator(cx, cy, cz, rx, ry, rz, quaternion, center_stddev, radii_stddev, rotation_stddev, pts2)
% Produces PDMs of input ellipsoids with random variations in their
% parameters
%   Author: Matthew Leming
%   Inputs:
%   - cx, cy, cz - Centers of ellipsoids (to be within a 128x128x128 space)
%   - rx, ry, rz - Radii of ellipsoids
%   - quaternion - Used for rotation of ellipsoid
%   - center_stddev, radii_stddev, angle_stddev - standard deviations of
%     the above parameters on a normal randomized distribution
%   - pts2 - a 1x222 matrix of xyz coordinates of radii 45, 27, and 18, an
%     angle rotation of 0, and a center at 0,0,0. Used as the basis


xrange = 128;
yrange = 128;
zrange = 128;

% Apply randomization to parameters
cx = normrnd(cx, center_stddev);
cy = normrnd(cy, center_stddev);
cz = normrnd(cz, center_stddev);
rx = normrnd(rx, (rx/10));
ry = normrnd(ry, (ry/10));
rz = normrnd(rz, (rz/10));

x_axis = [1 0 0];
y_axis = [0 1 0];
z_axis = [0 0 1];

% Rotate the unit vectors
x_axis = quatrotate(quaternion, x_axis);
y_axis = quatrotate(quaternion, y_axis);
z_axis = quatrotate(quaternion, z_axis);

% The rotation matrix is formed, with edits in random x, y, and z
% directions
x_rot = normrnd(0,rotation_stddev);
y_rot = normrnd(0,rotation_stddev);
z_rot = normrnd(0,rotation_stddev);
rotation_matrix = [x_axis' y_axis' z_axis'];
rotation_matrix = [1 0 0; 0 cos(x_rot) -sin(x_rot); 0 sin(x_rot) cos(x_rot)] * rotation_matrix;
rotation_matrix = [cos(y_rot) 0 sin(y_rot); 0 1 0; -sin(y_rot) 0 cos(y_rot)] * rotation_matrix;
rotation_matrix = [cos(z_rot) -sin(z_rot) 0; sin(z_rot) cos(z_rot) 0; 0 0 1] * rotation_matrix;

pts_xyz = [pts2(1:3:end) pts2(2:3:end) pts2(3:3:end)];
new_pts_xyz = [];
for i=1:size(pts_xyz,1)
    a = [[pts_xyz(i,1)/45 pts_xyz(i,2)/27 pts_xyz(i,3)/18]*rotation_matrix];
    x=a(1)*rx + cx;
    y=a(2)*ry + cy;
    z=a(3)*rz + cz;
    new_pts_xyz = [new_pts_xyz [x y z]];
end
%new_pts_xyz = normrnd(new_pts_xyz, 0.5);
new_pts_xyz = new_pts_xyz';

end
