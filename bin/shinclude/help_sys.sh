#!/bin/bash
#
# # help_sys.sh - Help System Functions for Bash Scripts
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
# - **Environment**:
#
#   - **MD_PROCESSOR**: Set to the markdown processor of your choice, if `glow`
#       is in your path this will use that.

# Capture the fully qualified path of the sourced script
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
# Don't source this script if it's already been sourced.
[[ "${__VENV_SOURCED_LIST}" =~ "${THIS_SCRIPT}" ]] && return || __VENV_SOURCED_LIST="${__VENV_SOURCED_LIST} ${THIS_SCRIPT}"
echo "Sourcing: ${THIS_SCRIPT}"


# Help System Functions

# Use an environment variable for markdown processor, defaulting to 'glow'
export MD_PROCESSOR=${MD_PROCESSOR:-"glow"}

# Define an array of internal functions to exclude from help and documentation
__VENV_INTERNAL_FUNCTIONS=(
    ${__VENV_INTERNAL_FUNCTIONS[@]}
    "init_help_system"
    "general_help"
    "help_scripts"
    "specific_script_help"
    "specific_function_help"
    "help_functions"
    "do_help"
    "help"
)


# Initialize a single array to store function names and their corresponding documentation
declare -a __VENV_FUNCTIONS
declare -a __VENV_SCRIPTS


