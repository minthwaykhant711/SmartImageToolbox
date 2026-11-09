function tests = testUIOperations
% TESTUIOPERATIONS Every enhancement and segmentation operation runs through its GUI callback.
    tests = functiontests(localfunctions);
end
function setupOnce(testCase)
    old = getenv('SMART_IMAGE_TOOLBOX_VISIBLE');
    setenv('SMART_IMAGE_TOOLBOX_VISIBLE', 'off');
    app = runToolbox();
    testCase.TestData.State = app.UIFigure.UserData;
    testCase.TestData.Image = imread('peppers.png');
    testCase.addTeardown(@() delete(app));
    testCase.addTeardown(@() setenv('SMART_IMAGE_TOOLBOX_VISIBLE', old));
end
function testEnhancementOperations(testCase)
    state = testCase.TestData.State;
    state.Workspace.loadImage(testCase.TestData.Image, 'Operation smoke test');
    ui = state.Enhancement;
    for item = ui.OperationDropDown.Items
        if strcmp(item{1}, 'Histogram Matching'), continue; end   % needs a reference image dialog
        ui.OperationDropDown.Value = item{1}; ui.OperationDropDown.ValueChangedFcn([], []);
        ui.Panel.ResultImage = [];
        ui.ApplyButton.ButtonPushedFcn([], []);
        verifyNotEmpty(testCase, ui.Panel.ResultImage, ui.Panel.StatusLabel.Text);
        verifyEqual(testCase, ui.Panel.ResultName, item{1});
    end
    matching = applyEnhancementOperation(testCase.TestData.Image, 'Histogram Matching', [], imread('cameraman.tif'));
    verifyNotEmpty(testCase, matching);
    ui.CompareButton.ButtonPushedFcn([], []);
end
function testSegmentationOperations(testCase)
    state = testCase.TestData.State;
    state.Workspace.loadImage(testCase.TestData.Image, 'Operation smoke test');
    ui = state.Segmentation;
    for item = ui.OperationDropDown.Items
        ui.OperationDropDown.Value = item{1}; ui.OperationDropDown.ValueChangedFcn([], []);
        ui.Panel.ResultImage = [];
        ui.ApplyButton.ButtonPushedFcn([], []);
        verifyNotEmpty(testCase, ui.Panel.ResultImage, ui.Panel.StatusLabel.Text);
        verifyEqual(testCase, ui.Panel.ResultName, item{1});
    end
    ui.CompareSegmentsButton.ButtonPushedFcn([], []);
    verifyFalse(testCase, startsWith(ui.Panel.StatusLabel.Text, 'Error'), ui.Panel.StatusLabel.Text);
end
