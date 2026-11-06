function captureInterface()
% CAPTUREINTERFACE Export real MATLAB UI previews for visual verification.
    root = fileparts(fileparts(mfilename('fullpath')));
    output = fullfile(root, 'docs', 'screenshots');
    if ~isfolder(output), mkdir(output); end
    previous = getenv('SMART_IMAGE_TOOLBOX_VISIBLE');
    setenv('SMART_IMAGE_TOOLBOX_VISIBLE','off');
    restore = onCleanup(@() setenv('SMART_IMAGE_TOOLBOX_VISIBLE',previous)); %#ok<NASGU>
    app = runToolbox();
    closeApp = onCleanup(@() delete(app)); %#ok<NASGU>
    state = app.UIFigure.UserData;
    state.Workspace.loadImage(imread('peppers.png'), 'Sample image');
    state.Enhancement.OperationDropDown.Value = 'Contrast Adjustment';
    state.Enhancement.OperationDropDown.ValueChangedFcn([],[]);
    state.Enhancement.ApplyButton.ButtonPushedFcn([],[]);
    app.TabGroup.SelectedTab = app.EnhancementTab;
    settleAndExport(app.UIFigure,fullfile(output,'enhancement.png'));
    state.Segmentation.CompareButton.ButtonPushedFcn([],[]);
    app.TabGroup.SelectedTab = app.SegmentationTab;
    settleAndExport(app.UIFigure,fullfile(output,'segmentation.png'));
    state.Transformation.OperationDropDown.Value = 'Interpolation Comparison';
    state.Transformation.OperationDropDown.ValueChangedFcn([],[]);
    state.Transformation.ApplyButton.ButtonPushedFcn([],[]);
    app.TabGroup.SelectedTab = app.TransformationTab;
    settleAndExport(app.UIFigure,fullfile(output,'transformation.png'));
    samples = load(fullfile(root,'assets','sampleDigits.mat'));
    state.Workspace.loadImage(samples.images(:,:,8),'MNIST sample: 7');
    state.Recognition.RecognizeButton.ButtonPushedFcn([],[]);
    app.TabGroup.SelectedTab = app.DigitrecognitionTab;
    assert(contains(state.Recognition.ResultLabel.Text, 'ANN:'), state.Recognition.Panel.StatusLabel.Text);
    settleAndExport(app.UIFigure,fullfile(output,'digit-recognition.png'));
    writer = appdesigner.internal.serialization.FileWriter(fullfile(root,'app','SmartImageToolbox.mlapp'));
    writer.writeAppScreenshot(fullfile(output,'digit-recognition.png'));
    fprintf('Interface previews saved to %s\n',output);
end
function settleAndExport(figure, filename)
    drawnow;
    pause(1);
    drawnow;
    exportapp(figure,filename);
end
