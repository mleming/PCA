% The following are visuals of the following images, initialized on my ASM and SNAP
% A) An unblurred, unnoisy, 30x30x30 sphere
% B) A blurred, noisy, 30x30x30 sphere
% C) A blurred, noisy, 20x30x40 ellipsoid
% D) A blurred, noisy, 20x30x40 ellipsoid rotated by the quaternion 1+i+k+j
% E) An MR-polluted 20x30x40, unrotated image

% Generate the ellipsoid images
imageA_original = outputEllipsoidQuaternionRotate( 64, 64, 64, 30, 30, 30, [1 0 0 0], '', 1);
imageA = imageA_original;

imageB_original = outputEllipsoidQuaternionRotate( 64, 64, 64, 30, 30, 30, [1 0 0 0], '', 1);
imageB = smooth3(imageB_original, 'gaussian', 3, 5);
imageB = imnoise(imageB, 'gaussian', 0, 0.1);

imageC_original = outputEllipsoidQuaternionRotate( 64, 64, 64, 40, 30, 20, [1 0 0 0], '', 1);
imageC = smooth3(imageC_original, 'gaussian', 3, 5);
imageC = imnoise(imageC, 'gaussian', 0, 0.1);

imageD_original = outputEllipsoidQuaternionRotate( 64, 64, 64, 40, 30, 20, [0 0 0 1], '', 1);
imageD = smooth3(imageD_original, 'gaussian', 3, 5);
imageD = imnoise(imageD, 'gaussian', 0, 0.1);

load('matlab_variables/cubeMRI.mat');
cubeMRI(:) = (cubeMRI(:) - min(cubeMRI(:)))/(max(cubeMRI(:)) - min(cubeMRI(:))) * 0.8 + 0.2;
imageE_original = outputEllipsoidQuaternionRotate( 64, 64, 64, 40, 30, 20, [1 0 0 0], '', 1);
imageE = cubeMRI + imageE_original;

imageF_original = outputEllipsoidQuaternionRotate( 64, 64, 64, 40, 30, 20, [1 0 0 0], '', 1);
imageF = cubeMRI*5 + imageF_original;
imageF(:) = imageF(:)/max(imageF(:));



% Write the images
writeMETA(imageA,'test_cases/testA');
writeMETA(imageB,'test_cases/testB');
writeMETA(imageC,'test_cases/testC');
writeMETA(imageD,'test_cases/testD');
writeMETA(imageE,'test_cases/testE');
writeMETA(imageF,'test_cases/testF');