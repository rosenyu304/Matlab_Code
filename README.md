# MATLAB Code Portfolio

This repository showcases my selected MATLAB projects spanning **research** and **teaching**, demonstrating proficiency across the MATLAB ecosystem including the Statistics and Machine Learning Toolbox, Optimization Toolbox, and core numerical computing capabilities.

## Repository Structure

```
Matlab_Code/
├── GITBO_research/          % Research: Bayesian Optimization in MATLAB
│   ├── GP_GITBO.m           % Gradient-Informed BO algorithm
│   ├── GP_EI.m              % Standard GP + Expected Improvement baseline
│   ├── run.m                % Driver script to compare algorithms
│   └── plotting.m           % Convergence visualization
│
├── TabPFN_matlab/           % MATLAB wrapper for TabPFN cloud API
│   ├── TabPFNClassifier.m   % Classification wrapper (fit, predict, predict_proba)
│   ├── TabPFNRegressor.m    % Regression wrapper (fit, predict)
│   ├── install_tabpfn.m     % Install Python dependencies
│   ├── setup_tabpfn.m       % Configure and verify Python environment
│   ├── set_tabpfn_access_token.m % Set API access token
│   └── example_*.m          % Usage examples
│
└── Teaching_materials/      % Teaching: Course materials I developed at MIT
    ├── Intro_to_ML_Lab_1.pdf        % Lab: Supervised learning (k-NN classification)
    ├── Intro_to_ML_Lab_2.pdf        % Lab: Unsupervised learning (k-Means clustering)
    ├── Optimization_Lab_content.pdf % Lab: Convexity, golden section search, fmincon
    └── Optimization_HW_problems.pdf % HW: Interval halving, spring design, genetic algorithms
```

---

## Research: Gradient-Informed Bayesian Optimization (GIT-BO)

This folder contains a pure-MATLAB implementation of the **GIT-BO** algorithm from my research on high-dimensional Bayesian optimization ([ICLR 2026](https://openreview.net/forum?id=9iTdKS4SRQ)).

<!-- ### Key idea
Standard Bayesian optimization with Gaussian processes scales poorly to high dimensions because the acquisition function must be optimized over the full *D*-dimensional space. GIT-BO addresses this by:
1. Fitting a GP surrogate with `fitrgp` (Matern 5/2 kernel, automatic hyperparameter tuning).
2. Computing numerical gradients of the GP predictive mean at a set of pending points.
3. Performing eigendecomposition on the gradient outer-product matrix to identify a low-rank **active subspace**.
4. Focusing candidate generation and acquisition function evaluation within this subspace. -->

### MATLAB toolboxes and features used
| Feature | Where |
|---|---|
| `fitrgp` &mdash; Gaussian process regression | `GP_GITBO.m`, `GP_EI.m` |
| `predict` &mdash; GP mean and variance predictions | Acquisition function evaluation |
| `normcdf`, `normpdf` &mdash; Expected Improvement | `GP_EI.m`, `GP_GITBO.m` |
| `eig` &mdash; Eigendecomposition for subspace discovery | `GP_GITBO.m` |
| `inputParser` &mdash; Name-value argument handling | Both algorithm files |
| Vectorized matrix operations | Gradient computation, candidate sampling |
| Plotting (`plot`, `subplot`, `saveas`) | `plotting.m` |

### Running the code
```matlab
% From the GITBO_research/ directory
run   % Compares GP-GITBO vs GP-EI on a 200D Ackley benchmark

% After the run completes:
plotting   % Generates convergence comparison figures
```

---

## TabPFN for MATLAB

A MATLAB wrapper for the [TabPFN](https://github.com/PriorLabs/tabpfn-client) cloud-based tabular prediction service. Mirrors the approach of [R-tabpfn](https://github.com/PriorLabs/R-tabpfn), using MATLAB's built-in Python interop (`py.*`) to call the Python `tabpfn-client` package.

### Key features
- `TabPFNClassifier` — classification with `fit`, `predict`, and `predict_proba`
- `TabPFNRegressor` — regression with `fit` and `predict`
- One-line setup: `install_tabpfn()` installs all Python dependencies
- Handles MATLAB-to-numpy data conversion automatically

### MATLAB features used
| Feature | Where |
|---|---|
| `pyenv` — Python environment configuration | `setup_tabpfn.m` |
| `py.importlib.import_module` — Python interop | All wrapper files |
| `py.numpy.array` — MATLAB-to-numpy conversion | `TabPFNClassifier.m`, `TabPFNRegressor.m` |
| `handle` class with OOP | `TabPFNClassifier.m`, `TabPFNRegressor.m` |
| `validateattributes` — input validation | `TabPFNClassifier.m`, `TabPFNRegressor.m` |

### Quick start
```matlab
pyenv('Version', '~/matlab-tabpfn-venv/bin/python')
set_tabpfn_access_token('YOUR_TOKEN');

clf = TabPFNClassifier();
clf.fit(X_train, y_train);
predictions = clf.predict(X_test);
```

See [`TabPFN_matlab/README.md`](TabPFN_matlab/README.md) for full installation and setup instructions.

---

## Teaching: MIT Course Materials (2.086, Spring 2025 & 2024)

I developed MATLAB-based lab exercises and homework assignments as a teaching assistant for **MIT 2.086 — Numerical Computation for Mechanical Engineers**. These materials guide students through core computational methods using MATLAB's toolboxes.

### Introduction to Machine Learning Labs
- **Lab 1 — Supervised Learning (k-NN Classification):** Students classify bicycle types (Road vs. Mountain) using `fitcknn`, explore feature scaling (min-max, z-score), evaluate models with confusion matrices, and analyze the effect of feature count on accuracy.
- **Lab 2 — Unsupervised Learning (k-Means Clustering):** Students implement k-Means from scratch, use SSE elbow plots and silhouette analysis (`meanSilhouette`) to select *K*, handle missing data with `fillmissing`, and compare 2-feature vs. 8-feature clustering.

### Optimization Labs and Homework
- **Lab — Optimization Fundamentals:** Covers convex sets/functions with visualization, golden section search implementation, and constrained optimization of a tension-compression spring using `fmincon` with nonlinear constraints.
- **Homework — Optimization Methods:** Interval halving for blackbox minimization, geometric transformations on 3D point clouds (dilation, rotation, projection) with optimization via `fmincon`, and maximization using genetic algorithms (`ga` from the Global Optimization Toolbox).

### MATLAB toolboxes and features used
| Feature | Where |
|---|---|
| `fitcknn` &mdash; k-NN classification | ML Lab 1 |
| `cvpartition` &mdash; Cross-validation splits | ML Lab 1 |
| `confusionmat`, `confusionchart` | ML Lab 1 |
| `gplotmatrix` &mdash; Scatter-matrix visualization | ML Lab 1 |
| `fmincon` &mdash; Constrained nonlinear optimization | Optimization Lab & HW |
| `ga` &mdash; Genetic algorithm (Global Optimization Toolbox) | Optimization HW |
| `fplot`, `fsurf`, `gscatter`, `plot3` | Throughout |

---
