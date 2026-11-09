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
