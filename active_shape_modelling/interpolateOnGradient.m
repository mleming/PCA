function Value = interpolateOnGradient( gradient, Xq, Yq, Zq )
% Performs linear interpolation on a 3D array in order to get the
% approximate "in between" value. This does not test array size limits,
% however, and assumes that the input coordinates work in those regards.

Xlower = floor(Xq);
Xupper = Xlower + 1;
Ylower = floor(Yq);
Yupper = Ylower + 1;
Zlower = floor(Zq);
Zupper = Zlower + 1;

Xbet1 = (abs(Xq - Xupper))*gradient(Xlower, Ylower, Zlower) + (abs(Xq - Xlower))*gradient(Xupper, Ylower, Zlower);
Xbet2 = (abs(Xq - Xupper))*gradient(Xlower, Yupper, Zlower) + (abs(Xq - Xlower))*gradient(Xupper, Yupper, Zlower);
Ybet1 = (abs(Yq-Yupper))*Xbet1 + (abs(Yq-Ylower))*Xbet2;
Xbet3 = (abs(Xq - Xupper))*gradient(Xlower, Ylower, Zupper) + (abs(Xq - Xlower))*gradient(Xupper, Ylower, Zupper);
Xbet4 = (abs(Xq - Xupper))*gradient(Xlower, Yupper, Zupper) + (abs(Xq - Xlower))*gradient(Xupper, Yupper, Zupper);
Ybet2 = (abs(Yq-Yupper))*Xbet3 + (abs(Yq-Ylower))*Xbet4;

Value = (abs(Zq-Zupper))*Ybet1 + (abs(Zq-Zlower))*Ybet2;

end

