function ui = createSegmentationUI(parentTab)
% CREATESEGMENTATIONUI
% Creates the Segmentation GUI inside an existing MATLAB tab.

    % Store the uploaded image and UI components
    ui = struct();
    originalImage = [];

    % ==========================================
    % 1. ORIGINAL IMAGE DISPLAY
    % ==========================================

    ui.OriginalAxes = uiaxes(parentTab);

    ui.OriginalAxes.Position = [20 150 250 180];

    title(ui.OriginalAxes, 'Original Image');


    % ==========================================
    % 2. PROCESSED IMAGE DISPLAY
    % ==========================================

    ui.ProcessedAxes = uiaxes(parentTab);

    ui.ProcessedAxes.Position = [300 150 250 180];

    title(ui.ProcessedAxes, 'Processed Image');


    % ==========================================
    % 3. OPERATION LABEL
    % ==========================================

    ui.OperationLabel = uilabel(parentTab);

    ui.OperationLabel.Text = 'Operation';

    ui.OperationLabel.Position = [40 115 100 22];


    % ==========================================
    % 4. OPERATION DROPDOWN
    % ==========================================

    ui.OperationDropDown = uidropdown(parentTab);

    ui.OperationDropDown.Items = {
        'Sobel Edge Detection'
    };

    ui.OperationDropDown.Position = [140 115 350 22];


    % ==========================================
    % 5. UPLOAD IMAGE BUTTON
    % ==========================================

    ui.UploadButton = uibutton(parentTab, 'push');

    ui.UploadButton.Text = 'Upload Image';

    ui.UploadButton.Position = [60 40 150 30];

    ui.UploadButton.ButtonPushedFcn = @uploadImage;


    % ==========================================
    % 6. APPLY BUTTON
    % ==========================================

    ui.ApplyButton = uibutton(parentTab, 'push');

    ui.ApplyButton.Text = 'Apply';

    ui.ApplyButton.Position = [350 40 150 30];

    ui.ApplyButton.ButtonPushedFcn = @applySegmentation;


    % ==========================================
    % 7. UPLOAD IMAGE CALLBACK
    % ==========================================

    function uploadImage(~, ~)

        [file, path] = uigetfile( ...
            {'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files'}, ...
            'Select an Image');

        if isequal(file, 0)
            return;
        end

        % Read selected image
        originalImage = imread(fullfile(path, file));

        % Display original image
        imshow(originalImage, ...
            'Parent', ui.OriginalAxes);

        % Clear previous processed image
        cla(ui.ProcessedAxes);

        title(ui.ProcessedAxes, 'Processed Image');

    end


    % ==========================================
    % 8. APPLY SEGMENTATION CALLBACK
    % ==========================================

    function applySegmentation(~, ~)

        % Check whether an image was uploaded
        if isempty(originalImage)

            uialert(ancestor(parentTab, 'figure'), ...
                'Please upload an image first.', ...
                'No Image');

            return;
        end

        % Get selected operation
        operation = ui.OperationDropDown.Value;

        % Apply segmentation algorithm
        switch operation

            case 'Sobel Edge Detection'

                output = sobelEdge(originalImage);

            otherwise

                uialert(ancestor(parentTab, 'figure'), ...
                    'Unknown segmentation operation.', ...
                    'Error');

                return;

        end

        % Display processed image
        imshow(output, ...
            'Parent', ui.ProcessedAxes);

    end

end