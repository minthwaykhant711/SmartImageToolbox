% demoTransformations.m
% Script demo for Module 3: runs every transformation on a sample image and
% displays the original and transformed results side by side for evaluation.

img = imread('peppers.png');

%% Geometric transformations (reverse mapping, bilinear)
figure('Name', 'Geometric Transformations');
tiledlayout(2, 3, 'TileSpacing', 'compact');
nexttile; imshow(img); title('Original');
nexttile; imshow(translateImage(img, 60, 40)); title('Translation (60, 40)');
nexttile; imshow(scaleImage(img, 0.6)); title('Scaling 0.6x');
nexttile; imshow(rotateImage(img, 30)); title('Rotation 30\circ');
A = buildAffineMatrix(size(img), 15, 1, 0.8, 0.3, 0, 0, 0);
nexttile; imshow(affineTransform(img, A)); title('Affine (shear + rotation)');
nexttile; imshow(rotateImage(img, 30, 'bilinear', 'forward')); title('Rotation, forward mapping');

%% Interpolation comparison on a 4x zoom of a crop
crop = img(150:210, 200:260, :);
figure('Name', 'Interpolation Comparison');
tiledlayout(1, 4, 'TileSpacing', 'compact');
nexttile; imshow(crop); title('Crop');
methods = {'nearest', 'bilinear', 'bicubic'};
for k = 1:3
    nexttile; imshow(resizeImage(crop, 4, methods{k})); title(methods{k});
end

%% Radial distortion: simulate barrel distortion, then correct it
distorted = correctRadialDistortion(checkerboard(40, 6, 6) > 0.5, -0.3, 0, 'bilinear', 'distort');
corrected = correctRadialDistortion(distorted, -0.3, 0, 'bilinear', 'correct');
figure('Name', 'Radial Distortion');
tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile; imshow(distorted); title('Barrel distorted (k1 = -0.3)');
nexttile; imshow(corrected); title('Corrected');

%% Registration: recover a known affine transform
gray = rgb2gray(img);
moving = affineTransform(gray, buildAffineMatrix(size(gray), 12, 1.1, 1.1, 0, 0, 15, -10), ...
    'bilinear', 'reverse', 'same');
[registered, T, info] = registerImages(gray, moving, 'features');
disp(info.summary);
figure('Name', 'Image Registration');
tiledlayout(1, 3, 'TileSpacing', 'compact');
nexttile; imshow(gray); title('Fixed');
nexttile; imshow(moving); title('Moving');
nexttile; imshow(imfuse(gray, registered, 'falsecolor')); title('Fixed vs registered');
