#!/bin/bash
#
# init_env.sh - Initialize Environment and Source Utility Scripts
#
# - **Purpose**:
#     - This script initializes the environment and sources utility scripts for managing virtual environments.
# - **Usage**: 
#     - Source this script in other bash scripts to import the necessary environment and utility functions.
#       any scripts whcih or dependencies may be addedc to this script at the end.
#
#       ```bash
#       source_util_script "script_name"
#       ````
#
# - **Input Parameters**: 
#     - None
#
# - **Output**: 
#     - Sets up the environment and imports utility functions.
#
# - **Exceptions**: 
#     - Exits with code 1 if it fails to find any of the required scripts.
#
INTERNAL_FUNCTIONS=(
    ${INTERNAL_FUNCTIONS[@]}
    "source_util_script"
)

source_util_script(){
#
# source_util_script - Source a utility script by its name.
#
# - **Purpose**:
#    - Sources a utility script given its name. The script must reside in the directory specified by the global variable MY_BIN.
# - **Usage**: 
#     - source_util_script "script_name"
# - **Input Parameters**: 
#     1. `script_name` (string) - The name of the utility script to source.
# - **Output**: 
#     - Sourcing of the utility script. 
# - **Exceptions**: 
#     - Exits with code 1 if the script is not found in the directory specified by MY_BIN.
#
    local script_name="$1"
    [ -f "${MY_BIN}/${script_name}.sh" ] && . "${MY_BIN}/${script_name}.sh" \
        || { echo "${MY_NAME}: Could not find ${script_name}.sh in INCLUDE_DIR: ${MY_BIN}"; exit 1; }
}

# Determine the real path of the script
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
# Don't source this script if it's already been sourced.
[[ "${_SOURCED_LIST}" =~ "${THIS_SCRIPT}" ]] && return || _SOURCED_LIST="${_SOURCED_LIST} ${THIS_SCRIPT}"
echo "Sourcing:${THIS_SCRIPT}"

# Extract script name, directory, and arguments
MY_NAME=$(basename ${THIS_SCRIPT})
MY_BIN=$(dirname ${THIS_SCRIPT})
MY_ARGS=$*
MY_INCLUDE="${MY_BIN}/shinclude"

# Initialize Conda environment to ensure the availability of Python packages and functions in these scripts.
__conda_setup="$('${HOME}/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "${HOME}/miniconda3/etc/profile.d/conda.sh" ]; then
        . "${HOME}/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="${HOME}/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# Source utility functions
source_util_script "help_sys"
source_util_script "util_funcs"
source_util_script "venv_funcs"
