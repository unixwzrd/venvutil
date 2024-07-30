# Function: source_util_script
## Description
- **Purpose**: 
  - The `source_util_script` function is designed to source a utility script from a specified directory. It's a helper function used within the `init_env.sh` script to modularly load additional scripts as needed.
- **Usage**: 
  - This function is called with a single argument: the name of the script to be sourced (without the `.sh` extension). It checks for the presence of the script in the directory specified by `__VENV_INCLUDE` and sources it if found. If the script is not found, it prints an error message and returns with an exit code of 1.
- **Input Parameters**: 
  - `script_name`: The name of the script to source (without the `.sh` extension).
- **Output**: 
  - Sources the specified script if found. Otherwise, outputs an error message.
- **Exceptions**: 
  - Exits with a return code of 1 if the specified script is not found in the directory `__VENV_INCLUDE`.
## Examples
- **Sourcing a Script**:
  ```bash
  # Call within a bash script
  source_util_script "my_util"
  # This attempts to source 'my_util.sh' from the directory specified in __VENV_INCLUDE
  ```

