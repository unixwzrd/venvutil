#!/bin/bash

# # Script: venv_funcs.sh
#  venv_funcs.sh - Virtual Environment Management Functions for Bash Scripts
#  ## Description
#  - **Purpose**: 
#    - This script provides a collection of functions to manage conda virtual environments.
#    - Functions include creating, deleting, switching, and cloning environments, among others.
#
#  ## Usage
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
#
# - **Usage Example**:
#   ```shellscript
#   source venv_funcs.sh
#   benv myenv
#   cact myenv
#   ```
#
# - **Dependencies**: 
#   - This script depends on the `conda` command-line tool for managing virtual environments.
#   - The `util_funcs.sh` script is also required and should be located in the same directory as this script.
#
# - **Notes**:
#   - This script assumes that the `conda` command is available in the system's PATH.
#   - It is recommended to source this script in other scripts rather than executing it directly.
#   - Make sure to set the appropriate permissions on this script to allow execution.
#
# - **Author**: [Your Name]
# - **Last Modified**: [Date]
#
# - **Version**: [Version Number]
#

# Capture the fully qualified path of the sourced script
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
# Don't source this script if it's already been sourced.
[[ "${__VENV_SOURCED_LIST}" =~ "${THIS_SCRIPT}" ]] && return || __VENV_SOURCED_LIST="${__VENV_SOURCED_LIST} ${THIS_SCRIPT}"
echo "Sourcing: ${THIS_SCRIPT}"

# Extract script name, directory, and arguments
MY_NAME=$(basename ${THIS_SCRIPT})
__VENV_BIN=$(dirname "$(dirname "${THIS_SCRIPT}")")
__VENV_BASE=$(dirname "${__VENV_BIN}")
__VENV_ARGS=$*
__VENV_INCLUDE="${__VENV_BASE}/bin/shinclude"

[ -f "${__VENV_INCLUDE}/util_funcs.sh" ] && . "${__VENV_INCLUDE}/util_funcs.sh" \
    || ( echo "Could not find util_funcs.sh in INCLUDEDIR: ${__VENV_INCLUDE}" && exit 1 )

__VENV_INTERNAL_FUNCTIONS=(
    ${__VENV_INTERNAL_FUNCTIONS[@]}
    "push_venv"
    "pop_venv"
    "__set_venv_vars"
)

# This is so we can pass a return code up through sub-shells since set values are lost in subshells.
# May or may not be a good ide, but we might want to pass get the return value of our function calls,
# and not that o fthe last command that ren in the function call which may me 0 for an echo comamnd
# when it's the last command in th efunction and we want the return code of the function.
# This is something we would like where the echo sattement will return a value lik ethe last item
# poped off the stack. So instead of a sub-shell, whcih will also not return a value, we can use
# this to set the return code and exit the function passing thie to return or exit.  echo would be
# the last command in the function and we would get the return code of the function.
#
#__rc__ is internal aand is in a our function shell includes.
# It woudl be nice to come up with a fairly "automatuc" way to do this.
__rc__=0

# Initialize the stack
__VENV_STACK=()

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
    stack_value=${__sv__}
    return ${__rc__}
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
# `vpfx` - Return the current VENV prefix.
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
    if [ -z "${__VENV_PREFIX}" ]; then
        echo "Error: No VENV prefix has been set." >&2
        __rc__=1
        return ${__rc__}
    fi
    
    echo "${__VENV_PREFIX}"
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
    if [ -z "${__VENV_NUM}" ]; then
        echo "Error: No VENV sequence number has been set." >&2
        __rc__=1
        return ${__rc__}
    fi
    
    echo "${__VENV_NUM}"
}

# # Function: vdsc
# `vdsc` - Return the current VENV description.
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
    if [ -z "${__VENV_DESC}" ]; then
        echo "Error: No VENV sequence number has been set." >&2
        __rc__=1
        return ${__rc__}
    fi
    
    echo "${__VENV_DESC}"
}

# # Function: cact
# `cact` - Change active VENV.
#
# ## Description
# - **Purpose**: 
#   - Changes the active virtual environment to the specified one.
# - **Usage**: 
#   - `cact [env_name]`
# - **Input Parameters**: 
#   - `env_name` (string) - The name of the environment to activate.
# - **Output**: 
#   - Activates the specified virtual environment.
# - **Exceptions**: 
#   - Errors if the environment does not exist.
#
cact() {
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
    if [[ "${__VENV_STACK[${#__VENV_STACK[@]}]}" == "$new_env" ]]; then
        pop_venv
    fi

    # Set variables
    __VENV_NAME=$1
    __set_venv_vars ${__VENV_NAME}
    __VENV_PARMS=$(echo "$*" | cut -d '.' -f 4-)
    # Push new environment to stack
    push_venv
    # Deactivate current environment
    # dact
    # Activate new environment
    echo "Activating new environment: ${__VENV_NAME}..."
    conda activate "${__VENV_NAME}" || { echo "Error: Failed to activate new environment." 1>&2; return 1; }
}

