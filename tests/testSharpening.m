
clc;
close all;

% Initialize project
projectRoot = fileparts(fileparts(mfilename('fullpath')));
run(fullfile(projectRoot, 'setupProject.m'));

% Load sample image
img = imread('cameraman.tif');

% Apply sharpening
laplacianResult = applyLaplacianSharpening(img, 1);
highPassResult = applyHighPassSharpening(img, 1.5);

% Display results
figure('Name', 'Image Sharpening Comparison');

subplot(1,3,1);
imshow(img);
title('Original Image');

subplot(1,3,2);
imshow(laplacianResult);
title('Laplacian Sharpening');

subplot(1,3,3);
imshow(highPassResult);
title('High-Pass Sharpening');
