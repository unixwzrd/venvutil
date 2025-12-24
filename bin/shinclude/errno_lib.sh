#!/usr/bin/env bash
# # Script: errno_lib.sh
# `errno_lib.sh` - Provides POSIX errno codes and utilities for Bash scripts
# ## Description
# - **Purpose**:
#   - Offers functions to retrieve and manage POSIX error codes within Bash scripts.
# ## Usage
#   - Source this script in your Bash scripts to utilize error code utilities.
#     ```bash
#     source /path/to/errno_lib.sh
#     ```
# ## Input Parameters
#   - None.
# ## Output
#   - Functions that output error codes and messages.
# ## Exceptions
#   - Returns specific error codes if system `errno.h` is not found or invalid errno codes are provided.
# ## Initialization
#   - Ensures the script is sourced only once and initializes necessary variables.
#
# ## Dependencies
# - `string_lib.sh` (for utility functions like `to_upper`)

## Initialization
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
if ! declare -p __VENV_SOURCED >/dev/null 2>&1; then declare -g -A __VENV_SOURCED; fi
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

# Get the string_lib.sh script
source_lib string_lib

# Get the helpsys_lib.sh script
# source_lib helpsys_lib

# Add internal functions to the __VENV_INTERNAL_FUNCTIONS array.
if ! declare -p __VENV_INTERNAL_FUNCTIONS >/dev/null 2>&1; then declare -ga __VENV_INTERNAL_FUNCTIONS; fi
# Quote to prevent word splitting/globbing, or split robustly with mapfile or read -a.
# shellcheck disable=SC2206
__VENV_INTERNAL_FUNCTIONS=(
    ${__VENV_INTERNAL_FUNCTIONS[@]}
    "errval"
)

# Set default debug level, if not already set.
if ! declare -p debug_level >/dev/null 2>&1; then declare -g debug_level=20; fi
# Return code
if ! declare -p __rc__ >/dev/null 2>&1; then declare -g __rc__=0; fi


# # Function set_debug
# `set_debug` - Sets the debug level for the script.
#
# ## Description
# - **Purpose**: 
#   - Sets the debug level for the script.
#   - Debug level may be given as a value between 0 and 99
#   - Debug level may be given as a text log level of the highest level to display:
#     DEBUG, INFO, WARNING, ERROR, CRITICAL, or SILENT
# - **Usage**: 
#   - `set_debug <debug_level>` 
# - **Input Parameters**: 
#   - `debug_level`: The debug level to set.
# - **Output**: 
#   - Sets the debug level for the script.
# - **Exceptions**: 
#   - Warns if invalid level provided and keeps previous level
set_debug() {
    __rc__=0
    local OPTIND=1
    while getopts "h" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; __rc__=0; return 0 ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; __rc__=22; return ${__rc__} ;;
        esac
    done
    shift $((OPTIND - 1))

    local new_level="$1"
    local current_level

    current_level="$debug_level"

    # Need to set this to 20 is it's not already set so INFO messages do not get suppressed
    debug_level=20

    # If numeric, validate range
    if [[ "$new_level" =~ ^[0-9]+$ ]]; then
        if ! [ "$new_level" -ge 0 ] && [ "$new_level" -le 99 ]; then
            log_message "WARNING" "Invalid debug level '$new_level'. Must be between 0-99. Keeping current level ($debug_level)."
            __rc__=22
        fi
    else
        new_level=$(errval "$new_level")
    fi

    if [ "$new_level" -eq "$current_level" ]; then
        log_message "INFO" "Debug level unchanged from current level $current_level"
    fi

    # Restore previous debug level
    debug_level="$new_level"

    return ${__rc__}
}


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

    if [ "$1" == "0" ]; then
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
        line=$(grep -wE "#define [A-Z0-9_]+[[:space:]]+$errno_code[[:space:]]" "$errno_file" | head -n 1)
        errno_code=$(echo "$line" | awk '{print $2}')
    else
        # Not using braces for that, it's a regular expression here.
        # Use braces when expanding arrays, e.g. ${array[idx]} (or ${var}[.. to quiet).
        # shellcheck disable=SC1087
        line=$(grep -wE "#define $errno_code[ \t]*" "$errno_file" | head -n 1)
    fi

    errno_num=$(echo "$line" | awk '{print $3}')
    errno_text=$(echo "$line" | sed -e 's/#define[ \t]*[A-Z0-9_]*[ \t]*[A-Z0-9_]*[ \t]*\/\* \(.*\) \*\//\1/')

    # If errno_num is not numeric, it's likely a macro reference
    if [[ "$errno_num" =~ ^[a-zA-Z]+$ ]]; then
        # Call errno with the macro name to get numeric value
        errno "$errno_num" >/dev/null 2>&1
        errno_num=$?
    fi

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
        errno_text=$(echo "$line" | sed -e 's/#define[ \t]*[A-Z0-9_]*[ \t]*[A-Z0-9_]*[ \t]*\/\* \(.*\) \*\//\1/')
        
        # If errno_num is not numeric, it's likely a macro reference
        if [[ "$errno_num" =~ ^[a-zA-Z]+$ ]]; then
            # Call errno with the macro name to get numeric value
            errno "$errno_num" >/dev/null 2>&1
            errno_num=$?
        fi
        
        echo "($errno_code: $errno_num): $errno_text"
    done

    __rc__=0
    return ${__rc__}
}