# # Function: dact
# `dact` - Deactivate the current VENV.
#
# ## Description
# - **Purpose**: 
#   - Deactivates the current virtual environment.
# - **Usage**: 
#   - `dact`
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Deactivates the current VENV.
# - **Exceptions**: 
#   - None
#
dact() {
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
    stack_value="${__sv__}"
    return ${__rc__}
}

# # Function: pact
# `pact` - Switch to the Previous Active VENV.
#
# ## Description
# - **Purpose**: 
#   - Switches to the previous active virtual environment.
# - **Usage**: 
#   - `pact`
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Activates the previous VENV.
# - **Exceptions**: 
#   - Errors if no previous environment exists.
#
pact() {
    pop_venv
    local previous_env=${__sv__}

    # Change to previous VENV
    if [ $? -eq 0 ]; then
        cact "$previous_env"
        pop_venv > /dev/null
    else
        echo "No previous environment to switch to."
    fi
}

# # Function: lenv
# `lenv` - List All Current VENVs with last modification date.
#
# ## Description
# - **Purpose**: 
#   - Lists all the currently available conda virtual environments with their last modification date.
# - **Usage**: 
#   - `lenv`
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - A list of all existing conda virtual environments with their last modification date.
#   ```bash
#   2024-11-30    pa1                                 ~/miniconda3/envs/pa1
#   2024-11-30    pa1..base-3-10                      ~/miniconda3/envs/pa1..base-3-10
#   2024-11-30    seq311.00.case-analitics            ~/miniconda3/envs/seq311.00.case-analitics
#   2024-12-05    pa1.00.case-analytics               ~/miniconda3/envs/pa1.00.case-analytics
#   ```
# - **Exceptions**: 
#   - If no environments are available, the output from `conda info -e` will indicate this.
#
lenv() {
    # Fetch environment information
    local envs_info
    envs_info=$(conda info --envs | grep -E -v '^#')

    # Prepare a temporary file to store environment details
    local temp_file
    temp_file=$(mktemp)

    # Iterate over each environment and fetch creation date
    while IFS= read -r line; do
        local env_name env_path creation_date active_marker
        env_name=$(echo "$line" | awk '{print $1}')
        env_path=$(echo "$line" | awk '{print $NF}')

        # Fetch creation date using stat
        if [ -d "$env_path" ]; then
            creation_date=$(stat -c "%y" "$env_path" | cut -d' ' -f1)
        else
            creation_date="N/A"
        fi

        # Remove $HOME from the path
        env_path=${env_path/$HOME/\~}

        # Handle active environment marker
        if [[ "$line" == *\** ]]; then
            active_marker="*"
        else
            active_marker=" "
        fi

        # Write to temporary file
        printf "%s\t%s %s\t%s\n" "$creation_date" "$active_marker" "$env_name" "$env_path" >> "$temp_file"
    done <<< "$envs_info"

    # Display the results
    column -t -s $'\t' < "$temp_file"

    # Clean up
    rm "$temp_file"
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
    local last_env=$(lenv | grep -E "^${prefix}." | tail -1 | cut -d " " -f 1)
    echo "${last_env}"
}

# # Function: benv
# `benv` - Create a New Base Virtual Environment.
#
# ## Description
# - **Purpose**: 
#   - Creates a new base conda virtual environment and activates it.
# - **Usage**: 
#   - `benv ENV_NAME [EXTRA_OPTIONS]`
# - **Input Parameters**: 
#   - `ENV_NAME` (string) - The name of the new environment to create.
#   - `EXTRA_OPTIONS` (string, optional) - Additional options to pass to `conda create`.
# - **Output**: 
#   - Creates and activates the new environment.
# - **Exceptions**: 
#   - Errors during environment creation are handled by conda.
#
benv() {
    local env_name="$1"; shift
    local extra_options="$*"

    echo "Creating base virtual environment ${env_name} ${extra_options}"
    conda create -n "${env_name}" ${extra_options} -y || {
        echo "Error: Failed to create environment ${env_name}" >&2
        __rc__=1
        return ${__rc__}
    }

    echo "Base environment created - activating ${env_name}"
    cact "${env_name}"
}

