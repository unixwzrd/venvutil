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

__strip_space(){
#
# # `__strip_space` - Remove Leading and Trailing Whitespaces
# 
# ## Description
# - **Purpose**:
#   - Removes leading and trailing whitespaces from the input string.
# - **Usage**: 
#   - `__strip_space "string"`
# - **Input Parameters**: 
#   - `str`: The string from which to remove leading and trailing whitespaces.
# - **Output**: 
#   - A new string with whitespaces removed from both ends.
# - **Exceptions**: None.
# 
    local argstring="$*"
    echo ${argstring}
}

__zero_pad(){
# 
# # `__zero_pad` - Pad a Single-Digit Number with a Leading Zero
# 
# ## Description
# - **Purpose**:
#   - The `__zero_pad` function pads a given number with a leading zero if it's a single-digit number, ensuring consistent formatting for numerical values.
# - **Usage**: 
#   - Call the function with a number to add a leading zero if it is a single digit. For example:
#     ```bash
#     padded_number=$(__zero_pad "5")
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

__next_step(){
#
# __next_step - Increment a given sequence number by 1 and pad it with a zero if needed.
#
# - **Purpose**:
#
#   - Increment a given sequence number by 1 and pad it with a zero if needed.
#
# - **Usage**: 
#
#   - __next_step "[0-99]"
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
    echo "$(__zero_pad ${sn})"
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
    local i j temp1 temp2 len

    # Assign named array to local array
    eval "local_array=(\"\${$array_name[@]}\")"
    len=${#local_array[@]}

    for ((i=2; i<len; i+=2)); do
        temp1=${local_array[i]}
        temp2=${local_array[i+1]}

        # Find the correct position for temp1, temp2 by comparing with all preceding pairs
        j=i
        while [[ j -ge 2 ]]; do
            if [[ ${local_array[j-2]} > $temp1 ]]; then
                # Shift the pair at j-2 forward to make room for temp1, temp2
                local_array[j]=${local_array[j-2]}
                local_array[j+1]=${local_array[j-1]}
                j=$((j-2))
            else
                # Correct position found, break the loop
                break
            fi
        done

        # Place temp1, temp2 in their correct position
        local_array[j]=$temp1
        local_array[j+1]=$temp2
    done

    # Assign sorted local array back to original named array
    eval "${array_name}=(\"\${local_array[@]}\")"

}


push_stack() {
#
# # `push_stack` - Push a Value onto a Named Stack
# 
# #### Description
# - **Purpose**:
#   - Pushes a value onto a named stack.
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
    local arr_name=$1
    eval "local len=\${#${arr_name}[@]}"
    if [ $len -eq 0 ]; then
        echo "Stack is empty"
        return 1
    fi
    local last_index=$(($len - 1))
    eval "local popped_value=\${${arr_name}[$last_index]}"
    eval "unset '${arr_name}[$last_index]'"
    echo "$popped_value"
}
