function ui = createSegmentationUI(parent, workspace)
% CREATESEGMENTATIONUI Segmentation, morphology, and comparison controls.
    if nargin < 2, workspace = ImageWorkspace(); end
    panel = ImageProcessingPanel(parent, 'Segmentation', ...
        'Separate foreground, compare edges, and refine regions before recognition.', workspace);
    panel.addHeading('Processing');
    operations = {'Sobel Edge Detection', 'Prewitt Edge Detection', 'Canny Edge Detection', ...
        'Global Thresholding', 'Otsu Thresholding', 'Adaptive Thresholding', 'Watershed Segmentation', ...
        'Dilation', 'Erosion', 'Opening', 'Closing', 'Shape-Based Segmentation', ...
        'HSV Color Segmentation', 'RGB Color Segmentation'};
    operation = panel.addDropDown('Operation', operations, @onOperationChanged);
    polarity = panel.addDropDown('Foreground', {'Auto', 'Bright foreground', 'Dark foreground'});
    threshold = panel.addNumber('Threshold', 0.5, [0 1]);
    radius = panel.addNumber('Disk radius (px)', 2, [0 50]);
    minimum = panel.addNumber('Minimum area (px)', 20, [0 Inf]);
    maximum = panel.addNumber('Maximum area (px)', 1000000, [1 Inf]);
    shape = panel.addDropDown('Region shape', {'All shapes', 'Round regions', 'Elongated regions'});
    bounds = gobjects(1, 6);
    for index = 1:6, bounds(index) = panel.addNumber('Color bound', mod(index + 1, 2), [0 1]); end
    helpLabel = panel.addInfo('', 56);
    applyButton = panel.addButton('Apply Segmentation', @onApply, true);
    compareButton = panel.addButton('Compare Edge Detectors', @onCompareEdges);
    compareSegments = panel.addButton('Compare Segmentations', @onCompareSegments);
    panel.finish();
    onOperationChanged();
    ui = struct('Panel', panel, 'OperationDropDown', operation, 'ApplyButton', applyButton, ...
        'CompareButton', compareButton, 'CompareSegmentsButton', compareSegments, ...
        'OriginalAxes', panel.Axes(1), 'ProcessedAxes', panel.Axes(2), ...
        'RadiusField', radius, 'ThresholdField', threshold, 'ColorBounds', bounds);
    function onOperationChanged(~, ~)
        op = operation.Value;
        panel.showControl(threshold, strcmp(op, 'Global Thresholding'));
        panel.showControl(radius, ismember(op, {'Dilation', 'Erosion', 'Opening', 'Closing'}));
        isShape = strcmp(op, 'Shape-Based Segmentation');
        panel.showControl(minimum, isShape); panel.showControl(maximum, isShape);
        panel.showControl(shape, isShape);
        panel.showControl(polarity, ismember(op, {'Global Thresholding','Otsu Thresholding', ...
            'Adaptive Thresholding','Dilation','Erosion','Opening','Closing','Shape-Based Segmentation'}));
        isColor = contains(op, 'Color Segmentation');
        if startsWith(op, 'HSV'), names = {'Hue', 'Saturation', 'Value'};
        else, names = {'Red', 'Green', 'Blue'}; end
        if strcmp(op, 'HSV Color Segmentation'), values = [0 0.12 0.3 1 0.1 1];
        else, values = [0.5 1 0 0.5 0 0.5]; end
        for index = 1:6
            panel.showControl(bounds(index), isColor);
            if mod(index, 2), side = 'min'; else, side = 'max'; end
            bounds(index).UserData.Label.Text = [names{ceil(index / 2)} ' ' side];
            if isColor, bounds(index).Value = values(index); end
        end
        if isColor, helpLabel.Text = 'Set channel ranges from 0 to 1. Hue can wrap across red when min exceeds max.';
        elseif strcmp(op, 'Watershed Segmentation'), helpLabel.Text = 'Colors identify separate regions. Save labels as MAT or the color view as PNG.';
        elseif isShape, helpLabel.Text = 'Filter foreground components by area and eccentricity. Holes within digits are preserved.';
        else, helpLabel.Text = 'Auto foreground treats the border as background. Choose a polarity to override it.'; end
    end
    function parameters = currentParameters()
        values = [bounds.Value];
        parameters = struct('Radius', radius.Value, 'Threshold', threshold.Value, ...
            'MinArea', minimum.Value, 'MaxArea', maximum.Value, 'Shape', shape.Value, ...
            'Polarity', polarity.Value, 'Lower', values(1:2:6), 'Upper', values(2:2:6));
    end
    function onApply(~, ~)
        if ~panel.requireImage(), return; end
        try
            timer = tic;
            [output, kind] = applySegmentationOperation(panel.InputImage, operation.Value, currentParameters());
            displayImage = output;
            if strcmp(kind, 'labels'), displayImage = colorizeRegions(output); end
            panel.setResult(output, operation.Value, displayImage, kind);
            panel.setStatus(sprintf('%s completed in %.0f ms.', operation.Value, toc(timer) * 1000));
        catch exception, panel.setStatus(exception.message); end
    end
    function onCompareEdges(~, ~)
        if ~panel.requireImage(), return; end
        try
            results = {sobelEdge(panel.InputImage), prewittEdge(panel.InputImage), cannyEdge(panel.InputImage)};
            panel.setResult(results{3}, 'Canny Edge Detection');
            panel.showPanels({'Input image', 'Sobel', 'Prewitt', 'Canny'});
            panel.showImage(1, panel.InputImage, 'Input image');
            names = {'Sobel', 'Prewitt', 'Canny'};
            for index = 1:3, panel.showImage(index + 1, results{index}, names{index}); end
            panel.setStatus('Edge comparison. Canny is the active result for saving or the next stage.');
        catch exception, panel.setStatus(exception.message); end
    end
    function onCompareSegments(~, ~)
        if ~panel.requireImage(), return; end
        try
            parameters = currentParameters();
            first = applySegmentationOperation(panel.InputImage, 'Otsu Thresholding', parameters);
            second = applySegmentationOperation(panel.InputImage, 'Adaptive Thresholding', parameters);
            labels = watershedSegmentation(panel.InputImage);
            panel.setResult(first, 'Otsu Thresholding');
            panel.showPanels({'Input image', 'Otsu', 'Adaptive', 'Watershed regions'});
            panel.showImage(1, panel.InputImage, 'Input image');
            panel.showImage(2, first, 'Otsu'); panel.showImage(3, second, 'Adaptive');
            panel.showImage(4, colorizeRegions(labels), 'Watershed regions');
            panel.setStatus('Segmentation comparison. Otsu is the active result for saving or recognition.');
        catch exception, panel.setStatus(exception.message); end
    end
end
