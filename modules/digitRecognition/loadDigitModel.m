function bundle = loadDigitModel(projectRoot, modelType)
% LOADDIGITMODEL Cache models and invalidate the cache when a file changes.
    persistent cache
    if isempty(cache), cache = struct(); end
    type = lower(char(modelType));
    if ~ismember(type, {'knn', 'ann'}), error('loadDigitModel:Type', 'Choose KNN or ANN.'); end
    filename = fullfile(projectRoot, 'models', [type 'Model.mat']);
    details = dir(filename);
    if isempty(details), error('loadDigitModel:Missing', 'Model not found: %s. Run trainAndEvaluate first.', filename); end
    key = type;
    stamp = [details.datenum details.bytes];
    if isfield(cache, key) && strcmp(cache.(key).Path, filename) && isequal(cache.(key).Stamp, stamp)
        bundle = cache.(key).Bundle; return;
    end
    stored = load(filename);
    variable = [type 'Model'];
    if ~isfield(stored, variable), error('loadDigitModel:Contents', 'The MAT file does not contain %s.', variable); end
    bundle.Model = stored.(variable);
    bundle.ClassNames = string(0:9);
    if isfield(stored, 'classNames'), bundle.ClassNames = string(stored.classNames(:)');
    elseif strcmp(type, 'knn'), bundle.ClassNames = string(bundle.Model.ClassNames(:)'); end
    bundle.Type = upper(type);
    cache.(key) = struct('Path', filename, 'Stamp', stamp, 'Bundle', bundle);
end
