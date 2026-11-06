function ui = buildDigitRecognitionPanel(parent, workspace, projectRoot)
% BUILDDIGITRECOGNITIONPANEL Single-digit preprocessing and KNN/ANN comparison.
    panel = ImageProcessingPanel(parent, 'Digit recognition', ...
        'Upload one handwritten digit or send a processed result from another tab.', workspace, @onSample);
    panel.SampleButton.Text = 'Sample Digit';
    panel.addHeading('Recognition');
    model = panel.addDropDown('Model', {'Compare Both', 'KNN', 'ANN'});
    interpolation = panel.addDropDown('Interpolation', {'Bilinear', 'Nearest', 'Bicubic'});
    stroke = panel.addNumber('Stroke thickening', 0, [0 2]);
    panel.addInfo('Default preprocessing preserves stroke width, removes small artifacts, and centers the digit on 28 x 28 pixels.', 64);
    preview = panel.addButton('Preview Normalized Digit', @onPreview);
    recognize = panel.addButton('Recognize Digit', @onRecognize, true);
    prediction = panel.addInfo('Predicted digit: --', 74);
    prediction.FontSize = 20; prediction.FontWeight = 'bold';
    theme = toolboxTheme(); prediction.FontColor = theme.Accent;
    timing = panel.addInfo('KNN and ANN use the same 784 input features.', 48);
    panel.finish();
    panel.Controls.RowHeight{prediction.Layout.Row} = 0;
    panel.Controls.RowHeight{timing.Layout.Row} = 0;
    canvas = panel.Axes(1).Parent;
    content = uigridlayout(panel.Root, [2 1]);
    content.Layout.Row = 1; content.Layout.Column = 2;
    content.RowHeight = {90, '1x'}; content.Padding = [0 0 0 0];
    content.BackgroundColor = theme.Background;
    panel.Root.RowHeight = {'1x'};
    canvas.Parent = content; canvas.Layout.Row = 2; canvas.Layout.Column = 1;
    summary = uigridlayout(content, [1 2]);
    summary.Layout.Row = 1; summary.ColumnWidth = {'1x', '1x'};
    summary.BackgroundColor = theme.Surface;
    prediction.Parent = summary; prediction.Layout.Row = 1; prediction.Layout.Column = 1;
    timing.Parent = summary; timing.Layout.Row = 1; timing.Layout.Column = 2;
    timing.HorizontalAlignment = 'right';
    panel.SendButton.Visible = 'off';
    panel.Footer.RowHeight{panel.SendButton.Layout.Row} = 0;
    panel.ChainButton.Text = 'Use Normalized Digit';
    listener = addlistener(workspace, 'RecognitionRequested', @onReceived);
    resetListener = addlistener(workspace, 'ImageChanged', @(~, ~) resetPrediction());
    sampleIndex = 0;
    ui = struct('Panel', panel, 'ModelDropDown', model, 'StrokeField', stroke, ...
        'PreviewButton', preview, 'RecognizeButton', recognize, 'ResultLabel', prediction, ...
        'TimingLabel', timing, 'Listeners', {{listener, resetListener}});

    function onSample(~, ~)
        try
            samples = load(fullfile(projectRoot, 'assets', 'sampleDigits.mat'));
            sampleIndex = mod(sampleIndex, size(samples.images, 3)) + 1;
            workspace.loadImage(samples.images(:, :, sampleIndex), sprintf('MNIST sample: %d', samples.labels(sampleIndex)));
            panel.setStatus('Sample digit loaded. Preview or recognize it with either model.');
        catch exception, panel.setStatus(exception.message); end
    end
    function resetPrediction()
        prediction.Text = 'Predicted digit: --';
        timing.Text = 'KNN and ANN use the same 784 input features.';
    end
    function onReceived(~, ~)
        panel.InputImage = workspace.RecognitionImage;
        panel.ResultImage = [];
        panel.SourceLabel.Text = ['From ' workspace.RecognitionSource];
        resetPrediction();
        onPreview();
    end
    function features = prepare()
        [features, normalized] = preprocessDigitImage(panel.InputImage, ...
            StrokeRadius=stroke.Value, Interpolation=lower(interpolation.Value));
        panel.setResult(normalized, 'Normalized 28 x 28 digit');
    end
    function onPreview(~, ~)
        if ~panel.requireImage(), return; end
        try
            prepare(); resetPrediction();
            panel.setStatus('The image on the right is exactly what the classifiers will receive.');
        catch exception
            resetPrediction(); panel.setStatus(exception.message);
        end
    end
    function onRecognize(~, ~)
        if ~panel.requireImage(), return; end
        recognize.Enable = 'off';
        cleanup = onCleanup(@() set(recognize, 'Enable', 'on')); %#ok<NASGU>
        try
            features = prepare();
            if strcmp(model.Value, 'Compare Both'), names = {'KNN', 'ANN'};
            else, names = {model.Value}; end
            results = cell(1, numel(names));
            for index = 1:numel(names)
                results{index} = predictDigitFeatures(features, loadDigitModel(projectRoot, names{index}));
            end
            panel.showPanels({'Input image', 'Normalized 28 x 28 digit', 'Model scores', 'Model scores'});
            panel.showImage(1, panel.InputImage, 'Input image');
            panel.showImage(2, panel.ResultImage, 'Normalized 28 x 28 digit');
            lines = cell(1, numel(names)); times = cell(1, numel(names));
            for index = 1:numel(names)
                result = results{index};
                ax = panel.Axes(index + 2);
                bar(ax, 0:9, reorderScores(result), 'FaceColor', theme.Accent);
                axis(ax, 'on'); xlim(ax, [-0.75 9.75]); ylim(ax, [0 1]);
                ax.XTick = 0:9; xlabel(ax, 'Digit'); ylabel(ax, 'Model score');
                title(ax, [result.Model ' scores']);
                lines{index} = sprintf('%s: %s', result.Model, result.PredictedDigit);
                times{index} = sprintf('%s %.1f ms', result.Model, result.Seconds * 1000);
            end
            prediction.Text = strjoin(lines, newline);
            timing.Text = strjoin(times, ' | ');
            panel.setStatus('Prediction complete. Scores show model preferences; they are not calibrated certainty.');
        catch exception
            resetPrediction(); panel.setStatus(exception.message);
        end
    end
    function scores = reorderScores(result)
        scores = zeros(1, 10);
        for digit = 0:9
            index = find(result.ClassNames == string(digit), 1);
            if ~isempty(index), scores(digit + 1) = result.Scores(1, index); end
        end
    end
end