# # Function: errno_warn
#  `errno_warn` - Prints a warning message to STDERR and returns the error number.
# ## Description
# - **Purpose**: 
#   - Prints a warning message to STDERR using the provided error code and optional message.
#   - Sets the return code but does not exit the script.
#   - Accepts either POSIX error codes (e.g. EACCES) or error numbers (e.g. 13).
# - **Usage**: 
#   - `errno_warn <errno_code> [message]`
# - **Example**:
#   - `errno_warn EACCES "Failed to access file"`
#   - `errno_warn 13 "Permission denied"`
# - **Input Parameters**: 
#   - `errno_code`: The error code to use (POSIX name or number)
#   - `message`: (Optional) Additional message to include in the warning
# - **Output**: 
#   - Prints warning messages to STDERR including:
#     - Optional custom message if provided
#     - Call stack trace with function name, line number and file
#     - Error message corresponding to the error code
# - **Return Value**: 
#   - Returns the numeric error code
#
errno_warn() {
    __rc__=$1
    shift
    local message="$*"
    error_text=$(errno "${__rc__}"); __rc__=$?
    [ -n "${message}" ] && log_message "WARNING" "${message}"
    if [ "${FUNCNAME[1]}" != "_deprecated" ]; then
        log_message "WARNING" "FUNCTION: ${FUNCNAME[1]} LINE: ${BASH_LINENO[1]} FILE: ${BASH_SOURCE[-1]}"
    fi
    log_message "WARNING" "${error_text}"
    return "${__rc__}"
}

# # Function: errno_exit
#  `errno_exit` - Prints an error message to STDERR and exits with the error number.
# ## Description
# - **Purpose**: 
#   - Prints an error message to STDERR using the provided error code and optional message.
#   - Exits the script with the corresponding error number.
#   - Accepts either POSIX error codes (e.g. EACCES) or error numbers (e.g. 13).
# - **Usage**: 
#   - `errno_exit <errno_code> [message]`
# - **Example**:
#   - `errno_exit EACCES "Failed to access file"`
#   - `errno_exit 13 "Permission denied"`
# - **Input Parameters**: 
#   - `errno_code`: The error code to use (POSIX name or number)
#   - `message`: (Optional) Additional message to include in the error
# - **Output**: 
#   - Prints error messages to STDERR including:
#     - Optional custom message if provided
#     - Call stack trace with function name, line number and file
#     - Error message corresponding to the error code
# - **Exit Status**: 
#   - Exits with the numeric error code
#
errno_exit() {
    __rc__=$1
    shift
    local message="$*"
    error_text=$(errno "${__rc__}"); __rc__=$?
    [ -n "${message}" ] && log_message "ERROR" "${message}"
    log_message "ERROR" "FUNCTION: ${FUNCNAME[1]} LINE: ${BASH_LINENO[1]} FILE: ${BASH_SOURCE[-1]}"
    log_message "ERROR" "${error_text}"
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
    echo "${message_class[$1]:-debug_level}"
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
#
#  TODO Add option to specify a -l parameter for an optional log file
#
# Optional configuration (set these from the caller)
#   LOG_FILE=/path/to/file.log
#   LOG_PREFIX="setup"          # overrides script_name prefix if set
#   VERBOSE=true|false          # if true, tee to stderr and file
#   LOG_MKDIR=true|false        # auto mkdir -p dirname(LOG_FILE)

log_message() {
    local OPTIND=1
    while getopts "h" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    local message_level="$1"; shift
    local message_out="$*"

    local message_class
    message_class=$(errval "$message_level")

    local script_name
    script_name=$(basename "${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}")

    local prefix="${LOG_PREFIX:-$script_name}"
    local line="(${prefix}) ${message_level}(${message_class}): ${message_out}"

    local log_file="${LOG_FILE:-}"

    if [[ -z "${message_class+_}" ]]; then
        echo "(log_message) WARNING: Unknown log level '$message_level'. Message: $message_out" >&2
        errno_exit 9
    fi

    # severity gate (your existing behavior)
    if [[ "${debug_level:-999}" -gt "${message_class}" ]]; then
        return 0
    fi

    if [[ -n "$log_file" && "${LOG_MKDIR:-true}" == true ]]; then
        mkdir -p "$(dirname "$log_file")" 2>/dev/null || true
    fi

    if [[ "${VERBOSE:-false}" == true ]]; then
        if [[ -n "$log_file" ]]; then
            printf '%s\n' "$line" | tee -a "$log_file" >&2
        else
            printf '%s\n' "$line" >&2
        fi
    else
        if [[ -n "$log_file" ]]; then
            printf '%s\n' "$line" >>"$log_file"
        else
            printf '%s\n' "$line" >&2
        fi
    fi
}

# # Function _deprecated
# `_deprecated` - Prints a deprecation warning message to STDERR.
#
# ## Description
# - **Purpose**: 
#   - Prints a deprecation warning message to STDERR.
# - **Usage**: 
#   - `_deprecated <message>`
# - **Input Parameters**: 
#   - `message`: The message to print.
# - **Output**: 
#   - Prints a deprecation warning message to STDERR.
#
_deprecated() {
    errno_warn ENOTSUP "Function \"${FUNCNAME[1]}\" is deprecated. ${*}"
}

__rc__=0
return ${__rc__}