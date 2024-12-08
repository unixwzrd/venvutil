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

# Extract script name, directory, and arguments
declare -g __VENV_BIN
declare -g __VENV_BASE
declare -g __VENV_ARGS=$*
__VENV_BIN=$(dirname "$(dirname "${THIS_SCRIPT}")")
__VENV_BASE=$(dirname "${__VENV_BIN}")

# Help System Initialization

# Use an environment variable for markdown processor, defaulting to 'glow'
declare -g MD_PROCESSOR=${MD_PROCESSOR:-"glow"}

# Define an array of internal functions to exclude from help and documentation
declare -g -a __VENV_INTERNAL_FUNCTIONS=(
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
declare -g -a sorted_function_names
declare -g -a sorted_script_names

# Initialize variables to store the length of the longest script and function names
declare -g longest_script_name=0
declare -g longest_function_name=0

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
    cd ${__VENV_BASE} || errno_exit ENOENT
    local dir_name="$1"
    local script_dir="${dir_name}"
    local doc_dir="docs/shdoc/${dir_name}"
    readarray -t script_files < <(find "$script_dir" -type f -name "*.sh")
    for script in "${script_files[@]}"; do
        local script_name
        script_name="$(basename "$script")"
        local markdown_file="${doc_dir}/scripts/${script_name}.md"
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
                local function_markdown_path="${doc_dir}/functions/${function}.md"
                __VENV_FUNCTIONS["$function"]="$function_markdown_path"
                sorted_function_names+=("$function")
                
                # Update longest function name length
                if [[ ${#function} -gt $longest_function_name ]]; then
                    longest_function_name=${#function}
                fi
            fi
        done < "$script"
    done
    readarray -t sorted_script_names < <(printf "%s\n" "${sorted_script_names[@]}" | sort)
    readarray -t sorted_function_names < <(printf "%s\n" "${sorted_function_names[@]}" | sort)
    
    cd -
}

# # function: init_help_system
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
    
    cd -
}


# # function: script_descruption
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


# # function: write_index_header
#  `write_index_header` - Writes the header section of the README.
# ## Description
# - **Purpose**:
#   - Creates the initial header content for the README documentation.
# - **Usage**: 
#   - `write_index_header <file_path>`
# - **Input Parameters**: 
#   - `file_path`: The path to the README file.
# - **Output**: 
#   - Writes the header content to the specified README file.
# - **Exceptions**: 
#   - None
#
write_index_header() {
    local readme_file="$1"
    {
        echo -e "# Script Documentation"
        echo -e "## The for more details of the project, see [README.md](README.md)"
        echo -e ""
        echo -e "# List of scripts in project"
        echo -e ""
        printf "<pre><table>\n" >> "${readme_file}"
    } > "${readme_file}"
}


generate_nbsp_padding() {
    local name="$1"
    local longest_name="$2"
    local padding_length=$((longest_name - ${#name} + 1))
    local nbsp=""
    for ((i = 0; i < padding_length; i++)); do
        nbsp+="&nbsp;"
    done
    echo "$nbsp"
}


# # function: write_readme_entry
#  `write_readme_entry` - Creates an entry in the README for a script or function.
# ## Description
# - **Purpose**:
#   - Adds a Markdown link to the README file for the given script or function.
# - **Usage**: 
#   - `create_readme <name> <description> <markdown_path> <readme_file>`
# - **Input Parameters**: 
#   - `name`: The name of the script or function.
#   - `description`: A brief description.
#   - `markdown_path`: Path to the Markdown documentation.
#   - `readme_file`: Path to the README file.
# - **Output**: 
#   - Appends a Markdown-formatted link to the README.
# - **Exceptions**: 
#   - None
#
write_readme_entry() {
    local script_name="$1"
    local readme_file="$2"

    local script_doc_path
    script_doc_path=$(dirname "$(dirname "${__VENV_SCRIPTS[$script_name]}")")

    local script_doc_name="${script_name//./_}.md"
    local script_doc_file="${script_doc_path}/${script_doc_name}"

    printf "<tr><td><a href=\"%s\">%s</a></td><td>%s</td></tr>\n" \
        "${script_doc_file}" "${script_name}" \
        "$(script_description "$script_name")" >> "${readme_file}"
}


# # Function: writee_script_index_header
#  `write_script_index_header` - Write the description of the script and the functions contained in it
# ## Description
# - **Purpose**:
#   - Write the script showt descrtiptionand the finctions with it. These will link to their
#     individual documentation.
# - **Usage**: 
#   - `write_script_index <script_index_file>`
# - **Input Parameters**: 
#   - `script_index_file`: The path to the script function index file.
# - **Output**: 
#   - Writes a list of scripts with links to script and function documentation.
# - **Exceptions**: 
#   - None
#
write_script_index_header() {
    local script_name="$1"
    local script_index_file="$2"
    local script_doc_file="${__VENV_SCRIPTS[$script_name]}"
    {
        echo -e "# List of functions in script: ${script_name}"
        echo -e ""
        echo -e "### [${script_name}](/${script_doc_file}) - $(script_description "$script_name")"
        echo -e ""
        echo -e "## List of functions in script: [${script_name}](${script_doc_file})"
        echo -e ""
        printf "<pre><table>\n"
    } > "${script_index_file}"
}


# # Function: write_script_function_entry
#  `write_script_function_entry` - Write a function entry in the documentation.
# ## Description
# - **Purpose**:
#   - Generate Markdown documentation for a specific function.
# - **Usage**: 
#   - `write_script_function_entry <script_index_file>`
# - **Input Parameters**: 
#   - `script_index_file`: The path to the script function index file.
# - **Output**: 
#   - Writes the documentation for the specified function to a file.
# - **Exceptions**: 
#   - None
#
write_script_function_entry() {
    local function_name="$1"
    local script_index_file="$2"

    local script_markdown_path="${__VENV_FUNCTIONS[$function_name]}"

    printf "<tr><td><a href=\"%s\">%s</a></td><td>%s</td></tr>\n" \
        "${script_markdown_path}" "${function_name}" \
        "$(function_description "$function_name")" >> "${script_index_file}"
}


# # Function write_script_doc
#  `write_script_doc` - Write the documentation for a script.
# ## Description
# - **Purpose**:
#   - Generate Markdown documentation for a specific script.
# - **Usage**: 
#   - `write_script_doc <script_name> <script_index_file> <readme_file> <script_markdown>`
# - **Input Parameters**: 
#   - `script_name`: The name of the script to generate documentation for.
# - **Output**: 
#   - Writes the documentation for the specified script to a file.
# - **Exceptions**: 
#   - None
#
write_script_doc() {
    local script_name="$1"; shift
    local script_index_file="$1"; shift
    local readme_file="$1"; shift
    local script_markdown="$*"

    local markdown_file_name="${__VENV_SCRIPTS[$script_name]}"

    echo -e "$script_markdown" > "${markdown_file_name}"
    write_page_footer "${markdown_file_name}"

    write_script_index_header "${script_name}" "${script_index_file}"

    write_readme_entry "${script_name}" "${readme_file}"
}


# # Function: write_function_doc
#  `write_function_doc` - Write the documentation for a function.
# ## Description
# - **Purpose**:
#   - Generate Markdown documentation for a specific function.
# - **Usage**: 
#   - `write_function_doc <function_name>`
# - **Input Parameters**: 
#   - `function_name`: The name of the function to generate documentation for.
# - **Output**: 
#   - Writes the documentation for the specified function to a file.
# - **Exceptions**: 
#   - None
#
write_function_doc() {
    local function_name="$1"; shift
    local script_index_file="$1"; shift
    local function_markdown="$*"

    local function_markdown_file="${__VENV_FUNCTIONS[$function_name]}"

    echo -e "$function_markdown" > "$function_markdown_file"
    write_page_footer "$function_markdown_file"

    write_script_function_entry "${function_name}" "${script_index_file}"
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
    local date_mark

    date_mark=$(date "+Generated: %Y %m %d at %H:%M:%S")

    {
        echo -e "</table></pre>"
        echo -e ""
        echo "---"
        echo -e "Generated Markdown Documentation"
        echo -e "Generated on:${date_mark}"
    } >> "${file_path}"
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

    date_mark=$(date "+Generated: %Y %m %d at %H:%M:%S")

    {
        echo -e ""
        echo "---"
        echo -e "Generated Markdown Documentation"
        echo -e "Generated on:${date_mark}"
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
    cd "${__VENV_BASE}"  || errno_exit ENOENT

    local conf_file="conf/help_sys.conf"
    local shdoc_dir="docs/shdoc"
    [ -d "${shdoc_dir}" ] || mkdir -p "${shdoc_dir}"

    local in_progress_timestamp="${shdoc_dir}/.in-progress"
    local completed_timestamp="${shdoc_dir}/AUTO_GENERATED_DO_NOT_MODIFY_OR_PLACE_FILES_HERE"
    touch "${in_progress_timestamp}"

    local readme_file="docs/README.md"
    write_index_header "${readme_file}"

    local search_dirs
    readarray -t search_dirs < <(grep -v '^#' "$conf_file" | sed '/^$/d')

    # Iterate over directories to find shell scripts and their documentation
    for dir_name in "${search_dirs[@]}"; do
        local script_dir="${dir_name}"
        local doc_dir="${shdoc_dir}/${dir_name}"
        local script_docs_path="${doc_dir}/scripts"
        local function_docs_path="${doc_dir}/functions"
        [ -d "${function_docs_path}" ] || mkdir -p "${function_docs_path}"
        [ -d "${script_docs_path}" ] || mkdir -p "${script_docs_path}"
        local script_files
        script_files=($(file "${script_dir}"/* | grep "shell script" | cut -d":" -f1))

        # Iterate over sorted script names
        local script_path
        for script_path in "${script_files[@]}"; do
            local script_name
            script_name=$(basename "$script_path")
            local script_index_file="${dir_name}/${script_name//./_}.md"
            
            log_message "INFO" "Generating markdown for script: $script_name"

            local in_script_doc=false
            local in_function_doc=false
            local script_entry=false
            local previous_line
            local extracted_markdown=""
            local function_name=""

            # Open the script file for reading
            while IFS= read -r line || [[ -n "${line}" ]]; do


                # Check for beginning of the script.
                if [[ "${line}" =~ ^\#! ]]; then
                    script_entry=true
                    in_function_doc=false
                    continue
                fi

                # In the script, skip blank lines, lines with only whitespace, or
                # lines beginning with '#' optionally followed by whitespace
                if [[ "${script_entry}" == true && ("${line}" =~ ^[[:space:]]*$ || \
                        "${line}" =~ ^#[[:space:]]*$) ]]; then
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
                    write_script_doc "${script_name}" "${script_index_file}" "${readme_file}" \
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
                    extracted_markdown="## ${function_name}\n${extracted_markdown}"
                    extracted_markdown+="## Definition\n"
                    extracted_markdown+="* [${script_name}](/${script_index_file})"
                    write_function_doc "${function_name}" "${script_index_file}" "${extracted_markdown}"
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
            write_table_footer "${script_index_file}"
        done
    done

    write_table_footer "${readme_file}"

    # After documentation generation is complete
    mv "${in_progress_timestamp}" "${completed_timestamp}"
    # Now find and delete old markdown files
    find "${shdoc_dir}" -type f -name '*.md' ! -newer "${completed_timestamp}" -exec rm {} \;
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

    for function in ${sorted_function_names[@]}; do
        # Skip internal functions
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
