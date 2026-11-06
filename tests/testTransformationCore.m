function tests = testTransformationCore
    tests = functiontests(localfunctions);
end
function testIdentityAndQuarterTurn(testCase)
    image = uint8(reshape(1:30, 5, 6));
    for name = {'nearest','bilinear','bicubic'}
        verifyEqual(testCase, warpImage(image, eye(3), name{1}), image);
        verifyEqual(testCase, rotateImage(image, 90, name{1}), rot90(image));
    end
end
function testResizingAndOutsideSamples(testCase)
    verifyEqual(testCase, resizeImage(uint8(42), [5 7], 'bilinear'), ones(5,7,'uint8')*42);
    output = interpolateImage(ones(3), [1 Inf NaN -10], [1 2 2 2], 'bilinear');
    verifyEqual(testCase, output, [1 0 0 0]);
    verifyError(testCase, @() resizeImage(ones(3), [0 5]), 'MATLAB:expectedPositive');
end
function testFullCanvasAndRadialIdentity(testCase)
    image = uint8(ones(5)*200);
    output = rotateImage(image, 30, 'nearest');
    verifySize(testCase, output, [7 7]);
    verifyEqual(testCase, correctRadialDistortion(image, 0, 0), image);
end
