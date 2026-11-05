function labels = watershedSegmentation(inputImage)
% WATERSHEDSEGMENTATION Segment an image into watershed catchment basins.
%
% The image is converted to grayscale and normalized, then segmented from
% the gradient-magnitude surface. Extended-minimum markers suppress shallow
% minima before watershed is applied. The output is a label matrix with the
% same height and width as the input: positive integers identify regions and
% zero identifies watershed ridge lines.

    grayImage = validateAndConvertToGray(inputImage, 'watershedSegmentation');
    normalizedImage = im2double(grayImage);

    gradientImage = imgradient(normalizedImage);
    minimaMask = imextendedmin(gradientImage, 0.02);
    imposedGradient = imimposemin(gradientImage, minimaMask);
    labels = watershed(imposedGradient);

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
