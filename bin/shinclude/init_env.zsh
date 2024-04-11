#!/bin/bash
#
# `init_envzsh` - Initialize Environment and Source Utility Scripts
# 
# ## Description
# - **Purpose**: 
#   - `init_envzsh` is designed to initialize the environment for bash scripting, particularly in the context of managing virtual environments. It sets up the necessary environment and sources utility scripts required for the proper functioning of other scripts in the system. It is responsible for orchestrating the environment setup in the correct order and can also be used to source additional environment or setup scripts as required, such as `.env.local` files.
# - **Usage**: 
#   - This script is intended to be sourced in other bash scripts to import the necessary environment and utility functions. It also contains a function that can be called to perform environment setup tasks in user scripts. To use it, include the following line in your bash scripts:
#     ```zsh
#     source /path/to/init_env.zsh
#     ```
# - **Input Parameters**: 
#   - None. The script operates without requiring any input parameters.
# - **Output**: 
#   - Upon execution, `init_env.zsh` sets up the environment, sources utility scripts, and prepares the system for managing virtual environments.
# - **Exceptions**: 
#   - The script exits with code 1 if it fails to find any of the required scripts or if any part of the initialization process fails.
# 
# ## Dependencies
# - This script relies on utility scripts located in a specified directory (`__VENV_INCLUDE`). It specifically sources the following utility scripts:
#   - `util_funcs.zsh`
#   - `help_sys.zsh`
#   - `venv_funcs.zsh`
# - The script also assumes the presence of a Conda environment and attempts to initialize it.
# 
# ## Examples
# - **Sourcing the Script**:
#   ```zsh
#   # In your zas script
#   source /path/to/init_env.xsh
# ```
# 

# Determine the real path of the script
[[ -L "$0" ]] && THIS_SCRIPT=$(readlink "$0") || THIS_SCRIPT="$0"
# Don't source this script if it's already been sourced.
[[ "${__VENV_SOURCED_LIST}" =~ "${THIS_SCRIPT}" ]] && return || __VENV_SOURCED_LIST="${__VENV_SOURCED_LIST} ${THIS_SCRIPT}"
echo "Sourcing: ${THIS_SCRIPT}"

# Extract script name, directory, and arguments
__VENV_BIN=$(dirname $(dirname "${THIS_SCRIPT}"))
__VENV_BASE=$(dirname "${__VENV_BIN}")
__VENV_ARGS=$*
__VENV_INCLUDE="${__VENV_BASE}/bin/shinclude"

__VENV_INTERNAL_FUNCTIONS=(
    ${__VENV_INTERNAL_FUNCTIONS[@]}
    "source_util_script"
)

source_util_script() {
# # Function: source_util_script
# 
# ## Description
# - **Purpose**: 
#   - The `source_util_script` function is designed to source a utility script from a specified directory. It's a helper function used within the `init_envzsh` script to modularly load additional scripts as needed.
# - **Usage**: 
#   - This function is called with a single argument: the name of the script to be sourced (without the `zsh` extension). It checks for the presence of the script in the directory specified by `__VENV_INCLUDE` and sources it if found. If the script is not found, it prints an error message and returns with an exit code of 1.
# - **Input Parameters**: 
#   - `script_name`: The name of the script to source (without the `zsh` extension).
# - **Output**: 
#   - Sources the specified script if found. Otherwise, outputs an error message.
# - **Exceptions**: 
#   - Exits with a return code of 1 if the specified script is not found in the directory `__VENV_INCLUDE`.
# 
# ## Examples
# - **Sourcing a Script**:
#   ```bash
#   # Call within a bash script
#   source_util_script "my_util"
#   # This attempts to source 'my_utilzsh' from the directory specified in __VENV_INCLUDE
#   ```
# 
    local script_name="$1"
    [[ -f "${__VENV_INCLUDE}/${script_name}zsh" ]] && . "${__VENV_INCLUDE}/${script_name}zsh" || { echo "${__VENV_INCLUDE}: Error sourcing script ${script_name}zsh in INCLUDE_DIR: ${__VENV_INCLUDE}"; return 1; }
}

# Initialize Conda environment
__conda_setup="$("${HOME}/miniconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [[ -f "${HOME}/miniconda3/etc/profile.d/condazsh" ]]; then
        . "${HOME}/miniconda3/etc/profile.d/condazsh"
    else
        export PATH="${HOME}/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# Source utility functions
source_util_script "util_funcs"
source_util_script "help_sys"
source_util_script "wrapper_funcs"
source_util_script "venv_funcs"
