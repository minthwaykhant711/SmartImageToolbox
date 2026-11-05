
function X = preprocessMNIST(images)
% PREPROCESSMNIST Convert MNIST images into model-ready features.
%
% Input:
%   images - 28 x 28 x N uint8 images
%
% Output:
%   X - N x 784 normalized feature matrix

    % Normalize pixel values from 0-255 to 0-1
    normalizedImages = single(images) / 255;

    % Flatten each 28x28 image into 784 features
    X = reshape(normalizedImages, 784, [])';

end
