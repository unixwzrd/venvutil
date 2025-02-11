#!/usr/bin/env bash
# # Script: helpsys_lib.sh
# `helpsys_lib.sh` - Help System Functions for Bash Scripts
# ## Description
# - **Purpose**: 
#   - Provides a dynamic help system for all sourced bash scripts.
#   - It can list available functions, provide detailed information about each function, and list sourced scripts.
#  ## Usage
#   - Source this script in other bash scripts to enable the dynamic help system.
#     ```bash
#     source helpsys_lib.sh
#     ```
# ## Input Parameters
#   - None. All input is handled by the individual functions.
# ## Output
#   - Enables a help system that can be accessed by calling `help` in the terminal.
#   - Supports generating Markdown documentation.
# ## Exceptions
#   - Some functions may return specific error codes or print error messages to STDERR.
#   - Refer to individual function documentation for details.
# ## Environment
#   - **MD_PROCESSOR**: Set to the markdown processor of your choice. If `glow` is in your path, it will use that.

## Initialization
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
if ! declare -p __VENV_SOURCED >/dev/null 2>&1; then declare -g -A __VENV_SOURCED; fi
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

# Dependencies
# Get the init_lib.sh script
# shellcheck source=/dev/null
# source "${__VENV_INCLUDE}/init_lib.sh"
# Get the errno_lib.sh script
# source_lib errno_lib
# Get the util_lib.sh script
# source_lib util_lib

# Initialize associative arrays to store function names and their corresponding documentation
declare -g -A __VENV_FUNCTIONS
declare -g -A __VENV_SCRIPTS

# Initialize arrays to store sorted names for functions and scripts
declare -g -a sorted_function_names
declare -g -a sorted_script_names

# Initialize variables to store the length of the longest script and function names
declare -g longest_script_name=0
declare -g longest_function_name=0

# Help System Initialization

# Use an environment variable for markdown processor, defaulting to 'glow'
declare -g MD_PROCESSOR=${MD_PROCESSOR:-"glow"}

