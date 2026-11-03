
% setupProject.m
% Initialize Smart Image Processing Toolbox

root = fileparts(mfilename('fullpath'));

% Add project source folders to MATLAB path
addpath(fullfile(root, 'app'));
addpath(genpath(fullfile(root, 'modules')));
addpath(genpath(fullfile(root, 'recognition')));

% Keep data and model directories as absolute paths
projectPaths.root = root;
projectPaths.models = fullfile(root, 'models');
projectPaths.data = fullfile(root, 'data');
projectPaths.assets = fullfile(root, 'assets');

disp('Smart Image Processing Toolbox initialized.');
disp(['Project root: ', root]);
