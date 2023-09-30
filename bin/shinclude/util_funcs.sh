#!/bin/bash
# Capture the fully qualified path of the sourced script
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
# Don't source this script if it's already been sourced.
[[ "${_SOURCED_LIST}" =~ "${THIS_SCRIPT}" ]] && return || _SOURCED_LIST="${_SOURCED_LIST} ${THIS_SCRIPT}"
echo "Sourcing:${THIS_SCRIPT}"


# Utility functions

# Source scripts variable
SOURCE_SCRIPTS="${BASH_SOURCE[@]}"

# Define an array of internal functions to exclude from help and documentation
INTERNAL_FUNCTIONS=("init_help_system" "help_functions" "help" "generate_markdown")

# Initialize a single array to store function names and their corresponding documentation
declare -a FUNC_ARRAY

# Function to populate function names and their docs
init_help_system() {
    [[ -n "${FUNC_ARRAY[*]}" ]] && return

    local script
    local func
    local doc

    for script in ${BASH_SOURCE[@]}; do
        while IFS= read -r func; do
            if [[ ! " ${FUNC_ARRAY[*]} " =~ " ${func} " ]]; then
                doc=$(awk "BEGIN{flag=0} /^${func}\(\)/ {flag=1} /^#/ {if (flag) print substr(\$0, 3)} /^[a-zA-Z0-9_]+\(\)/ {if (\$0 !~ /^${func}\(\)/) flag=0}" "${script}")
                FUNC_ARRAY+=("${func}")
                FUNC_ARRAY+=("${doc}")
            fi
        done < <(awk -F'[(]' '/^[a-zA-Z0-9_]+\(\)/ {print $1}' "${script}")
    done

    # Sort FUNC_ARRAY based on function names while keeping them paired with their descriptions
    for ((i=0; i<${#FUNC_ARRAY[@]}; i+=2)); do
        for ((j=0; j<${#FUNC_ARRAY[@]}-2; j+=2)); do
            if [[ "${FUNC_ARRAY[j]}" > "${FUNC_ARRAY[j+2]}" ]]; then
                # Swap function names
                temp="${FUNC_ARRAY[j]}"
                FUNC_ARRAY[j]="${FUNC_ARRAY[j+2]}"
                FUNC_ARRAY[j+2]="$temp"
                
                # Swap corresponding docs
                temp="${FUNC_ARRAY[j+1]}"
                FUNC_ARRAY[j+1]="${FUNC_ARRAY[j+3]}"
                FUNC_ARRAY[j+3]="$temp"
            fi
        done
    done
}

# Call the initialization function
init_help_system

# Function to display general help
help_functions() {
    echo -e "\nUse 'help function_name' for detailed information on each function.\n"
    for func in "${FUNC_NAMES[@]}"; do
        echo "  - ${func}"
    done
    echo ""
}

help(){
    do_help "$@" | (command -v glow > /dev/null 2>&1 && glow || cat )
}

# Function to generate the appropriate help information for a specific function
do_help(){
    local func=$1

    # Generate the markdown if requested.
    if [[ "${func}" == "generate_markdown" ]]; then
        generate_markdown
        return
    fi
    local func=$1

    if [[ -z "${func}" ]]; then
        echo -e "\nUse 'help function_name' for detailed information on each function.\n"
        for ((i=0; i<${#FUNC_ARRAY[@]}; i+=2)); do
            echo "  - ${FUNC_ARRAY[i]}"
        done
        echo ""
        return
    fi

    for ((i=0; i<${#FUNC_ARRAY[@]}; i+=2)); do
        if [[ "${FUNC_ARRAY[i]}" == "${func}" ]]; then
            echo -e "${FUNC_ARRAY[i+1]}"
            return
        fi
        echo ""
    done

    echo "Function not found."
}




# Function to generate Markdown documentation
generate_markdown(){
    local all_funcs=()
    local seen_funcs=()  # To keep track of functions already documented

    echo "# Function Documentation" 

    # Iterate over all source scripts to read functions
    for script in ${SOURCE_SCRIPTS}; do
        script_funcs=($(awk -F'[(]' '/^[a-zA-Z0-9_]+\(\)/ {print $1}' "${script}"))
        all_funcs=("${all_funcs[@]}" "${script_funcs[@]}")
    done

    # Deduplicate function names
    all_funcs=($(printf "%s\n" "${all_funcs[@]}" | sort -u))

    for func in "${all_funcs[@]}"; do
        if [[ ! " ${seen_funcs[@]} " =~ " ${func} " ]]; then  # Skip if already documented
            if [[ "${func}" != "init_help_system" && "${func}" != "help_functions" && "${func}" != "help" && "${func}" != "generate_markdown" ]]; then
                echo -e "\n## Function: ${func}\n"
                for script in ${SOURCE_SCRIPTS}; do
                    awk "/${func}\(\)/ { flag=1; count=1; next } flag && /^#/ { sub(/^# ?/, \"\"); print \$0 } { if (flag) count += gsub(/{/, \"\") - gsub(/}/, \"\"); if (count == 0 && !/^#/) flag=0 }" "${script}"
                done
                seen_funcs+=("$func")  # Mark as documented
            fi
        fi
    done
}


__strip_space(){
#
# __strip_space *string*
#
# - **Purpose**: Remove leading and trailing whitespaces from the input string.
# - **Input Parameters**: 
#     1. `str` (string) - The string from which to remove leading and trailing whitespaces.
# - **Output**: 
#     - A new string with whitespaces removed from both ends.
# - **Exceptions**: None
#
    local argstring="$*"
    echo ${argstring}
}

__zero_pad(){
#
# __zero_pad nn
#
# - **Purpose**: Pad a given number with a leading zero if it's a single-digit number.
# - **Input Parameters**: 
#     1. `num` (integer) - The number to pad. Can be single or double-digit.
# - **Output**: 
#     - The padded number as a string.
#     - If no number is specified, it will default to 00.
# - **Exceptions**: None
#
    local num="$1"
    printf "%02d" "${num}"
}

__next_step(){
#
# __next_step [0-99]
#
# - **Purpose**: Increment a given sequence number by 1 and pad it with a zero if needed.
# - **Input Parameters**: 
#     1. `sequenceNum` (integer) - The sequence number to increment. Must be between 00 and 99.
# - **Output**: 
#     - The next sequence number as a string, zero-padded if necessary.
# - **Exceptions**: 
#     - Returns an error code 22 if the sequence number is not between 00 and 99.
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
