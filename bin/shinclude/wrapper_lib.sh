#!/usr/bin/env bash
# # Script: wrapper_lib.sh
# `wrapper_lib.sh` - Python Package Manager Wrapper Functions
# ## Description
# - **Purpose**: 
#   - Provides enhanced functionality for managing Python package commands by wrapping pip and conda.
#   - Intercepts and logs changes to virtual environments for rollback, auditing, and future use in venvdiff or vdiff.
# - **Usage**: 
#   - Source this script in your command line environment to import the wrapper functions.
#   - For example, in another script: `source wrapper_lib.sh`.
# - **Features**:
#   - Saves a `pip freeze` before any potentially destructive changes to a virtual environment.
#   - Logs the complete command line to a log file for both conda and pip.
#   - Persists logs in the `$HOME/.venvutil` directory, even after virtual environments are deleted.
# - **Dependencies**: 
#   - Requires Bash and the Python package managers pip and conda.
# - **Exceptions**: 
#   - Some functions may return specific error codes or print error messages to STDERR.
#   - Refer to individual function documentation for details.

## Initialization
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
if ! declare -p __VENV_SOURCED >/dev/null 2>&1; then declare -gA __VENV_SOURCED; fi
if [[ "${__VENV_SOURCED[${THIS_SCRIPT}]:-}" == 1 ]]; then 
    # echo "************************* SKIPPED SKIPPED SKIPPED SKIPPED             ************************* -----> $(basename "${THIS_SCRIPT}")" >&2
    return 
fi
__VENV_SOURCED["${THIS_SCRIPT}"]=1

# shellcheck disable=SC2034
MY_NAME=$(basename "${THIS_SCRIPT}")
__VENV_BIN=$(dirname "$(dirname "${THIS_SCRIPT}")")
__VENV_BASE=$(dirname "${__VENV_BIN}")
__VENV_INCLUDE="${__VENV_BASE}/bin/shinclude"

# Get the init_lib.sh script
# shellcheck source=/dev/null
source "${__VENV_INCLUDE}/init_lib.sh"

# Get the errno_lib.sh script
source_lib errno_lib

# Add internal functions to the __VENV_INTERNAL_FUNCTIONS array.
if ! declare -p __VENV_INTERNAL_FUNCTIONS >/dev/null 2>&1; then declare -ga __VENV_INTERNAL_FUNCTIONS; fi
# Quote to prevent word splitting/globbing, or split robustly with mapfile or read -a.
# shellcheck disable=SC2206
__VENV_INTERNAL_FUNCTIONS=(
    ${__VENV_INTERNAL_FUNCTIONS[@]}
    "pip"
    "conda"
    "get_function_hash"
    "__venv_conda_check"
)

# # Function: get_function_hash
# `get_function_hash` - Get the hash of a function's definition.
#
# ## Description
# - **Purpose**: 
#   - Computes the hash of a function's definition for integrity checks.
# - **Usage**: 
#   - `get_function_hash [function_name]`
# - **Input Parameters**: 
#   - `function_name` (string) - The name of the function to hash.
# - **Output**: 
#   - The hash of the function's definition.
# - **Exceptions**: 
#   - None
#
get_function_hash() {
    declare -f "$1" | md5 | cut -d' ' -f1
}

# Define the location of the venvutil config directory
export VENVUTIL_CONFIG="${VENVUTIL_CONFIG:-${HOME}/.venvutil}"
# Create the directory recursively for the frozen VENV's for recovery.
mkdir -p "${VENVUTIL_CONFIG}/freeze" "${VENVUTIL_CONFIG}/log"

