classdef TabPFNRegressor < handle
% TABPFNREGRESSOR Wrapper for the TabPFN cloud regression service.
%   reg = TabPFNRegressor() creates a TabPFN regressor that communicates
%   with the Prior Labs cloud API via the Python tabpfn-client package.
%
%   Methods:
%     fit(X, y)    - Upload training data to the TabPFN server.
%     predict(X)   - Return predicted values.
%
%   Example:
%     reg = TabPFNRegressor();
%     reg.fit(X_train, y_train);
%     predictions = reg.predict(X_test);

    properties (Access = private)
        estimator   % Python TabPFNRegressor object
    end

    methods
        function obj = TabPFNRegressor()
            % Create a new TabPFNRegressor by instantiating the Python class.
            tabpfn = py.importlib.import_module('tabpfn_client');
            obj.estimator = tabpfn.TabPFNRegressor();
        end

        function fit(obj, X, y)
            % FIT Upload training data to the TabPFN server.
            %   reg.fit(X, y) where X is an N-by-P numeric matrix
            %   and y is an N-element numeric vector.

            validateattributes(X, {'numeric'}, {'2d', 'nonempty'}, 'fit', 'X');
            validateattributes(y, {'numeric'}, {'vector', 'nonempty'}, 'fit', 'y');

            np = py.importlib.import_module('numpy');
            X_py = np.array(X);
            y_py = np.array(y(:)');

            try
                obj.estimator.fit(X_py, y_py);
            catch ME
                error('TabPFN:FitError', 'Error during fitting: %s', ME.message);
            end
        end

        function predictions = predict(obj, X)
            % PREDICT Return predicted regression values.
            %   preds = reg.predict(X) where X is an M-by-P numeric matrix.
            %   Returns a 1-by-M double array of predicted values.

            validateattributes(X, {'numeric'}, {'2d', 'nonempty'}, 'predict', 'X');

            np = py.importlib.import_module('numpy');
            X_py = np.array(X);

            try
                preds_py = obj.estimator.predict(X_py);
                predictions = double(preds_py);
            catch ME
                error('TabPFN:PredictError', 'Error during prediction: %s', ME.message);
            end
        end
    end
end
