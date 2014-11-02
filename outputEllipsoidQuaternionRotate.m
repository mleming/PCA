function ellipsoid = outputEllipsoidQuaternionRotate( cx, cy, cz, rx, ry, rz, quaternion, file_name, polarity)
%AUTHOR: Matthew Leming
%   Outputs an ellipsoid that is rotated by the input quaternion,
%   represented as a 4-element array (real, i, j, k).
xrange = 128;
yrange = 128;
zrange = 128;

if polarity
    ellipsoid = zeros([xrange yrange zrange]);
else
    ellipsoid = ones([xrange yrange zrange]);
end
x_axis = [1 0 0];
y_axis = [0 1 0];
z_axis = [0 0 1];

% Rotate the unit vectors
x_axis = quatrotate(quaternion, x_axis);
y_axis = quatrotate(quaternion, y_axis);
z_axis = quatrotate(quaternion, z_axis);

%Multiply this by the coordinates that are found to by in a non-rotated
%ellipsoid
rotation_matrix =  [x_axis' y_axis' z_axis'];

%Rounding errors cause a grid of values to not be filled in on the 3D
%ellipsoid, so there are eight calls to ensure that rounding errors after
%rotation do not leave holes in a resulting ellipsoid.
for x=1:xrange
    for y=1:yrange
        for z=1:zrange
            if ((x-cx)/rx)^2 + ((y-cy)/ry)^2 + ((z-cz)/rz)^2 < 1
                B = [x-cx y-cy z-cz];
                C = [B*rotation_matrix];
                if floor(C(1))+cx >= 1 && floor(C(2))+cy >= 1 && floor(C(3))+cz >= 1 && ceil(C(1))+cx <= xrange && ceil(C(2))+cy <= yrange  && ceil(C(3))+cz <= zrange 
                     ellipsoid(floor(C(1))+cx,floor(C(2))+cy,floor(C(3))+cz) = polarity;
                     ellipsoid(floor(C(1))+cx,floor(C(2))+cy,ceil(C(3))+cz) = polarity;
                     ellipsoid(floor(C(1))+cx,ceil(C(2))+cy,floor(C(3))+cz) = polarity;
                     ellipsoid(floor(C(1))+cx,ceil(C(2))+cy,ceil(C(3))+cz) = polarity;
                     ellipsoid(ceil(C(1))+cx,floor(C(2))+cy,floor(C(3))+cz) = polarity;
                     ellipsoid(ceil(C(1))+cx,floor(C(2))+cy,ceil(C(3))+cz) = polarity;
                     ellipsoid(ceil(C(1))+cx,ceil(C(2))+cy,floor(C(3))+cz) = polarity;
                     ellipsoid(ceil(C(1))+cx,ceil(C(2))+cy,ceil(C(3))+cz) = polarity;
                end
            end
        end
    end
end

%writeMETA(ellipsoid,file_name);


end

