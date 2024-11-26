# venv_funcs.sh - Virtual Environment Management Functions

## Description

- **Purpose**: This script provides a collection of functions to manage conda virtual environments. Functions include creating, deleting, switching, and cloning environments, among others.

- **Usage**: Source this script in other bash scripts to import the virtual environment management functions. For example, in another script: `source venv_funcs.sh`.

- **Input Parameters**: None. All input is handled by the individual functions.

- **Output**: The script provides various virtual environment management functions for use in other bash scripts.

- **Exceptions**: Some functions may return specific error codes or print error messages to STDERR. Refer to individual function documentation for details.

- **Internal Variables**:
  - `__VENV_NUM`: The sequence of the venv in a `__VENV_PREFIX` series.
  - `__VENV_PREFIX`: The prefix of the VENV.
  - `__VENV_DESC`: A very short description of the VENV.

- **Functions**: Includes functions like `push_venv()`, `pop_venv()`, `__set_venv_vars()`, and others for managing virtual environments efficiently.
