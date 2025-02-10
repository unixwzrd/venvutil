#!/usr/bin/env bash
# # Script: type_lib.sh
# `type_lib.sh` - Support functions for variable type handling.
# ## Description
# - **Purpose**:
#   - Offers functions to handle variable types.
# ## Usage
#   - Source this script in your Bash scripts to utilize its functions.
#     ```bash
#     source /path/to/type_lib.sh
#     ```
# ## Input Parameters
#   - None.
# ## Output
#   - Sets variables from the setup.cf file for package installation.
# ## Exceptions
#   - Returns specific error codes if the setup.cf file is not found or invalid.
# ## Initialization
#   - Ensures the script is sourced only once and initializes necessary variables.

## Initialization
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
if ! declare -p __VENV_SOURCED >/dev/null 2>&1; then declare -g -A __VENV_SOURCED; fi
if [[ "${__VENV_SOURCED[${THIS_SCRIPT}]:-}" == 1 ]]; then
    # echo "************************* SKIPPED SKIPPED SKIPPED SKIPPED             ************************* -----> $(basename "${THIS_SCRIPT}")" >&2
    return
fi
__VENV_SOURCED["${THIS_SCRIPT}"]=1
# echo "************************* READING READING READING READING             ************************* -----> $(basename "${THIS_SCRIPT}")" >&2

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
# shellcheck disable=SC2206
__VENV_INTERNAL_FUNCTIONS=(
    ${__VENV_INTERNAL_FUNCTIONS[@]}
)

# # Function: var_type
# `var_type` - Get the Type of a Variable
#
# ## Description
# - **Purpose**:
#   - Retrieves the type of a variable.
# - **Usage**:
#   - `var_type [-h] "var_name"`
# - **Options**:
#   - `-h`   Show this help message
# - **Examples**:
#   - `var_type "my_variable"`
#   - `var_type=$(var_type "my_variable")
# - **Input Parameters**:
#   - `var_name`: The name of the variable.
# - **Output**:
#   - The type of the variable as a string. Can be one of `array`, `associative`, `scalar`, or `unknown`.
# - **Exceptions**:
#   - None.
var_type() {
    local OPTIND=1
    # Parse options
    while getopts "h" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    local var_name="$1"
    local var_type
    var_type=$(declare -p "$var_name" 2>/dev/null | cut -d ' ' -f 2)

    __rc__=0
    case "$var_type" in
        -a)
            echo "array"
            ;;
        -A)
            echo "associative"
            ;;
        -i)
            echo "integer"
            ;;
        --)
            echo "scalar"
            ;;
        -ar)
            echo "read only array"
            __rc__=1
            ;;
        -Ar)
            echo "read only associative"
            __rc__=1
            ;;
        -ir)
            echo "read only integer"
            __rc__=1
            ;;
        -r)
            echo "read only scalar"
            __rc__=1
            ;;
        *)
            echo "unknown"
            __rc__=93
            ;;
    esac

    return ${__rc__}
}

# # Function: set_variable
# `set_variable` - Assign a value to a named variable, respecting existing type or inferring new
#
# ## Description
# - **Purpose**:
#   - Assigns a value to a named variable, respecting its existing type or inferring a new type.
#   - Handles arrays, associative arrays, scalars, and integers.
# - **Usage**:
#   - `set_variable "var_name" "value_ref1"`
#   - `set_variable "var_name" "value_ref1" "value_ref2"`
# - **Input Parameters**:
#   - `var_name`: The name of the variable to set.
#   - `value_ref1`: Name reference to first value/array to assign.
#   - `value_ref2`: (Optional) Name reference to second value/array to merge with first.
# - **Output**:
#   - None. Sets the target variable with the provided value(s).
# - **Exceptions**:
#   - None. Will create new variable if it doesn't exist.
set_variable() {
    local var_name=$1
    local -n var_ref1=$2
    local var_ref2=""
    if [ -n "${3:-}" ]; then
        local -n var_ref2=$3
    fi

    # log_message "DEBUG2" "assign_variable: var_name=$var_name, var_value=\"$var_value\", var_type=$var_type"

    local var_type
    var_type=$(var_type "$var_name")

    case "$var_type" in
        "array")
            declare -g -a "${var_name}"
            local new_array=()
            new_array=( "${var_ref1[@]}" "${var_ref2[@]}" )
            readarray -t "${var_name}" < <(for element in "${new_array[@]}"; do echo "$element"; done)
            ;;
        "associative")
            declare -g -A "${var_name}"
            # shellcheck disable=SC2178
            declare -n new_array="${var_name}"
            for key in "${!var_ref1[@]}"; do
                new_array[$key]="${var_ref1[$key]}"
            done
            if [ -n "$var_ref2" ]; then
                for key in "${!var_ref2[@]}"; do
                    if [ -n "${new_array[$key]}" ]; then
                        new_array[$key]="${new_array[$key]}, ${var_ref2[$key]}"
                    else
                        new_array[$key]="${var_ref2[$key]}"
                    fi
                done
            fi
            ;;
        "scalar")
            declare -g "${var_name}"="${var_ref1}"
            ;;
        "integer")
            declare -g "${var_name}"="${var_ref1}"
            ;;
         *)
            declare -g "${var_name}"="${var_ref1:-}"
            ;;
    esac
}

# # Function: handle_variable
# `handle_variable` - Manage variable assignments based on predefined actions
#
# ## Description
# - **Purpose**:
#   - Controls how variables are assigned based on a predefined action table.
#   - Supports merging, setting, preserving config values, or discarding changes.
# - **Usage**:
#   - `handle_variable "var_name" "value_ref"`
# - **Input Parameters**:
#   - `var_name`: The name of the variable to handle.
#   - `value_ref`: Name reference to the value to potentially assign.
# - **Output**:
#   - None. Modifies the target variable according to its action rule.
# - **Exceptions**:
#   - Exits with code 2 if the action for the variable is unknown.
# - **Required Global Variables**:
#   - `var_actions`: Associative array mapping variable names to actions:
#     - "merge": Combines existing value with new value
#     - "set": Uses the new value
#     - "config": Preserves the config file value
#     - "discard": Keeps the original value
handle_variable() {
    local var_name=$1
    [[ -z "$2" || "$2" =~ ^[[:space:]]*$ ]] &&
        { errno_warn EINVAL "handle_variable: var_name=$var_name, value_ref='$2'"; return $?; }

    # shellcheck disable=SC2034
    local -n var_name_val=$2
    # shellcheck disable=SC2034
    local -n current_value=${var_name}

    # TODO Handle different action tables.

    # shellcheck disable=SC2154
    case "${var_actions["$var_name"]}" in
        "merge")
            # Merge the current value with the value from the config file
            set_variable "$var_name" "current_value" "var_name_val"
            ;;
        "set")
            # Set the variable from the command line or defaults
            set_variable "$var_name" "var_name_val"
            ;;
        "config")
            # Set the variable from the config file setting
            set_variable "$var_name" "current_value"
            ;;
        "discard")
            # Preserve the original value
            set_variable "$var_name" "current_value"
            ;;
        *)
            log_message "ERROR" "Unknown config_variable_action for variable \"$var_name\": ${var_actions["$var_name"]}"
            exit 2  # (ENOENT: 2): No such file or directory
            ;;
    esac
}

__rc__=0
return ${__rc__}
