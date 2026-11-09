function output = adaptiveThreshold(inputImage)
% ADAPTIVETHRESHOLD Segment an image using locally adaptive thresholds.
%
% Input:
%   inputImage - Nonempty RGB or grayscale image
%
% Output:
%   output - Binary image with the input spatial dimensions

    grayImage = validateAndConvertToGray(inputImage, 'adaptiveThreshold');
    normalizedImage = im2double(grayImage);
    threshold = adaptthresh(normalizedImage);
    output = imbinarize(normalizedImage, threshold);

end
