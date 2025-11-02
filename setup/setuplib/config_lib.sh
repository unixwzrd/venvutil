#!/usr/bin/env bash
# # Script: config_lib.sh
# `config_lib.sh` - Configuration Management and Variable Handling
#
# ## Description
# - **Purpose**:
#   - Manages configuration file loading
#   - Handles variable initialization
#   - Controls configuration precedence
#   - Provides configuration validation
#
#  ##  Configuration handling
#     - Dependency resolution
#
#  ##  Configuration handling
#  - Modeled to use pkg-config like files.
#  - Performs variable expansion on assigned values including arrays.
#  - Variables can be set using the following syntax:
#    - prefix=$HOME/local/venvutil
#    - exec_prefix=${prefix}
#    - libdir=${exec_prefix}/lib
#    - includedir=${prefix}/include
#    - bindir=${exec_prefix}/bin
#    - datadir=${prefix}/share
#    - sysconfdir=${prefix}/etc
#
#  ## Variable Handling
#  - using an associative array with the variable names as keys and an action to use the values.
#  - Associative array contains (key) VARNAME: (value) Action pairs.
#  - Actions are the following:
#    - "set" - set the variable to the value
#    - "merge" - merge the value into the variable
#    - "config" - from the config settings
#    - "discard" - discard and use the default or standard config value.
#
# ## Usage
# - Source this script in your Bash scripts to utilize its functions.
#   ```bash
#   source_lib config_lib
#   ```
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
    "load_config"
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
    declare -g -A pkg_config_actions=(
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


# Function to ensure a directory exists. If it does not, it creates it.
#
# Args:
#   $1 (string): The path of the directory to be checked.
#
# Returns:
#   None
#
check_directory() {
    local dir_path="$1"
    if [[ ! -d "$dir_path" ]]; then
        mkdir -p "$dir_path" || { log_message "ERROR" "Failed to create directory \"$dir_path\"."; exit 1; }
        log_message "WARNING" "Created directory \"$dir_path\"."
    fi
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

# # Function: load_config
# `load_config` - Loads package configuration from setup.cf file.
# ## Description
# - **Purpose**:
#   - This function reads the setup.cf file and sets variables for package installation.
# - **Usage**:
#   - `load_config <config_file> <var_actions>`
# - **Input Parameters**:
#   - `config_file`: The path to the configuration file.
#   - `var_actions`: The associative array of variable actions.
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
load_config() {
    local config_file="$1"
    local -n var_actions="$2"
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
            pkg_config_values["${key}"]="${value}"
            pkg_config_set_vars+=("${key}")
            declare -g -a "${key}"
            local -a tmp_array=()
            for item in ${value}; do
                if ! expanded="$(expand_variable "$item")"; then
                    log_message "ERROR" "Invalid quoted scalar assignment: $line"
                fi
                tmp_array+=($expanded)
            done
            # Pass the entire array as a reference
            update_variable var_actions "${key}" tmp_array
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
            pkg_config_values["${key}"]="${value}"
            pkg_config_set_vars+=("${key}")
            if ! expanded="$(expand_variable "$value")"; then
                log_message "ERROR" "Invalid scalar assignment: $line"
                continue
            fi
            update_variable var_actions "${key}" expanded
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
            else
                # Handle empty value case
                expanded=" "
            fi
            update_variable var_actions "${key}" expanded
            continue
        fi

        log_message "WARNING" "Line doesn't match known pattern: '$line'"
    done < "$config_file"
    return 0
}

# # Function: dump_config
# `dump_config` - Write configuration variables to a file or stdout in valid Bash syntax
#
# ## Description
# - **Purpose**: 
#   - Writes configuration variables to a file or stdout in valid Bash syntax
#   - Supports writing scalar variables, arrays, and associative arrays
#   - Can optionally sort variables
#
# ## Usage
#   ```bash
#   dump_config [-s] [-o output_file] [-h] <variable_array>
#   ```
#
# ## Options
#   - `-s`: Sort variables alphabetically before writing
#   - `-o output_file`: Write to specified file (default: stdout)
#   - `-h`: Display help message
#
# ## Input Parameters
#   - `variable_array`: Name of array containing variables to write
#
# ## Output
#   - Writes variables to the specified file (or stdout) in valid Bash syntax:
#     - Scalar variables: `var="value"`
#     - Arrays: `var=("elem1" "elem2")`
#     - Associative arrays: `declare -A var=([key1]="val1" [key2]="val2")`
#
# ## Returns
#   - 0: Success
#   - 1: Invalid option provided
#
# ## Examples
#   ```bash
#   # Write config to stdout
#   dump_config config_vars
#
#   # Write sorted config to file
#   dump_config -s -o config.conf config_vars
#   ```
dump_config() {
    __rc__=0
    local sort_vars=false
    local output_file="/dev/stdout"
    local OPTIND=1

    while getopts "so:h" opt; do
        case $opt in
            s) sort_vars=true ;;
            o) output_file="$OPTARG" ;;
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            \?) log_message "ERROR" "Invalid option: -$OPTARG"; echo "$USAGE"; return 1 ;;
        esac
    done
    shift $((OPTIND-1))

    # Get the variable array name from remaining arguments
    local -n var_list="$1"

    # Truncate file if writing to file (not stdout)
    if [[ "$output_file" != "/dev/stdout" ]]; then
        : > "$output_file"
        log_message "INFO" "Writing config to $output_file"
    fi

    # Sort if requested
    if [[ "$sort_vars" == true ]]; then
        # Print array elements on separate lines, sort them, and read back into array
        readarray -t sorted_array < <(printf '%s\n' "${var_list[@]}" | sort)
        var_list=("${sorted_array[@]}")
    fi

    for var_name in "${var_list[@]}"; do
        local var_type
        var_type="$(var_type "$var_name")"

        case "$var_type" in
            "array")
                # Start array declaration
                printf '%s=(' "$var_name" >> "$output_file"
                local -n array_ref="$var_name"
                # Print each non-empty element
                for value in "${array_ref[@]}"; do
                    # TODO Remove this at some point
                    # This is a patch to handle old errors in config processing.
                    # Skip lone parentheses that may have been incorrectly parsed
                    if [[ "$value" == "(" || "$value" == ")" ]]; then
                        continue
                    fi

                    if [ -n "${value}" ]; then
                        printf '"%s" ' "$value" >> "$output_file"
                    fi
                done
                # Close array declaration
                printf ')\n' >> "$output_file"
                ;;
            "associative")
                printf 'declare -A %s=(' "$var_name" >> "$output_file"
                local -n array_ref="$var_name"
                for key in "${!array_ref[@]}"; do
                    printf ' [%s]="%s"' "$key" "${array_ref[$key]}" >> "$output_file"
                done
                printf ' )\n' >> "$output_file"
                ;;
            *)
                printf '%s="%s"\n' "$var_name" "${!var_name}" >> "$output_file"
                ;;
        esac
    done

    return 0
}

