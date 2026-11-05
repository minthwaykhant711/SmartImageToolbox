function output = globalThreshold(inputImage, threshold)
% GLOBALTHRESHOLD Segment an image with one global intensity threshold.
%
% Input:
%   inputImage - Nonempty RGB or grayscale image
%   threshold  - Optional normalized threshold in [0, 1] (default 0.5)
%
% Output:
%   output - Binary image with the input spatial dimensions

    if nargin < 2
        threshold = 0.5;
    end

    if ~isscalar(threshold) || ~isnumeric(threshold) || ~isfinite(threshold) ...
            || threshold < 0 || threshold > 1
        error('globalThreshold:InvalidThreshold', ...
            'Threshold must be a finite scalar between 0 and 1.');
    end

    grayImage = validateAndConvertToGray(inputImage, 'globalThreshold');
    output = imbinarize(im2double(grayImage), threshold);

end

function grayImage = validateAndConvertToGray(inputImage, functionName)
    if isempty(inputImage) || ~(isnumeric(inputImage) || islogical(inputImage)) ...
            || ~isreal(inputImage) || any(~isfinite(inputImage(:)))
        error([functionName ':InvalidInput'], ...
            'Input must be a nonempty numeric or logical image.');
    end

    if ndims(inputImage) == 2
        grayImage = inputImage;
    elseif ndims(inputImage) == 3 && size(inputImage, 3) == 3
        grayImage = rgb2gray(inputImage);
    else
        error([functionName ':InvalidInput'], ...
            'Input must be a grayscale image or an RGB image with three channels.');
    end
end
