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
__VENV_INTERNAL_FUNCTIONS=("init_help_system" "functions to esclude from help documentation" )

# General wrapper function for logging specific command actions
do_wrapper() {
    local cmd=$1
    local action=$2

    # Define the actions to log
    local actions_to_log=("install" "uninstall" "remove" "rename" "update")

    # Check if the action should be logged
    if [[ " ${actions_to_log[*]} " == *" $action "* ]]; then
        # Logging the command invocation
        # TODO decide on a place to hold the log file.
        echo "# $(date '+%Y-%m-%d %H:%M:%S'): $cmd $*" >> /dev/null
    fi

    # Execute the command
    command "$cmd" "$@"
}

# Specific wrapper functions for pip and conda
pip() {
    do_wrapper pip "$@"
}

conda() {
    do_wrapper conda "$@"
}
