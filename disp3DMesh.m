function disp3DMesh( data, north, south, west, east, color )
%disp3DMesh displays 3D mesh of the ellipsoid
%	Input
%   1. data: vector of ellipsoid you would like to display
%   2. idx_n: index for north for each points
%   3. idx_s: index for south for each points
%   4. idx_w: index for west  for each points
%   5. idx_e: index for east  for each points
%   
    %figure, hold on
    hold on
    for j=1:74
        idx = 3*(j-1);
        idx_n = 3*(north(j)-1);
        idx_s = 3*(south(j)-1);
        idx_e = 3*(east(j)-1);
        idx_w = 3*(west(j)-1);

        line([data(idx+1); data(idx_n+1)],...
             [data(idx+2); data(idx_n+2)],...
             [data(idx+3); data(idx_n+3)], 'Color', color)

        line([data(idx+1); data(idx_s+1)],...
             [data(idx+2); data(idx_s+2)],...
             [data(idx+3); data(idx_s+3)], 'Color', color)

        line([data(idx+1); data(idx_e+1)],...
             [data(idx+2); data(idx_e+2)],...
             [data(idx+3); data(idx_e+3)], 'Color', color)

        line([data(idx+1); data(idx_w+1)],...
             [data(idx+2); data(idx_w+2)],...
             [data(idx+3); data(idx_w+3)], 'Color', color)
    end
    grid on
    axis equal
    view([130 20])
    hold on
end

