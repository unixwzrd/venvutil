#!/usr/bin/env bash
# # Script: venv_lib.sh
# `venv_lib.sh` - Virtual Environment Management Functions for Bash Scripts
# ## Description
# - **Purpose**: 
#   - This script provides a collection of functions to manage conda virtual environments.
#   - Functions include creating, deleting, switching, and cloning environments, among others.
#
# ## Usage
#  - Source this script in other bash scripts to import the virtual environment management functions.
#  - For example, in another script: `source venv_funcs.sh`.
#
# - **Input Parameters**: 
#   - None. All input is handled by the individual functions.
#
# - **Output**: 
#   - The script provides various virtual environment management functions for use in other bash scripts.
#
# - **Exceptions**: 
#   - Some functions may return specific error codes or print error messages to STDERR.
#   - Refer to individual function documentation for details.
#
# - **Internal Variables**
#   - __VENV_NUM    The sequence of the venv in a "__VENV_PREFIX" series.
#   - __VENV_PREFIX The prefix of the VENV
#   - __VENV_DESC   A very short description of the VENV.
#
# - **Functions**:
#   - `push_venv()`: Specialized push the default VENV onto the stack.
#   - `pop_venv()`: Specialized pop the VENV off the stack and decrement.
#   - `__set_venv_vars()`: Sets internal VENV variables.
#   - `snum()`: Force set the VENV Sequence number.
#   - `vpfx()`: Return the current VENV prefix.
#   - `vnum()`: Return the current VENV sequence number.
#   - `vdsc()`: Return the current VENV description.
#   - `cact()`: Change active VENV.
#   - `dact()`: Deactivate the current VENV.
#   - `pact()`: Switch to the Previous Active VENV.
#   - `lenv()`: List All Current VENVs.
#   - `lastenv()`: Retrieve the Last Environment with a Given Prefix.
#   - `benv()`: Create a New Base Virtual Environment.
#   - `nenv()`: Create a New Virtual Environment in a Series.
#   - `vren()`: Rename a Virtual Environment
#
# ## Usage Example
#   ```shellscript
#   source venv_lib.sh
#   benv myenv
#   cact myenv
#   ```
#
# ## Dependencies
#   - This script depends on the `conda` command-line tool for managing virtual environments.
#   - The `util_funcs.sh` script is also required and should be located in the same directory as this script.
#
# ## Notes
#   - This script assumes that the `conda` command is available in the system's PATH.
#   - It is recommended to source this script in other scripts rather than executing it directly.
#   - Make sure to set the appropriate permissions on this script to allow execution.
#
# ## Author
#   - Michael Sullivan <unixwzrd@unixwzrd.ai>
#   - https://unixwzrd.ai/
#   - https://github.com/unixwzrd
#   - https://github.com/unixwzrd/venvutil
#

## Initialization
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
if ! declare -p __VENV_SOURCED >/dev/null 2>&1; then declare -g __VENV_SOURCED; fi
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

# Get the helpsys_lib.sh script
# source_lib helpsys_lib

# Get the util_lib.sh script
# source_lib util_lib

# Get the wrapper_lib.sh script
# source_lib wrapper_lib

# Add internal functions to the __VENV_INTERNAL_FUNCTIONS array.
if ! declare -p __VENV_INTERNAL_FUNCTIONS >/dev/null 2>&1; then declare -ga __VENV_INTERNAL_FUNCTIONS; fi
# shellcheck disable=SC2206
__VENV_INTERNAL_FUNCTIONS=(
    ${__VENV_INTERNAL_FUNCTIONS[@]}
    "push_venv"
    "pop_venv"
    "__set_venv_vars"
)

# Initialize the stack
declare -ga __VENV_STACK=()


# # Function: push_venv
# `push_venv` - Specialized push the default VENV onto the stack.
#
# ## Description
# - **Purpose**: 
#   - Pushes the default virtual environment onto the stack.
# - **Usage**: 
#   - `push_venv`
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Modifies the stack to include the current environment.
# - **Exceptions**: 
#   - None
#
push_venv() {
    push_stack __VENV_STACK "${CONDA_DEFAULT_ENV}"
}

