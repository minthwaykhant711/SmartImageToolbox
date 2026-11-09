function grayImage = validateAndConvertToGray(inputImage, functionName)
% VALIDATEANDCONVERTTOGRAY Shared input check for the segmentation functions.
%
% Inputs:
%   inputImage   - Nonempty RGB or grayscale image
%   functionName - Caller name, used for the '<functionName>:InvalidInput' error ID
%
% Output:
%   grayImage - The input converted to grayscale

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
