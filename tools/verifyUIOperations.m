function verifyUIOperations()
    previous=getenv('SMART_IMAGE_TOOLBOX_VISIBLE');
    setenv('SMART_IMAGE_TOOLBOX_VISIBLE','off');
    restore=onCleanup(@()setenv('SMART_IMAGE_TOOLBOX_VISIBLE',previous)); %#ok<NASGU>
    app=runToolbox(); cleanup=onCleanup(@()delete(app)); %#ok<NASGU>
    state=app.UIFigure.UserData;
    image=imread('peppers.png');
    state.Workspace.loadImage(image,'Operation smoke test');
    ui=state.Enhancement;
    for item=ui.OperationDropDown.Items
        if strcmp(item{1},'Histogram Matching'), continue; end
        ui.OperationDropDown.Value=item{1}; ui.OperationDropDown.ValueChangedFcn([],[]);
        ui.Panel.ResultImage = [];
        ui.ApplyButton.ButtonPushedFcn([],[]);
        assert(~isempty(ui.Panel.ResultImage) && strcmp(ui.Panel.ResultName,item{1}),ui.Panel.StatusLabel.Text);
    end
    matching=applyEnhancementOperation(image,'Histogram Matching',[],imread('cameraman.tif'));
    assert(~isempty(matching));
    ui.CompareButton.ButtonPushedFcn([],[]);
    ui=state.Segmentation;
    for item=ui.OperationDropDown.Items
        ui.OperationDropDown.Value=item{1}; ui.OperationDropDown.ValueChangedFcn([],[]);
        ui.Panel.ResultImage = [];
        ui.ApplyButton.ButtonPushedFcn([],[]);
        assert(~isempty(ui.Panel.ResultImage) && strcmp(ui.Panel.ResultName,item{1}),ui.Panel.StatusLabel.Text);
    end
    ui.CompareSegmentsButton.ButtonPushedFcn([],[]);
    assert(~startsWith(ui.Panel.StatusLabel.Text,'Error'));
    fprintf('All enhancement and segmentation operation callbacks completed.\n');
end
