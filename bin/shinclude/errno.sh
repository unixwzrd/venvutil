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

# # Function: errno
#  `errno` - Provides POSIX errno codes and values for use in scripts or lookup of error codes on the command line.
# ## Description
# - **Purpose**: 
#   - This function takes an errno code or errno number and prints the corresponding error message to STDOUT. Sets the exit code to the errno value and returns, unless there is an internal error.
# - **Usage**: 
#   - `errno [-h] [errno_code|errno_number]`
# - **Options**: 
#   - `-h`   Show this help message
# - **Input Parameters**: 
#   - `errno_code|errno_number`: The errno code (e.g., EACCES) or number.
# - **Output**: 
#   - Outputs the error code and message in the format `(errno_code: errno_num): errno_text`.
# - **Exceptions**: 
#   - 2: Could not find system errno.h
#   - 22: Invalid errno name
#
errno() {
    local OPTIND=1

    # Check if no arguments were passed
    if [ $# -eq 0 ]; then
        vhelp "${FUNCNAME[0]}"
        return 0
    fi

    # Parse options
    while getopts "h" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    if [ "$1" -eq 0 ]; then
        echo "No error"
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
        # shellcheck disable=SC1087
        line=$(grep -wE "#define [A-Z0-9_]+[[:space:]]+$errno_code[[:space:]]" "$errno_file")
        errno_code=$(echo "$line" | awk '{print $2}')
    else
        # Not using braces for that, it's a regular expression here.
        # Use braces when expanding arrays, e.g. ${array[idx]} (or ${var}[.. to quiet).
        # shellcheck disable=SC1087
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
        return "${__rc__}"
    fi
}

# # Function: errfind
#  `errfind` - Find the error code for a given string.
# ## Description
# - **Purpose**: 
#   - Searches the POSIX errno.h file for a given string and returns any matching error codes and messages.
# - **Usage**: 
#   - `errfind [-h] <string>`
# - **Options**: 
#   - `-h`   Show this help message
# - **Input Parameters**: 
#   - `string`: The string to search for within errno definitions.
# - **Output**: 
#   - Outputs matching error codes and their messages or a message indicating no matches found.
# - **Exceptions**: 
#   - None.
#
errfind() {
    local OPTIND=1
    # Parse options
    while getopts "h" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

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
#   - Prints a warning message to STDERR using the `errno` function and sets the return code. It
#     will report the error without exiting the script. You may use the POSIX error code or the 
#     error number.
# - **Usage**: 
#   - `errno_warn <errno_code>`
# - **Example**:
#   - `errno_warn EACCES`
#   - `errno_warn 13`
# - **Input Parameters**: 
#   - `errno_code`: The errno code to generate a warning for.
# - **Output**: 
#   - Outputs a warning message to STDERR with caller info including:
#     - Function name that called errno_warn
#     - Line number where errno_warn was called
#     - Source file where errno_warn was called
#     - Function name that called the function that called errno_warn
#     - Line number where that function was called
#     - Source file containing that function call
# - **Exceptions**: 
#   - Returns the error number associated with the provided errno code.
#
errno_warn() {
    __rc__=$1
    echo "WARNING: $(errno "${__rc__}")" >&2
    echo "WARNING: FUNCTION: ${FUNCNAME[0]} LINE: ${BASH_LINENO[0]} FILE: ${BASH_SOURCE[0]}" >&2
    return "${__rc__}"
}

# # Function: errno_exit
#  `errno_exit` - Prints an error to STDERR using the errno function and exits with the error number.
# ## Description
# - **Purpose**: 
#   - Prints an error message to STDERR using the `errno` function and exits the script with the corresponding error number.
#     You may use the POSIX error code or the error number.
# - **Usage**: 
#   - `errno_exit <errno_code>`
# - **Example**:
#   - `errno_exit EACCES`
#   - `errno_exit 13`
# - **Input Parameters**: 
#   - `errno_code`: The errno code to generate an error for.
# - **Output**: 
#   - Outputs an error message to STDERR with caller info including:
#     - Function name that called errno_exit
#     - Line number where errno_exit was called
#     - Source file where errno_exit was called
#     - Function name that called the function that called errno_exit
#     - Line number where that function was called
#     - Source file containing that function call
# - **Exceptions**: 
#   - Exits the script with the provided error number.
#
errno_exit() {
    __rc__=$1
    echo "ERROR: $(errno "${__rc__}")" >&2
    echo "ERROR: FUNCTION: ${FUNCNAME[0]} LINE: ${BASH_LINENO[0]} FILE: ${BASH_SOURCE[0]}" >&2
    exit "${__rc__}"
}

# # Function: errval
# `errval` - Returns the numeric value associated with a log level.
#
# ## Description
# - **Purpose**: 
#   - Converts a text log level (like "DEBUG", "INFO", etc.) to its corresponding numeric value.
#   - Used internally to compare log levels for filtering messages.
# - **Usage**: 
#   - `errval <log_level>`
# - **Input Parameters**: 
#   - `log_level`: The text log level to convert. Supported values:
#     - DEBUG0-DEBUG9: Values 9-1 respectively
#     - DEBUG: Value 10
#     - INFO: Value 20
#     - WARNING/WARN: Value 30 
#     - ERROR: Value 40
#     - CRITICAL: Value 50
#     - SILENT: Value 99
# - **Output**: 
#   - Returns the numeric value corresponding to the provided log level.
# - **Exceptions**: 
#   - Returns empty if an invalid log level is provided.
#
errval() {
    declare -A message_class=(
        ["DEBUG9"]=1
        ["DEBUG8"]=2
        ["DEBUG7"]=2
        ["DEBUG6"]=3
        ["DEBUG5"]=4
        ["DEBUG4"]=5
        ["DEBUG3"]=6
        ["DEBUG2"]=7
        ["DEBUG1"]=8
        ["DEBUG0"]=9
        ["DEBUG"]=10
        ["INFO"]=20
        ["WARNING"]=30
        ["WARN"]=30
        ["ERROR"]=40
        ["CRITICAL"]=50
        ["SILENT"]=99
    )
    echo "${message_class[$1]}"
}


## Function: log_message
#  `log_message` - Prints a message to STDERR based on the provided log level.
# ## Description
# - **Purpose**: 
#   - Prints a message to STDERR if the provided log level is greater than or equal to the current
#     debug level. The lower the level, the more verbose the messages will be. 
# - **Usage**: 
#   - `log_message [-h] <log_level> <message>`
# - **Options**: 
#   - `-h`   Show this help message, though not usually used from the command line.
# - **Input Parameters**: 
#   - `log_level`: The log level to check against the debug level. Supported log levels are:
#     - `TRACE`
#     - `DEBUG10`-`DEBUG0`
#     - `DEBUG`  - used as a synonym for DEBUG10
#     - `INFO`
#     - `WARNING`
#     - `ERROR`
#     - `CRITICAL`
#     - `SILENT`
#   - `message`: The message to print if the log level is greater than or equal to the current debug level.
# - **Output**: 
#   - Prints a message to STDERR if the provided log level is greater than or equal to the current debug level.
log_message() {
    local OPTIND=1
    # Parse options
    while getopts "h" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    local message_level="$1"; shift
    local message_class
    message_class=$(errval "$message_level")
    local message_out="$*"

    # Check if the provided message level exists in the message_class array
    if [[ -z "${message_class+_}" ]]; then
        echo "($MY_NAME) WARNING: Unknown log level '$message_level'. Message: $message_out" >&2
        errno_exit 9
    fi

    # echo " LOG_MESSAGE CALLED: ${message_level} ${debug_level} ($MY_NAME): ${message_out}" >&2
    # Compare the current debug_level with the message's severity level
    if [ "$debug_level" -le "${message_class}" ]; then
        echo "$MY_NAME ${message_level}($debug_level): ${message_out}" >&2
    fi
}

## Initialization
# Determine the real path of the script
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
# Declare the global associative array if not already declared
if [[ -z "${__VENV_SOURCED+x}" ]]; then
    declare -Ag __VENV_SOURCED
fi
# Don't source this script if it's already been sourced.
if [[ -n "${__VENV_SOURCED["${THIS_SCRIPT}"]}" ]]; then
    echo "Skipping already sourced script: ${THIS_SCRIPT}"
    return 0
fi
__VENV_SOURCED["${THIS_SCRIPT}"]=1
echo "Sourcing: ${THIS_SCRIPT}"

# Extract script name, directory, and arguments
# MY_NAME appears unused. Verify use (or export if used externally).
# shellcheck disable=SC2034
MY_NAME=$(basename "${THIS_SCRIPT}")
__VENV_BIN=$(dirname "$(dirname "${THIS_SCRIPT}")")
__VENV_BASE=$(dirname "${__VENV_BIN}")
__VENV_ARGS=$*
__VENV_INCLUDE="${__VENV_BASE}/bin/shinclude"

# Add internal functions to the __VENV_INTERNAL_FUNCTIONS array.
# Quote to prevent word splitting/globbing, or split robustly with mapfile or read -a.
# shellcheck disable=SC2206
__VENV_INTERNAL_FUNCTIONS=(
    ${__VENV_INTERNAL_FUNCTIONS[@]}
    "errval"
)

# Set default debug level, if not already set.
debug_level=${debug_level:-30}

# Ensure util_funcs.sh is sourced for utility functions
if declare -f "source_util_script" >/dev/null 2>&1; then
    source_util_script "util_funcs"
    log_message "INFO" "Sourced util_funcs.sh"
else
    # shellcheck source=/dev/null
    source "${__VENV_INCLUDE}/util_funcs.sh"
    log_message "INFO" "Sourced ${__VENV_INCLUDE}/util_funcs.sh"
fi

__rc__=0
