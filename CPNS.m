function [ final_28_tuples, PNS ] = CPNS( n_tuples )
% From an input of 222xN ellipsoid PMDs, output a 28xN tuple of Euclidean
% values, for use in PCA. Also output a PNS, so that the 28 tuples can be
% converted easily back to 222 tuples


centered_PDM = zeros(size(n_tuples));
centers_of_gravity = [];
scale_variables = [];

% Prepare the tuples to be input into PNSmain, by centering the ellipsoids,
% then scaling them
for i=1:size(n_tuples,2)
    tuple = n_tuples(:,i);
    xyz_tuple = [tuple(1:3:end) tuple(2:3:end) tuple(3:3:end)];
    meanxyz = mean(xyz_tuple);
    centers_of_gravity = [centers_of_gravity meanxyz'];
    
    sum_of_squares = 0;
    for j=1:size(xyz_tuple,1)
        sum_of_squares = sum_of_squares + (xyz_tuple(j,1)-meanxyz(1))^2 + (xyz_tuple(j,2)-meanxyz(2))^2 + (xyz_tuple(j,3)-meanxyz(3))^2;
        xyz_tuple(j,:) = xyz_tuple(j,:) - meanxyz;
    end
    scale_variables = [scale_variables sqrt(sum_of_squares)];
    
    xyz_tuple = xyz_tuple';
    centered_PDM(:,i) = xyz_tuple(:);
end

scaled_centered_PDM = zeros(size(centered_PDM));
for i=1:size(centered_PDM,2)
    scaled_centered_PDM(:,i) = centered_PDM(:,i) / scale_variables(i);
end

% The Euclidean conversion happens here
[resmat, PNS] = PNSmain(scaled_centered_PDM);

euclideanized_sphere = zeros(size(resmat));
for i=1:size(resmat,2)
    euclideanized_sphere(:,i) = resmat(:,i)*scale_variables(i);
end

% Add in 4 more Euclidean values to the 1x24 matrices, to output nx28
% matrices
commensurated_scale_variables = mean(scale_variables) * log(scale_variables/mean(scale_variables));
final_28_tuples = zeros([28 size(n_tuples,2)]);
for i=1:size(final_28_tuples,2)
    final_28_tuples(:,i) = [euclideanized_sphere(:,i)' centers_of_gravity(:,i)' commensurated_scale_variables(i)'];
end
end

