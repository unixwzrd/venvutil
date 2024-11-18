#!/bin/bash
# # Script: help_sys.sh
# `help_sys.sh` - Help System Functions for Bash Scripts
# ## Description
# - **Purpose**: 
#   - Provides a dynamic help system for all sourced bash scripts.
#   - It can list available functions, provide detailed information about each function, and list sourced scripts.
# - **Usage**: 
#   - Source this script in other bash scripts to enable the dynamic help system.
#     ```bash
#     source help_sys.sh
#     ```
# - **Input Parameters**: 
#   - None. All input is handled by the individual functions.
# - **Output**: 
#   - Enables a help system that can be accessed by calling `help` in the terminal.
#   - Supports generating Markdown documentation.
# - **Exceptions**: 
#   - Some functions may return specific error codes or print error messages to STDERR.
#   - Refer to individual function documentation for details.
# - **Environment**:
#   - **MD_PROCESSOR**: Set to the markdown processor of your choice. If `glow` is in your path, it will use that.

# Determine the real path of the script
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
# Don't source this script if it's already been sourced.
[[ "${__VENV_SOURCED_LIST}" =~ "${THIS_SCRIPT}" ]] && return || __VENV_SOURCED_LIST="${__VENV_SOURCED_LIST} ${THIS_SCRIPT}"
echo "Sourcing: ${THIS_SCRIPT}"

# Help System Initialization

# Use an environment variable for markdown processor, defaulting to 'glow'
export MD_PROCESSOR=${MD_PROCESSOR:-"glow"}

# Define an array of internal functions to exclude from help and documentation
__VENV_INTERNAL_FUNCTIONS=(
    ${__VENV_INTERNAL_FUNCTIONS[@]}
    "init_help_system"
    "general_help"
    "specific_script_help"
    "specific_function_help"
    "help_functions"
    "do_help"
)

# Initialize associative arrays to store function names and their corresponding documentation
declare -g -A __VENV_FUNCTIONS
declare -g -A __VENV_SCRIPTS

# Initialize arrays to store sorted names for functions and scripts
sorted_function_names=()
sorted_script_names=()

# Initialize variables to store the length of the longest script and function names
longest_script_name=0
longest_function_name=0

