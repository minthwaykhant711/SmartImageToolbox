function state = initializeToolboxApp(app)
% INITIALIZETOOLBOXAPP Build responsive tabs around one shared image workspace.
    if strcmp(getenv('SMART_IMAGE_TOOLBOX_VISIBLE'), 'off'), app.UIFigure.Visible = 'off'; end
    app.UIFigure.Theme = 'light';
    projectRoot = fileparts(fileparts(mfilename('fullpath')));
    addpath(genpath(fullfile(projectRoot, 'modules')));
    theme = toolboxTheme();
    tabs = [app.EnhancementTab app.SegmentationTab app.TransformationTab app.DigitrecognitionTab];
    for tab = tabs, delete(tab.Children); tab.BackgroundColor = theme.Background; end
    app.UIFigure.Name = 'Smart Image Toolbox | Handwritten Digit Recognition';
    app.UIFigure.Position = [80 70 1320 860];
    app.UIFigure.Color = theme.Background;
    root = uigridlayout(app.UIFigure, [2 1]);
    root.RowHeight = {62, '1x'};
    root.Padding = [14 10 14 14];
    root.BackgroundColor = theme.Background;
    header = uigridlayout(root, [2 2]);
    header.RowHeight = {30, 22}; header.ColumnWidth = {'1x', 360};
    header.Padding = [4 0 4 0]; header.BackgroundColor = theme.Background;
    titleLabel = uilabel(header, 'Text', 'Smart Image Toolbox', 'FontSize', 24, ...
        'FontWeight', 'bold', 'FontColor', theme.Text);
    titleLabel.Layout.Row = 1; titleLabel.Layout.Column = 1;
    subtitle = uilabel(header, 'Text', 'Enhance  /  Segment  /  Transform  /  Recognize', ...
        'FontSize', 12, 'FontColor', theme.Muted);
    subtitle.Layout.Row = 2; subtitle.Layout.Column = 1;
    source = uilabel(header, 'Text', 'Upload an image in any tab to begin', ...
        'HorizontalAlignment', 'right', 'WordWrap', 'on', 'FontColor', theme.Muted);
    source.Layout.Row = [1 2]; source.Layout.Column = 2;
    app.TabGroup.Parent = root;
    app.TabGroup.Layout.Row = 2;
    app.TabGroup.FontSize = 14;
    workspace = ImageWorkspace();
    enhancement = buildEnhancementPanel(app.EnhancementTab, workspace);
    segmentation = createSegmentationUI(app.SegmentationTab, workspace);
    transformation = buildTransformationPanel(app.TransformationTab, workspace);
    recognition = buildDigitRecognitionPanel(app.DigitrecognitionTab, workspace, projectRoot);
    changeListener = addlistener(workspace, 'ImageChanged', @(~, ~) updateSource());
    recognitionListener = addlistener(workspace, 'RecognitionRequested', @(~, ~) selectRecognition());
    state = struct('Workspace', workspace, 'Enhancement', enhancement, ...
        'Segmentation', segmentation, 'Transformation', transformation, 'Recognition', recognition, ...
        'Listeners', {{changeListener, recognitionListener}}, 'ProjectRoot', projectRoot);
    app.UIFigure.UserData = state;
    function updateSource()
        source.Text = sprintf('%s\n%d x %d pixels', workspace.CurrentSource, ...
            size(workspace.CurrentImage, 2), size(workspace.CurrentImage, 1));
    end
    function selectRecognition()
        app.TabGroup.SelectedTab = app.DigitrecognitionTab;
    end
end
