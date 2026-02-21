%% TabPFN Classification Example
% This script demonstrates how to use TabPFN for classification in MATLAB.

%% Step 1: Set your access token
% Get your token at: https://ux.priorlabs.ai/account
set_tabpfn_access_token('YOUR_ACCESS_TOKEN');

%% Step 2: Generate example data
rng(42);
n_train = 80;
n_test = 20;
n_features = 5;

X_train = randn(n_train, n_features);
y_train = randi([0, 2], 1, n_train);  % 3 classes: 0, 1, 2

X_test = randn(n_test, n_features);
y_test = randi([0, 2], 1, n_test);

%% Step 3: Create classifier, fit, and predict
clf = TabPFNClassifier();
clf.fit(X_train, y_train);

predictions = clf.predict(X_test);
probabilities = clf.predict_proba(X_test);

%% Step 4: Display results
fprintf('Predictions:\n');
disp(predictions);

fprintf('Probabilities:\n');
disp(probabilities);

accuracy = sum(predictions == y_test) / length(y_test);
fprintf('Accuracy: %.2f%%\n', accuracy * 100);
