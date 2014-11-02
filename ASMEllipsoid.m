function out_pdm = ASMEllipsoid( Fx, Fy, Fz, eigenmodes, principle_standard_deviations, initial_pdm, center_point, polarity,north, south, east, west )
% Matthew Leming
% Active Shape Modelling for the input ellipsoid PDM and eigenmodes
% This method ought to be run multiple times. It moves a PDM out into an
% image of an ellipsoid by projecting each point along its normal vector,
% in the gradient space. If it finds no values along these normal vectors,
% the PDM merely expands. It is then centered and projected to the shape
% space.


% This is usually just 64x64x64. It's the origin.
cx = center_point(1);
cy = center_point(2);
cz = center_point(3);

% Move the PDM into an array that's easier to take x, y, and z values from
initial_xyz = [initial_pdm(1:3:end) initial_pdm(2:3:end) initial_pdm(3:3:end)];

% Build the list of normal vectors that correspond to each point
outward_vector_list = [];
for i=1:size(initial_xyz,1)
    north_south =  initial_xyz(south(i),:) - initial_xyz(north(i),:);
    east_west = initial_xyz(west(i),:) - initial_xyz(east(i),:);
    outward_vector_list = [outward_vector_list normc(cross(north_south,east_west)')];
end

% This fits the ellipsoid to 13 potential places along the normal vectors.
% There is some tricky rounding and array boundary statements here, but
% essentially it tests which gradients are best fitted along the normals of
% each PDM.
new_pdm = [];

for i=1:size(outward_vector_list,2)
    best_grad_unround = initial_xyz(i,:)+ outward_vector_list(:,i)';
    best_grad = round(best_grad_unround);
    for j=-6:6
        % This stands for "potential gradient"
        pot_grad_unround = initial_xyz(i,:) + ((j)*outward_vector_list(:,i))';
        pot_grad = round(pot_grad_unround);
        if pot_grad(1) + cx > 0 && pot_grad(1) + cx < 129 && pot_grad(2) + cy > 0 && pot_grad(2) + cy < 129 && pot_grad(3) + cz > 0 && pot_grad(3) + cz < 129 ...
            && best_grad(1) + cx > 0 && best_grad(1) + cx < 129 && best_grad(2) + cy > 0 && best_grad(2) + cy < 129 && best_grad(3) + cz > 0 && best_grad(3) + cz < 129

            best_vector = [Fx(best_grad(1)+cx, best_grad(2) + cz, best_grad(3) + cz) ...
                Fy(best_grad(1)+cx, best_grad(2) + cz, best_grad(3) + cz) ...
                Fz(best_grad(1)+cx, best_grad(2) + cz, best_grad(3) + cz)];
            pot_vector = [Fx(pot_grad(1)+cx,pot_grad(2)+cy,pot_grad(3)+cz) ...
                Fy(pot_grad(1)+cx,pot_grad(2)+cy,pot_grad(3)+cz) ...
                Fz(pot_grad(1)+cx,pot_grad(2)+cy,pot_grad(3)+cz)];
            if abs(dot(best_vector, outward_vector_list(:,i))) < abs(dot(pot_vector, outward_vector_list(:,i)))
                best_grad = pot_grad;
                best_grad_unround = pot_grad_unround;
            end
        end
    end
    new_pdm = [new_pdm best_grad_unround'];
end
out_pdm = [];
for i=1:size(new_pdm,2)
    out_pdm = [out_pdm new_pdm(1,i) new_pdm(2,i) new_pdm(3,i)];
end
out_pdm = out_pdm';

% Project the ellipsoid to the shape space, after recentering it.
mean_x = mean(out_pdm(1:3:end));
mean_y = mean(out_pdm(2:3:end));
mean_z = mean(out_pdm(3:3:end));
% Subtract the center of gravity
out_pdm(1:3:end) = out_pdm(1:3:end) - mean_x;
out_pdm(2:3:end) = out_pdm(2:3:end) - mean_y;
out_pdm(3:3:end) = out_pdm(3:3:end) - mean_z;
% This commented code -- the weight -- is for possible adjustment in case
% the shape space affects the size of the PDM unfavorably. This shouldn't
% happen, but this code was used for testing.
% weight = sum(abs(out_pdm(:)));
eigendots = [];
% eigendots is the dot product of each eigenmode with the output pdm. These
% are summed up. The center of gravity is then re-added.
for i=1:size(eigenmodes,2)
    eigendots = [eigendots eigenmodes(:,i)*dot(out_pdm,eigenmodes(:,i))];
end
out_pdm = sum(eigendots')';
% out_pdm = out_pdm * weight/sum(abs(out_pdm(:)));
out_pdm(1:3:end) = out_pdm(1:3:end) + mean_x;
out_pdm(2:3:end) = out_pdm(2:3:end) + mean_y;
out_pdm(3:3:end) = out_pdm(3:3:end) + mean_z;


end

