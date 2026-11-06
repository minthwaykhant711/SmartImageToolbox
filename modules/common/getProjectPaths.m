function paths = getProjectPaths()
% GETPROJECTPATHS Portable paths and an optional external MNIST location.
    paths.root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    paths.models = fullfile(paths.root, 'models');
    paths.assets = fullfile(paths.root, 'assets');
    paths.results = fullfile(paths.root, 'results');
    paths.data = '';
    candidates = {getenv('SMART_IMAGE_DATASET'), ...
        fullfile(paths.root, 'datasets', 'mnist'), fullfile(paths.root, 'data', 'mnist')};
    for index = 1:numel(candidates)
        if ~isempty(candidates{index}) && isfile(fullfile(candidates{index}, 'train-images-idx3-ubyte'))
            paths.data = candidates{index}; return;
        end
    end
end
