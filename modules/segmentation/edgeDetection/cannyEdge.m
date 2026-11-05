function output = cannyEdge(inputImage)
% CANNYEDGE Detect edges using the Canny operator.
%
% Input:
%   inputImage - Nonempty RGB or grayscale image
%
% Output:
%   output - Binary edge image with the input spatial dimensions

    grayImage = validateAndConvertToGray(inputImage, 'cannyEdge');
    output = edge(grayImage, 'canny');

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
