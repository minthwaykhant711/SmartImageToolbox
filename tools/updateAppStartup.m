function updateAppStartup(filename)
% UPDATEAPPSTARTUP Preserve App Designer data while replacing the startup body.
    reader = appdesigner.internal.serialization.FileReader(filename);
    source = reader.readMATLABCodeText();
    code = reader.readAppCodeData();
    metadata = reader.readAppMetadata();
    body = {'appFolder = fileparts(which(class(app)));', ...
        'projectRoot = fileparts(appFolder);', ...
        'addpath(genpath(fullfile(projectRoot, ''modules'')));', ...
        'initializeToolboxApp(app);'};
    code.StartupCallback.Code = body;
    replacement = sprintf('function startupFcn(app)\n            %s\n        end', strjoin(body, sprintf('\n            ')));
    source = regexprep(source, '(?s)function startupFcn\(app\).*?\n\s*end', replacement, 'once');
    writer = appdesigner.internal.serialization.FileWriter(filename);
    writer.writeAppCodeData(source, struct('code', code), metadata);
end