# # Function: do_wrapper
# `do_wrapper` - General wrapper function for logging specific command actions.
#
# ## Description
# - **Purpose**: 
#   - Executes a Python package manager command with optional logging based on the specified action.
# - **Usage**: 
#   - `do_wrapper <cmd> <additional parameters>`
# - **Input Parameters**: 
#   - `cmd` (string) - The command to be executed.
#   - `additional parameters` (string) - Any additional parameters to be passed to the command.
# - **Output**: 
#   - None
# - **Exceptions**: 
#   - None
#
do_wrapper() {
    local cmd="$1"; shift
    local action="$1"
    local actions_to_log=("install" "uninstall" "remove"
                          "rename" "update" "upgrade"
                          "create" "clean" "config" "clone")
    local actions_to_exclude=("--help" "-h" "--dry-run")
    local cmd_args="$*"
    local env_vars
    env_vars=$( env | sed -E '/^SHELL=/,$d' | sed -E 's/^([A-Za-z_]+)=(.*)$/\1="\2"/' | tr '\n' ' ' )

    # Put the function back to "conda" our PROMPT_COMMAND will put it back after the command
    eval "conda() $(declare -f __venv_conda| sed '1d')"

    # Make the command be how the user invoked it rather than with the wrappers.
    local user_cmd
    user_cmd=$(echo "${cmd}" "${cmd_args}" | sed 's/__venv_//g')

    # Check if the command ${cmd} is a file or a function/alias. If it's not a function,
    # we want to run it with the "command" builtin to bypass shell functions or aliases.
    if type -P "${cmd}" &>/dev/null; then
        cmd="command ${cmd}"
    fi

    # local cmd_line="${env_vars} ${cmd} ${cmd_args}"
    local user_line="${env_vars} ${user_cmd}"

    # Check if the action is potentially destructive and should be logged. Don't log
    # --help, -h, or --dry-run.
    if [[ " ${actions_to_log[*]} " =~ ${action} ]] \
                && ! [[ "$*" =~ $(IFS="|"; echo "${actions_to_exclude[*]}") ]]; then
        local log_date
        local freeze_date
        log_date=$(date '+%Y-%m-%d %H:%M:%S')
        freeze_date=$(date "+%Y%m%d%H%M%S")
        local venv_log_dir="${VENVUTIL_CONFIG}/log"
        local venvutil_log="${VENVUTIL_CONFIG}/venvutil.log"
        local venv_history_log="${venv_log_dir}/${CONDA_DEFAULT_ENV}.log"
        local freeze_dir="${VENVUTIL_CONFIG}/freeze"
        local freeze_state="${freeze_dir}/${CONDA_DEFAULT_ENV}.${freeze_date}.txt"

        # Freeze the state of the environment before a potentially destructive command is executed.
        command pip freeze > "${freeze_state}"
        if eval " ${env_vars} ${cmd} ${cmd_args} "; then
            # Logging the command invocation if it completed successfully.
            {
                echo "# ${log_date}: Success - preference state: ${freeze_state}"
                echo "# ${log_date}: ${user_line}"
                echo "# ${log_date}: Current working directory: ${PWD}"
                echo "# ${log_date}: $(${cmd} --version)"
            } >> "${venv_history_log}"
            echo "# ${log_date} - ${CONDA_DEFAULT_ENV}: ${user_line}" >> "${venvutil_log}"
            # Freeze it again to get the current state, after any potentially destructive command
            # is executed. Sleep 2 second to ensure the filename is unique.
            sleep 2
            freeze_date=$(date "+%Y%m%d%H%M%S")
            freeze_state="${freeze_dir}/${CONDA_DEFAULT_ENV}.${freeze_date}.txt"
            command pip freeze > "${freeze_state}"
            echo "# ${log_date}: Success - post-freeze state: ${freeze_state}" >> \
                    "${venv_history_log}"
            # Make a symlink so the current state is always up-to-date.
            ln -sf "${freeze_state}" "${freeze_dir}/${CONDA_DEFAULT_ENV}.current.txt"
        else
            # Cleanup and log the failure and preserve the return code
            __rc__="$?"
            {
                echo "# ${log_date}: Command failure: $(errno ${__rc__})"
                echo "# ${log_date}: ${user_line}"
                echo "# ${log_date}: Current working directory: ${PWD}"
                echo "# ${log_date}: $(${cmd} --version)"
            } >> "${venv_history_log}"
            echo "# ${log_date} - ${CONDA_DEFAULT_ENV}: ${user_line}" >> "${venvutil_log}"
            echo "# ${log_date}: Command failed with return code $(errno ${__rc__})" >> \
                    "${venv_history_log}"
            rm "${freeze_state}"

        fi
    else
        # Execute the command without logging.
        # shellcheck disable=SC2086
        ${cmd} ${cmd_args}
        __rc__="$?"
    fi

    return "${__rc__}"
}

# # Function: pip
# `pip` - Wrapper function for pip commands.
#
# ## Description
# - **Purpose**: 
#   - Wraps pip commands to ensure environment variables are preserved. provides logging
#     for pip commands and the virtual environment affected
# - **Usage**: 
#   - `pip [arguments]`
# - **Input Parameters**: 
#   - `arguments` (string) - Arguments to pass to pip.
# - **Output**: 
#   - Executes the pip command with the provided arguments.
# - **Exceptions**: 
#   - None
#
pip() {
    do_wrapper pip "$@"
}

# # Function: __venv_conda_check
# `__venv_conda_check` - Ensure conda function is wrapped and check for definition changes.
#
# ## Description
# - **Purpose**: 
#   - Checks if the conda function definition has changed and re-hooks if necessary. Replaces
#     the conda function with a wrapper that logs the command and environment affected.
# - **Usage**: 
#   - `__venv_conda_check`
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Ensures the conda function is wrapped correctly.
# - **Exceptions**: 
#   - None
#
__venv_conda_check() {
    local current_hash
    current_hash=$(get_function_hash conda)
    if [[ "${current_hash}" != "${__venv_conda_hash:-}" ]]; then
        # Capture the current conda function definition and assign it to __venv_conda
        eval "__venv_conda() $(declare -f conda | sed '1d')" 2>/dev/null
        # Redefine the conda function to include the wrapper
        conda() {
            do_wrapper "__venv_conda" "$@"
        }
        # Set the hash to be the new conda function.
        __venv_conda_hash=$(get_function_hash conda)
    fi
}


if ! declare -p __venv_conda_hash >/dev/null 2>&1; then declare -g __venv_conda_hash; fi
# Run through the conda check function to ensure the conda function is wrapped
__venv_conda_check

# Initial hash of the Conda function. Must always update with new hash after defining.
__venv_conda_hash=$(get_function_hash conda)

# Modify the PROMPT_COMMAND to continuously check for function `conda` changes
__venv_prompt_command="${PROMPT_COMMAND:-}"
PROMPT_COMMAND="__venv_conda_check; ${PROMPT_COMMAND:-}"

__rc__=0
return ${__rc__}
