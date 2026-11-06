function annModel = trainANN(XTrain, YTrain, options)
% TRAINANN Train a 784-128-64-10 multilayer perceptron with optional validation.
    arguments
        XTrain
        YTrain
        options.ValidationData cell = {}
        options.MaxEpochs (1,1) double {mustBeInteger,mustBePositive} = 10
        options.MiniBatchSize (1,1) double {mustBeInteger,mustBePositive} = 128
        options.Plots (1,:) char = 'none'
    end
    validateattributes(XTrain, {'numeric'}, {'2d','nonempty','ncols',784,'real','finite'});
    if size(XTrain,1) ~= numel(YTrain), error('trainANN:Labels', 'Feature and label counts must match.'); end
    YTrain = categorical(string(YTrain), string(0:9));
    layers = [featureInputLayer(784, Normalization="none")
        fullyConnectedLayer(128)
        reluLayer
        fullyConnectedLayer(64)
        reluLayer
        fullyConnectedLayer(10)
        softmaxLayer];
    training = trainingOptions("adam", MaxEpochs=options.MaxEpochs, ...
        MiniBatchSize=options.MiniBatchSize, InitialLearnRate=0.001, ...
        Shuffle="every-epoch", Verbose=false, Plots=options.Plots, ...
        ExecutionEnvironment="cpu");
    if ~isempty(options.ValidationData)
        validation = options.ValidationData;
        validation{2} = categorical(string(validation{2}), string(0:9));
        training.ValidationData = validation;
        training.ValidationFrequency = max(1, ceil(size(XTrain,1)/options.MiniBatchSize));
    end
    annModel = trainnet(single(XTrain), YTrain, layers, "crossentropy", training);
end
