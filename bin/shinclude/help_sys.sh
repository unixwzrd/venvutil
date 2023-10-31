#!/bin/bash
#
# help_sys.sh - Help System Functions for Bash Scripts
#
# - **Purpose**: 
#   - This script provides a dynamic help system for all sourced bash scripts.
#   - It can list available functions, provide detailed information about each function, and list sourced scripts.
#
# - **Usage**: 
#   - Source this script in other bash scripts to enable the dynamic help system.
#   - For example, in another script: `source help_sys.sh`.
#
# - **Input Parameters**: 
#   - None. All input is handled by the individual functions.
#
# - **Output**: 
#   - Enables a help system that can be accessed by calling `help` in the terminal.
#   - Also supports generating Markdown documentation.
#
# - **Exceptions**: 
#   - Some functions may return specific error codes or print error messages to STDERR.
#   - Refer to individual function documentation for details.
#

# Capture the fully qualified path of the sourced script
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
# Don't source this script if it's already been sourced.
[[ "${_SOURCED_LIST}" =~ "${THIS_SCRIPT}" ]] && return || _SOURCED_LIST="${_SOURCED_LIST} ${THIS_SCRIPT}"
echo "Sourcing: ${THIS_SCRIPT}"


# Help System Functions

# Define an array of internal functions to exclude from help and documentation
INTERNAL_FUNCTIONS=(
    ${INTERNAL_FUNCTIONS[@]}
    "init_help_system"
    "general_help"
    "help_scripts"
    "specific_function_help"
    "help_functions"
    "generate_markdown"
    "do_help"
    "help"
)


# Initialize a single array to store function names and their corresponding documentation
declare -a FUNC_ARRAY


init_help_system() {
#
# init_help_system - Populate and sort FUNC_ARRAY with function names and documentation from sourced scripts.
#
# - **Purpose**:
#   - Initializes the help system by populating the FUNC_ARRAY with function names and their documentation.
# - **Usage**: 
#   - Automatically called when the script is sourced. No need to call it manually.
# - **Scope**:
#   - Global. Modifies the global array FUNC_ARRAY.
# - **Input Parameters**: 
#   - None. Internally iterates over the scripts listed in the _SOURCED_LIST array.
# - **Output**: 
#   - Populates FUNC_ARRAY with function names and their corresponding documentation.
#   - Sorts FUNC_ARRAY based on function names.
# - **Exceptions**: 
#   - None. However, it skips functions listed in INTERNAL_FUNCTIONS and those already in FUNC_ARRAY.
#
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


general_help(){
#
# general_help - Display general help options for the 'help' command.
#
# - **Purpose**:
#   - Provide an overview of the available help commands.
# - **Usage**: 
#   - general_help
# - **Scope**:
#   - Global
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Lists the general help commands available.
# - **Exceptions**: 
#   - None
#
    echo -e "\nAvailable commands for 'help':\n"
    echo "  - **functions**:         List available functions and their purpose."
    echo "  - **scripts**:           List available scripts and their purpose."
    echo "  - **generate_markdown**: Generate Markdown documentation for all functions."
    echo -e "\nTo get help on a specific function, use 'help function_name'.\n"
}

help_scripts() {
#
# help_scripts - List sourced scripts and their purpose.
#
# - **Purpose**:
#   - Display a list of sourced scripts.
# - **Usage**: 
#   - help_scripts
# - **Scope**:
#   - Global
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Lists the names of the sourced scripts.
# - **Exceptions**: 
#   - None
#
    echo "Debug: _SOURCED_LIST: ${_SOURCED_LIST[@]}"
    echo -e "\nList of sourced scripts and their purpose:\n"
    for script in ${_SOURCED_LIST[@]}; do
        # Extract the header comments from each script as its description
        #script_description=$(awk "/^#/ { sub(/^# ?/, \"\"); print \$0 }" "$script")
        echo "  - ${script}"
    done
    echo ""
}

specific_function_help(){
#
# specific_function_help - Provide detailed documentation for a given function.
#
# - **Purpose**:
#   - Display documentation for a specific function.
# - **Usage**: 
#   - specific_function_help "function_name"
# - **Scope**:
#   - Global
# - **Input Parameters**: 
#   1. `function_name` (string) - The name of the function.
# - **Output**: 
#   - Displays the documentation for the given function.
# - **Exceptions**: 
#   - Displays general help if the function is unknown.
#
    local func=$1

    # Provide the documentation for the function passed.
    for ((i=0; i<${#FUNC_ARRAY[@]}; i+=2)); do
        if [[ "${FUNC_ARRAY[i]}" == "${func}" ]]; then
            echo -e "${FUNC_ARRAY[i+1]}"
            return
        fi
    done
    echo "Unknown function: '${func}'"
    general_help
}


help_functions() {
#
# help_functions - List available functions and how to get their documentation.
#
# - **Purpose**:
#   - Provide a list of available functions and guidance on getting detailed documentation.
# - **Usage**: 
#   - help_functions
# - **Scope**:
#   - Global
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Lists available functions and how to get more information about them.
# - **Exceptions**: 
#   - None
#
    if [[ -z "${func}" ]]; then
        echo -e "\nUse 'help function_name' for detailed information on each function.\n"
        for ((i=0; i<${#FUNC_ARRAY[@]}; i+=2)); do
            # Get the second line of the function description.
            second_line=$(echo -e "${FUNC_ARRAY[i+1]}" | sed -n '2p')
            echo -e "  - ${second_line}\n"
        done
        echo ""
        return
    fi
}

generate_markdown(){
#
# generate_markdown - Generate Markdown documentation for all available functions.
#
# - **Purpose**:
#   - Generate comprehensive Markdown documentation for all functions.
# - **Usage**: 
#   - generate_markdown
# - **Scope**:
#   - Global
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Markdown-formatted documentation for all functions.
# - **Exceptions**: 
#   - None
#
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

do_help(){
#
# do_help - Dispatch help information based on the given subcommand.
#
# - **Purpose**:
#   - Serve as the main dispatcher for generating help information.
# - **Usage**: 
#   - do_help "subcommand"
# - **Scope**:
#   - Global
# - **Input Parameters**: 
#   1. `subcommand` (string) - The specific help topic or function name.
# - **Output**: 
#   - Appropriate help information based on the subcommand.
# - **Exceptions**: 
#   - None
#
    local subcommand=$1

    case "$subcommand" in
        "generate_markdown")
            generate_markdown | tee helpdoc.md
            ;;
        "functions")
            help_functions
            ;;
        "scripts")
            help_scripts
            ;;
        "")
            general_help
            ;;
        *)
            specific_function_help "$subcommand"
            ;;
    esac
}

help(){
#
# help - Main entry point for the help system.
#
# - **Purpose**:
#   - Facilitate the help system by initializing and delegating to other help functions.
# - **Usage**: 
#   - help [subcommand]
# - **Scope**:
#   - Global
# - **Input Parameters**: 
#   1. `subcommand` (optional string) - The specific help topic or function name.
# - **Output**: 
#   - Help information based on the optional subcommand, or general help if none provided.
# - **Exceptions**: 
#   - None
#
    if [[ -z "${FUNC_ARRAY[*]}" ]]; then
        init_help_system
    fi
    do_help "$@" | (command -v glow > /dev/null 2>&1 && glow || cat )
}
