function tests = testIntegratedWorkflow
    tests = functiontests(localfunctions);
end
function setupOnce(testCase)
    old = getenv('SMART_IMAGE_TOOLBOX_VISIBLE');
    setenv('SMART_IMAGE_TOOLBOX_VISIBLE', 'off');
    app = runToolbox();
    testCase.TestData.App = app;
    testCase.TestData.State = app.UIFigure.UserData;
    testCase.addTeardown(@() delete(app));
    testCase.addTeardown(@() setenv('SMART_IMAGE_TOOLBOX_VISIBLE', old));
end
function testEnhancementDefaultsAndSharedResult(testCase)
    state = testCase.TestData.State;
    original = ones(50,50,'uint8')*80;
    state.Workspace.loadImage(original, 'Test image');
    ui = state.Enhancement;
    ui.OperationDropDown.Value = 'Brightness Adjustment';
    ui.OperationDropDown.ValueChangedFcn([],[]);
    verifyEqual(testCase, ui.ParameterFields(1).Value, 0.15);
    ui.ApplyButton.ButtonPushedFcn([],[]);
    verifyEqual(testCase, state.Workspace.CurrentImage, original);
    result = ui.Panel.ResultImage;
    verifyGreaterThan(testCase, mean(result(:)), 80/255);
    ui.Panel.onChain([],[]);
    verifyEqual(testCase, state.Segmentation.Panel.InputImage, result);
    verifyEqual(testCase, state.Recognition.Panel.InputImage, result);
    state.Workspace.reset();
    verifyEqual(testCase, state.Workspace.CurrentImage, original);
end
function testSegmentationDisplayAndTransfer(testCase)
    state = testCase.TestData.State;
    image = false(80); image(20:60,35:42) = true;
    state.Workspace.loadImage(image, 'Test digit');
    ui = state.Segmentation;
    ui.OperationDropDown.Value = 'Watershed Segmentation';
    ui.OperationDropDown.ValueChangedFcn([],[]); ui.ApplyButton.ButtonPushedFcn([],[]);
    verifyEqual(testCase, ui.Panel.ResultKind, 'labels');
    verifySize(testCase, ui.Panel.ResultDisplay, [80 80 3]);
    verifyEqual(testCase, ui.Panel.SendButton.Enable, matlab.lang.OnOffSwitchState.off);
    ui.OperationDropDown.Value = 'Otsu Thresholding';
    ui.OperationDropDown.ValueChangedFcn([],[]); ui.ApplyButton.ButtonPushedFcn([],[]);
    ui.Panel.onSend([],[]);
    verifyEqual(testCase, testCase.TestData.App.TabGroup.SelectedTab, testCase.TestData.App.DigitrecognitionTab);
    verifySize(testCase, state.Recognition.Panel.ResultImage, [28 28]);
end
function testRecognitionAndTinyComparison(testCase)
    state = testCase.TestData.State; paths = getProjectPaths();
    samples = load(fullfile(paths.assets, 'sampleDigits.mat'));
    state.Workspace.loadImage(samples.images(:,:,8), 'Sample digit 7');
    state.Recognition.RecognizeButton.ButtonPushedFcn([],[]);
    verifyTrue(testCase, contains(state.Recognition.ResultLabel.Text, 'KNN:'));
    verifyTrue(testCase, contains(state.Recognition.ResultLabel.Text, 'ANN:'));
    state.Workspace.loadImage(uint8(ones(5)*100), 'Small image');
    ui = state.Transformation;
    ui.OperationDropDown.Value = 'Interpolation Comparison';
    ui.OperationDropDown.ValueChangedFcn([],[]); ui.ApplyButton.ButtonPushedFcn([],[]);
    verifyFalse(testCase, startsWith(ui.StatusLabel.Text, 'Error:'));
    verifyNotEmpty(testCase, ui.GetResult());
end
