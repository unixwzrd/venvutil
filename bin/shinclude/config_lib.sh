#!/usr/bin/env bash
# # Script: config_lib.sh
# `config_lib.sh` - Support functions for manifest and setup packaging.
# ## Description
# - **Purpose**:
#   - Offers functions to read the setup.cf file and set variables for package installation.
# - **Usage**:
#   - Source this script in your Bash scripts to utilize its functions.
#     ```bash
#     source_lib config_lib
#     ```
# - **Input Parameters**:
#   - None.
# - **Output**:
#   - Sets variables from the setup.cf file for package installation.
# - **Exceptions**:
#   - Returns specific error codes if the setup.cf file is not found or invalid.
# - **Initialization**:
#   - Ensures the script is sourced only once and initializes necessary variables.
#
# ## Dependencies
# - `setup.cf` (for package configuration)
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
source "${__VENV_INCLUDE}/init_lib.sh"

# Get the errno_lib.sh script
source_lib errno_lib

# Get the string_lib.sh script
# source_lib string_lib

# Get the type_lib.sh script
source_lib type_lib

# Declare global variables
# The values are the values by key in the .cf file regardless fo the operator used to set them.
# shellcheck disable=SC2034
declare -g -A pkg_config_values=()
# The set variables are the variables which have set values using the `=` operator
# shellcheck disable=SC2034
declare -g -a pkg_config_set_vars=()
# The desc variables are the variables which have desc values using the `:` operator
# shellcheck disable=SC2034
declare -g -a pkg_config_desc_vars=()

# Add internal functions to the __VENV_INTERNAL_FUNCTIONS array.
if ! declare -p __VENV_INTERNAL_FUNCTIONS >/dev/null 2>&1; then declare -ga __VENV_INTERNAL_FUNCTIONS; fi
# Quote to prevent word splitting/globbing, or split robustly with mapfile or read -a.
# shellcheck disable=SC2206
__VENV_INTERNAL_FUNCTIONS=(
    ${__VENV_INTERNAL_FUNCTIONS[@]}
    "expand_variables"
    "load_pkg_config"
)

# # Function: `pkg_config_vars`
# `pkg_config_vars` - Sets up the actions for the variables in a package config file.
#
# ## Description
# - **Purpose**:
#   - Sets up the actions for the variables in a package config file.
# - **Usage**:
#   - `pkg_config_vars`
# - **Input Parameters**:
#   - None.
# - **Output**:
#   - None.
# - **Exceptions**:
#   - None.
pkg_config_vars() {
    # shellcheck disable=SC2034
    declare -g -A var_actions=(
        ["Cflags"]="set"
        ["Conflicts"]="merge"
        ["Contribute"]="merge"
        ["Description"]="set"
        ["Libs"]="set"
        ["License"]="merge"
        ["Name"]="set"
        ["Repository"]="set"
        ["Requires"]="merge"
        ["Support"]="merge"
        ["Version"]="set"
        ["bindir"]="set"
        ["datadir"]="set"
        ["exec_prefix"]="set"
        ["include_dirs"]="set"
        ["include_files"]="set"
        ["includedir"]="set"
        ["libdir"]="set"
        ["prefix"]="set"
        ["sysconfdir"]="set"
    )
}

# # Function: expand_variable
# `expand_variable` - Expands variables in a given string.
# ## Description
# - **Purpose**:
#   - This function takes a string and expands variables within it.
# - **Usage**:
#   - `expand_variable "string_with_variables"`
# - **Input Parameters**:
#   - `string_with_variables`: The string containing variables to be expanded.
# - **Output**:
#   - The expanded string with variables replaced by their values.
#
expand_variable() {
    local input="$1"

    # Sanitize the input by escaping special characters if necessary
    # For example, you might want to escape quotes or backslashes
    sanitized_input=$(echo "$input" | sed 's/[&;|\n\\>=]/\\&/g')

    # Use eval to expand variables safely, handling both ${var} and $var notation
    eval echo "$sanitized_input"
}