# # Function: pop_venv
# `pop_venv` - Specialized pop the VENV off the stack and decrement.
#
# ## Description
# - **Purpose**: 
#   - Pops the virtual environment off the stack and decrements.
# - **Usage**: 
#   - `pop_venv`
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Modifies the stack to remove the current environment.
# - **Exceptions**: 
#   - None
#
pop_venv() {
    local stack_value
    pop_stack __VENV_STACK
    # shellcheck disable=SC2154
    echo "${__sv__}"
    return "${__rc__}"
}

# # Function: __set_venv_vars
# `__set_venv_vars` - Sets internal VENV variables.
#
# ## Description
# - **Purpose**: 
#   - Sets internal variables related to virtual environment management.
# - **Usage**: 
#   - `__set_venv_vars`
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Initializes internal VENV variables.
# - **Exceptions**: 
#   - None
#
__set_venv_vars() {
    __VENV_PREFIX=$(echo "$*" | cut -d '.' -f 1)
    __VENV_DESC=$(echo "$*" | cut -d '.' -f 3-) &&  __VENV_NUM=$(echo "$*" | cut -d '.' -f 2)
}

# # Function: snum
# `snum` - Force set the VENV Sequence number.
#
# ## Description
# - **Purpose**: 
#   - Forces the setting of the VENV sequence number.
# - **Usage**: 
#   - `snum [number]`
# - **Input Parameters**: 
#   - `number` (integer) - The sequence number to set.
# - **Output**: 
#   - Updates the sequence number for the current VENV.
# - **Exceptions**: 
#   - None
#
snum() {
    local new_num=$1
    
    # Validate that a number is actually provided
    if [ -z "${new_num}" ]; then
        echo "Error: No sequence number provided." >&2
        __rc__=1
    fi
    
    # Validate that the provided number is numeric
    if ! [[ "${new_num}" =~ ^[0-9]+$ ]]; then
        echo "Error: Sequence number must be numeric." >&2
        __rc__=1
        return ${__rc__}
    fi
    
    # Validate that the provided number is within a valid range (00-99)
    if [ "${new_num}" -lt 0 ] || [ "${new_num}" -gt 99 ]; then
        echo "Error: Sequence number must be between 00 and 99." >&2
        __rc__=1
        return ${__rc__}
    fi
    
    __VENV_NUM=$( zero_pad "${new_num}" )
}

# # Function: vpfx
# `vpfx` - Return the current VENV prefix of a sequenced set.
#
# ## Description
# - **Purpose**: 
#   - Returns the prefix of the current virtual environment.
# - **Usage**: 
#   - `vpfx`
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - The prefix of the current VENV.
# - **Exceptions**: 
#   - None
#
vpfx() {
    local env_name="$CONDA_DEFAULT_ENV"
    if [[ "$env_name" =~ ^([^.]*)\.([0-9]+)\.(.*)$ ]]; then
        echo "${BASH_REMATCH[1]}"
    fi
}

# # Function: vnum
# `vnum` - Return the current VENV sequence number.
#
# ## Description
# - **Purpose**: 
#   - Returns the sequence number of the current virtual environment.
# - **Usage**: 
#   - `vnum`
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - The sequence number of the current VENV.
# - **Exceptions**: 
#   - None
#
vnum() {
    if [[ "${__VENV_NAME}" =~ ^(.*)\.([0-9]+)\.(.*)$ ]]; then
        echo "${BASH_REMATCH[2]}"
    fi
}

# # Function: vdsc
# `vdsc` - Return the current VENV description of a sequenced set.
#
# ## Description
# - **Purpose**: 
#   - Returns the description of the current virtual environment.
# - **Usage**: 
#   - `vdsc`
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - The description of the current VENV.
# - **Exceptions**: 
#   - None
#
vdsc() {
    local env_name="$CONDA_DEFAULT_ENV"
    if [[ "$env_name" =~ ^([^.]*)\.([0-9]+)\.(.*)$ ]]; then
        echo "${BASH_REMATCH[3]}"
    fi
}

