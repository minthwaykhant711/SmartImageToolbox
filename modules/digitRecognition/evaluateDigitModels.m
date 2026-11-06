function report = evaluateDigitModels(datasetPath, options)
% EVALUATEDIGITMODELS Compare saved KNN/ANN models on the same held-out digits.
% Both the original MNIST features and the upload preprocessing path are tested.
    arguments
        datasetPath (1,:) char = ''
        options.ModelRoot (1,:) char = ''
        options.OutputDirectory (1,:) char = ''
        options.MaxTestSamples (1,1) double {mustBePositive} = 1000
        options.Seed (1,1) double {mustBeInteger,mustBeNonnegative} = 42
    end
    paths = getProjectPaths();
    if isempty(datasetPath), datasetPath = paths.data; end
    if isempty(datasetPath), error('evaluateDigitModels:Dataset', 'Pass the MNIST directory or set SMART_IMAGE_DATASET.'); end
    if isempty(options.ModelRoot), options.ModelRoot = paths.root; end
    if isempty(options.OutputDirectory), options.OutputDirectory = paths.results; end
    [images, labels] = loadMNIST(datasetPath, 'test');
    count = min(numel(labels), floor(options.MaxTestSamples));
    if count < 1, error('evaluateDigitModels:Count', 'Choose at least one test image.'); end
    stream = RandStream('mt19937ar', 'Seed', options.Seed);
    indices = randperm(stream, numel(labels), count);
    selected = images(:, :, indices);
    truth = string(labels(indices));
    original = preprocessMNIST(selected);
    processed = zeros(count, 784, 'single');
    rejected = false(count, 1);
    for index = 1:count
        try, processed(index, :) = preprocessDigitImage(selected(:, :, index));
        catch exception
            if startsWith(exception.identifier, 'preprocessDigitImage:')
                rejected(index) = true;
            else, rethrow(exception); end
        end
    end
    if ~isfolder(options.OutputDirectory), mkdir(options.OutputDirectory); end
    metrics = table();
    modes = {'Original MNIST', 'Upload preprocessing'};
    features = {original, processed};
    report = struct('Seed', options.Seed, 'TestIndices', indices, ...
        'ClassNames', string(0:9), 'PreprocessingVersion', 'single-digit-v3');
    for name = {'KNN', 'ANN'}
        bundle = loadDigitModel(options.ModelRoot, name{1});
        predictDigitFeatures(original(1, :), bundle); % Warm up before timing.
        for mode = 1:2
            result = predictDigitFeatures(features{mode}, bundle);
            predictions = result.PredictedDigit;
            invalid = false(count, 1);
            if mode == 2, invalid = rejected; predictions(invalid) = "<rejected>"; end
            accuracy = mean(predictions(:) == truth(:));
            row = table(string(name{1}), string(modes{mode}), count, accuracy, ...
                result.Seconds, result.Seconds/count*1000, nnz(invalid), ...
                'VariableNames', {'Model','InputMode','SampleCount','Accuracy','Seconds','MillisecondsPerImage','RejectedCount'});
            metrics = [metrics; row]; %#ok<AGROW>
            confusion = zeros(10, 11);
            for sample = 1:count
                predictedIndex = find(string(0:9) == predictions(sample), 1);
                if isempty(predictedIndex), predictedIndex = 11; end
                confusion(double(labels(indices(sample)))+1, predictedIndex) = ...
                    confusion(double(labels(indices(sample)))+1, predictedIndex) + 1;
            end
            key = sprintf('%s_mode%d', lower(name{1}), mode);
            report.(key) = struct('Predictions', predictions, 'Confusion', confusion);
            columnNames = ["Pred" + string(0:9), "Rejected"];
            confusionTable = array2table(confusion, 'VariableNames', cellstr(columnNames));
            confusionTable.TrueDigit = (0:9)';
            confusionTable = movevars(confusionTable, 'TrueDigit', 'Before', 1);
            writetable(confusionTable, fullfile(options.OutputDirectory, ['confusion-' key '.csv']));
        end
    end
    report.Metrics = metrics;
    writetable(metrics, fullfile(options.OutputDirectory, 'model-comparison.csv'));
    save(fullfile(options.OutputDirectory, 'evaluation.mat'), 'report');
    disp(metrics);
end
