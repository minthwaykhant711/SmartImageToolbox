function app = runToolbox()
% RUNTOOLBOX Launch this project copy without depending on the current folder.
    root = fileparts(mfilename('fullpath'));
    addpath(fullfile(root, 'app'));
    addpath(genpath(fullfile(root, 'modules')));
    app = SmartImageToolbox;
    if nargout == 0, clear app; end
end
