function ui = buildEnhancementPanel(parent, workspace)
% BUILDENHANCEMENTPANEL Enhancement controls and original/result comparisons.
    if nargin < 2, workspace = ImageWorkspace(); end
    panel = ImageProcessingPanel(parent, 'Enhancement', ...
        'Improve contrast, reduce noise, and inspect spatial or frequency filters.', workspace);
    panel.addHeading('Processing');
    operations = {'Histogram Equalization', 'Histogram Matching', 'Brightness Adjustment', ...
        'Contrast Adjustment', 'Mean Filter', 'Median Filter', 'Laplacian Sharpening', ...
        'High-Pass Sharpening', 'Fourier Low-Pass', 'Fourier High-Pass', 'Fourier Band-Pass'};
    operation = panel.addDropDown('Operation', operations, @onOperationChanged);
    first = panel.addNumber('Parameter', 1);
    second = panel.addNumber('Second parameter', 1);
    helpLabel = panel.addInfo('', 60);
    reference = [];
    referenceButton = panel.addButton('Load Histogram Reference', @onReference);
    applyButton = panel.addButton('Apply Enhancement', @onApply, true);
    compareButton = panel.addButton('Compare Histograms', @onCompare);
    panel.finish();
    onOperationChanged();
    ui = struct('Panel', panel, 'OperationDropDown', operation, 'ParameterFields', [first second], ...
        'ApplyButton', applyButton, 'CompareButton', compareButton, ...
        'OriginalAxes', panel.Axes(1), 'ProcessedAxes', panel.Axes(2));
    function onOperationChanged(~, ~)
        settings = enhancementSettings(operation.Value);
        fields = [first second];
        for index = 1:2
            available = index <= numel(settings.Values);
            panel.showControl(fields(index), available);
            if available
                fields(index).Limits = [-Inf Inf];
                fields(index).Value = settings.Values(index);
                fields(index).Limits = settings.Limits(index, :);
                fields(index).UserData.Label.Text = settings.Names{index};
            end
        end
        referenceButton.Enable = matlab.lang.OnOffSwitchState(strcmp(operation.Value, 'Histogram Matching'));
        referenceButton.Visible = referenceButton.Enable;
        if strcmp(operation.Value, 'Histogram Matching'), panel.Controls.RowHeight{referenceButton.Layout.Row} = 32;
        else, panel.Controls.RowHeight{referenceButton.Layout.Row} = 0; end
        helpLabel.Text = settings.Help;
    end
    function onReference(~, ~)
        [file, folder] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif', 'Reference image'});
        if isequal(file, 0), return; end
        try
            reference = readToolboxImage(fullfile(folder, file));
            panel.setStatus(['Reference loaded: ' file]);
        catch exception, panel.setStatus(exception.message); end
    end
    function onApply(~, ~)
        if ~panel.requireImage(), return; end
        try
            settings = enhancementSettings(operation.Value);
            values = [first.Value second.Value];
            timer = tic;
            result = applyEnhancementOperation(panel.InputImage, operation.Value, ...
                values(1:numel(settings.Values)), reference);
            panel.setResult(result, operation.Value);
            panel.setStatus(sprintf('%s completed in %.0f ms. Use or send the result to continue.', ...
                operation.Value, toc(timer) * 1000));
        catch exception, panel.setStatus(exception.message); end
    end
    function onCompare(~, ~)
        if isempty(panel.ResultImage), panel.setStatus('Apply an enhancement first.'); return; end
        panel.showPanels({'Input image', panel.ResultName, 'Input histogram', 'Result histogram'});
        panel.showImage(1, panel.InputImage, 'Input image');
        panel.showImage(2, panel.ResultImage, panel.ResultName);
        images = {panel.InputImage, panel.ResultImage};
        for index = 1:2
            gray = im2single(images{index});
            if size(gray, 3) == 3, gray = rgb2gray(gray); end
            [counts, centers] = imhist(gray);
            bar(panel.Axes(index + 2), centers, counts, 1, 'EdgeColor', 'none');
            axis(panel.Axes(index + 2), 'on');
            xlabel(panel.Axes(index + 2), 'Intensity'); ylabel(panel.Axes(index + 2), 'Pixels');
        end
        title(panel.Axes(3), 'Input histogram'); title(panel.Axes(4), 'Result histogram');
    end
end
