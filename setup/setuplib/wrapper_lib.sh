#!/usr/bin/env bash
# # Script: wrapper_lib.sh
# `wrapper_lib.sh` - Python Package Manager Wrapper Functions
# ## Description
# - **Purpose**:
#   - Provides enhanced functionality for managing Python package commands by wrapping pip and conda.
#   - Intercepts and logs changes to virtual environments for rollback, auditing, and future use in venvdiff or vdiff.
# ## Usage
#   - Source this script in your command line environment to import the wrapper functions.
#   - For example, in another script: `source wrapper_lib.sh`.
# ## Features
#   - Saves a `pip freeze` before any potentially destructive changes to a virtual environment.
#   - Logs the complete command line to a log file for both conda and pip.
#   - Persists logs in the `$HOME/.venvutil` directory, even after virtual environments are deleted.
# ## Dependencies
#   - Requires Bash and the Python package managers pip and conda.
# ## Exceptions
#   - Some functions may return specific error codes or print error messages to STDERR.
#   - Refer to individual function documentation for details.

## Initialization
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
if ! declare -p __VENV_SOURCED >/dev/null 2>&1; then declare -g -A __VENV_SOURCED; fi
if [[ "${__VENV_SOURCED[${THIS_SCRIPT}]:-}" == 1 ]]; then
    # echo "************************* SKIPPED SKIPPED SKIPPED SKIPPED             ************************* -----> $(basename "${THIS_SCRIPT}")" >&2
    return
fi
__VENV_SOURCED["${THIS_SCRIPT}"]=1
# echo "************************* SOURCED SOURCED SOURCED SOURCED             ************************* -----> $(basename "${THIS_SCRIPT}")" >&2

# shellcheck disable=SC2034
MY_NAME=$(basename "${THIS_SCRIPT}")
__VENV_BIN=$(dirname "$(dirname "${THIS_SCRIPT}")")
__VENV_BASE=$(dirname "${__VENV_BIN}")
__VENV_INCLUDE="${__VENV_BASE}/bin/shinclude"

# Get the init_lib.sh script
# shellcheck source=/dev/null
# source "${__VENV_INCLUDE}/init_lib.sh"

# Get the errno_lib.sh script
# source_lib errno_lib

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
    "venv_oprtaion_log"
    "get_venv_name_from_args"
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
    declare -f "$1" | md5sum | cut -d' ' -f1
}



# # Function: get_venv_name_from_args
# `get_venv_name_from_args` - Extracts the virtual environment name from command-line arguments.
#
# ## Description
# - **Purpose**:
#   - Parses a string of command-line arguments to find the virtual environment name specified with either `-n` or `-p`.
# - **Usage**:
#   - `get_venv_name_from_args [arguments_string]`
# - **Input Parameters**:
#   - `arguments_string` (string) - The command-line arguments to parse.
# - **Output**:
#   - The extracted virtual environment name.
# - **Exceptions**:
#   - None
#
get_venv_name_from_args() {
    local args="$1"
    local venv_name=""
    if [[ "$args" =~ -n[[:space:]]*([^\ ]+) ]]; then
        venv_name="${BASH_REMATCH[1]}"
    elif [[ "$args" =~ -p[[:space:]]*([^\ ]+) ]]; then
        venv_name="${BASH_REMATCH[1]}"
    fi
    echo "$venv_name"
}


