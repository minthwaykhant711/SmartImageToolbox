function [output, kind] = applySegmentationOperation(image, operation, parameters)
% APPLYSEGMENTATIONOPERATION Segmentation methods shared by the UI and tests.
    if nargin < 3, parameters = struct(); end
    defaults = struct('Radius', 2, 'MinArea', 20, 'MaxArea', Inf, ...
        'Shape', 'All shapes', 'Threshold', 0.5, 'Polarity', 'Auto', ...
        'Lower', [0 0.25 0], 'Upper', [1 1 1]);
    names = fieldnames(defaults);
    for index = 1:numel(names)
        if ~isfield(parameters, names{index}), parameters.(names{index}) = defaults.(names{index}); end
    end
    ImageWorkspace.validateImage(image);
    kind = 'mask';
    switch operation
        case 'Sobel Edge Detection', output = sobelEdge(image); return;
        case 'Prewitt Edge Detection', output = prewittEdge(image); return;
        case 'Canny Edge Detection', output = cannyEdge(image); return;
        case 'Global Thresholding', output = globalThreshold(image, parameters.Threshold);
        case 'Otsu Thresholding', output = otsuThreshold(image);
        case 'Adaptive Thresholding', output = adaptiveThreshold(image);
        case 'Watershed Segmentation'
            output = watershedSegmentation(image); kind = 'labels'; return;
        case {'RGB Color Segmentation', 'HSV Color Segmentation'}
            output = segmentByColor(image, operation(1:3), parameters.Lower, parameters.Upper); return;
        case {'Dilation', 'Erosion', 'Opening', 'Closing', 'Shape-Based Segmentation'}
            if islogical(image), output = image;
            else, output = otsuThreshold(image); end
        otherwise, error('applySegmentationOperation:Operation', 'Unknown segmentation operation.');
    end
    if ~islogical(image) || ~ismember(operation, {'Dilation', 'Erosion', 'Opening', 'Closing', 'Shape-Based Segmentation'})
        border = [output(1, :), output(end, :), output(:, 1)', output(:, end)'];
        if strcmp(parameters.Polarity, 'Dark foreground') || ...
                (strcmp(parameters.Polarity, 'Auto') && mean(border) > 0.5)
            output = ~output;
        end
    end
    if ismember(operation, {'Dilation', 'Erosion', 'Opening', 'Closing'})
        output = applyMorphology(output, operation, parameters.Radius);
    elseif strcmp(operation, 'Shape-Based Segmentation')
        output = shapeBasedSegmentation(output, parameters.MinArea, parameters.MaxArea, parameters.Shape);
    end
end
