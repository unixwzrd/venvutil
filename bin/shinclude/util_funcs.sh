#!/bin/bash
#
# # `util_funcs.sh` - Utility Functions for Bash Scripts
# 
# ## Description
# - **Purpose**:
#   - `util_funcs.sh` offers a collection of utility functions to assist in various common tasks within bash scripting. These functions provide streamlined solutions for string manipulation, number padding, and stack operations, enhancing the efficiency and readability of bash scripts that incorporate them.
# - **Usage**: 
#   - Source this script within other bash scripts to make the utility functions available for use:
#     ```bash
#     source /path/to/util_funcs.sh
#     ```
# - **Input Parameters**: 
#   - None. This script does not require input parameters as it is intended to be sourced by other scripts.
# - **Output**: 
#   - Provides utility functions that can be called from other bash scripts.
# - **Exceptions**: 
#   - Some functions within the script may return specific error codes depending on their internal logic. Refer to the individual function documentation for detailed exception handling.
# 
# ## Dependencies
# - None explicitly stated. The script is designed to be self-contained, relying only on standard bash features.
# 

# Capture the fully qualified path of the sourced script
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
# Don't source this script if it's already been sourced.
[[ "${__VENV_SOURCED_LIST}" =~ "${THIS_SCRIPT}" ]] && return || __VENV_SOURCED_LIST="${__VENV_SOURCED_LIST} ${THIS_SCRIPT}"
echo "Sourcing: ${THIS_SCRIPT}"

__VENV_INTERNAL_FUNCTIONS=(
    ${__VENV_INTERNAL_FUNCTIONS[@]}
)

# Utility functions

strip_space(){
#
# # `strip_space` - Remove Leading and Trailing Whitespaces
# 
# ## Description
# - **Purpose**:
#   - Removes leading and trailing spaces from the input string. 
# - **Usage**: 
#   - `strip_space "string"`
# - **Input Parameters**: 
#   - `str`: The string from which to remove leading and trailing whitespaces.
# - **Output**: 
#   - A new string with whitespaces removed from both ends.
# - **Exceptions**: None.
# 
    local argstring="$*"
    echo ${argstring}
}

zero_pad(){
# 
# # `zero_pad` - Pad a Single-Digit Number with a Leading Zero
# 
# ## Description
# - **Purpose**:
#   - The `zero_pad` function pads a given number with a leading zero if it's a single-digit number, ensuring consistent formatting for numerical values.
# - **Usage**: 
#   - Call the function with a number to add a leading zero if it is a single digit. For example:
#     ```bash
#     padded_number=$(zero_pad "5")
#     # Returns "05"
#     ```
# - **Input Parameters**: 
#   - `nn`: A number that needs padding.
# - **Output**: 
#   - A string representation of the number, padded with a leading zero if it was a single digit.
# - **Exceptions**: 
#   - None. The function handles single-digit numbers and does not modify numbers with two or more digits.
# 
    local num="$1"
    printf "%02d" "${num}"
}

next_step(){
#
# next_step - Increment a given sequence number by 1 and pad it with a zero if needed.
#
# - **Purpose**:
#
#   - Increment a given sequence number by 1 and pad it with a zero if needed.
#
# - **Usage**: 
#
#   - next_step "[0-99]"
#
# - **Scope**: Local. Modifies no global variables.
#
# - **Input Parameters**: 
#
#   1. `sequenceNum` (integer) - The sequence number to increment. Must be between 00 and 99.
#
# - **Output**: 
#
#   - The next sequence number as a string, zero-padded if necessary.
#
# - **Exceptions**: 
#
#   - Returns an error code 22 if the sequence number is not between 00 and 99. Error 22 means "Invalid Argument".
#
    local sn="$1"
    case "$sn" in
        ""|[[:space:]]* )
            sn=0
            ;;
       [0-9]|[0-9][0-9] )
            sn=$((10#${sn}))
            ((sn++))
            ;;
       *)
            echo "Exception, sequence must be a value between 00 and 99." >&2
            return 22 # EINVAL: Invalid Argument
            ;;
    esac
    echo "$(zero_pad ${sn})"
}

