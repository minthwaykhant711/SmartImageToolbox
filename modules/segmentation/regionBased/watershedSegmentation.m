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