# # Function: nenv
# `nenv` - Create a New Virtual Environment in a Series.
#
# ## Description
# - **Purpose**: 
#   - Creates a new conda virtual environment in a series identified by a prefix as a clone of the current venv.
# - **Usage**: 
#   - `nenv PREFIX [EXTRA_OPTIONS]`
# - **Input Parameters**: 
#   - `PREFIX` (string) - The prefix to identify the series of environments.
#   - `EXTRA_OPTIONS` (string, optional) - Additional options to pass to the environment creation.
# - **Output**: 
#   - Creates and activates the new environment with sequence number "00".
# - **Exceptions**: 
#   - Errors during environment creation are handled by conda.
#
nenv() {
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
}

# # Function: denv
# `denv` - Delete a Virtual Environment.
#
# ## Description
# - **Purpose**: 
#   - Deletes the specified virtual environment.
# - **Usage**: 
#   - `denv [env_name]`
# - **Input Parameters**: 
#   - `env_name` (string) - The name of the environment to delete.
# - **Output**: 
#   - Deletes the specified environment.
# - **Exceptions**: 
#   - Errors if the environment does not exist.
#
denv() {
    local env_to_delete="$1"

    if [ -z "${env_to_delete}" ]; then
        echo "Error: Environment name is required for deletion." >&2
        __rc__=1
        return ${__rc__}
    fi

    echo "Removing environment -> ${env_to_delete}"
    conda remove --all -n ${env_to_delete} -y
}

# # Function: renv
# `renv` - Revert to Previous Virtual Environment.
#
# ## Description
# - **Purpose**: 
#   - Deactivates the current active environment, deletes it, and then re-activates the previously active environment.
# - **Usage**: 
#   - `renv`
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Removes the current environment and reverts to the previous one.
# - **Exceptions**: 
#   - Errors during deactivation or deletion are handled by conda.
#
renv() {
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
    denv ${env_to_delete}  # Delete the environment
    cact ${previous_env}  # Reactivate the previous environment
}

# # Function: ccln
# `ccln` - Clone a Conda Environment.
#
# ## Description
# - **Purpose**: 
#   - Clones an existing conda environment.
# - **Usage**: 
#   - `ccln [source_env] [target_env]`
# - **Input Parameters**: 
#   - `source_env` (string) - The name of the environment to clone.
#   - `target_env` (string) - The name of the new cloned environment.
# - **Output**: 
#   - Creates a clone of the specified environment.
# - **Exceptions**: 
#   - Errors if the source environment does not exist.
#
ccln() {
    # If no description is provided, use the description of the current VENV
    if [ -z "$1" ]; then
        __VENV_DESC=$( vdsc )
    else
        __VENV_DESC=$1
    fi

    __VENV_NUM=$( next_step "$(vnum)" )
    __VENV_NAME="${__VENV_PREFIX}.${__VENV_NUM}.${__VENV_DESC}"

    # Clone the VENV
    conda create --clone "${CONDA_DEFAULT_ENV}" -n "${__VENV_NAME}" -y || return $?

    # Switch to the newly created VENV
    cact "${__VENV_NAME}"
}

# # Function: venvdiff
# `venvdiff` - Compare Two Virtual Environments.
#
# ## Description
# - **Purpose**: 
#   - Compares two virtual environments and lists differences.
# - **Usage**: 
#   - `venvdiff [env1] [env2]`
# - **Input Parameters**: 
#   - `env1` (string) - The first environment to compare.
#   - `env2` (string) - The second environment to compare.
# - **Output**: 
#   - Lists the differences between the two environments.
# - **Exceptions**: 
#   - Errors if either environment does not exist.
#
venvdiff() {
    # Check that two arguments are provided
    if [ "$#" -ne 2 ]; then
        echo "Usage: venvdiff env1 env2"
        __rc__=1
        return ${__rc__}
    fi

    local env1=$1
    local env2=$2

    # Activate the first environment and get the list of packages
    cact $env1 > /dev/null
    local env1_packages=$(pip list | tail -n +1)
    dact > /dev/null

    cact $env2 > /dev/null
    local env2_packages=$(pip list | tail -n +1)
    dact > /dev/null

    echo "Comparing packages in $env1 and $env2:"
    diff -y <(echo "$env1_packages") <(echo "$env2_packages")
}
