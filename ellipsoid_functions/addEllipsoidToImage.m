function [ output_args ] = addEllipsoidToImage(image, cx, cy, cz, rx, ry, rz, file_name  )
%AUTHOR: Matthew Leming
%   Scales an image to intensities 0 to 1, then adds an ellipsoid to that
%   by doubling the values in the ellipsoid region. Writes a metaimage for
%   use in ITK-SNAP

xrange = 128;
yrange = 128;
zrange = 128;

ellipsoid = zeros([xrange yrange zrange]);

% For scaling the image
min_value = min(image(:));
max_value = max(image(:));

% Add the ellipsoid to the input image, giving the ellipsoid double the
% intensity
for x=1:xrange
    for y=1:yrange
        for z=1:zrange
            if ((x-cx)/rx)^2 + ((y-cy)/ry)^2 + ((z-cz)/rz)^2 < 1
                ellipsoid(x,y,z) = 2*((image(x,y,z) - min_value)/(max_value - min_value));
            else
                ellipsoid(x,y,z) = ((image(x,y,z) - min_value)/(max_value - min_value));
            end
        end
    end
end

writeMETA(ellipsoid,file_name);

end

