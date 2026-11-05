
function knnModel = trainKNN(XTrain, YTrain, numNeighbors, numSamples)
% TRAINKNN Train a KNN classifier for handwritten digits.
%
% XTrain       - N x 784 feature matrix
% YTrain       - N x 1 categorical labels
% numNeighbors - Number of nearest neighbors
% numSamples   - Number of training samples to use

    % Limit training samples
    numSamples = min(numSamples, size(XTrain, 1));

    X = XTrain(1:numSamples, :);
    Y = YTrain(1:numSamples);

    % Train KNN classifier
    knnModel = fitcknn(X, Y, ...
        'NumNeighbors', numNeighbors, ...
        'Distance', 'euclidean', ...
        'Standardize', false);

    fprintf('KNN trained using %d samples (K = %d).\n', ...
        numSamples, numNeighbors);
end
