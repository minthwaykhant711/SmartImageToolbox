function results = runProjectTests()
% RUNPROJECTTESTS Run every automated test in tests/.
    root = fileparts(mfilename('fullpath'));
    run(fullfile(root, 'setupProject.m'));
    results = runtests(fullfile(root, 'tests'));
    assert(all([results.Passed]), 'runProjectTests:Failure', 'At least one automated test failed.');
end
