#!/bin/bash
#
# ## venv_funcs.sh - Virtual Environment Management Functions for Bash Scripts
#
# - **Purpose**: 
#   - This script provides a collection of functions to manage conda virtual environments.
#   - Functions include creating, deleting, switching, and cloning environments, among others.
#
# - **Usage**: 
#   - Source this script in other bash scripts to import the virtual environment management functions.
#   - For example, in another script: `source venv_funcs.sh`.
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

__rc__=0

# Initialize the stack
__VENV_STACK=()

# Specialized push the default VENV onto the stack
push_venv() {
    push_stack __VENV_STACK "${CONDA_DEFAULT_ENV}"
}

# Specialized pop the VENV off the stack and decrement.j
pop_venv() {
    local stack_value
    pop_stack __VENV_STACK
    stack_value=${__sv__}
    echo "${stack_value}"
    return ${__rc__}
}


# Sets internal VENV variables
__set_venv_vars() {
     __VENV_PREFIX=$(echo "$*" | cut -d '.' -f 1)
     __VENV_DESC=$(echo "$*" | cut -d '.' -f 3-) &&  __VENV_NUM=$(echo "$*" | cut -d '.' -f 2)
}

snum() {
#
# snum - Force set the VENV Sequence number.
#
# - **Purpose**:
#   - Force set the VENV Sequence number.
# - **Usage**: 
#   - snum NN
# - **Input Parameters**: 
#   1. `NN` (integer) - The VENV Sequence number to set. Must be a numeric value between 00 and 99.
# - **Output**: 
#   - Sets the global variable `__VENV_NUM` to the zero-padded sequence number.
#   - Prints an error message to STDERR and returns with status code 1 if unsuccessful.
# - **Exceptions**: None
#
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

vpfx() {
#
# vpfx - Return the current VENV prefix.
#
# - **Purpose**:
#   - Return the current VENV prefix.
# - **Usage**: 
#   - vpfx
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Prints the current VENV prefix to STDOUT.
#   - Prints an error message to STDERR and returns with status code 1 if unsuccessful.
# - **Exceptions**:
#    1  No value set.
#
    if [ -z "${__VENV_PREFIX}" ]; then
        echo "Error: No VENV prefix has been set." >&2
        __rc__=1
        return ${__rc__}
    fi
    
    echo "${__VENV_PREFIX}"
}

vnum() {
#
# vnum - Return the current VENV sequence number.
#
# - **Purpose**:
#   - Return the current VENV sequence number.
# - **Usage**: 
#   - vnum
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Prints the current VENV sequence number to STDOUT.
#   - Prints an error message to STDERR and returns with status code 1 if unsuccessful.
# - **Exceptions**:
#    1  No value set.
#
    if [ -z "${__VENV_NUM}" ]; then
        echo "Error: No VENV sequence number has been set." >&2
        __rc__=1
        return ${__rc__}
    fi
    
    echo "${__VENV_NUM}"
}

vdsc() {
#
# vdsc - Return the current VENV description.
#
# - **Purpose**:
#   - Return the current VENV description.
# - **Usage**: 
#   - vdsc
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Prints the current VENV description to STDOUT.
#   - Prints an error message to STDERR and returns with status code 1 if unsuccessful.
# - **Exceptions**:
#    1  No value set.
#
    if [ -z "${__VENV_DESC}" ]; then
        echo "Error: No VENV sequence number has been set." >&2
        __rc__=1
        return ${__rc__}
    fi
    
    echo "${__VENV_DESC}"
}

cact() {
#
# cact - Change active VENV
#
# - **Purpose**:
#    - Change the active virtual environment.
# - **Usage**: 
#    -  cact VENV_NAME
# - **Input Parameters**: 
#    1. `VENV_NAME` (string) - The name of the virtual environment to activate.
# - **Output**: 
#    - Messages indicating the deactivation and activation process.
#    - If unsuccessful, prints an error message to STDERR and returns with status code 1.
# - **Exceptions**: None
#
    local new_env="$1"
    # stack_op __VENV_STACK debug 1>&2
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
    # stack_op __VENV_STACK debug 1>&2
}

dact(){
#
# dact - Deactivate the current VENV
#
# - **Purpose**:
#   - Deactivate the currently active conda virtual environment.
# - **Usage**: 
#   - dact
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Deactivates the current virtual environment.
#   - Prints a message indicating the deactivated environment.
# - **Exceptions**: 
#   - If no environment is currently activated, conda will display an appropriate message.
#
    local stack_value

    # stack_op __VENV_STACK debug 1>&2
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
    # stack_op __VENV_STACK debug 1>&2
    echo ${stack_value}
    return ${__rc__}
}


pact(){
#
# pact - Switch to the Previous Active VENV
#
# - **Purpose**:
#   - Deactivate the current virtual environment and activate the previously active one.
# - **Usage**: 
#   - pact
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Deactivates the current environment and activates the previous one.
#   - Prints messages to indicate the switch.
# - **Exceptions**: 
#   - If no previous environment is stored, an error message will be displayed.
#
    pop_venv
    local previous_env=${__sv__}

    # Change to previous VENV
    if [ $? -eq 0 ]; then
        cact "$previous_env"
        pop_venv > /dev/null  # Pop the current(previous) VENV off the stack.
    else
        echo "No previous environment to switch to."
    fi
}

lenv(){
#
# lenv - List All Current VENVs
#
# - **Purpose**:
#  - List all the currently available conda virtual environments.
# - **Usage**: 
#     lenv
# - **Input Parameters**: 
#     None
# - **Output**: 
#     - A list of all existing conda virtual environments.
# - **Exceptions**: 
#     - If no environments are available, the output from `conda info -e` will indicate this.
#
    conda info -e | grep -E -v '^#'
}

lastenv(){
#
# lastenv - Retrieve the Last Environment with a Given Prefix
#
# - **Purpose**:
#   - Return the last conda virtual environment that starts with a given prefix.
# - **Usage**: 
#   - lastenv PREFIX
# - **Input Parameters**: 
#    1. `PREFIX` (string) - The prefix for the environment names you want to match.
# - **Output**: 
#   - The last conda environment that starts with the given prefix.
# - **Exceptions**: 
#   - If no environments match the prefix, the output will be empty.
#
    local prefix="$1"
    local last_env=$(lenv | grep -E "^${prefix}." | tail -1 | cut -d " " -f 1)
    echo "${last_env}"
}

benv(){
#
# benv - Create a New Base Virtual Environment
#
# - **Purpose**:
#   - Create a new base conda virtual environment and activate it.
# - **Usage**: 
#   - benv ENV_NAME [EXTRA_OPTIONS]
#   
#   ```code
#   benv myenv  python==3.10
#   ```
#
#   Will create a new environment named `myenv` with Python 3.10
#
#   After that, it will become the active virtual environment. This environment may be used for creating a series of new environments. with `nenv`.
#
# - **Input Parameters**: 
#   1. `ENV_NAME` (string) - The name of the new environment to create.
#   2. `EXTRA_OPTIONS` (string, optional) - Additional options to pass to `conda create`.
# - **Output**: 
#   - Creates and activates the new environment.
# - **Exceptions**: 
#   - Errors during environment creation are handled by conda.
#
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

nenv(){
#
# nenv - Create a New Virtual Environment in a Series
#
# - **Purpose**:
#   - Create a new conda virtual environment in a series identified by a prefix as a clone of the current venv. Resets and starts the sequence number from "00".
# - **Usage**: 
#   - nenv PREFIX [EXTRA_OPTIONS]
# - **Input Parameters**: 
#   1. `PREFIX` (string) - The prefix to identify the series of environments.
#   2. `EXTRA_OPTIONS` (string, optional) - Additional options to pass to the environment creation.
# - **Output**: 
#   - Creates and activates the new environment with sequence number "00".
# - **Exceptions**: 
#   - Errors during environment creation are handled by conda.
#
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

denv(){
#
#  denv - Delete a Specified Virtual Environment
#
# - **Purpose**:
#   - Delete a specified conda virtual environment.
# - **Usage**: 
#   - denv ENV_NAME
# - **Input Parameters**: 
#   1. `ENV_NAME` (string) - The name of the environment to be deleted.
# - **Output**: 
#   - Removes the specified environment.
# - **Exceptions**: 
#   - If no environment name is provided, an error message is displayed.
#   - Errors during deletion are handled by conda.
#
    local env_to_delete="$1"

    if [ -z "${env_to_delete}" ]; then
        echo "Error: Environment name is required for deletion." >&2
        __rc__=1
        return ${__rc__}
    fi

    echo "Removing environment -> ${env_to_delete}"
    conda remove --all -n ${env_to_delete} -y
}

renv(){
#
# renv - Revert to Previous Virtual Environment
#
# - **Purpose**:
#   - Deactivate the current active environment, delete it, and then re-activate the previously active environment.
# - **Usage**: 
#   - renv
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Removes the current environment and reverts to the previous one.
# - **Exceptions**: 
#   - Errors during deactivation or deletion are handled by conda.
#
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

ccln(){
#
# ccln - Clone the current VENV and increment the sequence number.
#
# - **Purpose**:
#   - Clone the current virtual environment and increment its sequence number.
# - **Usage**: 
#   - ccln [DESCRIPTION]
# - **Input Parameters**: 
#   1. `DESCRIPTION` (optional string) - A description for the new virtual environment.
# - **Output**: 
#   - Creates and activates a clone of the current environment with an incremented sequence number.
# - **Exceptions**: 
#   - None. If no description is provided, the description of the current VENV is used.
#
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

venvdiff()
{
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
    local env1_packages=$(pip list | tail -n +1 )
    dact > /dev/null

    echo $env1_packages > env1.txt

    # Activate the second environment and get the list of packages
    cact $env2 > /dev/null
    local env2_packages=$(pip list  | tail -n +1 )
    dact > /dev/null

    echo $env2_packages > env2.txt
    
    echo ""

    # Compare the packages
    diff -y <(echo "$env1_packages") <(echo "$env2_packages")

}
