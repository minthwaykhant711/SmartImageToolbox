function output = prewittEdge(inputImage)
% PREWITTEDGE Detect edges using the Prewitt operator.
%
% Input:
%   inputImage - Nonempty RGB or grayscale image
%
% Output:
%   output - Binary edge image with the input spatial dimensions

    grayImage = validateAndConvertToGray(inputImage, 'prewittEdge');
    output = edge(grayImage, 'prewitt');

end
