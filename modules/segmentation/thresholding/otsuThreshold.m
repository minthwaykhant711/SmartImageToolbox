function output = otsuThreshold(inputImage)
% OTSUTHRESHOLD Segment an image using Otsu's automatically selected threshold.
%
% Input:
%   inputImage - Nonempty RGB or grayscale image
%
% Output:
%   output - Binary image with the input spatial dimensions

    grayImage = validateAndConvertToGray(inputImage, 'otsuThreshold');
    normalizedImage = im2double(grayImage);
    threshold = graythresh(normalizedImage);
    output = imbinarize(normalizedImage, threshold);

end
