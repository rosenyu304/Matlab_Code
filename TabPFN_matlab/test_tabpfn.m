%% TabPFN MATLAB Wrapper Test Script
fprintf('=== TabPFN MATLAB Wrapper Tests ===\n\n');

%% Test 0: Configure Python environment
fprintf('Test 0: Configure Python env...\n');
try
    pe = pyenv;
    if pe.Status ~= "Loaded"
        pyenv('Version', '~/matlab-tabpfn-venv/bin/python');
        pe = pyenv;
    end
    fprintf('  Python version: %s\n', char(pe.Version));
    fprintf('  Python executable: %s\n', char(pe.Executable));
    fprintf('  PASS\n\n');
catch ME
    fprintf('  FAIL: %s\n\n', ME.message);
end

%% Test 1: Python environment check
fprintf('Test 1: Python environment...\n');
try
    pe = pyenv;
    fprintf('  Python version: %s\n', char(pe.Version));
    fprintf('  Python executable: %s\n', char(pe.Executable));
    fprintf('  PASS\n\n');
catch ME
    fprintf('  FAIL: %s\n\n', ME.message);
end

%% Test 2: setup_tabpfn (verify imports)
fprintf('Test 2: setup_tabpfn...\n');
try
    setup_tabpfn();
    fprintf('  PASS\n\n');
catch ME
    fprintf('  FAIL: %s\n\n', ME.message);
end

%% Test 3: TabPFNClassifier constructor
fprintf('Test 3: TabPFNClassifier constructor...\n');
try
    clf = TabPFNClassifier();
    fprintf('  Created TabPFNClassifier: %s\n', class(clf));
    fprintf('  PASS\n\n');
catch ME
    fprintf('  FAIL: %s\n\n', ME.message);
end

%% Test 4: TabPFNRegressor constructor
fprintf('Test 4: TabPFNRegressor constructor...\n');
try
    reg = TabPFNRegressor();
    fprintf('  Created TabPFNRegressor: %s\n', class(reg));
    fprintf('  PASS\n\n');
catch ME
    fprintf('  FAIL: %s\n\n', ME.message);
end

%% Test 5: Classifier fit + predict (requires valid token)
fprintf('Test 5: Classifier fit + predict...\n');
try
    set_tabpfn_access_token('YOUR_ACCESS_TOKEN');

    rng(42);
    X_train = randn(50, 3);
    y_train = randi([0, 1], 1, 50);
    X_test = randn(10, 3);

    clf2 = TabPFNClassifier();
    clf2.fit(X_train, y_train);
    preds = clf2.predict(X_test);
    proba = clf2.predict_proba(X_test);

    fprintf('  Predictions shape: %s\n', mat2str(size(preds)));
    fprintf('  Probabilities shape: %s\n', mat2str(size(proba)));
    fprintf('  Predictions: %s\n', mat2str(preds));
    fprintf('  PASS\n\n');
catch ME
    fprintf('  FAIL: %s\n\n', ME.message);
end

%% Test 6: Regressor fit + predict (requires valid token)
fprintf('Test 6: Regressor fit + predict...\n');
try
    rng(42);
    X_train = randn(50, 3);
    y_train = sin(X_train(:,1)) + 0.1 * randn(50, 1);
    X_test = randn(10, 3);

    reg2 = TabPFNRegressor();
    reg2.fit(X_train, y_train');
    preds = reg2.predict(X_test);

    fprintf('  Predictions shape: %s\n', mat2str(size(preds)));
    fprintf('  Predictions: %s\n', mat2str(preds, 4));
    fprintf('  PASS\n\n');
catch ME
    fprintf('  FAIL: %s\n\n', ME.message);
end

fprintf('=== Tests Complete ===\n');
