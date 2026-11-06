function report = trainAndEvaluate(datasetPath, options)
% TRAINANDEVALUATE Seeded split, K selection, ANN validation, and test reporting.
% Run explicitly: training is never performed automatically by the GUI.
    arguments
        datasetPath (1,:) char = ''
        options.OutputRoot (1,:) char = ''
        options.TrainingSamples (1,1) double {mustBeInteger,mustBePositive} = 10000
        options.KNNSamples (1,1) double {mustBeInteger,mustBePositive} = 5000
        options.MaxEpochs (1,1) double {mustBeInteger,mustBePositive} = 10
        options.MaxTestSamples (1,1) double {mustBePositive} = 1000
        options.Seed (1,1) double {mustBeInteger,mustBeNonnegative} = 42
    end
    paths = getProjectPaths();
    if isempty(datasetPath), datasetPath = paths.data; end
    if isempty(datasetPath), error('trainAndEvaluate:Dataset', 'Pass the uncompressed MNIST directory or set SMART_IMAGE_DATASET.'); end
    if isempty(options.OutputRoot), options.OutputRoot = paths.root; end
    previous = rng;
    cleanup = onCleanup(@() rng(previous)); %#ok<NASGU>
    rng(options.Seed, 'twister');
    [images, labels] = loadMNIST(datasetPath, 'train');
    indices = randperm(numel(labels), min(options.TrainingSamples, numel(labels)));
    X = preprocessMNIST(images(:, :, indices));
    Y = categorical(string(labels(indices)), string(0:9));
    partition = cvpartition(Y, 'Holdout', 0.15);
    trainX = X(training(partition), :); trainY = Y(training(partition));
    validationX = X(test(partition), :); validationY = Y(test(partition));
    knnCount = min(options.KNNSamples, size(trainX, 1));
    bestAccuracy = -Inf; bestK = 1;
    for k = [1 3 5]
        if k > knnCount, continue; end
        candidate = trainKNN(trainX, trainY, k, knnCount);
        accuracy = mean(predict(candidate, validationX) == validationY);
        if accuracy > bestAccuracy
            bestAccuracy = accuracy; bestK = k; knnModel = candidate; %#ok<NASGU>
        end
    end
    annModel = trainANN(trainX, trainY, MaxEpochs=options.MaxEpochs, ...
        ValidationData={validationX, validationY}); %#ok<NASGU>
    classNames = string(categories(trainY)); %#ok<NASGU>
    metadata = struct('Seed', options.Seed, 'FeatureFormat', 'column-major-single-0-to-1', ...
        'ANNTrainingSamples', size(trainX, 1), 'KNNTrainingSamples', knnCount, ...
        'ValidationSamples', size(validationX, 1), 'SelectedK', bestK, ...
        'KNNValidationAccuracy', bestAccuracy, 'MaxEpochs', options.MaxEpochs); %#ok<NASGU>
    models = fullfile(options.OutputRoot, 'models');
    if ~isfolder(models), mkdir(models); end
    backup = fullfile(models, ['backup-' char(datetime('now', 'Format', 'yyyyMMdd-HHmmssSSS'))]);
    for filename = {'knnModel.mat', 'annModel.mat'}
        existing = fullfile(models, filename{1});
        if isfile(existing)
            if ~isfolder(backup), mkdir(backup); end
            copyfile(existing, fullfile(backup, filename{1}));
        end
    end
    save(fullfile(models, 'knnModel.mat'), 'knnModel', 'classNames', 'metadata');
    save(fullfile(models, 'annModel.mat'), 'annModel', 'classNames', 'metadata');
    report = evaluateDigitModels(datasetPath, ModelRoot=options.OutputRoot, ...
        OutputDirectory=fullfile(options.OutputRoot, 'results'), ...
        MaxTestSamples=options.MaxTestSamples, Seed=options.Seed);
end
