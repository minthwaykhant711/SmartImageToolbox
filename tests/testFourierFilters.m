
clc;
close all;

% Initialize project
projectRoot = fileparts(fileparts(mfilename('fullpath')));
run(fullfile(projectRoot, 'setupProject.m'));

% Load sample image
img = imread('cameraman.tif');

% Apply Fourier filters
lowPass = applyFourierLowPass(img, 30);
highPass = applyFourierHighPass(img, 30);
bandPass = applyFourierBandPass(img, 15, 60);

% Display comparison
figure('Name', 'Fourier Filtering Comparison');

subplot(2,2,1);
imshow(img);
title('Original Image');

subplot(2,2,2);
imshow(lowPass);
title('Low-Pass Filter');

subplot(2,2,3);
imshow(highPass);
title('High-Pass Filter');

subplot(2,2,4);
imshow(bandPass);
title('Band-Pass Filter');
