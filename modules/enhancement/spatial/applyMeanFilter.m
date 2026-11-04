
function output = applyMeanFilter(img, kernelSize)
    % Apply mean filtering for noise reduction
    %
    % img        : Input grayscale or RGB image
    % kernelSize : Neighborhood size (e.g., 3, 5, 7)

    % Create averaging kernel
    kernel = ones(kernelSize, kernelSize) / (kernelSize^2);

    % Apply mean filter
    output = imfilter(img, kernel, 'replicate');
end