# # Function: cact
# `cact` - Change active VENV.
#
# ## Description
# - **Purpose**: 
#   - Changes the active virtual environment to the specified one.
# - **Usage**: 
#   - `cact [-h] [env_name]`
# - **Options**: 
#   - `-h`   Show this help message
#   - `-x`   Enable debug mode
# - **Input Parameters**: 
#   - `env_name` (string) - The name of the environment to activate.
# - **Output**: 
#   - Activates the specified virtual environment.
# - **Exceptions**: 
#   - Errors if the environment does not exist.
#
cact() {
    local OPTIND=1
    # Parse options
    while getopts "hx" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            x) set -x; local set_here="y" ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    local new_env="$1"

    # Validate input
    if [ -z "$1" ]; then
        echo "Error: No VENV name provided." 1>&2
        __rc__=1
        return ${__rc__}
    fi

    if [[ ${CONDA_DEFAULT_ENV} == "$new_env" ]]; then
        echo "Environment ${new_env} is already active." 1>&2
        return 0
    fi

    # Pop from stack if top of stack matches the new environment
    if [[ "${__VENV_STACK[${#__VENV_STACK[@]}]:-}" == "$new_env" ]]; then
        pop_venv
    fi

    # Set variables
    __VENV_NAME=$1
    __set_venv_vars "${__VENV_NAME}"
    __VENV_PARMS=$(echo "$*" | cut -d '.' -f 4-)
    # Push new environment to stack
    push_venv
    # Deactivate current environment
    # dact
    # Activate new environment
    echo "Activating new environment: ${__VENV_NAME}..."
    conda activate "${__VENV_NAME}" || { echo "Error: Failed to activate new environment." 1>&2; return 1; }
    if [ "${set_here:-}" == 'y' ]; then
        set +x
    fi
}

# # Function: dact
# `dact` - Deactivate the current VENV.
#
# ## Description
# - **Purpose**: 
#   - Deactivates the current virtual environment.
# - **Usage**: 
#   - `dact [-h]`
# - **Options**: 
#   - `-h`   Show this help message
#   - `-x`   Enable debug mode
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Deactivates the current VENV.
# - **Exceptions**: 
#   - None
#
dact() {
    local OPTIND=1
    # Parse options
    while getopts "hx" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            x) set -x; local set_here="y" ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    local stack_value

    if [ -z "${CONDA_DEFAULT_ENV}" ]; then
        echo "No conda environment is currently activated." 1>&2
        __rc__=1
        return ${__rc__}
    fi
    
    # Check if the environment actually exists
    if ! conda info --envs | awk '{print $1}' | grep -q -w "${CONDA_DEFAULT_ENV}"; then
        echo "Warning: The environment ${CONDA_DEFAULT_ENV} does not exist. It might have been renamed or deleted." 1>&2
        # Optionally pop from stack
        if [[ "${__VENV_STACK[-1]}" == "${CONDA_DEFAULT_ENV}" ]]; then
            pop_venv
        fi
        return 17
    fi

    echo "Deactivating: ${CONDA_DEFAULT_ENV}" 1>&2
    conda deactivate
    pop_venv
    # shellcheck disable=SC2034
    stack_value="${__sv__}"
    if [ "${set_here:-}" == 'y' ]; then
        set +x
    fi
    return "${__rc__}"
}

# # Function: pact
# `pact` - Switch to the Previous Active VENV.
#
# ## Description
# - **Purpose**: 
#   - Switches to the previous active virtual environment.
# - **Usage**: 
#   - `pact [-h]`
# - **Options**: 
#   - `-h`   Show this help message
#   - `-x`   Enable debug mode
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Activates the previous VENV.
# - **Exceptions**: 
#   - Errors if no previous environment exists.
#
pact() {
    local OPTIND=1

    # Parse options
    while getopts "hx" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            x) set -x; local set_here="y" ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    pop_venv
    local previous_env="${__sv__}"

    # Change to previous VENV
    if [ $? -eq 0 ]; then
        cact "$previous_env"
        pop_venv > /dev/null
    else
        echo "No previous environment to switch to."
    fi
    if [ "${set_here:-}" == 'y' ]; then
        set +x
    fi
}

