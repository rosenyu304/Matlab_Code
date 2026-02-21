# TabPFN for MATLAB

MATLAB wrapper for the [TabPFN](https://github.com/PriorLabs/tabpfn-client) cloud-based tabular prediction service. This package mirrors the approach of [R-tabpfn](https://github.com/PriorLabs/R-tabpfn), using MATLAB's built-in Python interop to call the `tabpfn-client` Python package.

## Prerequisites

- MATLAB R2019b or later (for `arguments` block support)
- Python 3.9 - 3.12 installed (must be a version [supported by your MATLAB release](https://www.mathworks.com/content/dam/mathworks/mathworks-dot-com/support/sysreq/files/python-support.pdf))

## Installation

### 1. Set up a compatible Python environment

MATLAB bundles its own OpenSSL 3.0.x libraries, which conflict with the newer OpenSSL (3.6+) shipped by conda-forge. To avoid `_ssl` import errors, create a virtualenv from the **macOS system Python** (which uses LibreSSL and avoids the conflict):

```bash
# Create a virtualenv from system Python
/usr/bin/python3 -m venv ~/matlab-tabpfn-venv

# Install dependencies
~/matlab-tabpfn-venv/bin/pip install numpy pandas scikit-learn
~/matlab-tabpfn-venv/bin/pip install "git+https://github.com/PriorLabs/tabpfn-client.git"
```

Alternatively, you can run `install_tabpfn()` from within MATLAB after pointing it to a compatible Python (see step 2).

### 2. Configure MATLAB to use the virtualenv

Run this **before** any other TabPFN calls (Python cannot be changed after it is loaded in a session):

```matlab
pyenv('Version', '~/matlab-tabpfn-venv/bin/python')
```

### 3. Add TabPFN_matlab to the MATLAB path

```matlab
addpath('/path/to/TabPFN_matlab')
```

### 4. Verify the setup (optional)

```matlab
setup_tabpfn()
```

### 5. Get an access token

Get your token at https://ux.priorlabs.ai/account

## Usage

### Classification

```matlab
% Configure Python (once per session, before any py.* calls)
pyenv('Version', '~/matlab-tabpfn-venv/bin/python')

% Set your access token
set_tabpfn_access_token('YOUR_ACCESS_TOKEN');

% Create classifier, fit, and predict
clf = TabPFNClassifier();
clf.fit(X_train, y_train);
predictions = clf.predict(X_test);
probabilities = clf.predict_proba(X_test);
```

### Regression

```matlab
set_tabpfn_access_token('YOUR_ACCESS_TOKEN');

reg = TabPFNRegressor();
reg.fit(X_train, y_train);
predictions = reg.predict(X_test);
```

## Troubleshooting

### SSL / OpenSSL errors

If you see errors like `Symbol not found: _X509_STORE_get1_objects`, your Python was built against a newer OpenSSL than MATLAB bundles. Fix: use a virtualenv created from `/usr/bin/python3` (macOS system Python) as described in the installation steps above. Do **not** use conda Python directly.

### Python version not supported

MATLAB only supports specific Python versions per release. Check the [compatibility table](https://www.mathworks.com/content/dam/mathworks/mathworks-dot-com/support/sysreq/files/python-support.pdf). The macOS system Python 3.9 works with MATLAB R2022b - R2025b.

### Cannot change Python after loading

`pyenv('Version', ...)` must be called before any `py.*` call in a session. If Python is already loaded, restart MATLAB.

## Files

| File | Description |
|------|-------------|
| `install_tabpfn.m` | Install Python dependencies (numpy, pandas, scikit-learn, tabpfn-client) |
| `setup_tabpfn.m` | Configure and verify the Python environment |
| `set_tabpfn_access_token.m` | Set the API access token |
| `TabPFNClassifier.m` | Classification wrapper (fit, predict, predict_proba) |
| `TabPFNRegressor.m` | Regression wrapper (fit, predict) |
| `example_classification.m` | Classification usage example |
| `example_regression.m` | Regression usage example |
| `test_tabpfn.m` | Test script |
