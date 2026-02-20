function [trained_X, MAX_ARR] = GP_EI(func, SEED, varargin)
% GP_EI - Standard Gaussian Process Bayesian Optimization with Expected Improvement
%
% INPUTS:
%   func   - struct with fields: .evaluate (function handle), .dim (int)
%   SEED   - random seed integer
%   Optional Name-Value:
%     'N_iterations' - number of BO iterations (default: 100)
%     'N_INIT'       - number of initial random samples (default: 50)
%     'N_PENDING'    - number of random candidates per iteration (default: 1000)
%     'SAVE_DIR'     - path to save results (default: [])
%     'Trail_N'      - trial index (default: 0)

    %% --- Parse inputs ---
    p = inputParser;
    addParameter(p, 'N_iterations', 100);
    addParameter(p, 'N_INIT',       50);
    addParameter(p, 'N_PENDING',    1000);
    addParameter(p, 'SAVE_DIR',     []);
    addParameter(p, 'Trail_N',      0);
    parse(p, varargin{:});
    opts = p.Results;

    %% --- Seed ---
    rng(SEED);

    DIM    = func.dim;
    N_iter = opts.N_iterations;

    %% --- Initial random samples ---
    trained_X = rand(opts.N_INIT, DIM);
    [~, trained_Y] = func.evaluate(trained_X);   % (N_INIT x 1)
    N_INIT = size(trained_X, 1);

    %% --- Pre-allocate ---
    trained_X = [trained_X; zeros(N_iter, DIM)];
    trained_Y = [trained_Y; zeros(N_iter, 1)];
    INIT_LOC  = N_INIT;

    TIME_ARR   = zeros(N_iter, 1);
    MAX_ARR    = zeros(N_iter, 1);
    TOTAL_TIME = 0;

    %% --- Main BO Loop ---
    for iter = 1:N_iter

        X_cur = trained_X(1:INIT_LOC, :);
        Y_cur = trained_Y(1:INIT_LOC, :);

        tic;

        %% (1) Best so far
        BEST_F = max(Y_cur);

        %% (2) Fit GP (standardize Y manually)
        Y_mean = mean(Y_cur);
        Y_std  = std(Y_cur);
        if Y_std == 0, Y_std = 1; end
        Y_norm = (Y_cur - Y_mean) / Y_std;

        gp_model = fitrgp(X_cur, Y_norm, ...
            'KernelFunction', 'matern52', ...
            'BasisFunction',  'constant', ...
            'Standardize',    false, ...
            'OptimizeHyperparameters', 'auto', ...
            'HyperparameterOptimizationOptions', ...
                struct('Verbose', 0, 'ShowPlots', false));

        %% (3) Random candidates
        X_cand = rand(opts.N_PENDING, DIM);

        %% (4) Evaluate EI over candidates
        [mu_norm, sigma_norm] = predict(gp_model, X_cand);
        mu    = mu_norm    * Y_std + Y_mean;
        sigma = sigma_norm * Y_std;
        sigma = max(sigma, 1e-9);

        z        = (mu - BEST_F) ./ sigma;
        EI_vals  = (mu - BEST_F) .* normcdf(z) + sigma .* normpdf(z);
        EI_vals  = max(EI_vals, 0);

        [~, best_idx]  = max(EI_vals);
        best_candidate = X_cand(best_idx, :);

        %% --- Log time ---
        TOTAL_TIME     = TOTAL_TIME + toc;
        TIME_ARR(iter) = TOTAL_TIME;

        %% (5) Evaluate and store
        [~, y_new] = func.evaluate(best_candidate);
        trained_X(INIT_LOC+1, :) = best_candidate;
        trained_Y(INIT_LOC+1, :) = y_new;
        INIT_LOC = INIT_LOC + 1;

        %% (6) Track best
        MAX_ARR(iter) = max(trained_Y(1:INIT_LOC));

        fprintf('[GP_EI]    Iter %3d) Best: %.6f\n', iter, MAX_ARR(iter));
    end

    %% --- Cummax ---
    MAX_ARR = cummax_vec(MAX_ARR);

    %% --- Save ---
    if ~isempty(opts.SAVE_DIR)
        save_folder = fullfile(opts.SAVE_DIR, 'GP_EI', sprintf('DIM_%d', DIM));
        if ~exist(save_folder, 'dir'), mkdir(save_folder); end
        save_file = fullfile(save_folder, sprintf('trial_%d.mat', opts.Trail_N));
        save(save_file, 'TIME_ARR', 'MAX_ARR', 'trained_X');
        fprintf('Saved GP_EI results to %s\n', save_file);
    end
end


%% -------------------------------------------------------------------------
function out = cummax_vec(v)
    out = v;
    for i = 2:length(v)
        out(i) = max(out(i-1), v(i));
    end
end