# # Function: write_config
# `write_config` - Write configuration variables to a file in valid Bash syntax
#
# ## Description
# - **Purpose**: 
#   - Writes configuration variables to a file in valid Bash syntax, handling different variable types appropriately
#
# ## Usage
#   ```bash
#   write_config <config_file> <variable_array>
#   ```
#
# ## Input Parameters
#   - `config_file`: Path to the output configuration file
#   - `variable_array`: Name of array containing variables names to write
#
# ## Output
#   - Writes variables to the specified file (or stdout) in valid Bash syntax:
#     - Scalar variables: `var="value"`
#     - Arrays: `var=("elem1" "elem2")`
#     - Associative arrays: `declare -A var=([key1]="val1" [key2]="val2")`
#
# ## Returns
#   - 0: Success
#   - 1: Invalid option provided
#
# ## Examples
#   ```bash
#   # Write config to file
#   write_config "/path/to/config.conf" config_vars
#   ```
#
# ## Deprecation Notice
# This function is deprecated and will be removed in a future version.
# Please use `dump_config` instead, which has a clearer interface:
#   ```bash
#   # Write to file
#   dump_config -o config.conf config_vars
#
#   # Write to stdout
#   dump_config config_vars
#   ```
write_config() {
    __rc__=0

    _deprecated "write_config is deprecated. Please use dump_config instead."
    __rc__=$?

    local config_file="$1"
    shift
    local -n vars_to_write="$1"

    local tmp_rc

    dump_config -o "$config_file" vars_to_write
    tmp_rc=$?

    if [[ "$tmp_rc" -ne 0 ]]; then
        __rc__=$tmp_rc
    fi

    return ${__rc__}
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
    __rc__=0
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
    return ${__rc__}
}


__rc__=0
return ${__rc__}
