`init_env.sh` - Initialize Environment and Source Utility Scripts
## Description
- **Purpose**: 
  - `init_env.sh` is designed to initialize the environment for bash scripting, particularly in the context of managing virtual environments. It sets up the necessary environment and sources utility scripts required for the proper functioning of other scripts in the system. It is responsible for orchestrating the environment setup in the correct order and can also be used to source additional environment or setup scripts as required, such as `.env.local` files.
- **Usage**: 
  - This script is intended to be sourced in other bash scripts to import the necessary environment and utility functions. It also contains a function that can be called to perform environment setup tasks in user scripts. To use it, include the following line in your bash scripts:
    ```bash
    source /path/to/init_env.sh
    ```
- **Input Parameters**: 
  - None. The script operates without requiring any input parameters.
- **Output**: 
  - Upon execution, `init_env.sh` sets up the environment, sources utility scripts, and prepares the system for managing virtual environments.
- **Exceptions**: 
  - The script exits with code 1 if it fails to find any of the required scripts or if any part of the initialization process fails.
## Dependencies
- This script relies on utility scripts located in a specified directory (`__VENV_INCLUDE`). It specifically sources the following utility scripts:
  - `util_funcs.sh`
  - `help_sys.sh`
  - `venv_funcs.sh`
- The script also assumes the presence of a Conda environment and attempts to initialize it.
## Examples
- **Sourcing the Script**:
  ```bash
  # In your bash script
  source /path/to/init_env.sh
```

