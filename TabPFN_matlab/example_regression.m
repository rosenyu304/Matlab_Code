%% TabPFN Regression Example
% This script demonstrates how to use TabPFN for regression in MATLAB.

%% Step 1: Set your access token
% Get your token at: https://ux.priorlabs.ai/account
set_tabpfn_access_token('YOUR_ACCESS_TOKEN');

%% Step 2: Generate example data
rng(42);
n_train = 80;
n_test = 20;
n_features = 3;

X_train = randn(n_train, n_features);
y_train = sin(X_train(:,1)) + 0.5 * X_train(:,2) + 0.1 * randn(n_train, 1);

X_test = randn(n_test, n_features);
y_test = sin(X_test(:,1)) + 0.5 * X_test(:,2) + 0.1 * randn(n_test, 1);

%% Step 3: Create regressor, fit, and predict
reg = TabPFNRegressor();
reg.fit(X_train, y_train');  % Pass y as row vector

predictions = reg.predict(X_test);

%% Step 4: Display results
fprintf('Predictions:\n');
disp(predictions);

mse = mean((predictions(:) - y_test(:)).^2);
fprintf('MSE: %.4f\n', mse);
