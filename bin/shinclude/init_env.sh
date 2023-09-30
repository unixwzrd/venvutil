#!/bin/bash

# init_env.sh - Initialize Environment and Source Utility Scripts

# - **Purpose**: This script initializes the environment and sources utility scripts for managing virtual environments.
# - **Usage**: 
#     - Source this script in other bash scripts to import the necessary environment and utility functions.
# - **Input Parameters**: 
#     None
# - **Output**: 
#     - Sets up the environment and imports utility functions.
# - **Exceptions**: 
#     - Exits with code 1 if it fails to find any of the required scripts.

# Function to source utility scripts
source_util_script(){
    local script_name="$1"
    [ -f ${MY_INCLUDE}/${script_name}.sh ] && . ${MY_INCLUDE}/${script_name}.sh \
        || ( echo "Could not find ${script_name}.sh in INCLUDEDIR: ${MY_INCLUDE}" && exit 1 )
}

# Determine the real path of the script
[ -L "$0" ] && THIS_SCRIPT=$(readlink -f "$0") || THIS_SCRIPT="$0"
# Don't source this script if it's already been sourced.
[[ "${_SOURCED_LIST}" =~ "${THIS_SCRIPT}" ]] return || _SOURCED_LIST="${_SOURCED_LIST} ${THIS_SCRIPT}"
echo "Sourcing:${THIS_SCRIPT}"

# Extract script name, directory, and arguments
MY_NAME=$(basename ${THIS_SCRIPT})
MY_BIN=$(dirname ${THIS_SCRIPT})
MY_ARGS=$*
MY_INCLUDE="${MY_BIN}/shinclude"

# Initialize conda
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
source_util_script "util_funcs"
source_util_script "venv_funcs"
