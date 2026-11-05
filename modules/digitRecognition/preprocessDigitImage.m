
function [features, processedImage] = preprocessDigitImage(img)
% PREPROCESSDIGITIMAGE Prepare an uploaded digit for MNIST models.
%
% Input:
%   img - Uploaded grayscale or RGB image
%
% Outputs:
%   features       - 1 x 784 normalized feature vector
%   processedImage - 28 x 28 normalized digit image

    % Step 1: Convert to grayscale
    if ndims(img) == 3
        img = im2gray(img);
    end

    % Step 2: Convert to floating-point [0, 1]
    gray = im2single(img);

    % Step 3: Ensure light digit on dark background
    border = [gray(1,:), gray(end,:), ...
              gray(:,1)', gray(:,end)'];

    if mean(border) > 0.5
        gray = 1 - gray;
    end

    % Step 4: Identify foreground pixels
    level = graythresh(gray);
    mask = gray > max(level, 0.1);

    if ~any(mask(:))
        error('No handwritten digit detected in the image.');
    end

    % Step 5: Crop around the digit
    [rows, cols] = find(mask);

    cropped = gray(min(rows):max(rows), ...
                   min(cols):max(cols));

    % Step 6: Resize while preserving aspect ratio
    [h, w] = size(cropped);
    scale = 20 / max(h, w);

    newH = max(1, round(h * scale));
    newW = max(1, round(w * scale));

    resized = imresize(cropped, [newH, newW]);
    % Slightly thicken thin handwritten strokes
    resized = imdilate(resized, strel('disk', 1));

    % Step 7: Center on a 28 x 28 black canvas
    processedImage = zeros(28, 28, 'single');

    startRow = floor((28 - newH) / 2) + 1;
    startCol = floor((28 - newW) / 2) + 1;

    processedImage(startRow:startRow+newH-1, ...
                   startCol:startCol+newW-1) = resized;

    % Step 8: Flatten into 784 features
    features = reshape(processedImage, 1, 784);

end
