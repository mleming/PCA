function [cx,cy,cz,rx,ry,rz,rotation_matrix] = parameterDeterminer( pts )
%Guesses the center, radii, and rotation of an input ellipsoid PDM
%cx,cy,cz,rx,ry,rz,quaternion
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
opp_rad = normr(cross(opposite_coords_max,opposite_coords_min))
opposite_coords_mid = pts_xyz(1,:);
for i=1:size(pts_xyz,1)
    pot = sum((sqrt(sum(pts_xyz(i,:).^2))*opp_rad - pts_xyz(i,:)).^2);
    best = sum((sqrt(sum(opposite_coords_mid.^2))*opp_rad - opposite_coords_mid).^2);
    if pot <= best
        opposite_coords_mid = pts_xyz(i,:);
    end
end
mid_radius = sqrt(sum(opposite_coords_mid.^2));
rx = max_radius
ry = mid_radius
rz = min_radius
dot(normc(opposite_coords_max'),normc(opposite_coords_min'))
if abs(dot(normc(opposite_coords_max'),normc(opposite_coords_min'))) > 0.2
    rotation_matrix = [1 0 0; 0 1 0; 0 0 1]
else
rotation_matrix = [normc(opposite_coords_max') normc(opposite_coords_mid') normc(opposite_coords_min') ]
rotation_matrix = rotation_matrix';
end
% 
% 
% [rotation_matrix, D]=eig(cov(pts_xyz,1));
% q = sqrt(diag(D*3));
% rx = q(1);
% ry = q(2);
% rz = q(3);
 
pts(1:3:end) = pts(1:3:end) + cx;
pts(2:3:end) = pts(2:3:end) + cy;
pts(3:3:end) = pts(3:3:end) + cz;


% c_x = 1;
% c_y = 1;
% c_z = 1;
% rad_x = 1;
% rad_y = 2;
% rad_z = 3;
% x_rot = pi/4;
% y_rot = pi/2;
% z_rot = pi/3;

% pts_xyz = [pts(1:3:end) pts(2:3:end) pts(3:3:end)];
% 
% syms x y z c_x c_y c_z rad_x rad_y rad_z x_rot y_rot z_rot
% 
% f(x,y,z,c_x, c_y, c_z, rad_x, rad_y, rad_z, x_rot, y_rot, z_rot) = (((x-c_x)*cos(y_rot)*cos(z_rot) + (y-c_y)*-cos(y_rot)*sin(z_rot) + (z-c_z)*sin(y_rot))^2)/(rad_x^2) + ...
%     (((x-c_x)*(cos(x_rot)*sin(z_rot) + cos(z_rot)*sin(x_rot)*sin(y_rot)) + (y-c_y)*(cos(x_rot)*cos(z_rot) - sin(x_rot)*sin(y_rot)*sin(z_rot)) + (z-c_z)*(-cos(y_rot)*sin(x_rot)))^2)/(rad_y^2) + ...
%     (((x-c_x)*(sin(x_rot)*sin(z_rot) - cos(x_rot)*cos(z_rot)*sin(y_rot)) + (y-c_y)*(cos(z_rot)*sin(x_rot) + cos(x_rot)*sin(y_rot)*sin(z_rot)) + (z-c_z)*(cos(x_rot)*cos(y_rot)))^2)/(rad_z^2);
% 
% d_c_x = diff(f,c_x);
% d_c_y = diff(f,c_y);
% d_c_z = diff(f,c_z);
% d_rad_x = diff(f,rad_x);
% d_rad_y = diff(f,rad_y);
% d_rad_z = diff(f,rad_z);
% d_x_rot = diff(f,x_rot);
% d_y_rot = diff(f,y_rot);
% d_z_rot = diff(f,z_rot);
% 
% guess = [min_radius max_radius ((min_radius+max_radius)/2) 0 pi/3 0];
% 
% row_gen(x,y,z) = [...
% %     d_c_x(x,y,z,guess(1),guess(2),guess(3),guess(4),guess(5),guess(6),guess(7),guess(8),guess(9))...
% %     d_c_y(x,y,z,guess(1),guess(2),guess(3),guess(4),guess(5),guess(6),guess(7),guess(8),guess(9))...
% %     d_c_z(x,y,z,guess(1),guess(2),guess(3),guess(4),guess(5),guess(6),guess(7),guess(8),guess(9))...
%     d_rad_x(x,y,z,cx,cy,cz,guess(1),guess(2),guess(3),guess(4),guess(5),guess(6))...
%     d_rad_y(x,y,z,cx,cy,cz,guess(1),guess(2),guess(3),guess(4),guess(5),guess(6))...
%     d_rad_z(x,y,z,cx,cy,cz,guess(1),guess(2),guess(3),guess(4),guess(5),guess(6))...
%     d_x_rot(x,y,z,cx,cy,cz,guess(1),guess(2),guess(3),guess(4),guess(5),guess(6))...
%     d_y_rot(x,y,z,cx,cy,cz,guess(1),guess(2),guess(3),guess(4),guess(5),guess(6))...
%     d_z_rot(x,y,z,cx,cy,cz,guess(1),guess(2),guess(3),guess(4),guess(5),guess(6))...
%     ];
% 
% offset = [100 100];
% %for j=1:10
% while sum(abs(offset)) > 2
%     dB = [];
%     A = [];
%     for i=1:size(pts_xyz,1)
%         dB = [dB 1 - double(f(pts_xyz(i,1),pts_xyz(i,2),pts_xyz(i,3),cx,cy,cz,guess(1),guess(2),guess(3),guess(4),guess(5),guess(6)))];
%         A = [A double(row_gen(pts_xyz(i,1),pts_xyz(i,2),pts_xyz(i,3))')];
%     end
%     dB = dB';
%     A = A';
%     offset = linsolve(A'*A,A'*dB);
%     guess = guess + offset';
%     guess = double(guess);
%     guess'
% end
% guess
% %rotations = [[                                    cos(y_rot)*cos(z_rot),                                   -cos(y_rot)*sin(z_rot),             sin(y_rot)]...
% %            [ cos(x_rot)*sin(z_rot) + cos(z_rot)*sin(x_rot)*sin(y_rot), cos(x_rot)*cos(z_rot) - sin(x_rot)*sin(y_rot)*sin(z_rot), -cos(y_rot)*sin(x_rot)]...
% %            [ sin(x_rot)*sin(z_rot) - cos(x_rot)*cos(z_rot)*sin(y_rot), cos(z_rot)*sin(x_rot) + cos(x_rot)*sin(y_rot)*sin(z_rot),  cos(x_rot)*cos(y_rot)]];

end

