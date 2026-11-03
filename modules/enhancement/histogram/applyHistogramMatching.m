
function output = applyHistogramMatching(sourceImg, referenceImg)
    % Apply histogram matching using a reference image
    %
    % Inputs:
    %   sourceImg    - Image to be processed
    %   referenceImg - Reference image
    %
    % Output:
    %   output       - Histogram-matched image

    % Convert source to grayscale
    if size(sourceImg, 3) == 3
        sourceImg = rgb2gray(sourceImg);
    end

    % Convert reference to grayscale
    if size(referenceImg, 3) == 3
        referenceImg = rgb2gray(referenceImg);
    end

    % Match source histogram to reference histogram
    output = imhistmatch(sourceImg, referenceImg);

end
