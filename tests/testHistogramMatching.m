
% Test histogram matching

clc;
close all;

% Initialize project paths
projectRoot = fileparts(fileparts(mfilename('fullpath')));
run(fullfile(projectRoot, 'setupProject.m'));

% Load sample images
source = imread('cameraman.tif');
reference = imread('pout.tif');

% Apply histogram matching
result = applyHistogramMatching(source, reference);

% Display comparison
figure('Name', 'Histogram Matching Test');

subplot(1,3,1);
imshow(source);
title('Source Image');

subplot(1,3,2);
imshow(reference);
title('Reference Image');

subplot(1,3,3);
imshow(result);
title('Matched Image');
