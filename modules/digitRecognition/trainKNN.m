function knnModel = trainKNN(XTrain, YTrain, numNeighbors, numSamples)
% TRAINKNN Train on the supplied rows (a runner performs seeded sampling).
    if nargin < 3, numNeighbors = 3; end
    if nargin < 4, numSamples = size(XTrain,1); end
    validateattributes(XTrain, {'numeric'}, {'2d','nonempty','ncols',784,'real','finite'});
    validateattributes(numNeighbors, {'numeric'}, {'scalar','positive','integer'});
    validateattributes(numSamples, {'numeric'}, {'scalar','positive','integer'});
    numSamples = min(numSamples, size(XTrain, 1));
    if numNeighbors > numSamples || numel(YTrain) ~= size(XTrain,1)
        error('trainKNN:Samples', 'Labels must match feature rows, and K must not exceed the sample count.');
    end
    knnModel = fitcknn(single(XTrain(1:numSamples,:)), YTrain(1:numSamples), ...
        'NumNeighbors', numNeighbors, 'Distance', 'euclidean', 'Standardize', false);
end
