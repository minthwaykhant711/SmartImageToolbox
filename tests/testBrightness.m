
clc;
close all;

% Initialize project
projectRoot = fileparts(fileparts(mfilename('fullpath')));
run(fullfile(projectRoot, 'setupProject.m'));

% Load sample image
img = imread('cameraman.tif');

% Apply brightness adjustments
brighter = adjustBrightness(img, 0.3);
darker = adjustBrightness(img, -0.3);

% Display results
figure('Name', 'Brightness Adjustment Test');

subplot(1,3,1);
imshow(img);
title('Original');

subplot(1,3,2);
imshow(brighter);
title('Brighter (+0.3)');

subplot(1,3,3);
imshow(darker);
title('Darker (-0.3)');
