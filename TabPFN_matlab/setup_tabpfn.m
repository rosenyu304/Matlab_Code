function setup_tabpfn(python_path)
% SETUP_TABPFN Configure and verify the Python environment for TabPFN.
%   setup_tabpfn() verifies that the current Python environment has
%   the required packages (numpy, tabpfn_client).
%
%   setup_tabpfn(PYTHON_PATH) sets the Python interpreter to use before
%   verifying. Note: Python cannot be changed after it has been loaded
%   in a MATLAB session; restart MATLAB to change interpreters.
%
%   Example:
%     setup_tabpfn()
%     setup_tabpfn('/usr/bin/python3')

    if nargin > 0 && ~isempty(python_path)
        pe = pyenv;
        if pe.Status == "Loaded"
            warning('TabPFN:PythonAlreadyLoaded', ...
                'Python is already loaded. Restart MATLAB to change the interpreter.');
        else
            pyenv('Version', python_path);
        end
    end

    % Verify numpy is available
    try
        py.importlib.import_module('numpy');
        fprintf('numpy: OK\n');
    catch
        error('TabPFN:MissingNumpy', ...
            'numpy not found. Run install_tabpfn() first.');
    end

    % Verify tabpfn_client is available
    try
        py.importlib.import_module('tabpfn_client');
        fprintf('tabpfn_client: OK\n');
    catch
        error('TabPFN:MissingTabPFN', ...
            'tabpfn_client not found. Run install_tabpfn() first.');
    end

    fprintf('TabPFN setup verified.\n');
end
