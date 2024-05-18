#!/usr/bin/env bash

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

# Check if the function errno is already defined and if it has return 0
if declare -f errno &> /dev/null; then
    return 0
fi

# Function: errno
#
# Provides POSIX errno codes and values for use in scripts or lookup of error codes on th ecommand line.
#
# Description: This function takes an errno code or errno number and prints the corresponding error message to STDOUT. Sets the exit code to the errno value and returns, unless there is an internal error.
#
# Usage: errno [errno_code|errno_number]
#
# Example: errno EACCES
#
# Returns: "error_code: error_text"
#
# Errors: 2, 22
#   2: Could not find system errno.h
#  22: Invalid errno name
#
function errno() {
    # Usage: errno [errno_code|errno_number]
    if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        echo "Usage: errno [errno_code|errno_number]"
        echo "Example: errno EACCES"
        return 0
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
        return 2
    fi

    local line errno_num errno_text

    if [[ "$errno_code" =~ ^[0-9]+$ ]]; then
        line=$(grep -wE "#define [A-Z_]*[ \t]*\b$errno_code\b" "$errno_file")
        errno_code=$(echo "$line" | awk '{print $2}')
    else
        line=$(grep -wE "#define $errno_code[ \t]*" "$errno_file")
    fi

    errno_num=$(echo "$line" | awk '{print $3}')
    errno_text=$(echo "$line" | sed -e 's/#define[ \t]*[A-Z0-9_]*[ \t]*[0-9]*[ \t]*\/\* \(.*\) \*\//\1/')

    if [ -z "$errno_num" ]; then
        echo "Error: Invalid errno code $errno_code" >&2
        return 22
    else
        echo "($errno_code: $errno_num): $errno_text"
        return "$errno_num"
    fi
}

# Function: to_upper
#
# Description: This function converts a string to uppercase
#
# Usage: to_upper <string>
#
# Example: to_upper "hello"
#
# Returns: "HELLO"
#
# Errors: None
#
function to_upper() {
    local str="$1"
    echo "${str^^}"
}

# Function: warn_errno
#
# Description: This function prints a warning using the errno function to STDERR and returns the error number
#
# Usage: warn <errno_code>
#
function errno_warn() {
    echo "WARNING: $(errno "$@")" >&2
    return $?
}

# Function: exit_errno
#
# Description: This function prints an error to STDERROR using the errno function and exits with the error number
#
# Usage: warn <errno_code>
#
function errno_exit() {
    echo "ERROR: $(errno "$@")" >&2
    exit $?
}
