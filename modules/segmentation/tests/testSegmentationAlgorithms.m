function tests = testSegmentationAlgorithms
% TESTSEGMENTATIONALGORITHMS Automated tests for segmentation functions.

    tests = functiontests(localfunctions);

end

function testGrayscaleAlgorithms(testCase)
    image = sampleGrayImage();
    functions = {@sobelEdge, @prewittEdge, @cannyEdge, @globalThreshold, ...
        @otsuThreshold, @adaptiveThreshold};

    for index = 1:numel(functions)
        output = functions{index}(image);
        verifySize(testCase, output, size(image));
        verifyClass(testCase, output, 'logical');
    end

    labels = watershedSegmentation(image);
    verifySize(testCase, labels, size(image));
    verifyTrue(testCase, isnumeric(labels));
end

function testRgbAlgorithms(testCase)
    image = repmat(sampleGrayImage(), 1, 1, 3);
    functions = {@sobelEdge, @prewittEdge, @cannyEdge, @globalThreshold, ...
        @otsuThreshold, @adaptiveThreshold};

    for index = 1:numel(functions)
        output = functions{index}(image);
        verifySize(testCase, output, size(image, [1 2]));
        verifyClass(testCase, output, 'logical');
    end

    labels = watershedSegmentation(image);
    verifySize(testCase, labels, size(image, [1 2]));
end

function testGlobalThresholdDefault(testCase)
    image = uint8([127 128]);
    verifyEqual(testCase, globalThreshold(image), logical([0 1]));
end

function testInvalidInputHandling(testCase)
    functions = {@prewittEdge, @cannyEdge, @globalThreshold, @otsuThreshold, ...
        @adaptiveThreshold, @watershedSegmentation};

    for index = 1:numel(functions)
        verifyError(testCase, @() functions{index}([]), ...
            [func2str(functions{index}) ':InvalidInput']);
    end
end

function testGuiOperationList(testCase)
    figure = uifigure('Visible', 'off');
    cleanup = onCleanup(@() delete(figure)); %#ok<NASGU>
    tabGroup = uitabgroup(figure);
    tab = uitab(tabGroup);
    ui = createSegmentationUI(tab);

    expectedItems = {'Sobel Edge Detection'; 'Prewitt Edge Detection'; ...
        'Canny Edge Detection'; 'Global Thresholding'; 'Otsu Thresholding'; ...
        'Adaptive Thresholding'; 'Watershed Segmentation'; ...
        'Dilation'; 'Erosion'; 'Opening'; 'Closing'; 'Shape-Based Segmentation'; ...
        'HSV Color Segmentation'; 'RGB Color Segmentation'};
    verifyEqual(testCase, ui.OperationDropDown.Items(:), expectedItems);
    verifyNotEmpty(testCase, ui.OriginalAxes);
    verifyNotEmpty(testCase, ui.ProcessedAxes);
end

function image = sampleGrayImage()
    image = zeros(100, 100, 'uint8');
    image(20:80, 20:80) = 120;
    image(40:60, 40:60) = 255;
end
