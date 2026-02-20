%% plotting.m
% Loads saved results and generates convergence comparison plots

clear; clc; close all;

%% --- Configuration ---
SAVE_DIR    = fullfile(pwd, 'results');
RESULTS_FILE = fullfile(SAVE_DIR, 'comparison_results.mat');

%% --- Load ---
if ~exist(RESULTS_FILE, 'file')
    error('Results file not found. Please run run.m first.');
end
data = load(RESULTS_FILE);

MAX_gitbo    = data.MAX_gitbo;
MAX_ei       = data.MAX_ei;
N_iterations = data.N_iterations;
DIM          = data.DIM;
iters        = (1:N_iterations)';

%% -----------------------------------------------------------------------
%  FIGURE: Convergence vs Iterations  (Best Objective Found)
% -----------------------------------------------------------------------
figure('Name', 'Convergence vs Iterations', ...
       'Position', [100, 100, 700, 450]);

init_best = min([MAX_gitbo(1), MAX_ei(1)]);


hold on;
p1 = plot([0; iters], -[init_best; MAX_gitbo], '-o',  ...
    'Color',      [0.20, 0.45, 0.80], ...
    'LineWidth',  2, ...
    'MarkerSize', 4, ...
    'MarkerFaceColor', [0.20, 0.45, 0.80], ...
    'DisplayName', 'GP-GITBO (EI)');

p2 = plot([0; iters], -[init_best; MAX_ei], '-s', ...
    'Color',      [0.85, 0.33, 0.10], ...
    'LineWidth',  2, ...
    'MarkerSize', 4, ...
    'MarkerFaceColor', [0.85, 0.33, 0.10], ...
    'DisplayName', 'GP-EI (Baseline)');

hold off;
grid on; box on;

xlabel('Iteration',          'FontSize', 13, 'FontWeight', 'bold');
ylabel('Best Objective (minimization view)', 'FontSize', 13, 'FontWeight', 'bold');
title(sprintf('Convergence Comparison — Ackley %dD', DIM), ...
      'FontSize', 14, 'FontWeight', 'bold');
legend([p1, p2], 'Location', 'best', 'FontSize', 11);
xlim([0, N_iterations]);
set(gca, 'FontSize', 11);

saveas(gcf, fullfile(SAVE_DIR, 'convergence_vs_iterations.png'));
fprintf('Saved: convergence_vs_iterations.png\n');

