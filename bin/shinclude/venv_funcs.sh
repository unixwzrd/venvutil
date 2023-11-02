#!/bin/bash
#
# venv_funcs.sh - Virtual Environment Management Functions for Bash Scripts
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
#   - __VENV_NUM    The sequence of th evenv in a "__VENV_PREFIX" series.
#   - __VENV_PREFIX The prefix of the VENV
#   - __VENV_DESC   A very short description of the VENV.

# Don't source this script if it's already been sourced.
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
[[ "${_SOURCED_LIST}" =~ "${THIS_SCRIPT}" ]] && return || _SOURCED_LIST="${_SOURCED_LIST} ${THIS_SCRIPT}"
echo "Sourcing: ${THIS_SCRIPT}"

MY_NAME=$(basename ${THIS_SCRIPT} )
MY_BIN=$(dirname ${THIS_SCRIPT})
MY_ARGS=$*
MY_INCLUDE=$( ( [ -d "${MY_BIN}/shinclude" ] && echo "${MY_BIN}/shinclude" ) || echo "${HOME}/shinclude" )

[ -f ${MY_INCLUDE}/util_funcs.sh ] && . ${MY_INCLUDE}/util_funcs.sh \
    || ( echo "Could not find venv_funcs.sh in INCLUDEDIR: ${MY_INCLUDE}" && exit 1 )

INTERNAL_FUNCTIONS=(
    ${INTERNAL_FUNCTIONS[@]}
    "push_venv"
    "pop_venv"
    "_set_venv_vars"
)


# VENV Management functions
# Initialize the stack
__VENV_STACK=("")

# Specialized push th edefaulkt VENV onto the stack
push_venv() {
    push_stack "__VENV_STACK" "$CONDA_DEFAULT_ENV"
}

# Specialized pop the VENV off th estack and decrement.j
pop_venv() {
    pop_stack "__VENV_STACK"
}

# Sets internal VENV variables
_set_venv_vars(){
     __VENV_PREFIX=$(echo "$*" | cut -d '.' -f 1)
     __VENV_DESC=$(echo "$*" | cut -d '.' -f 3-) &&  __VENV_NUM=$(echo "$*" | cut -d '.' -f 2)
}

snum(){
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
        return 1
    fi
    
    # Validate that the provided number is numeric
    if ! [[ "${new_num}" =~ ^[0-9]+$ ]]; then
        echo "Error: Sequence number must be numeric." >&2
        return 1
    fi
    
    # Validate that the provided number is within a valid range (00-99)
    if [ "${new_num}" -lt 0 ] || [ "${new_num}" -gt 99 ]; then
        echo "Error: Sequence number must be between 00 and 99." >&2
        return 1
    fi
    
    __VENV_NUM=$( __zero_pad "${new_num}" )
}

vpfx(){
#
# vpfx - Return the current VENV prefix.
#
# - **Purose**:
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
        return 1
    fi
    
    echo "${__VENV_PREFIX}"
}

vnum(){
#
# vnum - Return the current VENV sequence number.
#
# - **Purose**:
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
        return 1
    fi
    
    echo "${__VENV_NUM}"
}

vdsc(){
#
# vdsc - Return the current VENV description.
#
# - **Purose**:
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
        return 1
    fi
    
    echo "${__VENV_DESC}"
}

cact(){
#
# cact - Change active VENV
#
# - **Purose**:
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

    # Validate input
    if [ -z "$1" ]; then
        echo "Error: No VENV name provided." >&2
        return 1
    fi

    # Pop from stack if top of stack matches the new environment
    local last_index=$((${#__VENV_STACK[@]} - 1))
    if [[ "${__VENV_STACK[$last_index]}" == "$new_env" ]]; then
        pop_venv
    fi

    # Set variables
     __VENV_NAME=$1
     _set_venv_vars ${__VENV_NAME}
     __VENV_PARMS=$(echo "$*" | cut -d '.' -f 4-)
    # Push new environment to stack
    push_venv
    # Deactivate current environment
    dact
    # Activate new environment
    echo "Activating new environment: ${__VENV_NAME}..."
    conda activate "${__VENV_NAME}" || { echo "Error: Failed to activate new environment." >&2; return 1; }
}

dact(){
#
# dact - Deactivate the current VENV
#
# - **Purose**:
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
    local env_to_delete="$CONDA_DEFAULT_ENV"

    if [ -z "${env_to_delete}" ]; then
        echo "No conda environment is currently activated."
        return
    fi
    
    # Check if the environment actually exists
    if ! conda info --envs | awk '{print $1}' | grep -q -w "${env_to_delete}"; then
        echo "Warning: The environment ${env_to_delete} does not exist. It might have been renamed or deleted."
        # Optionally pop from stack
        if [[ "${__VENV_STACK[-1]}" == "$env_to_delete" ]]; then
            pop_stack "__VENV_STACK"
        fi
        return 17
    fi

    echo "Deactivating: ${env_to_delete}"
    conda deactivate
}

pact(){
#
# pact - Switch to the Previous Active VENV
#
# - **Purose**:
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
    local previous_env=$(pop_venv)

    # Change to previous VENV
    if [ $? -eq 0 ]; then
        cact "$previous_env"
    else
        echo "No previous environment to switch to."
    fi
}

lenv(){
#
# lenv - List All Current VENVs
#
# - **Purose**:
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
    conda info -e | egrep -v '^#'
}

lastenv(){
#
# lastenv - Retrieve the Last Environment with a Given Prefix
#
# - **Purose**:
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
    local last_env=$(lenv | egrep "^${prefix}." | tail -1 | cut -d " " -f 1)
    echo "${last_env}"
}

benv(){
#
# benv - Create a New Base Virtual Environment
#
# - **Purose**:
#   - Create a new base conda virtual environment and activate it.
# - **Usage**: 
#   - benv ENV_NAME [EXTRA_OPTIONS]
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
        return 1
    }

    echo "Base environment created - activating ${env_name}"
    cact "${env_name}"
}

nenv(){
#
# nenv - Create a New Virtual Environment in a Series
#
# - **Purose**:
#   - Create a new conda virtual environment in a series identified by a prefix. Resets and starts the sequence number from "00".
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
        return 1
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
# denv - Delete a Specified Virtual Environment
#
# - **Purose**:
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
        return 1
    fi

    echo "Removing environment -> ${env_to_delete}"
    conda remove --all -n ${env_to_delete} -y
}

renv(){
#
# renv - Revert to Previous Virtual Environment
#
# - **Purose**:
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
        return 1
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

    __VENV_NUM=$( __next_step "$(vnum)" )
    __VENV_NAME="${__VENV_PREFIX}.${__VENV_NUM}.${__VENV_DESC}"

    # Clone the VENV
    conda create --clone "${CONDA_DEFAULT_ENV}" -n "${__VENV_NAME}" -y || return $?

    # Switch to the newly created VENV
    cact "${__VENV_NAME}"
}
