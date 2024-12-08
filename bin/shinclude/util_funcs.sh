#!/bin/bash

# # Script: util_funcs.sh
# `util_funcs.sh` - Utility Functions for Bash Scripts
# ## Description
# - **Purpose**:
#   - Provides a collection of utility functions to assist in various common tasks within Bash scripting. These functions offer streamlined solutions for string manipulation, number padding, and stack operations, enhancing the efficiency and readability of Bash scripts that incorporate them.
# - **Usage**: 
#   - Source this script within other Bash scripts to make the utility functions available for use:
#     ```bash
#     source /path/to/util_funcs.sh
#     ```
# - **Input Parameters**: 
#   - None. This script is intended to be sourced by other scripts and does not require input parameters.
# - **Output**: 
#   - Provides utility functions that can be called from other Bash scripts.
# - **Exceptions**: 
#   - Some functions within the script may return specific error codes depending on their internal logic. Refer to the individual function documentation for detailed exception handling.
#
# ## Dependencies
# - None explicitly stated. The script is designed to be self-contained, relying only on standard Bash features.

# Capture the fully qualified path of the sourced script
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
# Don't source this script if it's already been sourced.
[[ "${__VENV_SOURCED_LIST}" =~ "${THIS_SCRIPT}" ]] && return || __VENV_SOURCED_LIST="${__VENV_SOURCED_LIST} ${THIS_SCRIPT}"
echo "Sourcing: ${THIS_SCRIPT}"

__VENV_INTERNAL_FUNCTIONS=(
    ${__VENV_INTERNAL_FUNCTIONS[@]}
)

# Utility functions

# # Function: strip_space
# `strip_space` - Remove Leading and Trailing Whitespaces
#
# ## Description
# - **Purpose**: 
#   - Removes leading and trailing spaces from the input string.
# - **Usage**: 
#   - `strip_space "  string  "`
# - **Input Parameters**: 
#   - `str`: The string from which to remove leading and trailing whitespaces.
# - **Output**: 
#   - A new string with whitespaces removed from both ends.
# - **Exceptions**: 
#   - None.
#
strip_space() {
    local argstring="$*"
    # Remove leading and trailing whitespaces
    echo "$argstring" | sed 's/^ *//;s/ *$//'
}

# # Function: zero_pad
# `zero_pad` - Pad a Single-Digit Number with a Leading Zero
#
# ## Description
# - **Purpose**: 
#   - Pads a given number with a leading zero if it's a single-digit number, ensuring consistent formatting for numerical values.
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
zero_pad() {
    local num="$1"
    printf "%02d" "${num}"
}

# # Function: next_step
# `next_step` - Increment a Given Sequence Number by 1 and Pad it with a Zero if Needed
#
# ## Description
# - **Purpose**:
#   - Increments a given sequence number by 1 and pads it with a zero if necessary.
# - **Usage**: 
#   - `next_step "09"`
# - **Scope**: 
#   - Local. Modifies no global variables.
# - **Input Parameters**: 
#   1. `sequenceNum` (integer) - The sequence number to increment. Must be between 00 and 99.
# - **Output**: 
#   - The next sequence number as a string, zero-padded if necessary.
# - **Exceptions**: 
#   - Returns an error code 22 if the sequence number is not between 00 and 99. Error 22 means "Invalid Argument".
#
next_step() {
    local sn="$1"
    case "$sn" in
        ""|[[:space:]]*)
            sn=0
            ;;
        [0-9]|[0-9][0-9])
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

