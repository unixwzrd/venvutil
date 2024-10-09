#!/usr/bin/env bash

# # Script: errno.sh
# `errno.sh` - Provides POSIX errno codes and utilities for Bash scripts
# ## Description
# - **Purpose**:
#   - Offers functions to retrieve and manage POSIX error codes within Bash scripts.
# - **Usage**:
#   - Source this script in your Bash scripts to utilize error code utilities.
#     ```bash
#     source /path/to/errno.sh
#     ```
# - **Input Parameters**:
#   - None.
# - **Output**:
#   - Functions that output error codes and messages.
# - **Exceptions**:
#   - Returns specific error codes if system `errno.h` is not found or invalid errno codes are provided.
# - **Initialization**:
#   - Ensures the script is sourced only once and initializes necessary variables.
#
# ## Dependencies
# - `util_funcs.sh` (for utility functions like `to_upper`)

# Determine the real path of the script
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
# Don't source this script if it's already been sourced.
[[ "${__VENV_SOURCED_LIST}" =~ "${THIS_SCRIPT}" ]] && return || __VENV_SOURCED_LIST="${__VENV_SOURCED_LIST} ${THIS_SCRIPT}"
echo "Sourcing: ${THIS_SCRIPT}"

# Extract script name, directory, and arguments
MY_NAME=$(basename "${THIS_SCRIPT}")
__VENV_BIN=$(dirname "$(dirname "${THIS_SCRIPT}")")
__VENV_BASE=$(dirname "${__VENV_BIN}")
__VENV_ARGS=$*
__VENV_INCLUDE="${__VENV_BASE}/bin/shinclude"

# Ensure util_funcs.sh is sourced for utility functions
source_util_script "util_funcs"

__VENV_INTERNAL_FUNCTIONS=(
   ${__VENV_INTERNAL_FUNCTIONS[@]}
   "errno"
   "errfind"
   "errno_warn"
   "errno_exit"
)

__rc__=0

# # Function: errno
#  `errno` - Provides POSIX errno codes and values for use in scripts or lookup of error codes on the command line.
# ## Description
# - **Purpose**: 
#   - This function takes an errno code or errno number and prints the corresponding error message to STDOUT. Sets the exit code to the errno value and returns, unless there is an internal error.
# - **Usage**: 
#   - `errno [errno_code|errno_number]`
# - **Input Parameters**: 
#   - `errno_code|errno_number`: The errno code (e.g., EACCES) or number.
# - **Output**: 
#   - Outputs the error code and message in the format `(errno_code: errno_num): errno_text`.
# - **Exceptions**: 
#   - 2: Could not find system errno.h
#   - 22: Invalid errno name
#
errno() {
    if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        echo "Usage: errno [errno_code|errno_number]"
        echo "Example: errno EACCES"
        __rc__=0
        return ${__rc__}
    fi

    local errno_code
    errno_code="$(to_upper "$1")"
    local errno_file
    if [ -f "/usr/include/sys/errno.h" ]; then
        errno_file="/usr/include/sys/errno.h"
    elif [ -f "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/sys/errno.h" ]; then
        errno_file="/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/sys/errno.h"
    else
        echo "Error: Could not lookup error code '${errno_code}' system errno.h not found." >&2
        __rc__=2
        return ${__rc__}
    fi

    local line errno_num errno_text

    if [[ "$errno_code" =~ ^[0-9]+$ ]]; then
        line=$(grep -wE "#define [A-Z_]*[ \t]*\b$errno_code\b" "$errno_file")
        errno_code=$(echo "$line" | awk '{print $2}')
    else
        # Use braces when expanding arrays, e.g. ${array[idx]} (or ${var}[.. to quiet). shellcheck SC1087
        # shellcheck disable=SC1087
        # Not using braces fo rthat, it's a regular expression here.
        line=$(grep -wE "#define $errno_code[ \t]*" "$errno_file")
    fi

    errno_num=$(echo "$line" | awk '{print $3}')
    errno_text=$(echo "$line" | sed -e 's/#define[ \t]*[A-Z0-9_]*[ \t]*[0-9]*[ \t]*\/\* \(.*\) \*\//\1/')

    if [ -z "$errno_num" ]; then
        echo "Error: Invalid errno code $errno_code" >&2
        __rc__=22
        return ${__rc__}
    else
        echo "($errno_code: $errno_num): $errno_text"
        __rc__="$errno_num"
        return ${__rc__}
    fi
}

# # Function: errfind
#  `errfind` - Find the error code for a given string.
# ## Description
# - **Purpose**: 
#   - Searches the POSIX errno.h file for a given string and returns any matching error codes and messages.
# - **Usage**: 
#   - `errfind <string>`
# - **Input Parameters**: 
#   - `string`: The string to search for within errno definitions.
# - **Output**: 
#   - Outputs matching error codes and their messages or a message indicating no matches found.
# - **Exceptions**: 
#   - None.
#
errfind() {
    local errno_file
    if [ -f "/usr/include/sys/errno.h" ]; then
        errno_file="/usr/include/sys/errno.h"
    elif [ -f "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/sys/errno.h" ]; then
        errno_file="/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/sys/errno.h"
    else
        echo "Error: Could not lookup error code '${errno_code}' system errno.h not found." >&2
        __rc__=2
        return ${__rc__}
    fi

    local lines errno_code errno_num errno_text
    local search_string="$1"

    lines=$(grep -i "#define [A-Z_]*[ \t]*.*$search_string.*" "$errno_file")
    if [ -z "$lines" ]; then
        echo "No error codes found for $search_string"
        __rc__=0
        return ${__rc__}
    fi

    echo "$lines" | while read -r line; do
        errno_code=$(echo "$line" | awk '{print $2}')
        errno_num=$(echo "$line" | awk '{print $3}')
        errno_text=$(echo "$line" | sed -e 's/#define[ \t]*[A-Z0-9_]*[ \t]*[0-9]*[ \t]*\/\* \(.*\) \*\//\1/')

        echo "($errno_code: $errno_num): $errno_text"
    done

    __rc__=0
    return ${__rc__}
}

# # Function: errno_warn
#  `errno_warn` - Prints a warning using the errno function to STDERR and returns the error number.
# ## Description
# - **Purpose**: 
#   - Prints a warning message to STDERR using the `errno` function and sets the return code.
# - **Usage**: 
#   - `errno_warn <errno_code>`
# - **Input Parameters**: 
#   - `errno_code`: The errno code to generate a warning for.
# - **Output**: 
#   - Outputs a warning message to STDERR.
# - **Exceptions**: 
#   - Returns the error number associated with the provided errno code.
#
errno_warn() {
    __rc__=$1
    echo "WARNING: $(errno "${__rc__}")" >&2
    return ${__rc__}
}

# # Function: errno_exit
#  `errno_exit` - Prints an error to STDERR using the errno function and exits with the error number.
# ## Description
# - **Purpose**: 
#   - Prints an error message to STDERR using the `errno` function and exits the script with the corresponding error number.
# - **Usage**: 
#   - `errno_exit <errno_code>`
# - **Input Parameters**: 
#   - `errno_code`: The errno code to generate an error for.
# - **Output**: 
#   - Outputs an error message to STDERR and exits the script.
# - **Exceptions**: 
#   - Exits the script with the provided error number.
#
errno_exit() {
    __rc__=$1
    echo "ERROR: $(errno "${__rc__}")" >&2
    exit ${__rc__}
}
