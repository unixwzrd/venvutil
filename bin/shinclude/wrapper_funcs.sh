#!/bin/bash

# Determine the real path of the script
THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}")
# Don't source this script if it's already been sourced.
[[ "${__VENV_SOURCED_LIST}" =~ "${THIS_SCRIPT}" ]] && return || __VENV_SOURCED_LIST="${__VENV_SOURCED_LIST} ${THIS_SCRIPT}"
echo "Sourcing: ${THIS_SCRIPT}"

# Define an array of internal functions to exclude from help and documentation
__VENV_INTERNAL_FUNCTIONS=(
    "${__VENV_INTERNAL_FUNCTIONS[@]}"
    "pip"
    "conda"
)

# Function to get the hash of a function's definition
get_function_hash() {
    declare -f "$1" | md5 | cut -d' ' -f1
}

# Define the location of the venvutil config directory
export VENVUTIL_CONFIG="${VENVUTIL_CONFIG:-${HOME}/.venvutil}"
# go ahead and create the directory recursively for the frozen VENV's for recovery.
# The config directory is it's parent, so it will get created at the same time
[[ -d ${VENVUTIL_CONFIG}/freeze ]] || mkdir -p "${VENVUTIL_CONFIG}/freeze"

do_wrapper() {
#
# do_wrapper - General wrapper function for logging specific command actions
#
# - **Purpose**:
#   - Executes a Python package maneger command with optional logging based on the specified action.
# - **Usage**:
#   - `do_wrapper <cmd> <additional parameters>`
#  - **Parameters**:
#    - cmd: The command to be executed.
#    - Additional parameters: Any additional parameters to be passed to the command.
# - **Returns**:
#   - None
#
    local cmd="$1"; shift
    local action="$1"
    local actions_to_log=("install" "uninstall" "remove" "rename" "update" "upgrade" "create" "clean" "config" "clone")
    local actions_to_exclude=("--help" "-h" "--dry-run")

    # Make the command be how the user invoked it rather than with the wrappers.
    local user_cmd=$(echo "$cmd $*" | sed 's/__venv_//g')

    # Check if the command ${cmd} is a file or a function/alias, if it has a command file,
    # we want to run it with the "command" builtin.
    if command -v ${cmd} > /dev/null 2>&1; then
        cmd="command ${cmd}"
    fi
    # Check if the action is potentially destructive and should be logged.
    if [[ " ${actions_to_log[*]} " =~ "${action}" ]] && ! [[ "$*" =~ $(IFS="|"; echo "${actions_to_exclude[*]}") ]]; then
        #set -x
        local file_date=$(date "+%Y%m%d%H%M%S")
        local cmd_date=$(date '+%Y-%m-%d %H:%M:%S')
        local freeze_dir="${VENVUTIL_CONFIG}/freeze"
        local freeze_state="${freeze_dir}/${CONDA_DEFAULT_ENV}.${file_date}.txt"
        # Freeze the state of the environment before a potentially destructive command is executed.
        command pip freeze >> "${freeze_state}"
        if ${cmd} "$@"; then
            local hist_log="${VENVUTIL_CONFIG}/${CONDA_DEFAULT_ENV}.log"
            # Logging the command invocation if it completed successfully.
            echo "# ${cmd_date}: ${user_cmd}" >> "${hist_log}"
            echo "# ${cmd_date}: $(${cmd} --version)" >> "${hist_log}"
            # The above code works for update, install, uninstall. upgrade but does not behave correctly
            # for other commands. The behaviors of these other commands is somewhat opaque. We will likely
            # need to parse yhe command line to determine what action to take in each case. This will possibly
            # require another function for logging. For now we will keep a running log of all commands in a
            # venvutil.log file in the config directory until we can enumerate all the possible actions and
            # log them correctly.
            local venvutil_log="${VENVUTIL_CONFIG}/venvutil.log"
            echo "# ${cmd_date} - ${CONDA_DEFAULT_ENV}: ${user_cmd}" >> "${venvutil_log}"
        fi
        #set +x
    else
        # Execute the command without logging.
        ${cmd} "$@"
    fi
}

# Specific wrapper function for pip
pip() {
    set > setlist.sh
    local command_line=$_
    echo "Complete Pip Command Line: ${command_line}" >&2
    do_wrapper "pip" "$@"
}

# Function to check if conda definition changed and re-hook if necessary
__venv_conda_check() {
    current_hash=$(get_function_hash conda)
    if [[ "${current_hash}" != "${__venv_conda_hash}" ]]; then
        # Capture the current conda function definition and assign it to __venv_conda
        eval "__venv_conda() $(declare -f conda | sed '1d')"

        # Redefine the conda function to include the wrapper
        conda() {
            do_wrapper "__venv_conda" "$@"
        }

        # Set the hash to be the new conda function.
        __venv_conda_hash=$(get_function_hash conda)
    fi
}

# Initial hash of the Conda function. Must always  new hash after defining.
__venv_conda_hash=$(get_function_hash conda)

# Run through the conda check function to ensure the conda function is wrapped
__venv_conda_check

# Modify the PROMPT_COMMAND to continuously check for function `conda` changes
__venv_prompt_command="${PROMPT_COMMAND}"
PROMPT_COMMAND="__venv_conda_check; ${PROMPT_COMMAND}"
