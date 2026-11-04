function buildTransformationPanel(parent)
    % Build the Module 3 (Geometric Transformations and Interpolation) GUI
    % inside any container: a uifigure, uipanel or the app's Transformation tab.
    %
    %   buildTransformationPanel(app.TransformationTab)

    operations = {'Translation', 'Scaling (Zoom)', 'Rotation', 'Affine Transformation', ...
                  'Radial Distortion Correction', 'Simulate Radial Distortion', ...
                  'Interpolation Comparison', 'Forward vs Reverse Mapping', 'Image Registration'};

    % Shared state for the nested callbacks
    originalImage = [];
    secondImage = [];
    resultImage = [];

    %% Layout
    root = uigridlayout(parent, [1 2]);
    root.ColumnWidth = {280, '1x'};
    root.Padding = [8 8 8 8];

    controls = uigridlayout(root, [27 2]);
    controls.ColumnWidth = {'1x', '1x'};
    controls.RowHeight = repmat({22}, 1, 27);
    controls.RowSpacing = 5;
    controls.Scrollable = 'on';

    row = 0;
    loadButton = addButton('Load Image', @onLoadImage, 'Load the image to transform');
    sampleButton = uibutton(controls, 'Text', 'Sample Image', 'ButtonPushedFcn', @onSampleImage, ...
        'Tooltip', 'Load a sample image shipped with MATLAB');
    sampleButton.Layout.Row = row; sampleButton.Layout.Column = 2;
    loadButton.Layout.Column = 1;

    operationDropDown = addDropDown('Operation', operations, @onOperationChanged);
    methodDropDown = addDropDown('Interpolation', {'Nearest', 'Bilinear', 'Bicubic'}, []);
    methodDropDown.Value = 'Bilinear';
    mappingDropDown = addDropDown('Mapping', {'Reverse', 'Forward'}, []);
    viewDropDown = addDropDown('Output canvas', {'Full', 'Same'}, []);

    txField = addNumber('Translate X (px)', 40);
    tyField = addNumber('Translate Y (px)', 25);
    sxField = addNumber('Scale X', 1.5);
    syField = addNumber('Scale Y', 1.5);
    angleField = addNumber('Rotation (deg)', 30);
    shxField = addNumber('Shear X', 0.2);
    shyField = addNumber('Shear Y', 0);
    k1Field = addNumber('k1 (radial)', -0.25);
    k2Field = addNumber('k2 (radial)', 0.05);
    zoomField = addNumber('Comparison zoom', 4);

    registrationDropDown = addDropDown('Registration', {'Feature matching', 'Mutual information'}, []);
    secondButton = addButton('Load Moving Image', @onLoadSecond, ...
        'Image to align onto the loaded (fixed) image');
    makeMovingButton = uibutton(controls, 'Text', 'Make Test Moving', ...
        'ButtonPushedFcn', @onMakeMoving, ...
        'Tooltip', 'Create a moving image by transforming the loaded image with the parameters above');
    makeMovingButton.Layout.Row = row; makeMovingButton.Layout.Column = 2;
    secondButton.Layout.Column = 1;

    row = row + 1;
    applyButton = uibutton(controls, 'Text', 'Apply', 'ButtonPushedFcn', @onApply, ...
        'FontWeight', 'bold');
    applyButton.Layout.Row = row; applyButton.Layout.Column = [1 2];

    resetButton = addButton('Reset Parameters', @onReset, 'Restore default parameter values');
    chainButton = uibutton(controls, 'Text', 'Use Result as Input', 'ButtonPushedFcn', @onChain, ...
        'Tooltip', 'Continue transforming from the current result');
    chainButton.Layout.Row = row; chainButton.Layout.Column = 2;
    resetButton.Layout.Column = 1;
    saveButton = addButton('Save Result', @onSave, 'Save the transformed image');
    saveButton.Layout.Column = [1 2];

    row = row + 1;
    statusLabel = uilabel(controls, 'Text', 'Load an image to begin.', 'WordWrap', 'on', ...
        'VerticalAlignment', 'top');
    statusLabel.Layout.Row = [row row + 5]; statusLabel.Layout.Column = [1 2];

    display = uigridlayout(root, [2 2]);
    display.RowHeight = {'1x', 0};
    display.Padding = [0 0 0 0];
    axesList = gobjects(1, 4);
    for k = 1:4
        axesList(k) = uiaxes(display);
        axesList(k).Layout.Row = ceil(k / 2);
        axesList(k).Layout.Column = mod(k - 1, 2) + 1;
        axis(axesList(k), 'off');
        axesList(k).Toolbar.Visible = 'on';
    end
    showPanels({'Original', 'Transformed'});

    onOperationChanged();

    %% Control builders

    function b = addButton(text, callback, tooltip)
        row = row + 1;
        b = uibutton(controls, 'Text', text, 'ButtonPushedFcn', callback, 'Tooltip', tooltip);
        b.Layout.Row = row;
        b.Layout.Column = [1 2];
    end

    function d = addDropDown(label, items, callback)
        row = row + 1;
        l = uilabel(controls, 'Text', label);
        l.Layout.Row = row; l.Layout.Column = 1;
        d = uidropdown(controls, 'Items', items);
        if ~isempty(callback)
            d.ValueChangedFcn = callback;
        end
        d.Layout.Row = row; d.Layout.Column = 2;
    end

    function f = addNumber(label, value)
        row = row + 1;
        l = uilabel(controls, 'Text', label);
        l.Layout.Row = row; l.Layout.Column = 1;
        f = uieditfield(controls, 'numeric', 'Value', value, 'UserData', value);
        f.Layout.Row = row; f.Layout.Column = 2;
    end

    %% Callbacks

    function onLoadImage(~, ~)
        img = pickImage('Select an Image');
        if ~isempty(img)
            setOriginal(img);
        end
    end

    function onSampleImage(~, ~)
        setOriginal(imread('peppers.png'));
    end

    function onLoadSecond(~, ~)
        img = pickImage('Select the Moving Image');
        if ~isempty(img)
            secondImage = img;
            showPanels({'Fixed', 'Moving'});
            showImage(1, originalImage, 'Fixed');
            showImage(2, secondImage, 'Moving');
            setStatus('Moving image loaded. Press Apply to register.');
        end
    end

    function onMakeMoving(~, ~)
        if ~requireImage(), return; end
        A = buildAffineMatrix(size(originalImage), angleField.Value, sxField.Value, ...
            syField.Value, shxField.Value, shyField.Value, txField.Value, tyField.Value);
        secondImage = affineTransform(originalImage, A, 'bilinear', 'reverse', 'same');
        showPanels({'Fixed', 'Moving'});
        showImage(1, originalImage, 'Fixed');
        showImage(2, secondImage, 'Moving (synthetic)');
        setStatus(sprintf(['Synthetic moving image created (rotation %.1f deg, scale %.2f x %.2f, ' ...
            'shear %.2f / %.2f, shift %.1f, %.1f px). Press Apply to register it back.'], ...
            angleField.Value, sxField.Value, syField.Value, shxField.Value, shyField.Value, ...
            txField.Value, tyField.Value));
    end

    function onOperationChanged(~, ~)
        op = operationDropDown.Value;
        usesMapping = ismember(op, {'Translation', 'Scaling (Zoom)', 'Rotation', 'Affine Transformation'});
        setEnabled(mappingDropDown, usesMapping);
        setEnabled(viewDropDown, ismember(op, {'Rotation', 'Affine Transformation', ...
            'Forward vs Reverse Mapping'}));
        setEnabled(methodDropDown, ~ismember(op, {'Interpolation Comparison', 'Image Registration'}));
        setEnabled([txField tyField], ismember(op, {'Translation', 'Affine Transformation'}));
        setEnabled([sxField syField], ismember(op, {'Scaling (Zoom)', 'Affine Transformation', ...
            'Forward vs Reverse Mapping'}));
        setEnabled(angleField, ismember(op, {'Rotation', 'Affine Transformation', ...
            'Forward vs Reverse Mapping'}));
        setEnabled([shxField shyField], strcmp(op, 'Affine Transformation'));
        setEnabled([k1Field k2Field], contains(op, 'Radial'));
        setEnabled(zoomField, strcmp(op, 'Interpolation Comparison'));
        isRegistration = strcmp(op, 'Image Registration');
        setEnabled([registrationDropDown secondButton makeMovingButton], isRegistration);
        if isRegistration
            % Registration test images are made from the affine parameters
            setEnabled([txField tyField sxField syField angleField shxField shyField], true);
        end
    end

    function onApply(~, ~)
        if ~requireImage(), return; end
        op = operationDropDown.Value;
        method = lower(methodDropDown.Value);
        mapping = lower(mappingDropDown.Value);
        view = lower(viewDropDown.Value);

        applyButton.Enable = 'off';
        cleanup = onCleanup(@() set(applyButton, 'Enable', 'on'));
        setStatus('Processing...');
        drawnow;

        try
            tic;
            switch op
                case 'Translation'
                    resultImage = translateImage(originalImage, txField.Value, tyField.Value, method, mapping);
                    showResult(op, sprintf('tx = %g, ty = %g', txField.Value, tyField.Value));

                case 'Scaling (Zoom)'
                    resultImage = scaleImage(originalImage, sxField.Value, syField.Value, method, mapping);
                    showResult(op, sprintf('sx = %g, sy = %g', sxField.Value, syField.Value));

                case 'Rotation'
                    resultImage = rotateImage(originalImage, angleField.Value, method, mapping, view);
                    showResult(op, sprintf('%g deg', angleField.Value));

                case 'Affine Transformation'
                    A = currentAffine();
                    resultImage = affineTransform(originalImage, A, method, mapping, view);
                    showResult(op, sprintf('A = [%.3f %.3f %.1f; %.3f %.3f %.1f]', A(1, :), A(2, :)));

                case 'Radial Distortion Correction'
                    resultImage = correctRadialDistortion(originalImage, k1Field.Value, k2Field.Value, method, 'correct');
                    showResult('Corrected', sprintf('k1 = %g, k2 = %g', k1Field.Value, k2Field.Value));

                case 'Simulate Radial Distortion'
                    resultImage = correctRadialDistortion(originalImage, k1Field.Value, k2Field.Value, method, 'distort');
                    showResult('Distorted', sprintf(['k1 = %g, k2 = %g. Use "Use Result as Input" ' ...
                        'and Radial Distortion Correction with the same k1, k2 to undo it.'], ...
                        k1Field.Value, k2Field.Value));

                case 'Interpolation Comparison'
                    runInterpolationComparison();

                case 'Forward vs Reverse Mapping'
                    runMappingComparison(method, view);

                case 'Image Registration'
                    runRegistration();
            end
        catch err
            setStatus(['Error: ' err.message]);
            uialert(ancestor(parent, 'figure'), err.message, 'Transformation Error');
        end
    end

    function onReset(~, ~)
        fields = [txField tyField sxField syField angleField shxField shyField k1Field k2Field zoomField];
        for f = fields
            f.Value = f.UserData;
        end
    end

    function onChain(~, ~)
        if isempty(resultImage)
            setStatus('There is no result to use yet.');
            return;
        end
        setOriginal(resultImage);
        setStatus('Result is now the input image.');
    end

    function onSave(~, ~)
        if isempty(resultImage)
            setStatus('There is no result to save yet.');
            return;
        end
        [file, path] = uiputfile({'*.png', 'PNG'; '*.jpg', 'JPEG'; '*.bmp', 'Bitmap'}, ...
            'Save Result', 'transformed.png');
        if isequal(file, 0), return; end
        imwrite(resultImage, fullfile(path, file));
        setStatus(['Saved to ' fullfile(path, file)]);
    end

    %% Operations with custom displays

    function runInterpolationComparison()
        zoom = zoomField.Value;
        if zoom <= 1
            error('Comparison zoom must be greater than 1.');
        end
        % Zoom into a central crop so the differences between methods are visible
        [h, w, ~] = size(originalImage);
        cropSize = max(8, round(min(h, w) / (2 * zoom)));
        r0 = round((h - cropSize) / 2) + 1;
        c0 = round((w - cropSize) / 2) + 1;
        crop = originalImage(r0:r0 + cropSize - 1, c0:c0 + cropSize - 1, :);

        names = {'Nearest', 'Bilinear', 'Bicubic'};
        times = zeros(1, 3);
        results = cell(1, 3);
        for k = 1:3
            t = tic;
            results{k} = resizeImage(crop, zoom, lower(names{k}));
            times(k) = toc(t);
        end
        resultImage = results{3};

        showPanels({'', '', '', ''});
        showImage(1, crop, sprintf('Original crop %dx%d', cropSize, cropSize));
        for k = 1:3
            showImage(k + 1, results{k}, sprintf('%s (%.0f ms)', names{k}, times(k) * 1000));
        end
        setStatus(sprintf(['Central %dx%d crop zoomed %gx. Nearest is blocky, bilinear is smooth ' ...
            'but softer, bicubic keeps edges sharpest. Saved result: bicubic.'], cropSize, cropSize, zoom));
    end

    function runMappingComparison(method, view)
        A = buildAffineMatrix(size(originalImage), angleField.Value, sxField.Value, ...
            syField.Value, 0, 0, 0, 0);
        t = tic;
        forwardNearest = affineTransform(originalImage, A, 'nearest', 'forward', view);
        tn = toc(t);
        t = tic;
        forwardSplat = affineTransform(originalImage, A, 'bilinear', 'forward', view);
        tb = toc(t);
        t = tic;
        reverse = affineTransform(originalImage, A, method, 'reverse', view);
        tr = toc(t);
        resultImage = reverse;

        showPanels({'', '', '', ''});
        showImage(1, originalImage, 'Original');
        showImage(2, forwardNearest, sprintf('Forward, nearest splat (%.0f ms)', tn * 1000));
        showImage(3, forwardSplat, sprintf('Forward, bilinear splat (%.0f ms)', tb * 1000));
        showImage(4, reverse, sprintf('Reverse, %s (%.0f ms)', method, tr * 1000));

        % Holes: pixels covered by the transformed image but never written to
        covered = affineTransform(true(size(originalImage, 1), size(originalImage, 2)), ...
            A, 'nearest', 'reverse', view);
        holes = nnz(covered & all(forwardNearest == 0, 3));
        setStatus(sprintf(['Rotation %g deg, scale %g x %g. Forward mapping pushes each source ' ...
            'pixel to the output; with nearest splatting %d covered pixels (%.1f%%) are never ' ...
            'written (holes). Bilinear splatting fills small gaps but still breaks up at large ' ...
            'zooms. Reverse mapping pulls every output pixel from the source, so it has no holes.'], ...
            angleField.Value, sxField.Value, syField.Value, holes, 100 * holes / max(nnz(covered), 1)));
    end

    function runRegistration()
        if isempty(secondImage)
            error('Load a moving image or press "Make Test Moving" first.');
        end
        if strcmp(registrationDropDown.Value, 'Feature matching')
            method = 'features';
        else
            method = 'mutualinfo';
        end
        t = tic;
        [registered, T, info] = registerImages(originalImage, secondImage, method);
        elapsed = toc(t);
        resultImage = registered;

        showPanels({'', '', '', ''});
        showImage(1, originalImage, 'Fixed');
        showImage(2, secondImage, 'Moving');
        showImage(3, registered, 'Registered moving');
        showImage(4, imfuse(originalImage, registered, 'falsecolor'), ...
            'Overlay (green/magenta = misaligned)');

        if strcmp(method, 'features')
            hold(axesList(2), 'on');
            plot(axesList(2), info.movingPoints(info.inliers, 1), ...
                info.movingPoints(info.inliers, 2), 'g+', 'MarkerSize', 6);
            hold(axesList(2), 'off');
        end
        % Alignment quality: correlation between fixed and registered where they overlap
        fixedGray = im2double(im2gray(originalImage));
        registeredGray = im2double(im2gray(registered));
        overlap = registeredGray > 0;
        quality = corr2(fixedGray(overlap), registeredGray(overlap));

        note = '';
        if strcmp(method, 'mutualinfo')
            note = ' (models rotation, uniform scale and translation only - no shear)';
        end
        setStatus(sprintf('%s%s in %.2f s. %s. Correlation after alignment = %.3f. T = [%.3f %.3f %.1f; %.3f %.3f %.1f]', ...
            registrationDropDown.Value, note, elapsed, info.summary, quality, T(1, :), T(2, :)));
    end

    %% Helpers

    function A = currentAffine()
        A = buildAffineMatrix(size(originalImage), angleField.Value, sxField.Value, ...
            syField.Value, shxField.Value, shyField.Value, txField.Value, tyField.Value);
    end

    function img = pickImage(prompt)
        img = [];
        [file, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp;*.tif;*.tiff', 'Image Files'}, prompt);
        if isequal(file, 0), return; end
        img = imread(fullfile(path, file));
    end

    function setOriginal(img)
        originalImage = img;
        resultImage = [];
        showPanels({'Original', 'Transformed'});
        showImage(1, img, 'Original');
        cla(axesList(2));
        setStatus(sprintf('Image loaded: %d x %d x %d. Choose an operation and press Apply.', ...
            size(img, 1), size(img, 2), size(img, 3)));
    end

    function showResult(name, details)
        elapsed = toc;
        showPanels({'Original', name});
        showImage(1, originalImage, 'Original');
        showImage(2, resultImage, name);
        setStatus(sprintf('%s: %s | %s interpolation, %s mapping | %dx%d -> %dx%d | %.0f ms', ...
            name, details, methodDropDown.Value, mappingDropDown.Value, ...
            size(originalImage, 1), size(originalImage, 2), ...
            size(resultImage, 1), size(resultImage, 2), elapsed * 1000));
    end

    function showPanels(names)
        % Two panels for single results, a 2x2 grid for comparisons
        if numel(names) == 4
            display.RowHeight = {'1x', '1x'};
        else
            display.RowHeight = {'1x', 0};
            cla(axesList(3)); cla(axesList(4));
        end
        for k = 1:numel(names)
            if ~isempty(names{k})
                title(axesList(k), names{k});
            end
        end
    end

    function showImage(k, img, label)
        ax = axesList(k);
        imshow(img, 'Parent', ax);
        title(ax, sprintf('%s  [%dx%d]', label, size(img, 1), size(img, 2)), 'Interpreter', 'none');
    end

    function ok = requireImage()
        ok = ~isempty(originalImage);
        if ~ok
            uialert(ancestor(parent, 'figure'), 'Please load an image first.', 'No Image');
        end
    end

    function setEnabled(components, enabled)
        set(components, 'Enable', matlab.lang.OnOffSwitchState(enabled));
    end

    function setStatus(text)
        statusLabel.Text = text;
    end
end
