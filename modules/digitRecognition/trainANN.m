
function annModel = trainANN(XTrain, YTrain)
% TRAINANN Train a neural network for MNIST digit recognition.
%
% XTrain - N x 784 normalized image features
% YTrain - N x 1 categorical digit labels

    layers = [
        featureInputLayer(784, Normalization="none")
        fullyConnectedLayer(128)
        reluLayer
        fullyConnectedLayer(64)
        reluLayer
        fullyConnectedLayer(10)
        softmaxLayer
    ];

    options = trainingOptions("adam", ...
        MaxEpochs=10, ...
        MiniBatchSize=128, ...
        InitialLearnRate=0.001, ...
        Shuffle="every-epoch", ...
        Verbose=true, ...
        Plots="training-progress");

    annModel = trainnet(XTrain, YTrain, layers, ...
        "crossentropy", options);

    disp('ANN training completed successfully!');
end
