% SETUPPROJECT Initialize source paths without adding nonexistent folders.
root = fileparts(mfilename('fullpath'));
addpath(root);
addpath(fullfile(root, 'app'));
addpath(genpath(fullfile(root, 'modules')));
projectPaths = getProjectPaths();
fprintf('Smart Image Toolbox initialized: %s\n', root);
if isempty(projectPaths.data)
    disp('MNIST is optional for the app. For training, set SMART_IMAGE_DATASET or pass a dataset folder.');
else
    fprintf('MNIST dataset: %s\n', projectPaths.data);
end