# # Function: venv_operation_log
# `venv_operation_log` - Logs the details of a virtual environment operation.
#
# ## Description
# - **Purpose**:
#   - Writes detailed log entries for a virtual environment operation to both a venv-specific log file and a global venvutil log.
# - **Usage**:
#   - `venv_operation_log [status] [log_date] [venv_name] [freeze_state] [cmd] [command_line]`
# - **Input Parameters**:
#   - `status` (integer) - The exit status of the command.
#   - `log_date` (string) - The timestamp for the log entry.
#   - `venv_name` (string) - The name of the target virtual environment.
#   - `freeze_state` (string) - The path to the pip freeze output file.
#   - `cmd` (string) - The base command executed (e.g., 'pip', 'conda').
#   - `command_line` (string) - The full command line that was run.
# - **Output**:
#   - None (writes to log files).
# - **Exceptions**:
#   - None
#
venv_operation_log() {
    local status="$1"
    local log_date="$2"
    local venv_name="$3"
    local freeze_state="$4"
    local cmd="$5"
    local command_line="$6"
    
    if [[ "${status}" -eq 0 ]]; then
        log_status="Success"
    else
        log_status="Failure"
    fi

    local venv_log="${VENVUTIL_CONFIG}/log/${venv_name}.log"

    local cmd_version=
    cmd_version="$(${cmd} --version)"
    local user_info
    user_info="UID: ${UID} EUID:${EUID}) HOST: $(uname -n) CWD: ${PWD}"


    {
        echo "# ==> ${log_date} <=="
        echo "# ${log_date}: ${log_status}: ${command_line}"
        echo "# ${log_date}: Return code: $(errno "${status}")"
        echo "# ${log_date}: ${cmd_version}"
        echo "# ${log_date}: ${user_info}"
        [ ${status} -eq 0 ] && echo "# ${log_date}: State: ${freeze_state}"
    } >> "${venv_log}"

    echo "# ${log_date} - ${venv_name}: ${command_line}" >> \
        "${VENVUTIL_CONFIG}/venvutil.log"
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
    __rc__=0
    local cmd="$1"; shift
    local action="$1"
    local actions_to_log=("install" "uninstall" "remove"
                          "rename" "update" "upgrade"
                          "create" "clean" "config" "clone")
    local actions_to_exclude=("--help" "-h" "--dry-run")
    local cmd_args="$*"
    local env_vars
    env_vars=$( env | sed -E '/^SHELL=/,$d' | sed -E 's/^([A-Za-z_]+)=(.*)$/\1="\2"/' | tr '\n' ' ' )

    # Put the function back to "conda" we will set it back at the end of this function.
    # local function_line
    # function_line=$(declare -f $cmd | sed '1d')
    # if [[ -n "${function_line}" ]]; then
    #     eval "conda() ${function_line}"
    # fi

    # Make the command be how the user invoked it rather than with the wrappers.
    local user_cmd
    user_cmd=$(echo "${cmd}" "${cmd_args}" | sed 's/__venv_//g')

    # Check if the command ${cmd} is a file or a function/alias. If it's not a function,
    # we want to run it with the "command" builtin to bypass shell functions or aliases.
    if type -P "${cmd}" &>/dev/null; then
        cmd="command ${cmd}"
    fi

    local user_line="${env_vars} ${user_cmd}"

    # Check if the action is potentially destructive and should be logged. Don't log
    # --help, -h, or --dry-run.
    if [[ " ${actions_to_log[*]} " =~ ${action} ]] \
                && ! [[ "$*" =~ $(IFS="|"; echo "${actions_to_exclude[*]}") ]]; then
        local freeze_date
        freeze_date=$(date "+%Y%m%d%H%M%S")
        local freeze_dir="${VENVUTIL_CONFIG}/freeze"
        local log_date
        log_date=$(date '+%Y-%m-%d %H:%M:%S')
        local venv_name="${CONDA_DEFAULT_ENV}"

        cmd_args=$(echo "${cmd_args}" | sed -E "s#-e[[:space:]]+\.[[:space:]]*#-e \"${PWD}\" #g")

        local freeze_state
        freeze_state="${freeze_dir}/${venv_name}.${freeze_date}.txt"
        if eval " ${env_vars} ${cmd} ${cmd_args} "; then
            __rc__="$?"
            command pip freeze > "${freeze_state}"
            ln -sf "${freeze_state}" "${freeze_dir}/${venv_name}.current.txt"

            if [[ "${action}" == "create" && "${cmd_args}" =~ "--clone" ]]; then
                # Prefer -n, fallback to -p
                clone_name=$(get_venv_name_from_args "${cmd_args}")
                freeze_state="${freeze_dir}/${clone_name}.${freeze_date}.txt"
                command pip freeze > "${freeze_state}"
                ln -sf "${freeze_state}" "${freeze_dir}/${clone_name}.current.txt"
                venv_operation_log "${__rc__}" "${log_date}" "${clone_name}" "${freeze_state}" "${cmd}" "${user_line}"
            elif [[ "${action}" == "remove" ]]; then
                clone_name=$(get_venv_name_from_args "${cmd_args}")
            fi
        else
            __rc__="$?"
        fi
        # Log the primary command and venv_name (which is either the Conda default or the one created)
        venv_operation_log "${__rc__}" "${log_date}" "${venv_name}" "${freeze_state}" "${cmd}" "${user_line}"
    else
        # Execute the command without logging.
        # shellcheck disable=SC2086
        ${cmd} ${cmd_args}
        __rc__="$?"
    fi

    # In case we are running in a script and not on the command line replace conda with our function
    # __venv_conda_check

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
        local line
        line=$(declare -f conda | sed '1d')
        if [[ -n "${line}" ]]; then
            eval "__venv_conda() ${line}" 2>/dev/null
        fi
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
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('${HOME}/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
# shellcheck disable=SC2181
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
# <<< conda initialize <<<

# Modify the PROMPT_COMMAND to continuously check for function `conda` changes
__venv_prompt_command="${PROMPT_COMMAND:-}"
PROMPT_COMMAND="__venv_conda_check; ${PROMPT_COMMAND:-}"

__rc__=0

# echo "************************* EXITING EXITING EXITING EXITING             ************************* -----> $(basename "${THIS_SCRIPT}")" >&2

__venv_conda_check

return ${__rc__}