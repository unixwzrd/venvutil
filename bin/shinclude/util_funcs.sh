#!/bin/bash
#
# util_funcs.sh - Utility Functions for Bash Scripts
#
# - **Purpose**: This script provides a collection of utility functions that can be sourced and used in other bash scripts.
# - **Usage**: 
#     - Source this script in other bash scripts to import the utility functions.
#     - For example, in another script: `source util_funcs.sh`.
# - **Input Parameters**: 
#     None
# - **Output**: 
#     - Provides utility functions for use in other bash scripts. Functions include string manipulation, number padding, and stack operations.
# - **Exceptions**: 
#     - Some functions may return specific error codes. Refer to individual function documentation for details.
#

# Capture the fully qualified path of the sourced script
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
# Don't source this script if it's already been sourced.
[[ "${_SOURCED_LIST}" =~ "${THIS_SCRIPT}" ]] && return || _SOURCED_LIST="${_SOURCED_LIST} ${THIS_SCRIPT}"
echo "Sourcing: ${THIS_SCRIPT}"

INTERNAL_FUNCTIONS=(
    ${INTERNAL_FUNCTIONS[@]}
)

# Utility functions

__strip_space(){
#
# __strip_space - Remove leading and trailing whitespaces from the input string.
#
# - **Purpose**:
#   - Remove leading and trailing whitespaces from the input string.
# - **Usage**: 
#   - __strip_space "string"
# - **Input Parameters**: 
#   1. `str` (string) - The string from which to remove leading and trailing whitespaces.
# - **Output**: 
#   - A new string with whitespaces removed from both ends.
# - **Exceptions**: None
#
    local argstring="$*"
    echo ${argstring}
}

__zero_pad(){
#
# __zero_pad - Pad a given number with a leading zero if it's a single-digit number.
#
# - **Purpose**:
#   - Pad a given number with a leading zero if it's a single-digit number.
# - **Usage**: 
#   - __zero_pad "nn"
# - **Input Parameters**: 
#   1. `num` (integer) - The number to pad. Can be single or double-digit.
# - **Output**: 
#   - The padded number as a string.
#   - If no number is specified, it will default to 00.
# - **Exceptions**: None
#
    local num="$1"
    printf "%02d" "${num}"
}

__next_step(){
#
# __next_step - Increment a given sequence number by 1 and pad it with a zero if needed.
#
# - **Purpose**:
#   - Increment a given sequence number by 1 and pad it with a zero if needed.
# - **Usage**: 
#   - __next_step "[0-99]"
# - **Scope**: Local. Modifies no global variables.
# - **Input Parameters**: 
#   1. `sequenceNum` (integer) - The sequence number to increment. Must be between 00 and 99.
# - **Output**: 
#   - The next sequence number as a string, zero-padded if necessary.
# - **Exceptions**: 
#   - Returns an error code 22 if the sequence number is not between 00 and 99. Error 22 means "Invalid Argument".
#
    local sn="$1"
    case "$sn" in
       ""|[[:space:]]* )
          sn=0
          ;;
       [0-9]|[0-9][0-9] )
          ((sn++))
          ;;
       *)
          echo "Exception, sequence must be a value between 00 and 99." >&2
          return 22 # EINVAL: Invalid Argument
          ;;
    esac
    echo "$(__zero_pad ${sn})"
}

push_stack() {
#
# push_stack - Push a value onto a named stack.
#
# - **Purpose**:
#   - Push a value onto a named stack.
# - **Usage**: 
#   - push_stack "stack_name" "value"
# - **Scope**:
#   - Local. However, the stack name can be a global variable, making the stack globally accessible.
# - **Input Parameters**: 
#   1. `stack_name` (string) - The name of the stack array.
#   2. `value` - The value to push onto the stack.
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
# pop_stack - Pop a value from a named stack.
#
# - **Purpose**:
#   - Pop a value from a named stack.
# - **Usage**: 
#   - pop_stack "stack_name"
# - **Scope**:
#   - Local. However, the stack name can be a global variable, making the stack globally accessible.
# - **Input Parameters**: 
#   1. `stack_name` (string) - The name of the stack array.
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