# Add internal functions to the __VENV_INTERNAL_FUNCTIONS array.
if ! declare -p __VENV_INTERNAL_FUNCTIONS >/dev/null 2>&1; then declare -ga __VENV_INTERNAL_FUNCTIONS; fi
# Quote to prevent word splitting/globbing, or split robustly with mapfile or read -a
# shellcheck disable=SC2206
declare -g -a __VENV_INTERNAL_FUNCTIONS=(
    ${__VENV_INTERNAL_FUNCTIONS[@]}
    "do_help"
    "docs_base_path"
    "function_description"
    "general_help"
    "general_help"
    "generate_markdown"
    "get_script_readme_file"
    "get_system_readme_file"
    "help_functions"
    "init_help_system"
    "init_help_system"
    "process_scripts"
    "script_description"
    "specific_function_help"
    "specific_function_help"
    "specific_script_help"
    "specific_script_help"
    "write_function_doc"
    "write_page_footer"
    "write_script_doc"
    "write_script_function_entry"
    "write_script_readme_header"
    "write_system_readme_entry"
    "write_system_readme_header"
    "write_table_footer"
)

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
    local current_dir=${PWD}
    cd "${__VENV_BASE}" || errno_exit ENOENT
    local dir_name="$1"
    local script_dir="${dir_name}"
    local scripts_docs_dir="docs/shdoc/${dir_name}"
    readarray -t script_files < <(find "$script_dir" -type f -name "*.sh")
    for script in "${script_files[@]}"; do
        local script_name
        script_name="$(basename "$script")"
        local markdown_file="${scripts_docs_dir}/scripts/${script_name}.md"
        __VENV_SCRIPTS["$script_name"]="$markdown_file"
        sorted_script_names+=("$script_name")
        
        if [[ ${#script_name} -gt $longest_script_name ]]; then
            longest_script_name=${#script_name}
        fi
        
        while IFS= read -r line; do
            if [[ "$line" =~ ^(function[[:space:]]+)?[a-zA-Z_][a-zA-Z0-9_]*\(\)[[:space:]]*\{ ]]; then
                # Reading function name
                function="${line%%(*}"
                function="${function/#function /}"  # Remove 'function ' prefix if exists
                # Correct the function markdown path
                local function_markdown_path="${scripts_docs_dir}/functions/${function}.md"
                __VENV_FUNCTIONS["$function"]="$function_markdown_path"
                sorted_function_names+=("$function")
                
                # Skip internal functions
                # shellcheck disable=SC2076,SC2199
                if [[ " ${__VENV_INTERNAL_FUNCTIONS[@]} " =~ " ${function} " ]]; then
                    continue
                fi

                # Update longest function name length
                if [[ ${#function} -gt $longest_function_name ]]; then
                    longest_function_name=${#function}
                fi
            fi
        done < "$script"
    done
    readarray -t sorted_script_names < <(printf "%s\n" "${sorted_script_names[@]}" | sort)
    readarray -t sorted_function_names < <(printf "%s\n" "${sorted_function_names[@]}" | sort)
    
    # shellcheck disable=SC2164
    cd "${current_dir}" > /dev/null 2>&1
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
#   - None.
# - **Output**: 
#   - Populates `__VENV_FUNCTIONS` with function names and their corresponding documentation.
#   - Sorts `__VENV_FUNCTIONS` based on function names.
# - **Exceptions**: 
#   - None
#
init_help_system() {
    local current_dir=${PWD}
    cd "${__VENV_BASE}" || errno_exit ENOENT

    [ -n "${__VENV_FUNCTIONS[*]}" ] && return
    local conf_file="conf/help_sys.conf"
    readarray -t search_dirs < <(grep -v '^#' "$conf_file" | sed '/^$/d')
    for dir_name in "${search_dirs[@]}"; do
        process_scripts "$dir_name"
    done
    # Sort names for alphabetical order
    readarray -t sorted_function_names < <(printf "%s\n" "${!__VENV_FUNCTIONS[@]}" | sort)
    readarray -t sorted_script_names < <(printf "%s\n" "${!__VENV_SCRIPTS[@]}" | sort)
    
    # shellcheck disable=SC2164
    cd "${current_dir}" > /dev/null 2>&1
}


# # Function: script_description
#  `script_description` - Get the description of a script.
# ## Description
# - **Purpose**:
#   - Retrieves the description of a script from its documentation file.
# - **Usage**: 
#   - `script_description <script_name>`
# - **Input Parameters**: 
#   - `script_name`: The name of the script.
# - **Output**: 
#   - Returns the description of the script as a string.
# - **Exceptions**: 
#   - None
#
script_description() {
    local script_name="$1"
    local doc_file="${__VENV_SCRIPTS[$script_name]}"
    local description

    if [[ -f "$doc_file" ]]; then
        description=$(head -n 2 "$doc_file" | tail -n 1)
        description="${description#*- }"
    fi

    description="${description:-"No description available"}"
    echo "${description}"
}


# # Function: function_description
#  `function_description` - Get the description of a function.
# ## Description
# - **Purpose**:
#   - Retrieves the description of a function from its documentation file.
# - **Usage**: 
#   - `function_description <function_name>`
# - **Input Parameters**: 
#   - `function_name`: The name of the function.
# - **Output**: 
#   - Returns the description of the function as a string.
# - **Exceptions**: 
#   - None
#
function_description() {
    local function_name="$1"
    local doc_file="${__VENV_BASE}/${__VENV_FUNCTIONS[$function_name]}"
    local description

    if [[ -f "$doc_file" ]]; then
        description=$(head -n 3 "$doc_file" | tail -n 1)
        description="${description#*- }"
    fi

    description="${description:-"No description available"}"
    echo "${description}"
}


# # Function: docs_base_path
#  `docs_base_path` - Get the base path for documentation files.
# ## Description
# - **Purpose**:
#   - Retrieves the base path for documentation files.
# - **Usage**: 
#   - `docs_base_path`
# - **Input Parameters**: 
#   - None
# - **Output**: 
#   - Returns the base path for documentation files as a string.
# - **Exceptions**: 
#   - None
#
docs_base_path() {
    echo "docs/shdoc"
}


# # Function: get_system_readme_file
#  `get_system_readme_file` - Get the path to the README file for scripts.
# ## Description
# - **Purpose**:
#   - Retrieves the path to the README file for scripts.
# - **Usage**: 
#   - `get_system_readme_file <readme_dir>`
# - **Input Parameters**: 
#   - `readme_dir`: Optional directory path to search for the README file.
# - **Output**: 
#   - Returns the path to the README file for scripts as a string.
# - **Exceptions**: 
#   - None
#
get_system_readme_file() {
    local readme_dir="$1"
    local scripts_readme_file="${readme_dir:-""}/README.md"
    echo "${scripts_readme_file}"
}


# # Function: get_script_readme_file
#  `get_script_readme_file` - Get the path to the README file for a script.
# ## Description
# - **Purpose**:
#   - Retrieves the path to the README file for a script.
# - **Usage**: 
#   - `get_script_readme_file <script_name> <script_dir>`
# - **Input Parameters**: 
#   - `script_name`: The name of the script.
#   - `script_dir`: The directory containing the script.
# - **Output**: 
#   - Returns the path to the README file for the script as a string.
# - **Exceptions**: 
#   - None
#
get_script_readme_file() {
    local script_name="$1"
    local script_dir="$2"

    local script_readme_file="${script_dir}/${script_name//./_}.md"

    echo "${script_readme_file}"
}


# # Function: write_system_readme_header
#  `write_system_readme_header` - Writes the header section of the README.
# ## Description
# - **Purpose**:
#   - Creates the initial header content for the README documentation.
# - **Usage**: 
#   - `write_system_readme_header <file_path>`
# - **Input Parameters**: 
#   - `file_path`: The path to the README file.
# - **Output**: 
#   - Writes the header content to the specified README file.
# - **Exceptions**: 
#   - None
#
write_system_readme_header() {

    local system_readme_file
    system_readme_file="$(docs_base_path)/$(get_system_readme_file "")"

    {
        echo -e "# System Script Documentation"
        echo -e ""
        echo -e "## The for more details of the project, see [README](/README.md)"
        echo -e ""
        echo -e "# List of scripts in project"
        echo -e ""
        echo -e "| Script | Description |"
        echo -e "|:--|:--|"
    } > "${system_readme_file}"
}


# # Function: write_system_readme_entry
#  `write_system_readme_entry` - Creates an entry in the README for a script or function.
# ## Description
# - **Purpose**:
#   - Adds a Markdown link to the README file for the given script or function.
# - **Usage**: 
#   - `write_system_readme_entry <script_name> <scripts_readme_file>`
# - **Input Parameters**: 
#   - `script_name`: The name of the script or function.
#   - `scripts_readme_file`: Path to the README file.
# - **Output**: 
#   - Appends a Markdown-formatted link to the README.
# - **Exceptions**: 
#   - None
#
write_system_readme_entry() {
    local script_name="$1"
    local script_dir="$2"

    local script_readme_file
    script_readme_file="$(get_script_readme_file "$script_name" "$script_dir")"

    local system_readme_file
    system_readme_file="$(docs_base_path)/$(get_system_readme_file "")"

    printf "| [%s](%s) | %s |\n" \
        "${script_name}" "${script_readme_file}" \
        "$(script_description "${script_name}")" >> "${system_readme_file}"
}


# # Function: write_script_readme_header
#  `write_script_readme_header` - Write the description of the script and the functions contained in it
# ## Description
# - **Purpose**:
#   - Write the script should description and the functions with it. These will link to their
#     individual documentation.
# - **Usage**: 
#   - `write_script_readme_header <script_name> <script_dir>`
# - **Input Parameters**: 
#   - `script_name`: The name of the script.
#   - `script_dir`: The directory containing the script.
# - **Output**: 
#   - Writes a list of scripts with links to script and function documentation.
# - **Exceptions**: 
#   - None
#
write_script_readme_header() {
    local script_name="$1"
    local script_dir="$2"

    local script_doc_file="${__VENV_SCRIPTS[$script_name]}"

    local script_readme_file
    script_readme_file="$(get_script_readme_file "$script_name" "$script_dir")"

    local script_readme_location
    script_readme_location="$(docs_base_path)/${script_readme_file}"

    {
        echo -e "# Functions Defined in Script: ${script_name}\n"
        echo -e "### [${script_name}](/${script_doc_file}) - $(script_description "$script_name")\n"
        echo -e "## List of Functions Defined\n"
        echo -e "| Function | Description |"
        echo -e "|:--|:--|"
    } > "${script_readme_location}"
}


# # Function: write_script_function_entry
#  `write_script_function_entry` - Write a function entry in the script documentation.
# ## Description
# - **Purpose**:
#   - Generate script entry for the script which defines it.
# - **Usage**: 
#   - `write_script_function_entry <function_name> <script_readme_file>`
# - **Input Parameters**: 
#   - `function_name`: The name of the function.
#   - `script_readme_file`: The path to the script function index file.
# - **Output**: 
#   - Writes the documentation for the specified function to a file.
# - **Exceptions**: 
#   - None
#
write_script_function_entry() {
    local function_name="$1"
    local script_name="$2"
    local script_dir="$3"

    local script_readme_file
    script_readme_file="$(get_script_readme_file "$script_name" "$script_dir")"

    local script_readme_location
    script_readme_location="$(docs_base_path)/${script_readme_file}"

    local function_markdown_path="${__VENV_FUNCTIONS[$function_name]}"
    function_markdown_path="functions/$(basename "$function_markdown_path")"

    printf "| [%s](%s) | %s |\n" \
        "${function_name}" "${function_markdown_path}" \
        "$(function_description "$function_name")" >> "${script_readme_location}"
}


# # Function write_script_doc
#  `write_script_doc` - Write the documentation for a script.
# ## Description
# - **Purpose**:
#   - Generate Markdown documentation for a specific script.
# - **Usage**: 
#   - `write_script_doc <script_name> <script_dir> <script_markdown>`
# - **Input Parameters**: 
#   - `script_name`: The name of the script to generate documentation for.
#   - `script_dir`: The directory where the script is located.
#   - `script_markdown`: The path to the script markdown file.
# - **Output**: 
#   - Writes the documentation for the specified script to a file.
# - **Exceptions**: 
#   - None
#
write_script_doc() {
    local script_name="$1"; shift
    local script_dir="$1"; shift
    local script_markdown="$*"

    local script_markdown_file="${__VENV_SCRIPTS[$script_name]}"

    local script_readme_file
    script_readme_file="$(get_script_readme_file "$script_name" "..")"

    {
        echo -e "$script_markdown"
        echo -e "\n"
        echo -e "## Defined in Script\n"
        echo -e "* [${script_name}](${script_readme_file})"
    } > "${script_markdown_file}"
    write_page_footer "${script_markdown_file}"

    write_script_readme_header "${script_name}" "${script_dir}"

    write_system_readme_entry "${script_name}" "${script_dir}"
}


# # Function: write_function_doc
#  `write_function_doc` - Write the documentation for a function.
# ## Description
# - **Purpose**:
#   - Generate Markdown documentation for a specific function.
# - **Usage**: 
#   - `write_function_doc <function_name> <script_name> <script_path> <function_markdown>`
# - **Input Parameters**: 
#   - `function_name`: The name of the function to generate documentation for.
# - **Output**: 
#   - Writes the documentation for the specified function to a file.
# - **Exceptions**: 
#   - None
#
write_function_doc() {
    local function_name="$1"; shift
    local script_name="$1"; shift
    local script_dir="$1"; shift
    local function_markdown="$*"

    local script_readme_file
    script_readme_file="$(get_script_readme_file "$script_name" "..")"

    local function_markdown_file="${__VENV_FUNCTIONS[$function_name]}"
    {
        echo -e "## ${function_name}"
        echo -e "$function_markdown"
        echo -e "## Definition \n"
        echo -e "* [${script_name}](${script_readme_file})"
    } > "${function_markdown_file}"
    write_page_footer "$function_markdown_file"

    write_script_function_entry "${function_name}" "${script_name}" "${script_dir}"
}

# # Function: write_table_footer
#  `write_table_footer` - Write the footer section of the README.
# ## Description
# - **Purpose**:
#   - Creates the footer content for the README documentation.
# - **Usage**: 
#   - `write_table_footer <file_path>`
# - **Input Parameters**: 
#   - `file_path`: The path to the README file.
# - **Output**: 
#   - Writes the footer content to the specified README file.
# - **Exceptions**: 
#   - None
#
write_table_footer() {
    local file_path="$1"
    {
        echo -e "\n---\n"
    } >> "${file_path}"
    write_page_footer "${file_path}"
}


# # function: write_page_footer
#  `write_page_footer` - Writes a standard footer for any document file
# ## Description
# - **Purpose**:
#   - Appends footer content and a timestamp to the README documentation.
# - **Usage**: 
#   - `write_page_footer <file_path>`
# - **Input Parameters**: 
#   - `file_path`: The path to the README file.
# - **Output**: 
#   - Appends footer content and timestamp to the README file.
# - **Exceptions**: 
#   - None
#
write_page_footer() {
    local file_path="$1"
    local date_mark

    date_mark=$(date "+Generated on: %Y-%m-%d at %H:%M:%S")

    {
        echo "---"
        echo ""
        echo "Website: [unixwzrd.ai](https://unixwzrd.ai)"
        echo "Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)"
        echo "Copyright (c) 2025 Michael Sullivan"
        echo "Apache License, Version 2.0"
        echo ""
        echo "Generated Markdown Documentation"
        echo "${date_mark}"
        # Add other footer content here
    } >> "${file_path}"
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
    local current_dir=${PWD}
    cd "${__VENV_BASE}"  || errno_exit ENOENT

    local conf_file="conf/help_sys.conf"
    local shdoc_base
    shdoc_base="$(docs_base_path)"
    mkdir -p "${shdoc_base}"

    local in_progress_timestamp="${shdoc_base}/.in-progress"
    local completed_timestamp="${shdoc_base}/AUTO_GENERATED_DO_NOT_MODIFY_OR_PLACE_FILES_HERE"
    touch "${in_progress_timestamp}"

    local system_readme_file
    system_readme_file="$(docs_base_path)/$(get_system_readme_file "")"
    write_system_readme_header

    local search_dirs
    readarray -t search_dirs < <(grep -v '^#' "$conf_file" | sed '/^$/d')

    # Iterate over directories to find shell scripts and their documentation
    for script_dir in "${search_dirs[@]}"; do
        local scripts_docs_dir="${shdoc_base}/${script_dir}"
        local script_docs_path="${scripts_docs_dir}/scripts"
        local function_docs_path="${scripts_docs_dir}/functions"
        mkdir -p "${function_docs_path}" "${script_docs_path}"
        local script_files
        readarray -t script_files < <(file "${script_dir}"/* | grep "shell script" | cut -d":" -f1)

        # Iterate over sorted script names
        local script_path
        for script_path in "${script_files[@]}"; do
            local script_name
            script_name=$(basename "$script_path")
            local script_readme_file
            script_readme_file="$(get_script_readme_file "$script_name" "$script_dir")"
            local script_readme_location
            script_readme_location="$(docs_base_path)/${script_readme_file}"
            
            log_message "INFO" "Generating markdown for script: $script_name"

            local in_script_doc=false
            local in_function_doc=false
            local script_entry=false
            local previous_line
            local extracted_markdown=""
            local function_name=""

            # Open the script file for reading
            while IFS= read -r line || [[ -n "${line}" ]]; do
                # Give the user something to look at while this is running.
                printf "."


                # Check for beginning of the script.
                if [[ "${line}" =~ ^\#! ]]; then
                    script_entry=true
                    in_function_doc=false
                    continue
                fi

                # In the script, skip blank lines, lines with only whitespace, or
                # lines beginning with '#' optionally followed by whitespace
                if [[ "${script_entry}" == true && \
                        ( "${line}" =~ ^[[:space:]]*$ || "${line}" =~ ^#[[:space:]]*$ ) ]]; then
                    continue
                fi

                # Handle Script documentation
                if [[ ("${in_script_doc}" == true || "${script_entry}" == true) && \
                        "${line}" =~ ^#+ ]]; then
                    extracted_markdown+="${line/#\# /}\n"
                    script_entry=false
                    in_script_doc=true
                    continue
                fi
                
                # Checking for end of script documentation
                if [[ "${in_script_doc}" == true && "${line}" =~ ^[[:space:]]*$ ]]; then
                    write_script_doc "${script_name}" "${script_dir}" \
                                        "${extracted_markdown}"
                    extracted_markdown=""
                    previous_line="${line}"
                    in_script_doc=false
                    continue
                fi

                # Checking for end of function code
                if [[ "${previous_line}" =~ ^}$ && "${line}" =~ ^[[:space]]*$ ]]; then
                    in_function_doc=false
                    continue
                fi

                # Check for beginning of a function documentation
                if [[ "${in_function_doc}" == false && "${previous_line}" =~ ^[[:space:]]*$ && \
                            "${line}" =~ ^#.* ]]; then
                    extracted_markdown+="${line/#\# /}\n"
                    in_function_doc=true
                    continue
                fi
                
                # Reset if we get a blank line before reaching the end of the function documentation
                if [[ "${in_function_doc}" == true && "${line}" =~ ^[[:space:]]*$ ]]; then
                    extracted_markdown=""
                    previous_line="${line}"
                    in_function_doc=false
                    continue
                fi

                # Check for single `#` on line followed by optional whitespace and skip it
                if [[ "${in_function_doc}" == true && "${line}" =~ ^#[[:space:]]*$ ]]; then
                    continue
                fi

                # Handle Function documentation
                if [[ "${in_function_doc}" == true && "${line}" =~ ^\#+ ]]; then
                    extracted_markdown+="${line/#\# /}\n"
                    continue
                fi

                # We reached the end of the function, reset
                if [[ "${line}" =~ ^(function[[:space:]]+)?[a-zA-Z_][a-zA-Z0-9_]*\(\)[[:space:]]*\{ ]]; then
                    function_name="${line%%(*}"
                    function_name="${function_name/#function /}"
                    write_function_doc "${function_name}" "${script_name}" "${script_dir}" \
                                        "${extracted_markdown}"
                    extracted_markdown=""
                    in_function_doc=false
                    continue
                fi

                # Skip the line if it does not have a-z, A-Z, _, or #, or if the line is entirely whitespace.
                if [[ ! "${line}" =~ ^[a-zA-Z_#[[:space:]]].* || "${line}" =~ ^[[:space:]]*$ ]]; then 
                    previous_line="${line}"
                    continue
                fi

                log_message "WARNING" "Invalid line type found: $line"

                previous_line="${line}"

            done < "$script_path"

            # Write the extracted documentation to the markdown file
            write_table_footer "${script_readme_location}"
        done
    done

    write_table_footer "${system_readme_file}"

    # After documentation generation is complete
    mv "${in_progress_timestamp}" "${completed_timestamp}"
    # Now find and delete old markdown files
    find "${shdoc_base}" -type f -name '*.md' ! -newer "${completed_timestamp}" -exec rm {} \;
    printf "\n"
    # disable this check because it is going to return anyway.
    # shellcheck disable=SC2164
    cd "${current_dir}" > /dev/null 2>&1
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
        printf "  * %-$((${longest_script_name}+1))s %s\n" "${script}:" "$(script_description "$script")"
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
        local markdown_file="${__VENV_BASE}/${__VENV_SCRIPTS[$script]}"
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

    # shellcheck disable=SC2199,SC2076
    if [[ " ${__VENV_INTERNAL_FUNCTIONS[@]} " =~ " ${func} " ]]; then
        echo "The function '${func}' is for internal use. Please refer to the system documentation."
        return
    fi

    echo ""

    if [[ -v __VENV_FUNCTIONS[$func] ]]; then
        local markdown_file="${__VENV_BASE}/${__VENV_FUNCTIONS[$func]}"
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
    local description
    local line

    echo -e "\nAvailable functions and their brief descriptions:\n"

    # shellcheck disable=SC2068
    for function in ${sorted_function_names[@]}; do
        # Skip internal functions
        # shellcheck disable=SC2199,SC2076
        if [[ " ${__VENV_INTERNAL_FUNCTIONS[@]} " =~ " ${function} " ]]; then
            continue
        fi
        printf "  * %-${longest_function_name}s %s\n" "${function}:" "$(function_description "$function")"
    done

    echo -e "\nUse 'vhelp \`function_name\`' for detailed information on each function.\n"

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
    command -v "${MD_PROCESSOR}" > /dev/null 2>&1 && md_command="${MD_PROCESSOR}" || md_command="cat"

    # Check if the subcommand is a known script name
    if [[ -n "${__VENV_SCRIPTS["${subcommand}"]:-""}" ]]; then
        is_script=1
    fi

    case "${subcommand}" in
        "generate_markdown")
            echo "Starting markdown generation"
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

__rc__=0
return ${__rc__}