# # Function: sort_2d_array
# `sort_2d_array` - Sort a Two-Dimensional Array
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
sort_2d_array() {
    local array_name="$1"
    local i j temp1 temp2 len temp_array

    # Assign named array to local array
    eval "temp_array=(\"\${${array_name}[@]}\")"
    len=${#temp_array[@]}

    for ((i=2; i<len; i+=2)); do
        temp1=${temp_array[i]}
        temp2=${temp_array[i+1]}

        # Find the correct position for temp1, temp2 by comparing with all preceding pairs
        j=i
        while [[ j -ge 2 ]]; do
            if [[ ${temp_array[j-2]} > "$temp1" ]]; then
                # Shift the pair at j-2 forward to make room for temp1, temp2
                temp_array[j]=${temp_array[j-2]}
                temp_array[j+1]=${temp_array[j-1]}
                j=$((j-2))
            else
                # Correct position found, break the loop
                break
            fi
        done

        # Place temp1, temp2 in their correct position
        temp_array[j]=$temp1
        temp_array[j+1]=$temp2
    done

    # Assign sorted local array back to original named array
    eval "${array_name}=(\"\${temp_array[@]}\")"
}

# # Function: push_stack
# `push_stack` - Push a Value onto a Named Stack
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
# - **Exceptions**: 
#   - None.
#
push_stack() {
    local stack_name="$1"
    local stack_value="$2"

    eval "${stack_name}+=(\"$stack_value\")"
    # echo "PUSH ${stack_name}: ${stack_value}" >&2
}

# # Function: pop_stack
# `pop_stack` - Pop a Value from a Named Stack
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
pop_stack() {
    local stack_name="$1"
    local popped_value

    # Dynamically get the length of the stack
    eval "local stack_length=\${#${stack_name}[@]}"

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

    __sv__="${popped_value}"
    __rc__=0
    return ${__rc__}
}

# # Function: stack_op
# `stack_op` - Perform Stack Operations
#
# ## Description
# - **Purpose**:
#   - Performs stack operations such as push, pop, and debug on a given stack.
# - **Usage**: 
#   - `stack_op <action> <stack_name> [value]`
# - **Input Parameters**: 
#   - `action`: The action to perform on the stack (`push`, `pop`, `debug`).
#   - `stack_name`: The name of the stack array.
#   - `value`: The value to push onto the stack (required for `push` action).
# - **Output**: 
#   - Executes the specified stack operation.
# - **Exceptions**: 
#   - Returns an error if an invalid action is provided.
#
stack_op() {
    local action="$1"
    local stack_name="$2"
    local stack_value="$3"
    case "$action" in
        "push")
            push_stack "$stack_name" "$stack_value"
            ;;
        "pop")
            pop_stack "$stack_name"
            echo "${__sv__}"      # Return the popped value
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

# # Function: stringclean
# `stringclean` - Sanitize a String by Removing Non-Alphanumeric Characters
#
# ## Description
# - **Purpose**:
#   - Sanitizes a string by removing all characters except alphabets and numbers.
# - **Usage**: 
#   - `cleaned_str=$(stringclean "Hello, World!")`
# - **Input Parameters**: 
#   - `str`: The string to sanitize.
# - **Output**: 
#   - The sanitized string containing only alphanumeric characters.
# - **Exceptions**: 
#   - None.
#
stringclean() {
    local str="$1"
    echo "${str//[^a-zA-Z0-9]/}"
}

# # Function: to_upper
# `to_upper` - Convert a String to Uppercase
#
# ## Description
# - **Purpose**:
#   - Converts a string to uppercase.
# - **Usage**: 
#   - `upper_str=$(to_upper "hello")`
# - **Input Parameters**: 
#   - `str`: The string to convert.
# - **Output**: 
#   - The uppercase version of the input string.
# - **Exceptions**: 
#   - None.
#
to_upper() {
    local str="$1"
    echo "${str^^}"
}

# # Function: ptree
# `ptree` - Display the Process Tree for a Given PID
#
# ## Description
# - **Purpose**:
#   - Recursively displays the process tree starting from a given PID.
# - **Usage**: 
#   - `ptree 1234`
# - **Input Parameters**: 
#   - `pid`: The Process ID to start the tree from.
#   - `indent` (optional): Indentation string for formatting.
# - **Output**: 
#   - A hierarchical display of processes starting from the specified PID.
# - **Exceptions**: 
#   - None.
#
ptree() {
    local pid="$1"
    local indent="${2:-" "}"
    
    # Get terminal width
    local term_width=$(tput cols)

    # Calculate effective width for command output
    local effective_width=$((term_width - ${#indent} - 14))

    # Display the current process with indentation and truncate command based on effective width
    ps -o pid,ppid,command -p "$pid" | awk -v indent="$indent" -v width="$effective_width" 'NR>1 {printf "%s%s %s %s\n", indent, $1, $2, substr($0, index($0,$3), width)}'

    # Get child processes
    local children
    children=$(pgrep -P "$pid")

    # Recurse for each child process
    for child in $children; do
        ptree "$child" "  $indent"
    done
}

# # Function: var_type
# `var_type` - Get the Type of a Variable
#
# ## Description
# - **Purpose**:
#   - Retrieves the type of a variable.
# - **Usage**: 
#   - `var_type=$(var_type "var_name")`
# - **Input Parameters**: 
#   - `var_name`: The name of the variable.
# - **Output**: 
#   - The type of the variable as a string. Can be one of `array`, `associative`, `scalar`, or `unknown`.
# - **Exceptions**: 
#   - None.
var_type() {
    local var_name="$1"
    local var_type=$(declare -p "$var_name" 2>/dev/null | cut -d ' ' -f 2) 
    case "$var_type" in
        -a)
            echo "array"
            ;;
        -A)
            echo "associative"
            ;;
        --)
            echo "scalar"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}