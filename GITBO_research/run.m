%% run.m
% Compares GP_GITBO vs GP_EI on a benchmark function
% Results are saved to ./results/ for plotting

clear; clc; close all;

%% --- Add paths ---
addpath(pwd);                            % current folder (GP_GITBO.m, GP_EI.m)
% addpath(fullfile(pwd, 'helpers'));     % uncomment if helpers are in subfolder

%% -----------------------------------------------------------------------
%  CONFIGURATION
% -----------------------------------------------------------------------
SEED         = 42;
N_iterations = 20;
N_INIT       = 50;
N_PENDING    = 1000;
SAVE_DIR     = fullfile(pwd, 'results');

%% -----------------------------------------------------------------------
%  DEFINE BENCHMARK FUNCTION
%  func.evaluate must return [GX, Y] where:
%    GX = [] for unconstrained problems
%    Y  = (N x 1) objective values (we MAXIMIZE)
% -----------------------------------------------------------------------

% --- Example 1: Negative Ackley (10D), max at 0 ---
DIM = 200;
func.dim = DIM;
func.evaluate = @ackley_evaluate;

% --- Example 2: Negative Rastrigin (uncomment to switch) ---
% DIM = 10;
% func.dim = DIM;
% func.evaluate = @rastrigin_evaluate;

fprintf('============================================\n');
fprintf(' Benchmark: Ackley | Dim: %d | Seed: %d\n', DIM, SEED);
fprintf('============================================\n\n');

%% -----------------------------------------------------------------------
%  RUN GP_GITBO
% -----------------------------------------------------------------------
fprintf('>>> Running GP_GITBO ...\n');
[X_gitbo, MAX_gitbo, rank_r] = GP_GITBO(func, SEED, ...
    'N_iterations', N_iterations, ...
    'Acquisition',  'EI', ...
    'N_PENDING',    N_PENDING, ...
    'SAVE_DIR',     SAVE_DIR, ...
    'Trail_N',      0);

%% -----------------------------------------------------------------------
%  RUN GP_EI
% -----------------------------------------------------------------------
fprintf('\n>>> Running GP_EI ...\n');
[X_ei, MAX_ei] = GP_EI(func, SEED, ...
    'N_iterations', N_iterations, ...
    'N_INIT',       N_INIT, ...
    'N_PENDING',    N_PENDING, ...
    'SAVE_DIR',     SAVE_DIR, ...
    'Trail_N',      0);

%% -----------------------------------------------------------------------
%  SAVE COMBINED RESULTS FOR PLOTTING
% -----------------------------------------------------------------------
if ~exist(SAVE_DIR, 'dir'), mkdir(SAVE_DIR); end

save(fullfile(SAVE_DIR, 'comparison_results.mat'), ...
    'MAX_gitbo', 'MAX_ei', ...
    'rank_r', ...
    'N_iterations', 'DIM', 'SEED');

fprintf('\nAll results saved to %s\n', SAVE_DIR);
fprintf('Run plotting.m to visualize results.\n');


%% -----------------------------------------------------------------------
%  BENCHMARK FUNCTION DEFINITIONS
% -----------------------------------------------------------------------

function [GX, Y] = ackley_evaluate(X)
% Negative Ackley function (maximization, optimum = 0 at X=0.5 after shift)
% X in [0,1]^d, shifted so optimum is at 0.5
    X_shift = X * 2*pi - pi;    % map [0,1] -> [-pi, pi]
    d   = size(X, 2);
    t1  = -20 * exp(-0.2 * sqrt(mean(X_shift.^2, 2)));
    t2  = -exp(mean(cos(2*pi*X_shift), 2));
    Y   = -(t1 + t2 + 20 + exp(1));   % negate for maximization
    GX  = [];
end

function [GX, Y] = rastrigin_evaluate(X)
% Negative Rastrigin function (maximization, optimum = 0 at X=0.5)
    X_shift = X * 10 - 5;   % map [0,1] -> [-5, 5]
    d  = size(X, 2);
    Y  = -(10*d + sum(X_shift.^2 - 10*cos(2*pi*X_shift), 2));
    GX = [];
end