#!/usr/bin/env bash
# # Script: init_lib.sh
# `init_lib.sh` - Library Initialization and Environment Setup
#
# ## Description
# - **Purpose**: 
#   - Initializes the environment for bash scripting, particularly in the context of managing virtual environments. It sets up the necessary environment and sources utility scripts required for the proper functioning of other scripts in the system. It is responsible for orchestrating the environment setup in the correct order and can also be used to source additional environment or setup scripts as required, such as `.env.local` files.
# ## Usage
#   - Source this script in other bash scripts to import the necessary environment and utility
#     functions. It also contains a function that can be called to perform environment setup tasks
#     in user scripts. To use it, include the following line in your bash scripts:
#     ```bash
#     source /path/to/init_lib.sh
#     ```
# ## Input Parameters
#   - None. The script operates without requiring any input parameters.
# ## Output
#   - Sets up the environment, sources utility scripts, and prepares the system for managing virtual environments.
# ## Exceptions
#   - Exits with code 1 if it fails to find any of the required scripts or if any part of the
#     initialization process fails.
#
# ## Dependencies
# - Utility scripts located in `__VENV_INCLUDE`:
#   - `util_lib.sh`
#   - `helpsys_lib.sh`
#   - `errno_lib.sh`
#   - `venv_lib.sh`
#   - `wrapper_lib.sh`
# - Conda environment

## Initialization
[[ -L "${BASH_SOURCE[0]}" ]] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
# Guard against re-sourcing init_lib.sh
if ! declare -p __VENV_SOURCED >/dev/null 2>&1; then declare -g -A __VENV_SOURCED; fi
if [[ "${__VENV_SOURCED[${THIS_SCRIPT}]:-}" == 1 ]]; then 
    # echo "************************* SKIPPED SKIPPED SKIPPED SKIPPED             ************************* -----> $(basename "${THIS_SCRIPT}")" >&2
    return 
fi
# Mark this script as sourced
__VENV_SOURCED[${THIS_SCRIPT}]=1
# echo "************************* SOURCED SOURCED SOURCED SOURCED             ************************* -----> $(basename "${THIS_SCRIPT}")" >&2

# Extract script name, directory, and arguments
declare -g __VENV_BIN
declare -g __VENV_BASE
declare -g __VENV_ARGS=$*
MY_NAME=$(basename "${THIS_SCRIPT}")
__VENV_BIN=$(dirname "$(dirname "${THIS_SCRIPT}")")
__VENV_BASE=$(dirname "${__VENV_BIN}")
__VENV_INCLUDE="${__VENV_BASE}/bin/shinclude"

# Add internal functions to the __VENV_INTERNAL_FUNCTIONS array.
if ! declare -p __VENV_INTERNAL_FUNCTIONS >/dev/null 2>&1; then declare -ga __VENV_INTERNAL_FUNCTIONS; fi
# Quote to prevent word splitting/globbing, or split robustly with mapfile or read -a.
# shellcheck disable=SC2206
__VENV_INTERNAL_FUNCTIONS=(
    ${__VENV_INTERNAL_FUNCTIONS[@]}
)

# Stack value
if ! declare -p __sv__ >/dev/null 2>&1; then declare -g __sv__=0; fi
# Return code
if ! declare -p __rc__ >/dev/null 2>&1; then declare -g __rc__=0; fi


# TODO Figure out why this function does not work in the other lib scripts.
# # Function: _source_check
# `_source_check` - Guard against re-sourcing the same script
# ## Description
# - **Purpose**: 
#   - Prevents re-sourcing the same script multiple times.
# - **Usage**: 
#   - `_source_check "${BASH_SOURCE[0]}"`
# - **Input Parameters**: 
#   - `file_to_source`: The path to the script to source.
# - **Output**: 
#   - Returns 1 if the script has already been sourced, otherwise returns 0.
# - **Exceptions**: 
#   - None.
#
check_lib() {
    local filename="$1"
    [ -L "${filename}" ] && filename=$(readlink -f "${filename}")
    if [[ "${__VENV_SOURCED[${filename}]:-0}" == 1 ]]; then
        return 0
    fi
    __VENV_SOURCED[${filename}]=1
    return 1
}

_source_check() {
    local sh_lib_name="$1"

    # Resolve symlinks
    if [[ -L "${sh_lib_name}" ]]; then
        sh_lib_name=$(readlink -f "${sh_lib_name}")
    fi
    if [[ "${__VENV_SOURCED[$sh_lib_name]:-0}" == 1 ]]; then
        return 1
    fi
    __VENV_SOURCED[$sh_lib_name]=1
    return 0
}

# # Function: source_lib
#  `source_lib` - Sources a utility script from the specified directory.
# ## Description
# - **Purpose**: 
#   - Sources a utility script from the specified directory. It's a helper function used within the
#    `init_env.sh` script to modularity load additional scripts as needed.
#   - Try to locate the SH_LIB directory which contains included scripts and functions in a
#     "standard" fashion. places we could look are, in this order:
#     - $(dirname "${THIS_SCRIPT}")
#     - $(dirname "${THIS_SCRIPT}")/shinclude
#     - $HOME/shinclude
#     - $HOME/bin directory
#     - $HOME/bin/shinclude directory
#     - from the environment variable `SH_LIB`
# - **Usage**: 
#   - `source_lib "script_name"`
# - **Input Parameters**: 
#   - `script_name`: The name of the script to source (without the `.sh` extension).
# - **Output**: 
#   - Sources the specified script if found. Otherwise, outputs an error message and returns with
#     an exit code of 1.
# - **Exceptions**: 
#   - Returns with exit code 1 if the specified script is not found in the directory `__VENV_INCLUDE`.
#
source_lib() {
    local sh_lib_name="$1"
    # echo "************************* SOURCE_LIB SOURCE_LIB SOURCE_LIB SOURCE_LIB ************************* source_lib -----> ${1}" >&2
    # set | grep -E '^__VENV_SOURCED' >&2
    # set | grep -E '^BASH_SOURCE' >&2
    # Doesn't matter if this gets called with a .sh extension, we'll strip it off and put it back.
    sh_lib_name="$(basename -s .sh "$sh_lib_name").sh"
    local dirname
    [ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
    MY_NAME="$(basename "${THIS_SCRIPT}")"
    SH_LIB="${SH_LIB:-""}"

    for dirname in "${SH_LIB}" "$(dirname "${THIS_SCRIPT}")" "${THIS_SCRIPT}/shinclude" "${HOME}/shinclude" "${HOME}/bin/shinclude"; do
        [ -f "${dirname}/${sh_lib_name}" ] && { SH_LIB="${dirname}"; break; }
    done

    if [[ -z "${SH_LIB:-}" ]]; then
        cat<<_EOT_ >&2
ERROR ($MY_NAME): Could not locate \`${sh_lib_name}\` file.
ERROR ($MY_NAME): Please set install ${sh_lib_name} which came with this repository in one of
    the following locations:
        - $(dirname "${THIS_SCRIPT}")/shinclude
        - $HOME/shinclude
        - $HOME/bin/shinclude
    or set the environment variable SH_LIB to the directory containing ${sh_lib_name}

_EOT_
        errno_exit ENOENT     # (ENOENT: 2): No such file or directory
    fi
    
    # shellcheck source=/dev/null
    source "${SH_LIB}/${sh_lib_name}"
    return 
}

# Get the venvutil_lib.sh script
# source_lib venvutil_lib

__rc__=0
return ${__rc__}
