function tests = testDigitPipeline
    tests = functiontests(localfunctions);
end
function testInvertedDigitAndNoise(testCase)
    image = zeros(80, 80, 'uint8');
    image(20:65, 38:43) = 255;
    [features, normalized] = preprocessDigitImage(image);
    inverse = preprocessDigitImage(255-image);
    verifyEqual(testCase, features, inverse, 'AbsTol', single(1e-6));
    noisy = image; noisy(2, 2) = 255;
    verifyEqual(testCase, preprocessDigitImage(noisy), features, 'AbsTol', single(1e-6));
    verifySize(testCase, normalized, [28 28]);
    verifySize(testCase, features, [1 784]);
    verifyGreaterThanOrEqual(testCase, min(features), single(0));
    verifyLessThanOrEqual(testCase, max(features), single(1));
end
function testBlankAndMultipleObjects(testCase)
    for value = [0 0.5 1]
        verifyError(testCase, @() preprocessDigitImage(ones(40)*value), 'preprocessDigitImage:NoDigit');
    end
    image = false(60, 160); image(15:45, 15:25) = true; image(15:45, 130:140) = true;
    verifyError(testCase, @() preprocessDigitImage(image), 'preprocessDigitImage:MultipleDigits');
end
function testCenteringAndStrokeOption(testCase)
    image = false(60); image(5:45, 8:11) = true; image(40:45, 8:25) = true;
    [~, normalized] = preprocessDigitImage(image);
    total = sum(normalized(:));
    cx = sum(sum(normalized,1).*(1:28))/total;
    cy = sum(sum(normalized,2).*(1:28)')/total;
    verifyLessThanOrEqual(testCase, abs(cx-14.5), 0.6);
    verifyLessThanOrEqual(testCase, abs(cy-14.5), 0.6);
    [~, thickened] = preprocessDigitImage(image, StrokeRadius=1);
    verifyGreaterThan(testCase, nnz(thickened > 0.5), nnz(normalized > 0.5));
end
function testSavedModelsUseSameFeatures(testCase)
    paths = getProjectPaths(); samples = load(fullfile(paths.assets, 'sampleDigits.mat'));
    features = preprocessMNIST(samples.images);
    for name = {'KNN','ANN'}
        result = predictDigitFeatures(features, loadDigitModel(paths.root, name{1}));
        verifySize(testCase, result.PredictedDigit, [10 1]);
        verifySize(testCase, result.Scores, [10 10]);
        verifyTrue(testCase, all(ismember(result.PredictedDigit, string(0:9))));
        verifyGreaterThanOrEqual(testCase, mean(result.PredictedDigit == string(samples.labels(:))), 0.7);
    end
end
function testAlreadyCenteredInputPreservesTrainingLayout(testCase)
    image = zeros(28,28,'uint8'); image(5:24,13:16) = 255;
    [features, normalized, info] = preprocessDigitImage(image);
    verifyTrue(testCase, info.PreservedCanonical);
    verifyEqual(testCase, normalized, im2single(image));
    verifyEqual(testCase, features, preprocessMNIST(image));
end
