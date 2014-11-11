function [cx,cy,cz,rx,ry,rz,rotation_matrix] = parameterDeterminer( pts )
% Guesses the center, radii, and rotation of an input ellipsoid PDM

cx = mean(pts(1:3:end));
cy = mean(pts(2:3:end));
cz = mean(pts(3:3:end));
pts(1:3:end) = pts(1:3:end) - cx;
pts(2:3:end) = pts(2:3:end) - cy;
pts(3:3:end) = pts(3:3:end) - cz;
pts_xyz = [pts(1:3:end) pts(2:3:end) pts(3:3:end)];

max_radius = 0;
min_radius = Inf;
opposite_coords_max = [];
opposite_coords_min = [];

%% Get the minimum and maximum radii
for i=1:size(pts_xyz,1)
    pot_radius = sqrt(sum(pts_xyz(i,:).^2));
    if pot_radius >= max_radius
        max_radius = pot_radius;
        opposite_coords_max = pts_xyz(i,:);
    end
    if pot_radius <= min_radius
        min_radius = pot_radius;
        opposite_coords_min = pts_xyz(i,:);
    end
end

%% Get the mid radius by projecting to the cross product of the minimum and maximum vectors
opp_rad = normr(cross(opposite_coords_max,opposite_coords_min));
opposite_coords_mid = pts_xyz(1,:);
for i=1:size(pts_xyz,1)
    pot = sum((sqrt(sum(pts_xyz(i,:).^2))*opp_rad - pts_xyz(i,:)).^2);
    best = sum((sqrt(sum(opposite_coords_mid.^2))*opp_rad - opposite_coords_mid).^2);
    if pot <= best
        opposite_coords_mid = pts_xyz(i,:);
    end
end
mid_radius = sqrt(sum(opposite_coords_mid.^2));
rx = max_radius;
ry = mid_radius;
rz = min_radius;

%% If it is spherical, there is a risk of the similar vectors not being orthogonal
%% Rotation matrixes are used in this case because they are naturally output
%% by the function; a translation to quaternions seemed unnecessary
if abs(dot(normc(opposite_coords_max'),normc(opposite_coords_min'))) > 0.2
    rotation_matrix = [1 0 0; 0 1 0; 0 0 1];
else
    rotation_matrix = [normc(opposite_coords_max') normc(opposite_coords_mid') normc(opposite_coords_min') ];
    rotation_matrix = rotation_matrix';
end

%% This is the theoretically ideal way to do this. However,
%% it was not found to work in practice for this PDM
% [rotation_matrix, D]=eig(cov(pts_xyz,1));
% q = sqrt(diag(D*3));
% rx = q(1);
% ry = q(2);
% rz = q(3);
 
pts(1:3:end) = pts(1:3:end) + cx;
pts(2:3:end) = pts(2:3:end) + cy;
pts(3:3:end) = pts(3:3:end) + cz;

end

