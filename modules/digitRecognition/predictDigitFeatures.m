function result = predictDigitFeatures(features, bundle)
% PREDICTDIGITFEATURES Predict one or more rows with saved class ordering.
    validateattributes(features, {'numeric'}, {'2d', 'nonempty', 'real', 'finite', 'ncols', 784});
    timer = tic;
    if strcmpi(bundle.Type, 'KNN')
        [predictions, scores] = predict(bundle.Model, single(features));
        predictions = string(predictions);
    else
        scores = minibatchpredict(bundle.Model, single(features));
        if isa(scores, 'dlarray'), scores = extractdata(scores); end
        scores = gather(scores);
        if size(scores, 2) ~= numel(bundle.ClassNames)
            error('predictDigitFeatures:ClassOrder', 'The model score columns do not match its saved class names.');
        end
        [~, index] = max(scores, [], 2);
        predictions = reshape(bundle.ClassNames(index), [], 1);
    end
    result = struct('Model', bundle.Type, 'PredictedDigit', predictions(:), ...
        'Scores', scores, 'ClassNames', bundle.ClassNames, 'Seconds', toc(timer));
end
