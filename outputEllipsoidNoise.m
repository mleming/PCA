function [ output_args ] = outputEllipsoidNoise(  cx, cy, cz, rx, ry, rz , file_name)
% AUTHOR: Matthew Leming
% Writes a metaimage for ITK-SNAP of a noisy, blurred ellipsoid image.


xrange = 128;
yrange = 128;
zrange = 128;

% Determines the maximum and minimum x+y+z values for later. This could
% easily be done by summing the above ranges for the max and then
% multiplying that by -1 for min, but later changes to orientation would
% potentially make it more favorable to calculate them directly.
max_xyz = -Inf;
min_xyz = Inf;
ellipsoid = ones([xrange yrange zrange]);

% For the Gaussian
smallest_radii = min([rx ry rz]);


% Make ellipsoid intensity 1 and the remaining values to x+y+z. Find the
% minimum and maximum of these values
for x=1:xrange
    for y=1:yrange
        for z=1:zrange
            if ((x-cx)/rx)^2 + ((y-cy)/ry)^2 + ((z-cz)/rz)^2 < 1
                ellipsoid(x,y,z) = 1;
            else
                ellipsoid(x,y,z) = x+y+z;
                if x+y+z > max_xyz
                    max_xyz = x+y+z;
                elseif x+y+z < min_xyz
                    min_xyz = x+y+z;
                end
            end
        end
    end
end

%Scale the x+y+z values outside of the ellipsoid to 0.2 (min) to 0.8 (max)
for x=1:xrange
    for y=1:yrange
        for z=1:zrange
            if ((x-cx)/rx)^2 + ((y-cy)/ry)^2 + ((z-cz)/rz)^2 >= 1
                ellipsoid(x,y,z) = ((ellipsoid(x,y,z) - min_xyz)/(max_xyz - min_xyz))*0.6 + 0.2;
            end
        end
    end
end

% Gaussian smooth
ellipsoid = smooth3(ellipsoid, 'gaussian', 3, smallest_radii/2);

% Gaussian noise
ellipsoid = imnoise(ellipsoid, 'gaussian', 0, 0.01);

writeMETA(ellipsoid,file_name);


end

