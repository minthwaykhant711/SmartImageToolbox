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
