function install_tabpfn()
% INSTALL_TABPFN Install the tabpfn-client Python package and dependencies.
%   install_tabpfn() installs numpy, pandas, scikit-learn, and tabpfn-client
%   into the Python environment configured for MATLAB.
%
%   Prerequisites: Python must be installed and configured via pyenv.
%
%   Example:
%     install_tabpfn()

    pe = pyenv;
    python_exe = pe.Executable;

    if python_exe == ""
        error('TabPFN:NoPython', ...
            'No Python interpreter configured. Use pyenv to set one.');
    end

    fprintf('Installing TabPFN dependencies using: %s\n', char(python_exe));

    % Install core dependencies
    cmd1 = sprintf('"%s" -m pip install numpy pandas scikit-learn', char(python_exe));
    [status1, result1] = system(cmd1);
    if status1 ~= 0
        error('TabPFN:InstallFailed', 'Failed to install dependencies:\n%s', result1);
    end

    % Install tabpfn-client from GitHub
    cmd2 = sprintf('"%s" -m pip install "git+https://github.com/PriorLabs/tabpfn-client.git"', char(python_exe));
    [status2, result2] = system(cmd2);
    if status2 ~= 0
        error('TabPFN:InstallFailed', 'Failed to install tabpfn-client:\n%s', result2);
    end

    fprintf('TabPFN installation complete.\n');
end
