
clc;
close all;

% Initialize project
projectRoot = fileparts(fileparts(mfilename('fullpath')));
run(fullfile(projectRoot, 'setupProject.m'));

% Load image
img = imread('cameraman.tif');

% Add salt-and-pepper noise
noisyImg = imnoise(img, 'salt & pepper', 0.08);

% Apply filters
meanResult = applyMeanFilter(noisyImg, 3);
medianResult = applyMedianFilter(noisyImg, 3);

% Display comparison
figure('Name', 'Mean vs Median Filtering');

subplot(1,4,1);
imshow(img);
title('Original');

subplot(1,4,2);
imshow(noisyImg);
title('Noisy Image');

subplot(1,4,3);
imshow(meanResult);
title('Mean Filter');

subplot(1,4,4);
imshow(medianResult);
title('Median Filter');