# # Function: lenv
# `lenv` - List All Current VENVs with last modification date.
#
# ## Description
# - **Purpose**: 
#   - Lists all the currently available conda virtual environments in alphabetical order with
#     their last modification date.
#   - Options are available to sort by last update time from oldest to newest.
#   - Options are available to reverse the sort order for either time or name.
# - **Usage**: 
#   - `lenv [[-l] [-t] [-r] [-h]]`
# - **Options**: 
#       - `-l`   Display last modification date and time
#       - `-t`   Sort by last update time
#       - `-r`   Reverse the sort order
#       - `-h`   Show this help message
#       - `-x`   Enable debug mode
# - **Output**: 
#   - A list of all existing conda virtual environments with their last modification date.
#   - The active environment is marked with an asterisk.
#   ```bash
#   2024-11-30    pa1                                  ~/miniconda3/envs/pa1
#   2024-11-30    pa1..base-3-10                     * ~/miniconda3/envs/pa1..base-3-10
#   2024-11-30    seq311.00.case-analytics             ~/miniconda3/envs/seq311.00.case-analytics
#   2024-12-05    pa1.00.case-analytics                ~/miniconda3/envs/pa1.00.case-analytics
#   ```
# - **Exceptions**: 
#   - If no environments are available, the output from `conda info -e` will indicate this.
#
lenv() {
    local sort_by_time=false
    local sort_opts=""
    local time_opts=" "
    local sort_key="3"
    local date_spacing="11"
    local OPTIND=1

    # Parse options
    while getopts "ltrhx" opt; do
        case $opt in
            t) sort_by_time=true ;;
            r) sort_opts="-r" ;;
            l) time_opts="."; sort_key="3"; date_spacing="20";;
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            x) set -x; local set_here="y" ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    # Get environment info excluding comments
    local envs_info
    envs_info=$(conda info --envs | grep -E -v '^#' )

    # Create a temporary file for sorting
    local temp_file
    temp_file=$(mktemp)

    # Collect max field lengths for consistent formatting
    local max_name_len=11
    local max_python_len=0

    while IFS= read -r line; do
        local env_name env_path modification_date python_version marker

        # Extract environment name and path
        env_name=$(echo "$line" | awk '{print $1}')
        [ -z "$env_name" ] && continue

        env_path=$(echo "$line" | awk '{print $NF}') # Last column

        # Get modification date
        modification_date="N/A"
        [ -d "$env_path" ] && modification_date=$(stat -c "%y" "$env_path" | cut -d"${time_opts}" -f1)

        # Get Python version if available
        python_version="Unknown"
        if [ -d "$env_path" ]; then
            python_version=$("$env_path"/bin/python --version 2>&1)
            python_version=${python_version#* }
            python_version=${python_version%% *}
        fi

        # Track max lengths for formatting
        (( ${#env_name} > max_name_len )) && max_name_len=${#env_name}
        (( ${#python_version} > max_python_len )) && max_python_len=${#python_version}

        # Replace $HOME at the beginning with `~`
        env_path=${env_path/#$HOME/\~}

        # Check if active environment
        marker=" "
        [[ "$line" == *\** ]] && marker="*"

        # Store formatted data in temp file for sorting
        echo "$modification_date|$python_version|$env_name|$marker|$env_path" >> "$temp_file"
    done <<< "$envs_info"

    # Adjust column spacing
    max_name_len=$(( max_name_len + 2 ))
    max_python_len=$(( max_python_len + 1 ))

    # Print header
    printf "%-${date_spacing}s %-${max_python_len}s %-${max_name_len}s %s  %s\n" \
        "Date" "Python" "Environment" " " "Path"

    # Sort and format output after sorting
    {
        if $sort_by_time; then
            sort -t '|' -n $sort_opts "$temp_file"
        else
            sort -t '|' -k ${sort_key} $sort_opts "$temp_file"
        fi
    } | while IFS='|' read -r mod_date py_ver env_name mark env_path; do
        printf "%-${date_spacing}s %-${max_python_len}s %-${max_name_len}s %s %s\n" \
            "$mod_date" "$py_ver" "$env_name" "$mark" "$env_path"
    done

    rm "$temp_file"

    if [ "${set_here:-}" == 'y' ]; then
        set +x
    fi 
}

# # Function: lastenv
# `lastenv` - Retrieve the Last Environment with a Given Prefix.
#
# ## Description
# - **Purpose**: 
#   - Retrieves the last environment with a specified prefix.
# - **Usage**: 
#   - `lastenv [prefix]`
# - **Input Parameters**: 
#   - `prefix` (string) - The prefix to search for.
# - **Output**: 
#   - The name of the last environment with the given prefix.
# - **Exceptions**: 
#   - None
#
lastenv() {
    local prefix="$1"
    local last_env
    last_env=$(lenv | grep -E "^${prefix}." | tail -1 | cut -d " " -f 1)
    echo "${last_env}"
}

# # Function: benv
# `benv` - Create a New Base Virtual Environment.
#
# ## Description
# - **Purpose**: 
#   - Creates a new base conda virtual environment and activates it.
#   - If no packages specified, creates environment with latest Python and pip.
# - **Usage**: 
#   - `benv [-h] ENV_NAME [PACKAGES...] [OPTIONS...]
# - **Options**: 
#   - `-h`   Show this help message
#   - `-x`   Enable debug mode
# - **Input Parameters**: 
#   - `ENV_NAME` (string) - The name of the new environment to create.
#   - `PACKAGES` (string, optional) - Packages to install. Defaults to latest Python and pip.
#   - `OPTIONS` (string, optional) - Additional options to pass to `conda create`.
# - ** Examples**: 
#   - `benv pa1` - Creates env with latest Python and pip
#   - `benv pa1 python=3.11 numpy pandas` - Creates env with specific packages
#   - `benv pa1 -c conda-forge python=3.11` - Uses conda-forge channel
# - **Output**: 
#   - Creates and activates the new environment.
# - **Exceptions**: 
#   - Errors during environment creation are handled by conda.
#
benv() {
    local OPTIND=1
    # Parse options
    while getopts "hx" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            x) set -x; local set_here="y" ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    # Check for environment name
    if [ -z "$1" ]; then
        echo "Error: Environment name is required" >&2
        vhelp "${FUNCNAME[0]}"
        return 1
    fi

    local env_name="$1"; shift
    local packages="$*"

    # If no packages specified, use latest Python and pip
    if [ -z "$packages" ]; then
        echo "Warning: No packages specified. Creating environment with latest Python." >&2
        packages="python"
    fi

    echo "Creating base virtual environment ${env_name} with packages: ${packages}"
    conda create -n "${env_name}" ${packages} -y || {
        echo "Error: Failed to create environment ${env_name}" >&2
        __rc__=1
        return "${__rc__}"
    }

    echo "Base environment created - activating ${env_name}"
    cact "${env_name}"
    if [ "${set_here:-}" == 'y' ]; then
        set +x
    fi
}

# # Function: nenv
# `nenv` - Create a New Virtual Environment in a Series.
#
# ## Description
# - **Purpose**: 
#   - Creates a new conda virtual environment in a series identified by a prefix as a clone of the current venv.
# - **Usage**: 
#   - `nenv [-h] PREFIX [EXTRA_OPTIONS]`
# - **Options**: 
#   - `-h`   Show this help message
#   - `-x`   Enable debug mode
# - **Input Parameters**: 
#   - `PREFIX` (string) - The prefix to identify the series of environments.
#   - `EXTRA_OPTIONS` (string, optional) - Additional options to pass to the environment creation.
# - **Output**: 
#   - Creates and activates the new environment with sequence number "00".
# - **Exceptions**: 
#   - Errors during environment creation are handled by conda.
#
nenv() {
    local OPTIND=1
    # Parse options
    while getopts "hx" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            x) set -x; local set_here="y" ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    local prefix="$1"; shift
    local extra_options="$*"

    [ -z "${prefix}" ] && {
        echo "Error: Prefix is required." >&2
        __rc__=1
        return ${__rc__}
    }

    # Reset the sequence number to start from "00"
    __VENV_NUM=""
    # Set the global prefix
    __VENV_PREFIX="${prefix}"
    # Create a clone of the base environment
    ccln "base"
    if [ "${set_here:-}" == 'y' ]; then
        set +x
    fi
}

# # Function: denv
# `denv` - Delete a Virtual Environment.
#
# ## Description
# - **Purpose**: 
#   - Deletes the specified virtual environment.
# - **Usage**: 
#   - `denv [-h] [env_name]`
# - **Options**: 
#   - `-h`   Show this help message
#   - `-x`   Enable debug mode
# - **Input Parameters**: 
#   - `env_name` (string) - The name of the environment to delete.
# - **Output**: 
#   - Deletes the specified environment.
# - **Exceptions**: 
#   - Errors if the environment does not exist.
#
denv() {
    local OPTIND=1
    # Parse options
    while getopts "hx" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            x) set -x; local set_here="y" ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    local env_to_delete="$1"

    if [ -z "${env_to_delete}" ]; then
        echo "Error: Environment name is required for deletion." >&2
        __rc__=1
        return ${__rc__}
    fi

    echo "Removing environment -> ${env_to_delete}"
    conda remove --all -n "${env_to_delete}" -y
    if [ "${set_here:-}" == 'y' ]; then
        set +x
    fi
}

# # Function: renv
# `renv` - Revert to Previous Virtual Environment.
#
# ## Description
# - **Purpose**: 
#   - Deactivates the current active environment, deletes it, and then re-activates the previously active environment.
# - **Usage**: 
#   - `renv [-h]`
# - **Options**: 
#   - `-h`   Show this help message
#   - `-x`   Enable debug mode
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Removes the current environment and reverts to the previous one.
# - **Exceptions**: 
#   - Errors during deactivation or deletion are handled by conda.
#
renv() {
    local OPTIND=1
    # Parse options
    while getopts "hx" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            x) set -x; local set_here="y" ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    local env_to_delete=${CONDA_DEFAULT_ENV}
    local previous_env=${__VENV_PREV}

    if [ -z "${env_to_delete}" ]; then
        echo "Error: No active environment to remove." >&2
        __rc__=1
        return ${__rc__}
    fi

    if [ -z "${previous_env}" ]; then
        echo "Warning: No previous environment to revert to. Reverting to base environment." >&2
        previous_env="base"
    fi

    dact  # Deactivate the current environment
    denv "${env_to_delete}"  # Delete the environment
    cact "${previous_env}"  # Reactivate the previous environment
    if [ "${set_here:-}" == 'y' ]; then
        set +x
    fi
}

# # Function: ccln
# `ccln` - Clone current Virtual Environment
#
# ## Description
# - **Purpose**: 
#   - Clones the current Virtual Environment to a new environment. It will
#     increment the sequence number if it is not already set. If there is no
#     sequence number, none will be added and the new environment will be named
#     the new environment will have the specified name.
# - **Usage**: 
#   - `ccln [-h] [new_env_name]`
# - **Options**: 
#   - `-h`   Show this help message
#   - `-x`   Enable debug mode
# - **Input Parameters**: 
#   - `new_env_name` (string) - The name of the new cloned environment.
# - **Output**: 
#   - Creates a clone of the specified environment.
# - **Exceptions**: 
#   - Errors if the source environment does not exist.
#
ccln() {
    local OPTIND=1
    # Parse options
    while getopts "hx" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            x) set -x; local set_here="y" ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    # Check if current environment exists
    if [ -z "${CONDA_DEFAULT_ENV}" ]; then
        echo "Error: No active environment to clone" >&2
        __rc__=1
        return ${__rc__}
    fi

    # Require a name/description for the new environment
    if [ -z "$1" ]; then
        echo "Error: New environment name/description is required" >&2
        __rc__=1
        return ${__rc__}
    fi

    local new_name
    local current_num
    current_num=$(vnum)

    if [ -n "${current_num}" ]; then
        # Current env has a sequence number, maintain the pattern
        __VENV_NUM=$(next_step "${current_num}")
        __VENV_DESC="$1"
        new_name="${__VENV_PREFIX}.${__VENV_NUM}.${__VENV_DESC}"
    else
        # No sequence number in current env, use plain name
        new_name="$1"
    fi

    # Clone the VENV
    conda create --clone "${CONDA_DEFAULT_ENV}" -n "${new_name}" -y || return $?

    # Switch to the newly created VENV
    cact "${new_name}"

    if [ "${set_here:-}" == 'y' ]; then
        set +x
    fi
}

# # Function: vren
# `vren` - Rename a Virtual Environment.
#
# ## Description
# - **Purpose**: 
#   - Renames a virtual environment and makes that environment current.
# - **Usage**: 
#   - `vren [-h] [new_name]`
# - **Options**: 
#   - `-h`   Show this help message
#   - `-x`   Enable debug mode
# - **Input Parameters**: 
#   - `old_name` (optional string) - The current name of the environment or 
#     the current environment if not specified.
#   - `new_name` (string) - The new name of the environment.
# - **Output**: 
#   - Renames the specified environment.
# - **Exceptions**: 
#   - Errors if the environment does not exist.
#
vren() {
    local OPTIND=1
    # Parse options
    while getopts "hx" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            x) set -x; local set_here="y" ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    local old_name new_name

    # Handle argument cases
    if [ $# -eq 0 ]; then
        echo "Error: A new name is required to rename the environment." >&2
        return 22  # EINVAL
    elif [ $# -eq 1 ]; then
        old_name="${CONDA_DEFAULT_ENV}"
        new_name="$1"
    else
        old_name="$1"
        new_name="$2"
    fi

    # Check if old environment exists
    if ! conda env list | grep -q "^${old_name} "; then
        echo "Error: Environment '${old_name}' does not exist." >&2
        __rc__=2  # ENOENT
        return ${__rc__}
    fi

    # Check if trying to rename to same name
    if [ "${new_name}" = "${old_name}" ]; then
        echo "Error: Cannot rename environment to itself." >&2
        __rc__=1  # EPERM
        return ${__rc__}
    fi

    # Check if new name already exists
    if conda env list | grep -q "^${new_name} "; then
        echo "Error: Environment '${new_name}' already exists." >&2
        __rc__=17  # EEXIST
        return ${__rc__}
    fi

    # If renaming current environment, deactivate it first
    if [ "${old_name}" = "${CONDA_DEFAULT_ENV}" ]; then
        if ! dact; then
            __rc__=$?
            return ${__rc__}
        fi
    fi

    # Perform the rename
    echo "Renaming environment '${old_name}' to '${new_name}'..."
    conda rename -n "${old_name}" "${new_name}" || {
        __rc__=$?
        echo "Error: Failed to rename environment." >&2
        return ${__rc__}
    }

    # Activate the renamed environment
    cact "${new_name}"

    __rc__=$?

    if [ "${set_here:-}" == 'y' ]; then
        set +x
    fi
    return ${__rc__}
}

# # Function: venvdiff
# `venvdiff` - Compare Two Virtual Environments.
#
# ## Description
# - **Purpose**: 
#   - Compares two virtual environments and lists differences.
# - **Usage**: 
#   - `venvdiff [-h] [env1] [env2]`
# - **Options**: 
#   - `-h`   Show this help message
#   - `-x`   Enable debug mode
# - **Input Parameters**: 
#   - `env1` (string) - The first environment to compare.
#   - `env2` (string) - The second environment to compare.
# - **Output**: 
#   - Lists the differences between the two environments.
# - **Exceptions**: 
#   - Errors if either environment does not exist.
#
vdiff() {
    local OPTIND=1
    # Parse options
    while getopts "hx" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            x) set -x; local set_here="y" ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    # Check that two arguments are provided
    if [ "$#" -ne 2 ]; then
        echo "Usage: venvdiff [-h] env1 env2" >&2
        __rc__=1
        return ${__rc__}
    fi

    local env1=$1
    local env2=$2

    # Activate the first environment and get the list of packages
    cact "${env1}" > /dev/null
    local env1_packages
    env1_packages=$(pip list | tail -n +1)
    dact > /dev/null

    cact "${env2}" > /dev/null
    local env2_packages
    env2_packages=$(pip list | tail -n +1)
    dact > /dev/null

    echo "Comparing packages in $env1 and $env2:"
    diff -y <(echo "$env1_packages") <(echo "$env2_packages")

    if [ "${set_here:-}" == 'y' ]; then
        set +x
    fi
}


__rc__=0
return ${__rc__}