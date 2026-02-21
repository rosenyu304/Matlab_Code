# Teaching Materials — MIT 2.086 (Spring 2025)

MATLAB-based lab exercises and homework assignments developed for **MIT 2.086 — Numerical Computation for Mechanical Engineers**. These materials guide students through supervised/unsupervised machine learning and constrained optimization using MATLAB.

## Materials

### Introduction to Machine Learning

| File | Topic | Description |
|------|-------|-------------|
| `Intro_to_ML_Lab_1.pdf` | Supervised Learning (k-NN Classification) | Classify bicycles as Road vs. Mountain Bike using k-nearest neighbors. Covers exploratory scatter-matrix plots (`gplotmatrix`), train/validation/test splitting (`cvpartition`), k-NN with and without feature scaling (min-max, z-score), confusion matrices, accuracy/TPR/FPR metrics, feature selection by correlation ranking, hyperparameter tuning (k = 3, 5, 7) on validation set, and MATLAB's Classification Learner app. |
| `Intro_to_ML_Lab_2.pdf` | Unsupervised Learning (k-Means Clustering) | Cluster bicycle geometries without labels. Students implement k-means from scratch (`myKMeans`), evaluate clusters with SSE elbow plots and mean silhouette scores (`meanSilhouette`), compare 2-feature vs. 8-feature clustering, handle missing data with `fillmissing`, and explore the curse of dimensionality. |

### Optimization

| File | Topic | Description |
|------|-------|-------------|
| `Optimization_Lab_content.pdf` | Optimization Fundamentals | Refresher on convex sets and functions with visualizations. Problem 1: Implement golden section search for unimodal minimization. Problem 2: Minimize the weight of a tension/compression spring using `fmincon` with nonlinear constraints (deflection, shear, surge frequency), then enforce integer coil count via constraint matrices. Problem 3: Optimize a solar heat exchanger pipe design using both `fmincon` and genetic algorithms (`ga`), comparing results. |
| `Optimization_HW_problems.pdf` | Optimization Methods (Homework) | Problem 1: Implement interval halving for blackbox minimization, verify with `fmincon`, and solve inverse problems. Problem 2: Optimize geometric transformations (translation + rotation) on 3D point clouds to match a target configuration using `fmincon`, including noisy measurements and different initial guesses. Problem 3: Maximize a 2D function using genetic algorithms (`ga`) with varying population sizes (20, 50, 100) and mutation rates (0.01, 0.1, 0.2). Problem 4: Minimize the volume of a three-bar truss under stress constraints using `ga`. |

## MATLAB Toolboxes and Functions Used

| Function / Feature | Material |
|---|---|
| `fitcknn` — k-NN classification | ML Lab 1 |
| `cvpartition` — train/validation/test splitting | ML Lab 1 |
| `confusionmat`, `confusionchart` — model evaluation | ML Lab 1 |
| `gplotmatrix` — scatter-matrix visualization | ML Lab 1 |
| Classification Learner App — automated model comparison | ML Lab 1 |
| `fillmissing` — missing data imputation | ML Lab 2 |
| `silhouette` — cluster quality visualization | ML Lab 2 |
| `fmincon` — constrained nonlinear optimization | Optimization Lab & HW |
| `optimoptions` — solver configuration | Optimization Lab & HW |
| `ga` — genetic algorithm (Global Optimization Toolbox) | Optimization Lab & HW |
| `fplot`, `fsurf`, `gscatter`, `plot3` — visualization | Throughout |

## Learning Objectives

- **ML Lab 1**: Understand the supervised learning pipeline — data splitting, feature scaling, model training, evaluation, and hyperparameter selection using a validation set.
- **ML Lab 2**: Contrast supervised vs. unsupervised learning, implement k-means from scratch, and use internal cluster metrics (SSE, silhouette) to choose K without labels.
- **Optimization Lab**: Apply convex optimization theory, implement a line-search method (golden section), and use `fmincon` for real engineering design problems with nonlinear constraints.
- **Optimization HW**: Practice interval-based optimization, geometric transformation optimization on 3D data, and stochastic global optimization with genetic algorithms.