sort_2d_array() {
# 
# # `sort_2d_array` - Sort a Two-Dimensional Array
# 
# ## Description
# - **Purpose**:
#   - Sorts a two-dimensional array in Bash. It's particularly useful for organizing data that is stored in a format of paired elements.
# - **Usage**: 
#   - This function can be used to sort arrays where each element consists of a pair of values (e.g., key-value pairs). It's beneficial in scenarios where data needs to be sorted based on one of the dimensions.
# - **Input Parameters**: 
#   - `array_name`: The name of the array variable that needs to be sorted.
# - **Output**: 
#   - The original array sorted based on the specified criteria.
# - **Exceptions**: 
#   - Handles exceptions or errors that may arise during the sorting process (to be detailed based on function's implementation).
# 
    local -a array_name=$1
    local i j temp1 temp2 len temp_arary

    # Assign named array to local array
    eval "temp_arary=(\"\${$array_name[@]}\")"
    len=${#temp_arary[@]}

    for ((i=2; i<len; i+=2)); do
        temp1=${temp_arary[i]}
        temp2=${temp_arary[i+1]}

        # Find the correct position for temp1, temp2 by comparing with all preceding pairs
        j=i
        while [[ j -ge 2 ]]; do
            if [[ ${temp_arary[j-2]} > $temp1 ]]; then
                # Shift the pair at j-2 forward to make room for temp1, temp2
                temp_arary[j]=${temp_arary[j-2]}
                temp_arary[j+1]=${temp_arary[j-1]}
                j=$((j-2))
            else
                # Correct position found, break the loop
                break
            fi
        done

        # Place temp1, temp2 in their correct position
        temp_arary[j]=$temp1
        temp_arary[j+1]=$temp2
    done

    # Assign sorted local array back to original named array
    eval "${array_name}=(\"\${temp_arary[@]}\")"

}


push_stack() {
#
# # `push_stack` - Push a Value onto a Named Stack
# 
# #### Description
# - **Purpose**:
#   - Pushes a value onto a named stack (added to the end of the stack). 
# - **Usage**: 
#   - `push_stack "stack_name" "value"`
# - **Input Parameters**: 
#   - `stack_name`: The name of the stack array.
#   - `value`: The value to push onto the stack.
# - **Output**: 
#   - Modifies the named stack by adding a new element.
# - **Exceptions**: None.
#
    local arr_name=$1
    local value=$2
    eval "${arr_name}+=(\"$value\")"
}

pop_stack() {
#
# # `pop_stack` - Pop a Value from a Named Stack
# 
# ## Description
# - **Purpose**:
#   - Pops a value from a named stack.
# - **Usage**: 
#   - `pop_stack "stack_name"`
# - **Input Parameters**: 
#   - `stack_name`: The name of the stack array.
# - **Output**: 
#   - Removes and returns the top element from the named stack.
# - **Exceptions**: 
#   - Returns an error message and error code 1 if the stack is empty.
# 
    local stack_name=$1
    local popped_value=""
    local i=0

    # Dynamically get the length of the stack
    eval "local stack_length=\${#$stack_name[@]}"

    # Check if the stack is empty
    if [[ "${stack_length}" -eq 0 ]]; then
        echo "Stack is empty"
        return 1
    fi

    # Use a for loop to rebuild the stack without the last element
    for ((i = 0; i < "${stack_length}" - 1; i++)); do
        eval "stack_temp[i]=\${${stack_name}[i]}"
    done

    # Pop the last value
    eval "popped_value=\${${stack_name}[${stack_length} - 1]}"

    # Reassign the modified array back to the original stack name
    eval "$stack_name=(\"\${stack_temp[@]}\")"

    echo "$popped_value"
}

stack_op() {
#
# Function: stack_op
# Description: Performs stack operations such as push, pop, and debug on a given stack.
# Parameters:
#   - stack_name: The name of the stack.
#   - action: The action to perform on the stack (push, pop, debug).
#   - value: The value to push onto the stack (required for push action).
# Returns: None
    local stack_name=$1
    local action=$2
    local value=$3
    case $action in
        "push")
            push_stack "$stack_name" "$value"
            ;;
        "pop")
            pop_stack "$stack_name"
            ;;
        "debug")
            echo "***************************** STACK: ${stack_name} *****************************"
            eval "echo \${${stack_name}[@]}"
            echo "***************************** STACK *****************************"
            ;;
        *)
            echo "Invalid action: $action"
            return 1
            ;;
    esac
}

stringclean() {
#
# Function: stringclean
# Description: Sanitizes a string by removing all characters except alphabets and numbers.
# Parameters:
#   - str: The string to sanitize.
# Returns: The sanitized string.
    local str="$1"
    echo "${str//[^a-zA-Z0-9]/}"
}

function errno() {
#
# Function: errno
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