# # Function: process_scripts
#  `process_scripts` - Process scripts in a given directory.
# ## Description
# - **Purpose**:
#   - Process scripts in a given directory, extracting function names and documentation.
# - **Usage**: 
#   - `process_scripts <dir_name>`
# - **Input Parameters**: 
#   - `dir_name`: The name of the directory to process.
# - **Output**: 
#   - Populates `__VENV_SCRIPTS` and `__VENV_FUNCTIONS` with script and function information.
# - **Exceptions**: 
#   - None
#
process_scripts() {
    local dir_name="$1"
    local script_dir="${__VENV_BASE}/${dir_name}"
    local doc_dir="${__VENV_BASE}/docs/shdoc/${dir_name}"
    readarray -t script_files < <(find "$script_dir" -type f -name "*.sh")
    for script in "${script_files[@]}"; do
        local script_name="$(basename "$script")"
        local markdown_file="${doc_dir}/scripts/${script_name}.md"
        echo "Assigning: ${script_name} -> ${markdown_file}"
        echo "Bash version: ${BASH_VERSION}"
        __VENV_SCRIPTS["$script_name"]="$markdown_file"
        echo "Assigned: ${__VENV_SCRIPTS[$script_name]}"
        
        if [[ ${#script_name} -gt $longest_script_name ]]; then
            longest_script_name=${#script_name}
        fi
        
        while IFS= read -r line; do
            if [[ "$line" =~ ^(function[[:space:]]+)?[a-zA-Z_][a-zA-Z0-9_]*\(\)[[:space:]]*\{ ]]; then
                # Reading function name
                func="${line%%(*}"
                func="${func/#function /}"  # Remove 'function ' prefix if exists
                # Correct the function markdown path
                echo "Function: ${func}"
                local func_markdown_path="${doc_dir}/functions/${func}.md"
                __VENV_FUNCTIONS["$func"]="$func_markdown_path"
                
                # Update longest function name length
                if [[ ${#func} -gt $longest_function_name ]]; then
                    longest_function_name=${#func}
                fi
            fi
        done < "$script"
    done
}

# # Function: init_help_system
#  `init_help_system` - Initialize the help system by populating function and script documentation.
# ## Description
# - **Purpose**:
#   - Initializes the help system by populating the `__VENV_FUNCTIONS` with function names and their documentation.
# - **Usage**: 
#   - Automatically called when the script is sourced. No need to call it manually.
# - **Scope**:
#   - Global. Modifies the global array `__VENV_FUNCTIONS`.
# - **Input Parameters**: 
#   - None. Internally iterates over the scripts listed in the `__VENV_SOURCED_LIST` array.
# - **Output**: 
#   - Populates `__VENV_FUNCTIONS` with function names and their corresponding documentation.
#   - Sorts `__VENV_FUNCTIONS` based on function names.
# - **Exceptions**: 
#   - None
#
init_help_system() {
    [ -n "${__VENV_FUNCTIONS[*]}" ] && return
    local conf_file="${__VENV_BASE}/conf/help_sys.conf"
    readarray -t search_dirs < <(grep -v '^#' "$conf_file" | sed '/^$/d')
    for dir_name in "${search_dirs[@]}"; do
        process_scripts "$dir_name"
    done
    # Sort names for alphabetical order
    readarray -t sorted_function_names < <(printf "%s\n" "${!__VENV_FUNCTIONS[@]}" | sort)
    readarray -t sorted_script_names < <(printf "%s\n" "${!__VENV_SCRIPTS[@]}" | sort)
}

# # Function: write_index_header
#  `write_index_header` - Writes the header section of the README.
# ## Description
# - **Purpose**:
#   - Creates the initial header content for the README documentation.
# - **Usage**: 
#   - `write_index_header <readme_path>`
# - **Input Parameters**: 
#   - `readme_path`: The path to the README file.
# - **Output**: 
#   - Writes the header content to the specified README file.
# - **Exceptions**: 
#   - None
#
write_index_header() {
    local readme_path="$1"
    echo "# Project Documentation" > "${readme_path}"
    echo "## Brief introduction of the project." >> "${readme_path}"
    # Add other header content here
}

# # Function: write_index_footer
#  `write_index_footer` - Writes the footer section of the README.
# ## Description
# - **Purpose**:
#   - Appends footer content and a timestamp to the README documentation.
# - **Usage**: 
#   - `write_index_footer <readme_path>`
# - **Input Parameters**: 
#   - `readme_path`: The path to the README file.
# - **Output**: 
#   - Appends footer content and timestamp to the README file.
# - **Exceptions**: 
#   - None
#
write_index_footer() {
    local readme_path="$1"
    local date_mark=$(date "+Generated: %Y %m %d at %H:%M:%S")

    echo "" >> "${readme_path}"
    echo "Footer content" >> "${readme_path}"
    echo "${date_mark}" >> "${readme_path}"
    # Add other footer content here
}

# # Function: create_readme
#  `create_readme` - Creates an entry in the README for a script or function.
# ## Description
# - **Purpose**:
#   - Adds a Markdown link to the README file for the given script or function.
# - **Usage**: 
#   - `create_readme <name> <description> <markdown_path> <readme_path>`
# - **Input Parameters**: 
#   - `name`: The name of the script or function.
#   - `description`: A brief description.
#   - `markdown_path`: Path to the Markdown documentation.
#   - `readme_path`: Path to the README file.
# - **Output**: 
#   - Appends a Markdown-formatted link to the README.
# - **Exceptions**: 
#   - None
#
create_readme() {
    local name="$1"
    local description="$2"
    local markdown_path="$3"
    local readme_path="$4"

    description="${description#*- }"   # Extract everything after '- '
    description="${description%%\\n*}"  # Stop at the first newline

    # Create a relative path for the markdown link
    local markdown_rel_path="${markdown_path/#${__VENV_BASE}/}"

    echo "- [${name}](${markdown_rel_path}): ${description}" >> "${readme_path}"
}

# # Function: generate_markdown
#  `generate_markdown` - Generate Markdown documentation for all available functions.
# ## Description
# - **Purpose**:
#   - Generate comprehensive Markdown documentation for all functions.
# - **Usage**: 
#   - `vhelp generate_markdown`
# - **Scope**:
#   - Global
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Markdown-formatted documentation for all functions.
# - **Exceptions**: 
#   - None
#
generate_markdown() {
    local shdoc_dir="docs/shdoc"
    [ -d "${shdoc_dir}" ] || mkdir -p "${shdoc_dir}"

    local progress_file="${shdoc_dir}/.in-progress"
    local timestamp_file="${__VENV_BASE}/${shdoc_dir}/AUTO_GENERATED_DO_NOT_MODIFY_OR_PLACE_FILES_HERE"
    touch "${progress_file}"

    local readme_index="${__VENV_BASE}/docs/README.md"
    write_index_header "${readme_index}"

    # Setup directory structure
    for dir_name in "${sorted_script_names[@]}"; do
        local doc_dir="${shdoc_dir}/${dir_name}"
        [ -d "${doc_dir}/functions" ] || mkdir -p "${doc_dir}/functions"
        [ -d "${doc_dir}/scripts" ] || mkdir -p "${doc_dir}/scripts"
    done

    # Iterate over sorted script names
    for script_name in "${sorted_script_names[@]}"; do
        local script_path="${__VENV_SCRIPTS[$script_name]}"
        local markdown_file="${__VENV_SCRIPTS[$script_name]}"
        echo "Generating markdown for script: $script_name"

        local extracted_markdown="# $script_name\n\n## Description\n"
        local in_script=false
        local in_function=false
        local current_func_name=""

        # Open the script file for reading
        while IFS= read -r line || [[ -n "${line}" ]]; do
            # Skip over a blank line in the documentation
            if [[ "${line}" =~ ^#[[:space:]]*$ ]]; then
                continue
            fi

            # Check for beginning of the script.
            if [[ "${line}" =~ ^#! ]]; then
                in_script=true
                in_function=false
                continue
            fi

            # Handle Script documentation
            if [[ "${in_script}" == true && "${line}" == \#* ]]; then
                extracted_markdown+="${line/#\# /}\n"
                continue
            else
                in_script=false
            fi

            # Check for beginning of a function
            if [[ "$line" =~ ^(function[[:space:]]+)?[a-zA-Z_][a-zA-Z0-9_]*\(\)[[:space:]]*\{ ]]; then
                in_function=true
                current_func_name="${line%%(*}"
                current_func_name="${current_func_name/#function /}"
                extracted_markdown+="\n### $current_func_name\n\n"
                continue
            fi

            # Handle Function documentation
            if [[ "$in_function" == true && "${line}" == \#* ]]; then
                extracted_markdown+="${line/#\# /}\n"
                continue
            fi

            # We reached the end of the function, reset
            if [[ "${in_function}" == true && "${line}" == '}' ]]; then
                in_function=false
                continue
            fi

        done < "$script_path"

        # Write the extracted documentation to the markdown file
        echo -e "$extracted_markdown" > "$markdown_file"
        create_readme "$script_name" "$extracted_markdown" "$markdown_file" "$readme_index"
    done

    write_index_footer "${readme_index}"

    # After documentation generation is complete
    mv "${progress_file}" "${timestamp_file}"
    # Now find and delete old markdown files
    find "${shdoc_dir}" -type f -name '*.md' ! -newer "${timestamp_file}" -exec rm {} \;
}

# # Function: general_help
#  `general_help` - Display general help options for the 'help' command.
# ## Description
# - **Purpose**:
#   - Provide an overview of the available help commands.
# - **Usage**: 
#   - `general_help`
# - **Scope**:
#   - Global
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Lists the general help commands available.
# - **Exceptions**: 
#   - None
#
general_help() {
    echo -e "\nAvailable commands for 'vhelp':\n"
    echo "  - **functions**:         List available functions and their purpose."
    echo "  - **scripts**:           List available scripts and their purpose."
    echo "  - **generate_markdown**: Generate Markdown documentation for all functions."
    echo -e "\nTo get help on a specific function, use 'vhelp function_name'.\n"
}

# # Function: help_scripts
#  `help_scripts` - List sourced scripts and their purpose.
# ## Description
# - **Purpose**:
#   - Display a list of sourced scripts.
# - **Usage**: 
#   - `help_scripts`
# - **Scope**:
#   - Global
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Lists the names of the sourced scripts.
# - **Exceptions**: 
#   - None
#
help_scripts() {
    local script
    local markdown_file
    local description

    echo -e "\nList of sourced scripts and their purpose:\n"

    for script in "${sorted_script_names[@]}"; do
        markdown_file="${__VENV_SCRIPTS[$script]}"

        if [[ -f "$markdown_file" ]]; then
            description=$(head -n 1 "$markdown_file")
            description="${description#*- }"
            printf "  * %-$((${longest_script_name}+1))s %s\n" "${script}:" "${description}"
        else
            printf "  - %s - No description available\n" "$script"
        fi
    done
    echo -e "\nUse 'vhelp \`script_name\` for detailed information on each script"
}

# # Function: specific_script_help
#  `specific_script_help` - Provide detailed documentation for a given script.
# ## Description
# - **Purpose**:
#   - Display documentation for a specific script.
# - **Usage**: 
#   - `specific_script_help <script_name>`
# - **Scope**:
#   - Global
# - **Input Parameters**: 
#   - `script_name`: The name of the script to get help for.
# - **Output**: 
#   - Displays the documentation for the specified script.
# - **Exceptions**: 
#   - Displays a message if the script is unknown or has no documentation.
#
specific_script_help() {

    local script=$1

    if [[ -v __VENV_SCRIPTS[$script] ]]; then
        local markdown_file="${__VENV_SCRIPTS[$script]}"
        if [[ -f "${markdown_file}" ]]; then
            ${MD_PROCESSOR:-cat} "${markdown_file}"
        else
            echo "No documentation available for '${script}'."
        fi
        return
    fi
    echo "Unknown script: '${script}'"
    general_help
}

# # Function: specific_function_help
#  `specific_function_help` - Provide detailed documentation for a given function.
# ## Description
# - **Purpose**:
#   - Display documentation for a specific function.
# - **Usage**: 
#   - `specific_function_help "function_name"`
# - **Scope**:
#   - Global
# - **Input Parameters**: 
#   - `function_name`: The name of the function to get help for.
# - **Output**: 
#   - Displays the documentation for the specified function.
# - **Exceptions**: 
#   - Displays general help if the function is unknown or internal.
#
specific_function_help() {
    local func=$1

    if [[ " ${__VENV_INTERNAL_FUNCTIONS[@]} " =~ " ${func} " ]]; then
        echo "The function '${func}' is for internal use. Please refer to the system documentation."
        return
    fi

    echo ""

    if [[ -v __VENV_FUNCTIONS[$func] ]]; then
        local markdown_file="${__VENV_FUNCTIONS[$func]}"
        if [[ -f "${markdown_file}" ]]; then
            ${MD_PROCESSOR:-cat} "${markdown_file}"
        else
            echo "No documentation available for '${func}'."
        fi
        return
    fi
    echo "Unknown function: '${func}'"
    general_help
}

# # Function: help_functions
#  `help_functions` - List available functions and how to get their documentation.
# ## Description
# - **Purpose**:
#   - Provide a list of available functions and guidance on getting detailed documentation.
# - **Usage**:
#   - `help_functions`
# - **Scope**:
#   - Global
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Lists available functions and how to get more information about them.
# - **Exceptions**: 
#   - None. However, it skips functions listed in `__VENV_INTERNAL_FUNCTIONS` and those already in `__VENV_FUNCTIONS`.
#
help_functions() {
    local func
    local markdown_file
    local description

    echo -e "\nAvailable functions and their brief descriptions:\n"

    for func in "${sorted_function_names[@]}"; do
        # Skip internal functions
        if [[ " ${__VENV_INTERNAL_FUNCTIONS[@]} " =~ " ${func} " ]]; then
            continue
        fi

        markdown_file="${__VENV_FUNCTIONS[$func]}"

        if [[ -f "${markdown_file}" ]]; then
            description=$(head -n 1 "${markdown_file}")
            description="${description#*- }"
            printf "  * %-${longest_function_name}s %s\n" "${func}:" "${description}"
        else
            printf "  * %-${longest_function_name}s No description available\n" "${func}"
        fi
    done

    echo -e "\nUse 'vhelp \`function_name\` for detailed information on each function."
}

# # Function: vhelp
#  `vhelp` - Main entry point for the help system.
# ## Description
# - **Purpose**:
#   - Facilitates the help system by initializing and delegating to other help functions.
# - **Usage**: 
#   - `vhelp [subcommand]`
# - **Scope**:
#   - Global
# - **Input Parameters**: 
#   - `subcommand` (optional): The specific help topic or function name.
# - **Output**: 
#   - Help information based on the optional subcommand, or general help if none provided.
# - **Exceptions**: 
#   - None
#
vhelp() {
    local subcommand=$1
    local is_script=0
    local md_command

    # Initialize help, if it hasn't been already
    if [[ -z "${__VENV_FUNCTIONS[*]}" ]]; then
        init_help_system
    fi

    # Use the markdown processor if available, otherwise default to 'cat'
    command -v ${MD_PROCESSOR} > /dev/null 2>&1 && md_command="${MD_PROCESSOR}" || md_command="cat"

    # Check if the subcommand is a known script name (without the .sh extension)
    for script in ${__VENV_SOURCED_LIST[@]}; do
        if [[ "${script##*/}" == "${subcommand}" ]]; then
            is_script=1
            break
        fi
    done

    case "${subcommand}" in
        "generate_markdown")
            echo "Starting markdown generation..."
            generate_markdown || errno_exit 1
            echo "Markdown generation complete."
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
                specific_script_help "${subcommand}" | ${md_command} || errno_exit 22
            else
                specific_function_help "${subcommand}" | ${md_command} || errno_exit 22
            fi
            ;;
    esac
}
