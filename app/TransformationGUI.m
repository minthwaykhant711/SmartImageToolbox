function fig = TransformationGUI()
    % Standalone window for Module 3: Geometric Transformations and Interpolation.
    % The same panel is embedded in SmartImageToolbox's Transformation tab.

    root = fileparts(fileparts(mfilename('fullpath')));
    addpath(genpath(fullfile(root, 'modules')));

    fig = uifigure('Name', 'Geometric Transformations and Interpolation', ...
        'Position', [100 100 1150 720]);
    buildTransformationPanel(fig);

    if nargout == 0
        clear fig
    end
end
