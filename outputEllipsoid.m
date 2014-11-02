function ellipsoid = outputEllipsoid( cx, cy, cz, rx, ry, rz, file_name )
% AUTHOR: Matthew Leming
% Given the centers (cx,cy,cz), this outputs an ellipsoid of radii rx, ry,
% and rz on a 128x128x128 image. The ellipsoid is of intensity 0.5, while
% the rest of the voxels are 0. Writes a file that is usable by ITK-SNAP
% (with name file_name).

xrange = 128;
yrange = 128;
zrange = 128;

ellipsoid = zeros([xrange yrange zrange]);


% Calculates pixels that are within the given ellipsoid
for x=1:xrange
    for y=1:yrange
        for z=1:zrange
            if ((x-cx)/rx)^2 + ((y-cy)/ry)^2 + ((z-cz)/rz)^2 < 1
                ellipsoid(x,y,z) = 0.5;
            end
        end
    end
end

% Write the file
writeMETA(ellipsoid,file_name);

end

