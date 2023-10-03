#!/bin/bash
# Capture the fully qualified path of the sourced script
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
# Don't source this script if it's already been sourced.
[[ "${_SOURCED_LIST}" =~ "${THIS_SCRIPT}" ]] && return || _SOURCED_LIST="${_SOURCED_LIST} ${THIS_SCRIPT}"
echo "Sourcing:${THIS_SCRIPT}"


# Help System Functions

# Define an array of internal functions to exclude from help and documentation
INTERNAL_FUNCTIONS=("init_help_system" "help_functions" "help" "generate_markdown" " do_help" )

# Initialize a single array to store function names and their corresponding documentation
declare -a FUNC_ARRAY

# Function to populate function names and their docs
init_help_system() {
    [[ -n "${FUNC_ARRAY[*]}" ]] && return

    local script
    local func
    local doc

        for script in ${_SOURCED_LIST[@]}; do
        while IFS= read -r func; do
            # Skip if the function is in INTERNAL_FUNCTIONS
            if [[ " ${INTERNAL_FUNCTIONS[@]} " =~ " ${func} " ]]; then
                continue
            fi
            # Skip if the function is already in FUNC_ARRAY
            if [[ ! " ${FUNC_ARRAY[*]} " =~ " ${func} " ]]; then
                doc=$(awk "BEGIN{flag=0} /^${func}\(\)/ {flag=1} /^#/ {if (flag) print substr(\$0, 3)} /^[a-zA-Z0-9_]+\(\)/ {if (\$0 !~ /^${func}\(\)/) flag=0}" "${script}")
                FUNC_ARRAY+=("${func}")
                FUNC_ARRAY+=("${doc}")
            fi
        done < <(awk -F'[(]' '/^[a-zA-Z0-9_]+\(\)/ {print $1}' "${script}")
    done

    # Sort FUNC_ARRAY based on function names while keeping them paired with their descriptions.
    # This will behave as a two dimensional array, but using offsets into teh array for teh added
    # sedonc dimension.
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


help_functions() {
#
# help_functions
#
# - **Purpose**: Display a list of available functions, providing a starting point for further help.
# - **Scope**: Global. Reads from global array FUNC_ARRAY.
# - **Input Parameters**: None.
# - **Output**: 
#   - A list of function names, excluding those meant for internal use.
# - **Exceptions**: None.
#
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

    #  Provide a list o functions and a helpful message on how to use the help.
    if [[ -z "${func}" ]]; then
        echo -e "\nUse 'help function_name' for detailed information on each function.\n"
        for ((i=0; i<${#FUNC_ARRAY[@]}; i+=2)); do
            echo "  - ${FUNC_ARRAY[i]}"
        done
        echo ""
        return
    fi

    # Provide the documentation for the function passed.
    for ((i=0; i<${#FUNC_ARRAY[@]}; i+=2)); do
        if [[ "${FUNC_ARRAY[i]}" == "${func}" ]]; then
            echo -e "${FUNC_ARRAY[i+1]}"
            return
        fi
        echo ""
    done

    # What happens if we don't find anything matching.
    echo "Function not found."
}

# Function to generate Markdown documentation
generate_markdown(){
    local all_funcs=()
    local seen_funcs=()  # To keep track of functions already documented

    echo "# Function Documentation" 

    # Iterate over all source scripts to read functions
    for script in ${_SOURCED_LIST}; do
        script_funcs=($(awk -F'[(]' '/^[a-zA-Z0-9_]+\(\)/ {print $1}' "${script}"))
        all_funcs=("${all_funcs[@]}" "${script_funcs[@]}")
    done

    # Deduplicate function names
    all_funcs=($(printf "%s\n" "${all_funcs[@]}" | sort -u))

    for func in "${all_funcs[@]}"; do
        if [[ ! " ${seen_funcs[@]} " =~ " ${func} " ]]; then  # Skip if already documented
            if [[ "${func}" != "init_help_system" && "${func}" != "help_functions" && "${func}" != "help" && "${func}" != "generate_markdown" ]]; then
                echo -e "\n## Function: ${func}\n"
                for script in ${_SOURCED_LIST}; do
                    awk "/${func}\(\)/ { flag=1; count=1; next } flag && /^#/ { sub(/^# ?/, \"\"); print \$0 } { if (flag) count += gsub(/{/, \"\") - gsub(/}/, \"\"); if (count == 0 && !/^#/) flag=0 }" "${script}"
                done
                seen_funcs+=("$func")  # Mark as documented
            fi
        fi
    done
}