init_help_system(){
#
# init_help_system - Populate and sort __VENV_FUNCTIONS with function names and documentation from sourced scripts.
# - **Purpose**:
#   - Initializes the help system by populating the __VENV_FUNCTIONS with function names and their documentation.
# - **Usage**: 
#   - Automatically called when the script is sourced. No need to call it manually.
# - **Scope**:
#   - Global. Modifies the global array __VENV_FUNCTIONS.
# - **Input Parameters**: 
#   - None. Internally iterates over the scripts listed in the __VENV_SOURCED_LIST array.
# - **Output**: 
#   - Populates __VENV_FUNCTIONS with function names and their corresponding documentation.
#   - Sorts __VENV_FUNCTIONS based on function names.
# - **Exceptions**: 
#   - None
#
    [ -n "${__VENV_FUNCTIONS[*]}" ] && return

    local script func line dir_name
    local shdoc_dir="${__VENV_BASE}/docs/shdoc"
    local conf_file="${__VENV_BASE}/conf/help_sys.conf"
    # Read directories from the configuration file
    local search_dirs=($(grep -v '^#' "$conf_file" | sed '/^$/d'))

    # Iterate over directories to find shell scripts
    for dir_name in "${search_dirs[@]}"; do
        local script_dir="${__VENV_BASE}/${dir_name}"
        local doc_dir="${shdoc_dir}/${dir_name}"

        local script_files=($(file "${script_dir}"/* | grep "shell script" | cut -d":" -f1))
        for script in ${script_files[@]}; do
            # Set the markdown path to the script markdown documentation
            local script_name=$(basename "${script}")  # Extract just the script name
            local markdown_file="${doc_dir}/scripts/${script_name}.md"
            # Store script name andpath to markdown in __VENV_SCRIPTS
            __VENV_SCRIPTS+=("${script_name}")
            __VENV_SCRIPTS+=("${markdown_file}")
            
            # Now extract function names for __VENV_FUNCTIONS
            while IFS= read -r line; do
                if [[ "$line" =~ ^(function[[:space:]]+)?[a-zA-Z_][a-zA-Z0-9_]*\(\)[[:space:]]*\{ ]]; then
                    # Reading function name
                    func="${line%%(*}"
                    func="${func/#function /}"  # Remove 'function ' prefix if exists
                    # Correct the function markdown path
                    local func_markdown_path="${doc_dir}/functions/${func}.md"
                    # Store function name and path to its documentation
                    __VENV_FUNCTIONS+=("$func")
                    __VENV_FUNCTIONS+=("$func_markdown_path")
                fi
            done < "${script}"
        done
    done 

    # Sort __VENV_FUNCTIONS and __VENV_SCRIPTS
    sort_2d_array __VENV_FUNCTIONS
    sort_2d_array __VENV_SCRIPTS
}

write_index_header() {
    local readme_path="$1"
    echo "# Project Documentation" > "${readme_path}"
    echo "## Brief introduction of the project." >> "${readme_path}"
    # Add other header content here
}

write_index_footer() {
    local readme_path="$1"
    local date_mark=$(date "+Generated: %Y %m %d at %H:%M:%S")

    echo "" >> "${readme_path}"
    echo "Footer content" >> "${readme_path}"
    echo "${date_mark}" >> "${readme_path}"
    # Add other footer content here
}

create_readme() {
    local name="$1"
    local description="$2"
    local markdown_path="$3"
    local readme_path="$4"

    description="${description#*- }"   # Extract everything after '- '
    description="${description%%\\n*}"  # Stop at the first newline

    # Create a relative path for the markdown link
    local markdown_rel_path="${markdown_path/#${__VENV_BASE}/}"

    echo "- [${name}](${markdown_rel_path}): ${description} >> ${readme_path}"
    echo "- [${name}](${markdown_rel_path}): ${description}" >> "${readme_path}"
}

generate_markdown(){
#
# ## generate_markdown - Generate Markdown documentation for all available functions.
# 
# - **Purpose**:
#   - Generate comprehensive Markdown documentation for all functions.
# - **Usage**: 
#   - vhelp generate_markdown
# - **Scope**:
#   - Global
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Markdown-formatted documentation for all functions.
# - **Exceptions**: 
#   - None
#
    local conf_file="${__VENV_BASE}/conf/help_sys.conf"
    local shdoc_dir="docs/shdoc"
    [ -d "${shdoc_dir}" ] || mkdir -p ${shdoc_dir}

    local timestamp_file="${__VENV_BASE}/${shdoc_dir}/AUTO_GENERATED_DO_NOT_MODIFY_OR_PLACE_FILES_HERE"
    local progress_file="${shdoc_dir}/.in-progress"
    local readme_index="${shdoc_dir}/README.md"

    touch "${progress_file}"
    
    # Temporary arrays to hold th edocumentation foe each function and script.
    local script_doc=()  # Array to collect scripts' names and documentation
    local function_doc=()  # Array to collect functions' names and documentation

    # State variables
    local in_script=false
    local in_function=false

    # Read the directories to document from the conf file
    local search_dirs=($(grep -v '^#' "$conf_file" | sed '/^$/d'))

    write_index_header ${readme_index}
    # Iterate over directories to find shell scripts and their documentation
    for dir_name in "${search_dirs[@]}"; do
        local script_dir="${__VENV_BASE}/${dir_name}"
        local doc_dir="${shdoc_dir}/${dir_name}"
        # local doc_dir="${shdoc_dir}/${dir_name}"
        [ -d "${doc_dir}/functions" ] || mkdir -p ${__VENV_BASE}${doc_dir}/functions
        [ -d "${doc_dir}/scripts" ] || mkdir -p ${doc_dir}/scripts

        local script_files=($(file "${script_dir}"/* | grep "shell script" | cut -d":" -f1))
        for script in "${script_files[@]}"; do
            local script_name=$(basename "${script}")
            local current_func_name=""  # Keep track of the current function

            # Extract the documentation from the script and functions
            while IFS= read -r line || [[ -n "${line}" ]]; do

                # Skip over a blank line in the documentation
                if [[ "${line}" =~ ^#[[:space:]]*$ ]]; then
                    continue
                fi

                # CHeck for beginning of the script.
                if [[ "${line}" =~ ^#! ]]; then
                    in_script=true
                    in_function=false
                    script_doc+=("${script_name}")
                    script_doc+=("")  # Placeholder for the documentation to be appended next
                    continue
                fi

                # Handle Script documentation
                if [[ "${in_script}" == true && "${line}" == \#* ]]; then
                    script_doc[$(( ${#script_doc[@]} - 1 ))]+="${line/#\# /}\n"
                    continue
                else
                    in_script=false
                fi

                # Check for beginning of a function
                if [[ "$line" =~ ^(function[[:space:]]+)?[a-zA-Z_][a-zA-Z0-9_]*\(\)[[:space:]]*\{ ]]; then  # Found a function definition
                    in_function=true
                    current_func_name="${line%%(*}"
                    current_func_name="${current_func_name/#function /}"  # Remove 'function ' prefix if exists
                    function_doc+=("${current_func_name}")
                    function_doc+=("")  # Placeholder for the documentation to be appended next
                    continue
                fi

                # Handle Function documentation
                if [[ "$in_function" == true && "${line}" == \#* ]]; then
                    function_doc[$(( ${#function_doc[@]} - 1 ))]+="${line/#\# /}\n"
                    continue
                fi
                
                # We reached the end of the function, reset
                if [[ "${in_function}" == true && "${line}" == '}' ]]; then
                    in_function=false
                    continue
                fi

            done < "$script"
        done
    done

    # Sort the arrays to align with __VENV_FUNCTIONS and __VENV_SCRIPTS
    sort_2d_array script_doc
    sort_2d_array function_doc

    # Write the documentation to markdown files
    for ((i=0; i<${#script_doc[@]}; i+=2)); do
        if [[ "${script_doc[i]}" == "${__VENV_SCRIPTS[i]}" ]]; then
            echo "Writing out docs for ${script_doc[i]}"
            echo -e "__VENV_BASE: ${__VENV_BASE}"
            echo -e "${script_doc[i+1]}" > "${__VENV_SCRIPTS[i+1]}"
            create_readme "${script_doc[i]}" "${script_doc[i+1]}" "${__VENV_SCRIPTS[i+1]}" "${readme_index}"
        else
            echo "Oh Crap! something went wrong generating for SCRIPTS, you need to reinitialize your shell."
            echo "Mismnatch: '${script_doc[i]}'  '${__VENV_SCRIPTS[i]}'"
            echo "Bailing out on further generation, the expected SCRIPT list does not agree"
            echo "with the help system initialization."
            return
        fi
    done
    for ((i=0; i<${#function_doc[@]}; i+=2)); do
        if [[ "${function_doc[i]}" == "${__VENV_FUNCTIONS[i]}" ]]; then
            echo "Writing out docs for ${function_doc[i]}"
            echo -e "${function_doc[i+1]}" > "${__VENV_FUNCTIONS[i+1]}"
            create_readme "${function_doc[i]}" "${function_doc[i+1]}" "${__VENV_FUNCTIONS[i+1]}" "${readme_index}"
        else
            echo "Oh Crap! something went wrong generating for FUNCTIONS, you need to reinitialize your shell."
            echo "Mismnatch: '${function_doc[i]}'  '${__VENV_FUNCTIONS[i]}'"
            echo "Bailing out on further generation, the expected FUNCTION list does not agree"
            echo "with the help system initialization."
            return
        fi
    done

    write_index_footer ${readme_index}

    # After documentation generation is complete
    mv "${progress_file}" "${timestamp_file}"
    # Now find and delete old markdown files
    # This should be either older or newer if it doesn't work, change it.
    find "${shdoc_dir}" -type f -name '*.md' ! -newer "${timestamp_file}" -exec rm {} \;
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
    echo -e "\nAvailable commands for 'vhelp':\n"
    echo "  - **functions**:         List available functions and their purpose."
    echo "  - **scripts**:           List available scripts and their purpose."
    echo "  - **generate_markdown**: Generate Markdown documentation for all functions."
    echo -e "\nTo get help on a specific function, use 'vhelp function_name'.\n"
}


help_scripts(){
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
    local longest=0
    local name description

    echo -e "\nList of sourced scripts and their purpose:\n"

    # Find the longest script name
    for ((i=0; i<${#__VENV_SCRIPTS[@]}; i+=2)); do
        if [[ ${#__VENV_SCRIPTS[i]} -gt ${longest} ]]; then
            longest=${#__VENV_SCRIPTS[i]}
        fi
    done

    for ((i=0; i<${#__VENV_SCRIPTS[@]}; i+=2)); do
        name="${__VENV_SCRIPTS[i]}"
        markdown_file="${__VENV_SCRIPTS[i+1]}"

        if [[ -f "$markdown_file" ]]; then
            # Fetch the first line or a specific section from the markdown file
            local description=$(head -n 1 "$markdown_file")
            description="${description#*- }"  # Extracts the part after '- '
            printf "  * %-$((${longest}+1))s %s\n" "${name}:" "${description}"
       else
            printf "  - %s - No description available\n" "$name"
        fi
    done
    echo -e "\nUse 'vhelp \`script_name\` for detailed information on each script"
}


specific_script_help() {

    local script=$1

    for ((i=0; i<${#__VENV_SCRIPTS[@]}; i+=2)); do
        if [[ "${__VENV_SCRIPTS[i]}" == "${script}" ]]; then
            local markdown_file="${__VENV_SCRIPTS[i+1]}"
            if [[ -f "${markdown_file}" ]]; then
                ${MD_PROCESSOR:-cat} ${markdown_file}
            else
                echo "No documentation available for '${script}'."
            fi
            return
        fi
    done
    echo "Unknown script: '${script}'"
    general_help
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

    if [[ " ${__VENV_INTERNAL_FUNCTIONS[@]} " =~ " ${func} " ]]; then
        echo "The function '${func}' is for internal use. Please refer to the system documentation."
        return
    fi

    echo ""

    for ((i=0; i<${#__VENV_FUNCTIONS[@]}; i+=2)); do
        if [[ "${__VENV_FUNCTIONS[i]}" == "${func}" ]]; then
            local markdown_file="${__VENV_FUNCTIONS[i+1]}"
            if [[ -f "${markdown_file}" ]]; then
                ${MD_PROCESSOR:-cat} ${markdown_file}
            else
                echo "No documentation available for '${func}'."
            fi
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
    #   - None. However, it skips functions listed in __VENV_INTERNAL_FUNCTIONS and those already in __VENV_FUNCTIONS.
    #
    local longest=0
    local name description

    # Find the longest function name
    for ((i=0; i<${#__VENV_FUNCTIONS[@]}; i+=2)); do
        if [[ ${#__VENV_FUNCTIONS[i]} -gt ${longest} ]]; then
            longest=${#__VENV_FUNCTIONS[i]}
        fi
    done

    echo -e "\nAvailable functions and their brief descriptions:\n"

    for ((i=0; i<${#__VENV_FUNCTIONS[@]}; i+=2)); do
        local name="${__VENV_FUNCTIONS[i]}"
        local markdown_file="${__VENV_FUNCTIONS[i+1]}"

        # TODO This i a slight problkem need to change to list commands/function explicitly
        # listed in am array of functions to list when getting help.
        # shellcheck disable=SC2076,SC2199
        if [[ " ${__VENV_INTERNAL_FUNCTIONS[@]} " =~ " ${name} " ]]; then
            continue
        fi

        if [[ -f "${markdown_file}" ]]; then
            # Fetch the first line or a specific section from the markdown file
            local description=$(head -n 1 "${markdown_file}")
            description="${description#*- }"  # Extracts the part after '- '

            # Adjust the spacing for name and description
            printf "  * %-${longest}s %s\n" "${name}:" "${description}"
        else
            # Handle case where there is no description available
            printf "  * %-${longest}s No description available\n" "${name}"
        fi
    done

    echo -e "\nUse 'vhelp \`function_name\` for detailed information on each function."
}


vhelp(){
#
# vhelp - Main entry point for the help system.
#
# - **Purpose**:
#   - Facilitate the help system by initializing and delegating to other help functions.
# - **Usage**: 
#   - vhelp [subcommand]
# - **Scope**:
#   - Global
# - **Input Parameters**: 
#   1. `subcommand` (optional string) - The specific help topic or function name.
# - **Output**: 
#   - Help information based on the optional subcommand, or general help if none provided.
# - **Exceptions**: 
#   - None
#
    local subcommand=$1
    local is_script=0
    local md_command

    # Initialize help, if it hasn't been already
    if [[ -z "${__VENV_FUNCTIONS[*]}" ]]; then
        init_help_system
    fi

    # Use the markdown processor if available, otherwise default to 'cat'
    command -v ${MD_PROCESSOR} > /dev/null 2>&1 &&  md_command="${MD_PROCESSOR}" \
        || md_command="cat"

    # Check if the subcommand is a known script name (without the .sh extension)
    for script in ${__VENV_SOURCED_LIST[@]}; do
        if [[ "${script##*/}" == "${subcommand}" ]]; then
            is_script=1
            break
        fi
    done

    case "${subcommand}" in
        "generate_markdown")
            generate_markdown 
            echo "Markdown geneartion complete."
            ;;
        "functions")
            help_functions | ${md_command}
            ;;
        "scripts")
            help_scripts | ${md_command}
            ;;
        "")
            general_help | ${md_command}
            ;;
        *)
            if (( is_script )); then
                specific_script_help "${subcommand}" | ${md_command}
            else
                specific_function_help "${subcommand}" | ${md_command}
            fi
            ;;
    esac
}
