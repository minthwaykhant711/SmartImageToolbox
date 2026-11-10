classdef ImageProcessingPanel < handle
    % Reusable controls, comparison canvas, and shared-image actions.
    properties
        Root
        Controls
        Sidebar
        Footer
        Axes
        StatusLabel
        SourceLabel
        Workspace
        InputImage = []
        ResultImage = []
        ResultDisplay = []
        ResultKind = 'image'
        ResultName = 'Result'
        ChainButton
        SendButton
        SaveButton
        ResetButton
        SampleButton
        PrimaryButton
        Row = 0
        Listener
    end
    methods
        function obj = ImageProcessingPanel(parent, titleText, description, workspace, sampleCallback)
            obj.Workspace = workspace;
            figure = ancestor(parent, 'figure');
            figure.Theme = 'light';
            theme = toolboxTheme();
            obj.Root = uigridlayout(parent, [1 2]);
            obj.Root.ColumnWidth = {310, '1x'};
            obj.Root.Padding = [12 12 12 12];
            obj.Root.ColumnSpacing = 14;
            obj.Root.BackgroundColor = theme.Background;
            obj.Sidebar = uigridlayout(obj.Root, [2 1]);
            obj.Sidebar.RowHeight = {'1x', 260};
            obj.Sidebar.Padding = [0 0 0 0];
            obj.Sidebar.RowSpacing = 0;
            obj.Sidebar.BackgroundColor = theme.Surface;
            obj.Controls = uigridlayout(obj.Sidebar, [55 2]);
            obj.Controls.ColumnWidth = {'1x', '1x'};
            obj.Controls.RowHeight = repmat({0}, 1, 55);
            obj.Controls.RowSpacing = 5;
            obj.Controls.Padding = [14 14 14 14];
            obj.Controls.Scrollable = 'on';
            obj.Controls.BackgroundColor = theme.Surface;
            obj.addHeading(titleText, 21);
            obj.addInfo(description, 48);
            obj.addButton('Upload Image', @obj.onUpload);
            if nargin < 5, sampleCallback = @(~, ~) workspace.loadImage(imread('peppers.png'), 'Sample image'); end
            obj.SampleButton = obj.addButton('Sample Image', sampleCallback);
            obj.SourceLabel = obj.addInfo('Load an image in any tab to begin.', 42);
            canvas = uigridlayout(obj.Root, [2 2]);
            canvas.RowHeight = {'1x', 0};
            canvas.Padding = [0 0 0 0];
            canvas.BackgroundColor = theme.Background;
            obj.Axes = gobjects(1, 4);
            for index = 1:4
                obj.Axes(index) = uiaxes(canvas);
                obj.Axes(index).Layout.Row = ceil(index / 2);
                obj.Axes(index).Layout.Column = mod(index - 1, 2) + 1;
                obj.Axes(index).FontName = theme.Font;
                showImageInBox(obj.Axes(index), []);
            end
            obj.showPanels({'Input image', 'Result'});
            obj.Listener = addlistener(workspace, 'ImageChanged', @(~, ~) obj.onImageChanged());
            obj.onImageChanged();
        end
        function label = addHeading(obj, text, fontSize)
            if nargin < 3, fontSize = 14; end
            label = obj.addInfo(text, max(28, fontSize + 10));
            label.FontSize = fontSize;
            label.FontWeight = 'bold';
            theme = toolboxTheme();
            label.FontColor = theme.Text;
        end
        function label = addInfo(obj, text, height)
            if nargin < 3, height = 38; end
            obj.nextRow(height);
            theme = toolboxTheme();
            label = uilabel(obj.Controls, 'Text', text, 'WordWrap', 'on', ...
                'FontName', theme.Font, 'FontSize', 12, 'FontColor', theme.Muted);
            label.Layout.Row = obj.Row;
            label.Layout.Column = [1 2];
        end
        function control = addButton(obj, text, callback, primary)
            if nargin < 4, primary = false; end
            obj.nextRow(32);
            theme = toolboxTheme();
            control = uibutton(obj.Controls, 'Text', text, 'ButtonPushedFcn', callback, ...
                'FontName', theme.Font, 'FontSize', 12);
            control.Layout.Row = obj.Row;
            control.Layout.Column = [1 2];
            if primary
                obj.PrimaryButton = control;
                control.BackgroundColor = theme.Accent;
                control.FontColor = [1 1 1];
                control.FontWeight = 'bold';
            end
        end
        function control = addNumber(obj, text, value, limits)
            if nargin < 4, limits = [-Inf Inf]; end
            obj.nextRow(26);
            label = uilabel(obj.Controls, 'Text', text, 'FontSize', 12);
            label.Layout.Row = obj.Row; label.Layout.Column = 1;
            control = uieditfield(obj.Controls, 'numeric', 'Value', value, 'Limits', limits);
            control.Layout.Row = obj.Row; control.Layout.Column = 2;
            control.UserData = struct('Label', label, 'Row', obj.Row, 'Default', value);
        end
        function control = addDropDown(obj, text, items, callback)
            if nargin < 4, callback = []; end
            obj.nextRow(28);
            label = uilabel(obj.Controls, 'Text', text, 'FontSize', 12);
            label.Layout.Row = obj.Row; label.Layout.Column = 1;
            if strcmp(text, 'Operation')
                label.Layout.Column = [1 2];
                obj.nextRow(32);
            end
            control = uidropdown(obj.Controls, 'Items', items);
            control.Layout.Row = obj.Row; control.Layout.Column = 2;
            control.UserData = struct('Label', label, 'Row', obj.Row);
            if strcmp(text, 'Operation'), control.Layout.Column = [1 2]; end
            if ~isempty(callback), control.ValueChangedFcn = callback; end
        end
        function showControl(obj, control, visible)
            row = control.UserData.Row;
            control.Visible = matlab.lang.OnOffSwitchState(visible);
            control.UserData.Label.Visible = matlab.lang.OnOffSwitchState(visible);
            if visible, obj.Controls.RowHeight{row} = 26;
            else, obj.Controls.RowHeight{row} = 0; end
        end
        function finish(obj)
            obj.Controls.RowHeight = obj.Controls.RowHeight(1:obj.Row);
            theme = toolboxTheme();
            obj.Footer = uigridlayout(obj.Sidebar, [5 2]);
            obj.Footer.RowHeight = {36, 32, 36, 30, '1x'};
            obj.Footer.Padding = [14 10 14 10];
            obj.Footer.BackgroundColor = theme.Surface;
            if ~isempty(obj.PrimaryButton)
                obj.Controls.RowHeight{obj.PrimaryButton.Layout.Row} = 0;
                obj.PrimaryButton.Parent = obj.Footer;
                obj.PrimaryButton.Layout.Row = 1; obj.PrimaryButton.Layout.Column = [1 2];
            end
            obj.ChainButton = uibutton(obj.Footer, 'Text', 'Use Result as Input', 'FontSize', 11, 'ButtonPushedFcn', @obj.onChain);
            obj.ChainButton.Layout.Row = 2; obj.ChainButton.Layout.Column = 1;
            obj.ResetButton = uibutton(obj.Footer, 'Text', 'Reset to Original', 'FontSize', 11, 'ButtonPushedFcn', @(~, ~) obj.Workspace.reset());
            obj.ResetButton.Layout.Row = 2; obj.ResetButton.Layout.Column = 2;
            obj.SendButton = uibutton(obj.Footer, 'Text', 'Send to Digit Recognition', ...
                'BackgroundColor', theme.Accent, 'FontColor', [1 1 1], 'FontWeight', 'bold', 'ButtonPushedFcn', @obj.onSend);
            obj.SendButton.Layout.Row = 3; obj.SendButton.Layout.Column = [1 2];
            obj.SaveButton = uibutton(obj.Footer, 'Text', 'Save Result', 'ButtonPushedFcn', @obj.onSave);
            obj.SaveButton.Layout.Row = 4; obj.SaveButton.Layout.Column = [1 2];
            obj.StatusLabel = uilabel(obj.Footer, 'Text', 'Choose an operation and press Apply.', ...
                'FontColor', theme.Muted, 'WordWrap', 'on', 'VerticalAlignment', 'top');
            obj.StatusLabel.Layout.Row = 5; obj.StatusLabel.Layout.Column = [1 2];
            obj.updateActions();
        end
        function ready = requireImage(obj)
            ready = ~isempty(obj.InputImage);
            if ~ready, obj.setStatus('Upload an image in any tab first.'); end
        end
        function setResult(obj, image, name, displayImage, kind)
            if nargin < 4 || isempty(displayImage), displayImage = image; end
            if nargin < 5, kind = 'image'; end
            obj.ResultImage = image;
            obj.ResultDisplay = displayImage;
            obj.ResultName = name;
            obj.ResultKind = kind;
            obj.showPanels({'Input image', name});
            obj.showImage(1, obj.InputImage, 'Input image');
            obj.showImage(2, displayImage, name);
            obj.updateActions();
        end
        function showPanels(obj, names)
            canvas = obj.Axes(1).Parent;
            if numel(names) > 2, canvas.RowHeight = {'1x', '1x'};
            else, canvas.RowHeight = {'1x', 0}; end
            for index = 1:4
                cla(obj.Axes(index));
                if index <= numel(names), title(obj.Axes(index), names{index}); end
            end
        end
        function showImage(obj, index, image, name)
            if isempty(image), return; end
            showImageInBox(obj.Axes(index), image);
            title(obj.Axes(index), name, 'Interpreter', 'none');
        end
        function setStatus(obj, text)
            if ~isempty(obj.StatusLabel) && isvalid(obj.StatusLabel)
                obj.StatusLabel.Text = text;
            end
        end
        function onImageChanged(obj)
            obj.InputImage = obj.Workspace.CurrentImage;
            obj.ResultImage = []; obj.ResultDisplay = [];
            obj.showPanels({'Input image', 'Result'});
            obj.showImage(1, obj.InputImage, 'Input image');
            if ~isempty(obj.InputImage)
                obj.SourceLabel.Text = sprintf('%s\n%d x %d pixels', ...
                    obj.Workspace.CurrentSource, size(obj.InputImage, 2), size(obj.InputImage, 1));
            end
            obj.updateActions();
        end
        function updateActions(obj)
            if isempty(obj.ChainButton), return; end
            hasResult = ~isempty(obj.ResultImage);
            canUse = hasResult && ~strcmp(obj.ResultKind, 'labels');
            obj.ChainButton.Enable = matlab.lang.OnOffSwitchState(canUse);
            obj.SendButton.Enable = matlab.lang.OnOffSwitchState(canUse);
            obj.SaveButton.Enable = matlab.lang.OnOffSwitchState(hasResult);
            obj.ResetButton.Enable = matlab.lang.OnOffSwitchState(~isempty(obj.Workspace.OriginalImage));
        end
        function onUpload(obj, ~, ~)
            [file, folder] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif;*.tiff', 'Image files'});
            if isequal(file, 0), return; end
            try
                obj.Workspace.loadImage(readToolboxImage(fullfile(folder, file)), file);
                obj.setStatus('Image loaded. It is available in every processing tab.');
            catch exception
                obj.setStatus(exception.message);
            end
        end
        function onChain(obj, ~, ~)
            if isempty(obj.ResultImage) || strcmp(obj.ResultKind, 'labels'), return; end
            obj.Workspace.useResult(obj.ResultImage, obj.ResultName);
            obj.setStatus('The result is now the shared input in all processing tabs.');
        end
        function onSend(obj, ~, ~)
            if isempty(obj.ResultImage) || strcmp(obj.ResultKind, 'labels'), return; end
            obj.Workspace.sendToRecognition(obj.ResultImage, obj.ResultName);
        end
        function onSave(obj, ~, ~)
            if isempty(obj.ResultImage), return; end
            [file, folder] = uiputfile({'*.png', 'PNG image'; '*.mat', 'MATLAB result'}, 'Save result', 'result.png');
            if isequal(file, 0), return; end
            try
                [~, ~, extension] = fileparts(file);
                if strcmpi(extension, '.mat')
                    result = obj.ResultImage; %#ok<NASGU>
                    save(fullfile(folder, file), 'result');
                else
                    imwrite(obj.ResultDisplay, fullfile(folder, file));
                end
                obj.setStatus(['Saved ' file]);
            catch exception
                obj.setStatus(exception.message);
            end
        end
    end
    methods (Access = private)
        function nextRow(obj, height)
            obj.Row = obj.Row + 1;
            obj.Controls.RowHeight{obj.Row} = height;
        end
    end
end
