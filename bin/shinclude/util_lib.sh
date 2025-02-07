#!/usr/bin/env bash
# # Script: util_lib.sh
# `util_lib.sh` - Utility Functions for Bash Scripts
# ## Description
# - **Purpose**:
#   - Provides a collection of utility functions to assist in various common tasks within Bash scripting. These functions offer streamlined solutions for string manipulation, number padding, and stack operations, enhancing the efficiency and readability of Bash scripts that incorporate them.
# - **Usage**: 
#   - Source this script within other Bash scripts to make the utility functions available for use:
#     ```bash
#     source /path/to/util_lib.sh
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

## Initialization
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
if ! declare -p __VENV_SOURCED >/dev/null 2>&1; then declare -gA __VENV_SOURCED; fi
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

# get the string_lib.sh script
source_lib string_lib

# Add internal functions to the __VENV_INTERNAL_FUNCTIONS array.
if ! declare -p __VENV_INTERNAL_FUNCTIONS >/dev/null 2>&1; then declare -ga __VENV_INTERNAL_FUNCTIONS; fi
# shellcheck disable=SC2206
__VENV_INTERNAL_FUNCTIONS=(
    ${__VENV_INTERNAL_FUNCTIONS[@]}
)

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
#   - Sorts a two-dimensional array in Bash. It's useful for organizing data that
#     is stored in a format of paired elements. the first "column" or element is in element number
#     `n` and the second column is in element number `n+1`. This shows the one dimensional structure
#     of the array mapped to the two dimensions of the array.
#       n  |  n+1
#     ----------------------------
#      0  |  1
#      1  |  2
#      3  |  4
#   - The array will be sorted on the "first" column
# - **Usage**: 
#   - `sort_2d_array [-h] "array_name"`
# - **Options**: 
#   - `-h`   Show this help message
# - **Input Parameters**: 
#   - `array_name`: The name of the array variable that needs to be sorted.
# - **Output**: 
#   - The original array sorted based on the specified criteria.
# - **Exceptions**: 
#   - Handles exceptions or errors that may arise during the sorting process (to be detailed based on function's implementation).
#
sort_2d_array() {
    local OPTIND=1
    # Parse options
    while getopts "h" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

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
#   - `push_stack [-h] "stack_name" "value"`
# - **Options**: 
#   - `-h`   Show this help message
# - **Input Parameters**: 
#   - `stack_name`: The name of the stack array.
#   - `value`: The value to push onto the stack.
# - **Output**: 
#   - Modifies the named stack by adding a new element.
# - **Exceptions**: 
#   - None.
#
push_stack() {
    local OPTIND=1
    # Parse options
    while getopts "h" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

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
#   - `pop_stack [-h] "stack_name"`
# - **Options**: 
#   - `-h`   Show this help message
# - **Input Parameters**: 
#   - `stack_name`: The name of the stack array.
# - **Output**: 
#   - Removes and returns the top element from the named stack.
# - **Exceptions**: 
#   - Returns an error message and error code 1 if the stack is empty.
#
pop_stack() {
    local OPTIND=1
    # Parse options
    while getopts "h" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    local stack_name="$1"
    local popped_value

    # Dynamically get the length of the stack
    eval "local stack_length=\${#${stack_name}[@]}"

    # Check if the stack is empty - SC complains, but it's done in the eval above.
    # shellcheck disable=SC2154
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
#   - `stack_op [-h] <action> <stack_name> [value]`
# - **Options**: 
#   - `-h`   Show this help message
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
    local OPTIND=1
    # Parse options
    while getopts "h" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

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

# # Function: ptree
# `ptree` - Display the Process Tree for a Given PID
#
# ## Description
# - **Purpose**:
#   - Recursively displays the process tree starting from a given PID.
# - **Usage**: 
#   - `ptree [-h] 1234`
# - **Options**: 
#   - `-h`   Show this help message
# - **Input Parameters**: 
#   - `pid`: The Process ID to start the tree from.
#   - `indent` (optional): Indentation string for formatting.
# - **Output**: 
#   - A hierarchical display of processes starting from the specified PID.
# - **Exceptions**: 
#   - None.
#
ptree() {
    local OPTIND=1
    # Parse options
    while getopts "h" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    local pid="$1"
    local indent="${2:-" "}"
    
    # Get terminal width
    local term_width
    term_width=$(tput cols)

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

__rc__=0
return ${__rc__}