# # Function: load_pkg_config
# `load_pkg_config` - Loads package configuration from setup.cf file.
# ## Description
# - **Purpose**:
#   - This function reads the setup.cf file and sets variables for package installation.
# - **Usage**:
#   - `load_pkg_config`
# - **Input Parameters**:
#   - None.
# - **Output**:
#   - Sets variables from the setup.cf file for package installation.
# - **Exceptions**:
#   - Returns specific error codes if the setup.cf file is not found or invalid.
# - **Examples** setup.cf file:
#     ```  
#     # Package Configuration File for venvutil
#     ## Define variables
#     prefix=$HOME/local/venvutil
#     exec_prefix=${prefix}
#     libdir=${exec_prefix}/lib
#     includedir=${prefix}/include
#     bindir=${exec_prefix}/bin
#     datadir=${prefix}/share
#     sysconfdir=${prefix}/etc
#     include_dirs=("bin" "docs" "conf")
#     include_files=("README.md" "LICENSE" "setup.sh" "setup.cf" "manifest.lst")
#
#     # Package metadata
#     Name: venvutil
#     Description: Virtual Environment Utilities
#     Version: 0.4.0
#     Repository: https://github.com/unixwzrd/venvutil
#     License: Apache License, Version 2.0
#     Support: https://github.com/unixwzrd/venvutil/issues
#     Contribute: https://patreon.com/unixwzrd
#     Contribute: https://www.ko-fi.com/unixwzrd
#
#     # Dependencies (if any)
#     Requires: python >= 3.10
#     Requires: bash >= 4.0
#     Requires: Conda >= 22.11
#     Requires: macOS
#     Requires: Linux
#     Conflicts:
#
#     # Compiler and linker flags (if applicable)
#     # Cflags: -I${includedir}
#     # Libs: -L${libdir} -lvenvutil
#     ```
load_pkg_config() {
    local config_file="$1"
    if [[ ! -f "$config_file" ]]; then
        errno_exit ENOENT "No such config file: $config_file"
    fi

    local key value expanded line

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Trim whitespace from both ends
        line="$(sed 's/^[[:space:]]*//; s/[[:space:]]*$//' <<< "$line")"

        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        # Case 1: Array assignment using `=` and `()`
        # Example: include_files=("README.md" "LICENSE" "setup.sh")
        if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=\((.*)\)$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            pkg_config_values["$key"]="$value"
            pkg_config_set_vars+=("$key")
            declare -g -a "$key"
            local -a tmp_array=()
            for item in ${value}; do
                if ! expanded="$(expand_variable "$item")"; then
                    log_message "ERROR" "Invalid quoted scalar assignment: $line"
                fi
                tmp_array+=($expanded)
            done
            # Pass the entire array as a reference
            handle_variable "${key}" tmp_array
            continue
        fi

        # Case 2: Normal scalar assignment using lvalue=rvalue
        #        The rvalue may or may not have "" however any $VAR, ${VAR} will be expanded.
        #        If the rvalue is enclosed in '' anything within the '' will be taken as literal.
        # Example: prefix=$HOME/local/venvutil
        if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            # shellcheck disable=SC2034
            pkg_config_values["$key"]="$value"
            pkg_config_set_vars+=("$key")
            if ! expanded="$(expand_variable "$value")"; then
                log_message "ERROR" "Invalid scalar assignment: $line"
                continue
            fi
            declare -g "${key}"
            handle_variable "$key" "expanded"
            continue
        fi

        # Case 3: Key-value pair with colon
        # Example: Description: Virtual Environment Utilities
        # Example: Requires: python >= 3.10
        # Example: Conflicts:
        if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*):([[:space:]]*([^[:space:]].*[^[:space:]])?)?$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[3]:-}"  # Use empty string if no value captured
            log_message "DEBUG" "Found key-value pair: $key : $value"
            if ! var_type ${key} > /dev/null 2>&1 ; then
                declare -g -a "${key}"
            fi
            if [ -n "$value" ]; then
                if ! expanded="$(expand_variable "$value")"; then
                    log_message "ERROR" "Invalid quoted assignment: $line"
                    continue
                fi
                handle_variable "$key" expanded
            else
                # Handle empty value case
                handle_variable "$key" ' '
            fi
            continue
        fi

        log_message "WARNING" "Line doesn't match known pattern: '$line'"
    done < "$config_file"
    return 0
}

# # Function: write_config
# `write_config` - Write variables in valid Bash syntax (scalar vs array).
# ## Description
# - **Purpose**:
#   - Writes variables in valid Bash syntax (scalar vs array).
# - **Usage**:
#   - `write_config "/path/to/output.conf" config_variables[@]`
# - **Input Parameters**:
#   - `config_file`: The path to the output file.
#   - `config_variables`: An array of variable names to write.
# - **Output**:
#   - Writes the variables to the output file in valid Bash syntax.
write_config() {
    local config_file="$1"
    shift
    local -a vars_to_write=("${!1}")

    : > "$config_file"  # Overwrite file
    log_message "INFO" "Writing config to $config_file"

    for var_name in "${vars_to_write[@]}"; do
        # Skip empty var_name
        [[ -z "${var_name}" ]] && continue

        local var_type
        var_type="$(var_type "$var_name")"

        case "$var_type" in
            "array")
                # Build array literal: var_name=("elem1" "elem2")
                local -a arr_copy=("${!var_name}")
                local array_literal='('
                for elem in "${arr_copy[@]}"; do
                    local escaped="${elem//\"/\\\"}"
                    array_literal+="\"$escaped\" "
                done
                array_literal="${array_literal%% }"  # remove trailing space
                array_literal+=')'
                echo "$var_name=$array_literal" >> "$config_file"
                ;;
            "associative")
                # Harder to re-serialize. Implement if needed.
                echo "# $var_name is associative. Implement your own logic." >> "$config_file"
                ;;
            "scalar"|"unknown")
                local val="${!var_name}"
                local escaped="${val//\"/\\\"}"
                echo "$var_name=\"$escaped\"" >> "$config_file"
                ;;
        esac
    done
    log_message "INFO" "Done writing config to $config_file"
}

# # Function: parse_manifest_metadata
# `parse_manifest_metadata` - Parses manifest metadata.
# ## Description
# - **Purpose**:
#   - This function reads the manifest file and sets variables for package installation.
# - **Usage**:
#   - `parse_manifest_metadata <manifest_file>`# - **Input Parameters**:
#   - `manifest_file`: The path to the manifest file.
# - **Output**:
#   - Sets variables from the manifest file for package installation.
parse_manifest_metadata() {
    local manifest_file="$1"
    if [ ! -f "$manifest_file" ]; then
        echo "ERROR: Manifest file $manifest_file not found." >&2
        exit 2
    fi
    echo "Parsing manifest metadata..." >&2
    while IFS='| ' read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ ^#.*$ ]] && continue    # Skip comments
        [[ -z "$line" ]] && break             # Stop at first blank line (end of metadata)
        if [[ "$line" =~ ^[A-Za-z_]+=.*$ ]]; then
            eval "$line"
        fi
    done < "$manifest_file"
    return 0
}


__rc__=0
return ${__rc__}
