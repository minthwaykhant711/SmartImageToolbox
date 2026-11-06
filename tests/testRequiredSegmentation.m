function tests = testRequiredSegmentation
    tests = functiontests(localfunctions);
end
function testMorphologyChangesForeground(testCase)
    mask = false(50); mask(15:35, 15:35) = true;
    verifyGreaterThan(testCase, nnz(applyMorphology(mask, 'Dilation', 2)), nnz(mask));
    verifyLessThan(testCase, nnz(applyMorphology(mask, 'Erosion', 2)), nnz(mask));
    noisy = mask; noisy(2, 2) = true;
    opened = applyMorphology(noisy, 'Opening', 1);
    verifyFalse(testCase, opened(2, 2));
    gap = mask; gap(24:25, 24:25) = false;
    closed = applyMorphology(gap, 'Closing', 2);
    verifyTrue(testCase, all(closed(24:25, 24:25), 'all'));
end
function testRgbAndWrappedHue(testCase)
    image = zeros(10, 20, 3);
    image(:,1:10,1) = 1; image(:,11:20,2) = 1;
    mask = segmentByColor(image, 'RGB', [0.8 0 0], [1 0.2 0.2]);
    verifyTrue(testCase, all(mask(:,1:10),'all'));
    verifyFalse(testCase, any(mask(:,11:20),'all'));
    hsv = zeros(5, 10, 3); hsv(:,:,2:3) = 1;
    hsv(:,1:5,1) = 0.98; hsv(:,6:10,1) = 0.02;
    mask = segmentByColor(hsv2rgb(hsv), 'HSV', [0.9 0.5 0.5], [0.1 1 1]);
    verifyTrue(testCase, all(mask, 'all'));
end
function testShapeFiltering(testCase)
    mask = false(80); mask(10:25,10:25) = true; mask(45:48,20:65) = true; mask(75,75) = true;
    output = shapeBasedSegmentation(mask, 10, Inf, 'Elongated regions');
    verifyFalse(testCase, output(15,15));
    verifyTrue(testCase, output(46,40));
    verifyFalse(testCase, output(75,75));
end
function testDarkDigitForeground(testCase)
    image = ones(40,40,'uint8')*255; image(8:32,18:22) = 0;
    mask = applySegmentationOperation(image, 'Otsu Thresholding');
    verifyTrue(testCase, mask(20,20)); verifyFalse(testCase, mask(1,1));
end
function testMoreThan256RegionColors(testCase)
    labels = reshape(0:399,20,20);
    image = colorizeRegions(labels);
    verifySize(testCase, image, [20 20 3]);
    verifyEqual(testCase, reshape(image(1,1,:),1,3), uint8([0 0 0]));
    verifyNotEqual(testCase, image(2,1,:), image(3,1,:));
end
