#!/usr/bin/env bash

# # Script: init_env.sh
# `init_env.sh` - Initialize Environment and Source Utility Scripts
# ## Description
# - **Purpose**: 
#   - Initializes the environment for bash scripting, particularly in the context of managing virtual environments. It sets up the necessary environment and sources utility scripts required for the proper functioning of other scripts in the system. It is responsible for orchestrating the environment setup in the correct order and can also be used to source additional environment or setup scripts as required, such as `.env.local` files.
# - **Usage**: 
#   - Source this script in other bash scripts to import the necessary environment and utility
#     functions. It also contains a function that can be called to perform environment setup tasks
#     in user scripts. To use it, include the following line in your bash scripts:
#     ```bash
#     source /path/to/init_env.sh
#     ```
# - **Input Parameters**: 
#   - None. The script operates without requiring any input parameters.
# - **Output**: 
#   - Sets up the environment, sources utility scripts, and prepares the system for managing virtual environments.
# - **Exceptions**: 
#   - Exits with code 1 if it fails to find any of the required scripts or if any part of the
#     initialization process fails.
#
# ## Dependencies
# - Utility scripts located in `__VENV_INCLUDE`:
#   - `util_funcs.sh`
#   - `help_sys.sh`
#   - `errno.sh`
#   - `venv_funcs.sh`
#   - `wrapper_funcs.sh`
# - Conda environment


# # Function: source_util_script
#  `source_util_script` - Sources a utility script from the specified directory.
# ## Description
# - **Purpose**: 
#   - Sources a utility script from the specified directory. It's a helper function used within the
#    `init_env.sh` script to modularity load additional scripts as needed.
# - **Usage**: 
#   - `source_util_script "script_name"`
# - **Input Parameters**: 
#   - `script_name`: The name of the script to source (without the `.sh` extension).
# - **Output**: 
#   - Sources the specified script if found. Otherwise, outputs an error message and returns with
#     an exit code of 1.
# - **Exceptions**: 
#   - Returns with exit code 1 if the specified script is not found in the directory `__VENV_INCLUDE`.
#
source_util_script() {
    local script_name="$1"
    local script_path="${__VENV_INCLUDE}/${script_name}.sh"
    if [ -f "$script_path" ]; then
        # shellcheck source=/dev/null
        . "$script_path"
    else
        echo "${__VENV_INCLUDE}: Error sourcing script ${script_name}.sh in INCLUDE_DIR: ${__VENV_INCLUDE}" >&2
        return 1
    fi
}

## Initialization
# Determine the real path of the script
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
# Declare the global associative array if not already declared
if [[ -z "${__VENV_SOURCED+x}" ]]; then
    declare -Ag __VENV_SOURCED
fi
# Don't source this script if it's already been sourced.
if [[ -n "${__VENV_SOURCED["${THIS_SCRIPT}"]}" ]]; then
    echo "Skipping already sourced script: ${THIS_SCRIPT}"
    return 0
fi
__VENV_SOURCED["${THIS_SCRIPT}"]=1
echo "Sourcing: ${THIS_SCRIPT}"

# Extract script name, directory, and arguments
__VENV_BIN=$(dirname "$(dirname "${THIS_SCRIPT}")")
__VENV_BASE=$(dirname "${__VENV_BIN}")
__VENV_ARGS=$*
__VENV_INCLUDE="${__VENV_BASE}/bin/shinclude"

# shellcheck disable=SC2206
__VENV_INTERNAL_FUNCTIONS=(
    ${__VENV_INTERNAL_FUNCTIONS[@]}
    "source_util_script"
)

# Initialize Conda environment
# shellcheck disable=SC2016
__conda_setup="$('${HOME}/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "${HOME}/miniconda3/etc/profile.d/conda.sh" ]; then
        # shellcheck source=/dev/null
        . "${HOME}/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="${HOME}/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# Source utility functions
source_util_script "util_funcs"
source_util_script "errno"
source_util_script "help_sys"
source_util_script "wrapper_funcs"
source_util_script "venv_funcs"

__rc__=0
