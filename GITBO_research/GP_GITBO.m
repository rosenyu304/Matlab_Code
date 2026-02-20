function [trained_X, MAX_ARR, rank_r_arr] = GP_GITBO(func, SEED, varargin)
% GP_GITBO - Gradient-Informed Trust-region Bayesian Optimization
%
% INPUTS:
%   func            - struct with fields: .evaluate (function handle), .dim (int)
%   SEED            - random seed
%   Optional Name-Value:
%     'N_iterations'       - number of BO iterations (default: 100)
%     'Acquisition'        - 'EI' or 'UCB' (default: 'EI')
%     'INITIAL_DIR'        - path to initial X .mat file (default: [])
%     'SAVE_DIR'           - path to save results (default: [])
%     'N_PENDING'          - number of pending samples (default: 1000)
%     'Trail_N'            - trial index (default: 0)

    %% --- Parse inputs ---
    p = inputParser;
    addParameter(p, 'N_iterations',     100);
    addParameter(p, 'Acquisition',      'EI');
    addParameter(p, 'INITIAL_DIR',      []);
    addParameter(p, 'SAVE_DIR',         []);
    addParameter(p, 'N_PENDING',        1000);
    addParameter(p, 'Trail_N',          0);
    parse(p, varargin{:});
    opts = p.Results;

    %% --- Seed ---
    rng(SEED);

    %% --- Dimension ---
    DIM = func.dim;

    %% --- Initial samples ---
    if ~isempty(opts.INITIAL_DIR)
        data = load(opts.INITIAL_DIR);
        trained_X = data.trained_X;
    else
        trained_X = rand(50, DIM);
    end
    N_INIT = size(trained_X, 1);

    %% --- Evaluate initial samples ---
    [GX, trained_Y] = func.evaluate(trained_X);
    % trained_Y: (N_INIT x 1), GX: (N_INIT x n_constraints) or []

    %% --- Pre-allocate storage for all iterations ---
    INIT_LOC     = N_INIT;
    N_iter       = opts.N_iterations;
    trained_X    = [trained_X;    zeros(N_iter, DIM)];
    trained_Y    = [trained_Y;    zeros(N_iter, 1)];
    if ~isempty(GX)
        GX = [GX; zeros(N_iter, size(GX,2))];
    end
    ITER_IND_LOC = INIT_LOC;

    TIME_ARR  = zeros(N_iter, 1);
    MAX_ARR   = zeros(N_iter, 1);
    rank_r_arr = zeros(N_iter, 1);
    TOTAL_TIME = 0;

    %% --- Main BO Loop ---
    for iter = 1:N_iter

        X_cur = trained_X(1:ITER_IND_LOC, :);
        Y_cur = trained_Y(1:ITER_IND_LOC, :);
        if ~isempty(GX)
            GX_cur = GX(1:ITER_IND_LOC, :);
        else
            GX_cur = [];
        end

        tic;

        %% (1) Best feasible so far
        BEST_F = get_best_feasible(Y_cur, GX_cur);

        %% (2) Fit GP
        % Normalize X to [0,1] (already assumed), standardize Y
        Y_mean = mean(Y_cur);
        Y_std  = std(Y_cur);
        if Y_std == 0, Y_std = 1; end
        Y_norm = (Y_cur - Y_mean) / Y_std;

        gp_model = fitrgp(X_cur, Y_norm, ...
            'KernelFunction',    'matern52', ...
            'BasisFunction',     'constant', ...
            'Standardize',       false, ...
            'OptimizeHyperparameters', 'auto', ...
            'HyperparameterOptimizationOptions', ...
                struct('Verbose', 0, 'ShowPlots', false));

        %% (3) GI Subspace via numerical gradients on pending points
        X_pen = rand(opts.N_PENDING, DIM);    % uniform random pending

        % Compute numerical gradients of GP mean at each pending point
        grad_mat = compute_gp_gradients(gp_model, X_pen, DIM);
        % grad_mat: (N_PENDING x DIM)

        %% (4) Eigendecomposition to find active subspace
        H_est = (grad_mat' * grad_mat) / size(X_pen, 1);   % (DIM x DIM)
        [eigvecs, eigvals_diag] = eig(H_est);
        eigvals = diag(eigvals_diag);

        % Sort descending
        [eigvals, idx] = sort(eigvals, 'descend');
        eigvecs = eigvecs(:, idx);

        % Find rank r covering 97.5% variance
        total_var = sum(eigvals);
        cum_var   = cumsum(eigvals) / total_var;
        % rank_r    = find(cum_var >= 0.975, 1, 'first');
        rank_r = 5;
        if isempty(rank_r), rank_r = DIM; end
        rank_r_arr(iter) = rank_r;

        U_r    = eigvecs(:, 1:rank_r);   % (DIM x rank_r)
        origin = mean(X_pen, 1)';         % (DIM x 1)

        %% (5) Sample in GI subspace and map back to original space
        alpha   = 2*rand(opts.N_PENDING, rank_r) - 1;       % uniform [-1,1]
        samples = origin' + alpha * U_r';                    % (N_PENDING x DIM)
        samples = max(0, min(1, samples));                   % clamp to [0,1]

        %% (6) Evaluate acquisition function on subspace samples
        best_candidate = optimize_acquisition(gp_model, samples, BEST_F, ...
                            Y_mean, Y_std, opts.Acquisition);

        %% --- Log time BEFORE evaluating the new point ---
        TOTAL_TIME     = TOTAL_TIME + toc;
        TIME_ARR(iter) = TOTAL_TIME;

        %% (7) Evaluate new candidate and store
        ITER_IND_LOC = INIT_LOC + 1;
        trained_X(INIT_LOC+1, :) = best_candidate;
        [g_new, y_new] = func.evaluate(best_candidate);
        trained_Y(INIT_LOC+1, :) = y_new;
        if ~isempty(GX)
            GX(INIT_LOC+1, :) = g_new;
        end
        INIT_LOC = ITER_IND_LOC;

        %% (8) Track best
        MAX_ARR(iter) = get_best_feasible(trained_Y(1:ITER_IND_LOC,:), ...
                                          GX_if_available(GX, ITER_IND_LOC));

        fprintf('Iter %d) Best: %.6f | rank_r: %d\n', iter, MAX_ARR(iter), rank_r);
    end

    %% --- Final cummax across all iterations ---
    MAX_ARR = cummax(MAX_ARR);

    %% --- Save or Plot ---
    if isempty(opts.SAVE_DIR)
        figure;
        subplot(1,2,1);
        plot(1:N_iter, -MAX_ARR); 
        xlabel('Iterations'); title(sprintf('Function Dim:%d', DIM));

        subplot(1,2,2);
        plot(TIME_ARR, -MAX_ARR);
        xlabel('Time (s)'); title(sprintf('Function Dim:%d', DIM));
    else
        save_folder = fullfile(opts.SAVE_DIR, ...
            sprintf('GP_GISubspace_%s', opts.Acquisition), ...
            sprintf('Function_DIM_%d', DIM));
        if ~exist(save_folder, 'dir'), mkdir(save_folder); end

        save_file = fullfile(save_folder, ...
            sprintf('trial_%d_iters_%d.mat', opts.Trail_N, N_iter));
        save(save_file, 'TIME_ARR', 'MAX_ARR', 'trained_X', 'rank_r_arr');
        fprintf('Saved results to %s\n', save_file);
    end

    fprintf('ACQ: %s | Dim: %d\n', opts.Acquisition, DIM);
    disp(rank_r_arr');
end


%% =========================================================================
%  HELPER: Numerical gradients of GP predictive mean
% =========================================================================
function grad_mat = compute_gp_gradients(gp_model, X, DIM)
% Finite-difference gradient of GP mean predictions
% Returns: grad_mat (N x DIM)
    N   = size(X, 1);
    h   = 1e-5;
    grad_mat = zeros(N, DIM);
    f0 = predict(gp_model, X);          % baseline predictions (N x 1)

    for d = 1:DIM
        X_fwd       = X;
        X_fwd(:,d)  = X_fwd(:,d) + h;
        X_fwd       = max(0, min(1, X_fwd));   % stay in bounds

        f_fwd        = predict(gp_model, X_fwd);
        grad_mat(:,d) = (f_fwd - f0) / h;
    end
end


%% =========================================================================
%  HELPER: Acquisition function evaluation
% =========================================================================
function best_x = optimize_acquisition(gp_model, samples, best_f, ...
                                        Y_mean, Y_std, acq_type)
% Evaluate EI or UCB over candidate samples; return argmax
    N = size(samples, 1);
    acq_vals = zeros(N, 1);

    [mu_norm, sigma_norm] = predict(gp_model, samples);
    % De-standardize
    mu    = mu_norm    * Y_std + Y_mean;
    sigma = sigma_norm * Y_std;
    sigma = max(sigma, 1e-9);

    switch upper(acq_type)
        case 'EI'
            % Standard EI (maximization)
            z         = (mu - best_f) ./ sigma;
            acq_vals  = (mu - best_f) .* normcdf(z) + sigma .* normpdf(z);
            acq_vals  = max(acq_vals, 0);
        case 'UCB'
            kappa     = best_f;   % mirrors the Python code passing BEST_F as beta
            acq_vals  = mu + kappa .* sigma;
    end

    [~, best_idx] = max(acq_vals);
    best_x = samples(best_idx, :);
end


%% =========================================================================
%  HELPER: Best feasible value
% =========================================================================
function best_val = get_best_feasible(Y, GX)
    if isempty(GX)
        best_val = max(Y);
    else
        feasible = all(GX <= 0, 2);
        if any(feasible)
            best_val = max(Y(feasible));
        else
            best_val = max(Y);   % fallback: no feasible point yet
        end
    end
end


%% =========================================================================
%  HELPER: GX slice (returns [] if GX is empty)
% =========================================================================
function out = GX_if_available(GX, loc)
    if isempty(GX)
        out = [];
    else
        out = GX(1:loc, :);
    end
end


%% =========================================================================
%  HELPER: Cumulative maximum
% =========================================================================
function out = cummax(v)
    out = v;
    for i = 2:length(v)
        out(i) = max(out(i-1), v(i));
    end
end