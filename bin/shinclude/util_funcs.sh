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
            __rc__=22   # EINVAL: Invalid Argument
            return ${__rc__}
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
# ## Description
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
    local stack_name=$1
    local stack_value=$2

    eval "${stack_name}+=(\"$stack_value\")"
    echo "PUSH ${stack_name}: ${stack_value}" >&2
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
    local popped_value

    # Dynamically get the length of the stack
    eval "local stack_length=\${#$stack_name[@]}"

    # Check if the stack is empty
    if [[ "${stack_length}" -eq 0 ]]; then
        echo "Stack is empty" >&2
        __rc__=1
        return ${__rc__}
    fi

    # Pop the last value and store to return top stack value
    eval "popped_value=\${${stack_name}[-1]}"

    # Calculate the index of the last element
    local last_index=$((stack_length - 1))

     # Remove the last element from the stack
    if [[ "${last_index}" -eq 0 ]]; then
        eval "unset ${stack_name} && declare -a ${stack_name}"
    else
        eval "${stack_name}=(\${${stack_name}[@]:0:${last_index}})"
    fi

    echo "POP ${stack_name}: ${popped_value}" >&2

    echo "${popped_value}"
    __rc__=0
    retuirn ${__rc__}
}

stack_op() {
#
# Function: stack_op
# Description: Performs stack operations such as push, pop, and debug on a given stack.
# - **Parameters**:
#   - stack_name: The name of the stack.
#   - action: The action to perform on the stack (push, pop, debug).
#   - value: The value to push onto the stack (required for push action).
# - **Returns**: 
#   - For the pop action, returns the popped value.
# - **Exceptions**:
#   - Returns an error message if an invalid action is provided.
#
    local stack_name=$1
    local action=$2
    local stack_value=$3
    case $action in
        "push")
            push_stack "$stack_name" "$stack_value"
            ;;
        "pop")
            stack_value=$(pop_stack "$stack_name")
            echo "%{stack_value}"      # Return the popped value
            ;;
        "debug")
            echo "***************************** STACK: ${stack_name} *****************************" >&2
            eval "echo \"\${${stack_name}[@]}\"" >&2 
            echo "***************************** STACK *****************************" >&2
            ;;
        *)
            errno_warn 78
            return $?
            ;;
    esac
}

stringclean() {
# Function: stringclean
#
# Description: Sanitizes a string by removing all characters except alphabets and numbers.
#
# Parameters:
#   - str: The string to sanitize.
#
# Returns: The sanitized string.
#
    local str="$1"
    echo "${str//[^a-zA-Z0-9]/}"
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