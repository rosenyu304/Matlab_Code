classdef TabPFNClassifier < handle
% TABPFNCLASSIFIER Wrapper for the TabPFN cloud classification service.
%   clf = TabPFNClassifier() creates a TabPFN classifier that communicates
%   with the Prior Labs cloud API via the Python tabpfn-client package.
%
%   Methods:
%     fit(X, y)        - Upload training data to the TabPFN server.
%     predict(X)       - Return predicted class labels.
%     predict_proba(X) - Return predicted class probabilities.
%
%   Example:
%     clf = TabPFNClassifier();
%     clf.fit(X_train, y_train);
%     predictions = clf.predict(X_test);
%     probabilities = clf.predict_proba(X_test);

    properties (Access = private)
        estimator   % Python TabPFNClassifier object
    end

    methods
        function obj = TabPFNClassifier()
            % Create a new TabPFNClassifier by instantiating the Python class.
            tabpfn = py.importlib.import_module('tabpfn_client');
            obj.estimator = tabpfn.TabPFNClassifier();
        end

        function fit(obj, X, y)
            % FIT Upload training data to the TabPFN server.
            %   clf.fit(X, y) where X is an N-by-P numeric matrix
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
            % PREDICT Return predicted class labels.
            %   preds = clf.predict(X) where X is an M-by-P numeric matrix.
            %   Returns a 1-by-M double array of class labels.

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

        function proba = predict_proba(obj, X)
            % PREDICT_PROBA Return predicted class probabilities.
            %   proba = clf.predict_proba(X) returns an M-by-K matrix
            %   where K is the number of classes.

            validateattributes(X, {'numeric'}, {'2d', 'nonempty'}, 'predict_proba', 'X');

            np = py.importlib.import_module('numpy');
            X_py = np.array(X);

            try
                proba_py = obj.estimator.predict_proba(X_py);
                proba = double(proba_py);
            catch ME
                error('TabPFN:PredictProbaError', 'Error during predict_proba: %s', ME.message);
            end
        end
    end
end
