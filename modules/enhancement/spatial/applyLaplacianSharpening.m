
function output = applyLaplacianSharpening(img, strength)
    % Sharpen image using the Laplacian operator
    % strength: 0 = unchanged, 1 = normal sharpening

    if nargin < 2
        strength = 1;
    end

    validateattributes(strength, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'nonnegative'});

    imgDouble = im2double(img);

    % Laplacian kernel (negative center)
    kernel = [0 1 0; 1 -4 1; 0 1 0];

    output = zeros(size(imgDouble));

    % Process grayscale or RGB channels
    for c = 1:size(imgDouble, 3)
        laplacian = imfilter(imgDouble(:,:,c), ...
            kernel, 'replicate', 'conv');

        output(:,:,c) = imgDouble(:,:,c) ...
            - strength * laplacian;
    end

    output = max(0, min(1, output));
end
