
clc;
close all;

% Initialize project
projectRoot = fileparts(fileparts(mfilename('fullpath')));
run(fullfile(projectRoot, 'setupProject.m'));

% Load sample image
img = imread('cameraman.tif');

% Apply contrast adjustment
higherContrast = adjustContrast(img, 1.8);
lowerContrast = adjustContrast(img, 0.5);

% Display comparison
figure('Name', 'Contrast Adjustment Test');

subplot(1,3,1);
imshow(img);
title('Original Image');

subplot(1,3,2);
imshow(higherContrast);
title('Higher Contrast (1.8)');

subplot(1,3,3);
imshow(lowerContrast);
title('Lower Contrast (0.5)');
