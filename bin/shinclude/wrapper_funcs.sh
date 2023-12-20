#!/bin/bash
#
# # `wrapper_funcs.sh
#` # Script Name
# 
# ## Description
# - **Purpose**: 
# - **Usage**: 
# - **Input Parameters**: 
# - **Output**: 
# - **Exceptions**: 
# 
# ## Dependencies
# - List of dependencies
# 
# ## Examples
# - Example 1
# - Example 2
# 
# #
# # # `wrapper_funcs.sh
# #` # Script Name
# 
# ## Description
# - **Purpose**: 
# - **Usage**: 
# - **Input Parameters**: 
# - **Output**: 
# - **Exceptions**: 
# 
# ## Dependencies
# - List of dependencies
# 
# ## Examples
# - Example 1
# - Example 2
# 

# Determine the real path of the script
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
# Don't source this script if it's already been sourced.
[[ "${__VENV_SOURCED_LIST}" =~ "${THIS_SCRIPT}" ]] && return || __VENV_SOURCED_LIST="${__VENV_SOURCED_LIST} ${THIS_SCRIPT}"
echo "Sourcing: ${THIS_SCRIPT}"


# Define an array of internal functions to exclude from help and documentation
__VENV_INTERNAL_FUNCTIONS=(
    ${__VENV_INTERNAL_FUNCTIONS[@]}
    "pip"
    "conda"
)

# Function to get the hash of a function's definition
get_function_hash() {
    declare -f "$1" | md5 | cut -d' ' -f1
}


# General wrapper function for logging specific command actions
do_wrapper() {
    local cmd="$1"; shift
    local action="$1"
    local hist_log="${CONDA_PREFIX}/conda-meta/install.log"
    local actions_to_log=("install" "uninstall" "remove" "rename" "update" "upgrade" "create")
    local actions_to_exclude=("--help" "-h" "--dry-run")

    # Prepare a pattern for exclusion actions
    local exclude_pattern=$(IFS="|"; echo "${actions_to_exclude[*]}")

    # Check if the command ${cmd} is a file or a function/alias, if it has a command file,
    # we want to run it with the "command" builtin.
    if command ${cmd} &> /dev/null;  then
        cmd="command ${cmd}"
    fi
    # Check if the action should be logged
    if [[ " ${actions_to_log[*]} " =~ "${action}" ]] && ! [[ "$*" =~ ${exclude_pattern} ]]; then
        if ${cmd} "$@"; then
            # Logging the command invocation if it completed successfully
            echo "# $(date '+%Y-%m-%d %H:%M:%S'): ${cmd} $*" >> "${hist_log}"
            echo "# $(${cmd} --version)" >> "${hist_log}"
        fi
    else
        # Execute the command without logging
        ${cmd} "$@"
    fi
}

# Specific wrapper function for pip
pip() {
    do_wrapper "pip" "$@"
}

# Function for Conda wrapper.
conda() {
    do_wrapper "__venv_conda" "$@"
}
# Initial hash of the Conda function. Must always set new has after defining.
__venv_conda_hash=$(get_function_hash conda)

__venv_conda_hook_install() {
    # Capture the current conda function definition and assign it to __venv_conda
    eval "__venv_conda() $(declare -f conda | sed '1d')"

    # Redefine the conda function to include the wrapper
    conda() {
        do_wrapper "__venv_conda" "$@"
    }
    # Set the hash to be the new conda function.
    __venv_conda_hash=$(get_function_hash conda)
}

# Function to check if conda definition changed and re-hook if necessary
__venv_conda_check() {
    current_hash=$(get_function_hash conda)
    if [[ "${current_hash}" != "${__venv_conda_hash}" ]]; then
        __venv_conda_hook_install
    fi
}

# Modify the PROMPT_COMMAND to continuously check for function `conda` changes
__venv_prompt_command="${PROMPT_COMMAND}"
PROMPT_COMMAND="__venv_conda_check; ${PROMPT_COMMAND}"
