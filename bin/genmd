#!/usr/bin/env bash
#
# Name:
#       genmd - Combined source code markdown generator.
#
# Usage:
#       genmd [options]
#
# Options:
#       -d, --debug [level]       Set debug level (0-9)
#                                 0: No debug output
#                                 1: Show informational messages
#                                 2: Show debug messages
#                                 3: Show regex commands and patterns
#                                 9: Show xtrace messages
#       -h, --help                Show this help message
#       -e, --exclude [patterns]  Exclude directories matching the given patterns.
#                                 Multiple patterns can be separated by '|'.
#       -f, --file [patterns]     Exclude files matching the given patterns.
#                                 Multiple patterns can be separated by '|' or spaces.
#       -p, --pattern [patterns]  Exclude additional patterns matching the given strings.
#                                 Multiple patterns can be separated by '|' or spaces.
#       -i, --include [patterns]  Include files matching the given patterns.
#                                 Multiple patterns can be separated by '|' or spaces.
#       -o, --output [filename]   Output file (default: combined_source.md)
#       -c, --config [filename]   Load configuration from a .grc or .cfg file.
#                                 If the filename does not end with .grc or .cfg, .grc will be appended.
#       -s, --settings [modes]    Show settings. Modes can be:
#                                 info: Show current settings
#                                 cfg: Write to configuration file
#                                 md: Include settings in markdown output
#                                 env: Output settings as environment variables
#                                 all: Perform info, md, and env actions
#       -n, --dry-run             Do not write the output file; print the files to be processed.
#       -v, --verbose             Show verbose output
#
# Description:
#       The genmd script generates markdown from the files in the specified directory,
#       excluding files and directories based on provided patterns. It outputs:
#       - Project filesystem directory structure
#       - Source code in a single markdown file for all included files.
#       - Excluded files are omitted based on exclusion patterns.
#
# Examples:
#       genmd -e "node_modules|dist" -f "*.log *.tmp"  -i "*css *.js" -s "info,md" -o project_overview.md
#       genmd --exclude "node_modules|dist" --file "*.log *.tmp" --include "info" --dry-run
#       genmd -s info,md -d 2
#
# Environment:
#       GENMD_BASE: The base directory to search for files in.
#       GENMD_DIR_EXCLUDES: A default list of directory patterns to exclude from the generated markdown.
#       GENMD_FILE_EXCLUDES: A default list of file patterns to exclude from the generated markdown.
#       GENMD_PATTERN_EXCLUDES: A default list of additional patterns to exclude from the generated markdown.
#       GENMD_FILE_INCLUDES: A default list of file patterns to include in the generated markdown.
#       PAGER: The pager to use for output, defaults to `less -R`
#
# Author:
#       Michael Sullivan <unixwzrd@unixwzrd.ai>
#           https://unixwzrd.ai/
#           https://github.com/unixwzrd
#
# License:
#       Apache License, Version 2.0
#

# Ensure the script exits on error and treats unset variables as errors
set -euo pipefail

# Check for Bash version 4+
if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "Error: genmd requires Bash version 4 or higher." >&2
    exit 75     # (EPROGMISMATCH: 75): Program version wrong
fi

# Define an array of variable names to display
settings_variables=(
    "GENMD_FILE_EXCLUDES"
    "GENMD_DIR_EXCLUDES"
    "GENMD_PATTERN_EXCLUDES"
    "GENMD_FILE_INCLUDES"
    "GENMD_BASE"
    "output_filename"
    "dry_run"
    "debug_level"
    "verbose"
)

my_name="$(basename "${BASH_SOURCE[0]}")"

# Allow the user to set GENMD_BASE externally, falling back to BASE_DIR, then to the current directory.
GENMD_BASE="${GENMD_BASE:-${BASE_DIR:-"."}}"

# Define output directories
output_dir="$GENMD_BASE/utils/output"
config_dir="$GENMD_BASE/utils/etc"

# Function to ensure directories exist
ensure_directory_exists() {
    local dir_path="$1"
    if [[ ! -d "$dir_path" ]]; then
        mkdir -p "$dir_path" || { echo "Error: Failed to create directory \"$dir_path\"." >&2; exit 1; }
    fi
}

# Ensure necessary directories exist
ensure_directory_exists "$output_dir"
ensure_directory_exists "$config_dir"

# Set default output filename within the output directory
output_filename="${output_dir}/combined_source.md"

# Derive the base name without extension
output_basename="$(basename "$output_filename" .md)"

# Set default config filename (prefer .grc, fallback to .cfg)
config_filename="${output_basename}.grc"

# Define the config file path
config_file_path="$config_dir/$config_filename"

# Check if config file exists and source it
if [[ -f "$config_file_path" ]]; then
    # shellcheck disable=SC1091
    source "$config_file_path"
    echo "INFO ($my_name): Configuration loaded from $config_file_path" >&2
fi

# Flags
dry_run=false
debug_level=0
verbose=false
settings_modes=("md")

# Initialize include and exclude arrays with default exclusions or environment variables
read -r -a file_excludes <<< "${GENMD_FILE_EXCLUDES:-*.ico *.svg *.png *.pdf *.jpg *.htaccess *.webp *.jekyll .DS_Store combined_source.md *.JPG *.png}"
read -r -a dir_excludes <<< "${GENMD_DIR_EXCLUDES:-tmp}"
echo "INFO ($my_name): GENMD_DIR_EXCLUDES: ${dir_excludes[*]}"
read -r -a pattern_excludes <<< "${GENMD_PATTERN_EXCLUDES:-}"
read -r -a file_includes <<< "${GENMD_FILE_INCLUDES:-footer|social|ss|liquid|\.md}"

# Function to display help message
display_help() {
    cat <<_EOT_ | ${PAGER:-less -R}

Usage: $my_name [options]

Options:
    -d, --debug [level]               Set debug level (0-9)
                                        0: No debug output
                                        1: Show informational messages
                                        2: Show debug messages
                                        3: Show regex commands and patterns
                                        9: Show xtrace messages
    -h, --help                        Show this help message
    -e, --exclude [patterns]          Exclude directories matching the given patterns.
                                        Multiple patterns can be separated by '|'.
    -f, --file [patterns]             Exclude files matching the given patterns.
                                        Multiple patterns can be separated by '|' or spaces.
    -p, --pattern [patterns]          Exclude additional patterns matching the given patterns.
                                        Multiple patterns can be separated by '|' or spaces.
    -i, --include [patterns]          Include only files matching the given strings
                                        Multiple patterns can be separated by '|' or spaces.
    -o, --output [filename]           Output file (default: combined_source.md)
    -c, --config [filename]           Load configuration from a .grc or .cfg file.
                                        If the filename does not end with .grc or .cfg, .grc will be appended.
    -s, --settings [modes]            Show settings. Modes can be:
                                        info: Show current settings
                                        md: Include settings in markdown output
                                        cfg: Write to configuration file
                                        env: Output settings as environment variables
                                        all: Perform info, md, and env actions
    -n, --dry-run                     Do not write the output file; print the files to be processed.
    -v, --verbose                     Show verbose output

Examples:
    $my_name -d 9 -e "utils _includes _data _posts js collaborates projects" \
            -f "*impression* professional.md *.png" \
            -i "footer social icss liquid" \
            -s all
    $my_name --exclude "node_modules|dist" --file "*.log *.tmp" --include "info" --dry-run
    $my_name -s info,md -d 2

Author: Michael Sullivan <unixwzrd@unixwzrd.ai>
        https://unixwzrd.ai/
        https://github.com/unixwzrd

License: Apache License, Version 2.0

_EOT_
    exit 22     # (EINVAL: 22): Invalid argument
}

# Function to display or write out the current settings
display_settings() {
    local modes=("$@")  # Array of modes passed to the function

    for mode in "${modes[@]}"; do
        case "$mode" in
            info)
                echo "genmd current settings" >&2
                for var in "${settings_variables[@]}"; do
                    echo "$var:    ${!var}" >&2
                done
                ;;
            md)
                {
                    echo "## genmd Settings"
                    echo ""
                    echo "| Variable               | Value                                                                 |"
                    echo "|------------------------|-----------------------------------------------------------------------|"
                    for var in "${settings_variables[@]}"; do
                        local value="${!var}"
                        value="${value//|/\\|}"
                        echo "| $var | $value |"
                    done
                    echo ""
                } >> "$output_filename"
                ;;
            cfg)
                save_config
                ;;
            env)
                {
                    echo ""
                    echo "## genmd Environment Variables"
                    echo ""
                    for var in "${settings_variables[@]}"; do
                        echo "export $var=\"${!var}\""
                    done
                    echo ""
                } > "${GENMD_BASE}/genmd_env.sh"
                ;;
            all)
                display_settings "info" "md" "env" "cfg"
                ;;
            *)
                echo "Error: Unknown mode '$mode' for --settings" >&2
                exit 22     # (EINVAL: 22): Invalid argument
                ;;
        esac
    done
}

sanitize_patterns() {
    # Retain alphanumerics, underscores, dots, asterisks, pipes, and spaces
    local cleanstring
    cleanstring=$(printf "%s" "$1" | sed -E 's/[^a-zA-Z0-9._*| ]//g')
    if [[ $debug_level -gt 1 ]]; then
        echo "DEBUG ($my_name): Dirty pattern: $1" >&2
        echo "DEBUG ($my_name): Clean pattern: $cleanstring" >&2
    fi
    echo "$cleanstring"
}

# Function to build a single regex pattern from an array of patterns
build_regex() {
    local caller_message="$1"
    local -n patterns_ref=$2  # Reference to the array
    local regex=""
    local escaped_pattern

    if [[ $debug_level -gt 1 ]]; then
        echo "DEBUG ($my_name): $caller_message patterns: ${patterns_ref[@]}" >&2
    fi

    for pattern in "${patterns_ref[@]}"; do
        if [[ $debug_level -gt 2 ]]; then
            echo "DEBUG ($my_name): $caller_message input pattern: $pattern" >&2
        fi
        # Escape special regex characters except for '*' and '|'
        escaped_pattern=$(printf "%s" "$pattern" | sed -E 's/([.+^(){}])/\\\1/g')
        # Replace '*' with '.*' for wildcard matching
        escaped_pattern=${escaped_pattern//\*/.*}
        # '|' is already handled as pattern separators
        if [[ $debug_level -gt 2 ]]; then
            echo "DEBUG ($my_name): $caller_message escaped pattern: $escaped_pattern" >&2
        fi
        if [[ -z "$regex" ]]; then
            regex="$escaped_pattern"
        else
            regex="$regex|$escaped_pattern"
        fi
    done

    if [[ $debug_level -gt 1 ]]; then
        echo "DEBUG ($my_name): $caller_message final regex: $regex" >&2
    fi

    echo "$regex"
}

# Function to build a list of files to include in the combined source
build_file_list() {
    local -n files_ref=$1
    local -n include_files_ref=$2
    local -n exclude_files_ref=$3
    local -n exclude_dirs_ref=$4
    local -n pattern_excludes_ref=$5

    # Change to GENMD_BASE and perform find
    cd "$GENMD_BASE"
    readarray -t files < <(find . -type f | sort -u)

    # Exclude directories in the exclude directory list
    if [[ ${#exclude_dirs_ref[@]} -gt 0 ]]; then
        local dir_regex
        dir_regex=$(build_regex "Exclude directories" "exclude_dirs_ref" | sed -E 's/([^|]+)/\/\1\//g')
        if [[ $debug_level -gt 2 ]]; then
            echo "DEBUG ($my_name): Excluding directories with regex: $dir_regex" >&2
        fi
        # Remove files within excluded directories
        readarray -t files < <(printf "%s\n" "${files[@]}" | grep -vE "($dir_regex)")
    fi

    # Exclude files based on file patterns
    if [[ ${#exclude_files_ref[@]} -gt 0 ]]; then
        local exclude_files_regex
        exclude_files_regex=$(build_regex "Exclude files" "exclude_files_ref")
        if [[ $debug_level -gt 2 ]]; then
            echo "DEBUG ($my_name): Excluding files with regex: $exclude_files_regex" >&2
        fi
        readarray -t files < <(printf "%s\n" "${files[@]}" | grep -vE "$exclude_files_regex")
    fi

    # Exclude any strings in the extra pattern list
    if [[ ${#pattern_excludes_ref[@]} -gt 0 ]]; then
        local pattern_excludes_regex
        pattern_excludes_regex=$(build_regex "Exclude patterns" "pattern_excludes_ref")
        if [[ $debug_level -gt 2 ]]; then
            echo "DEBUG ($my_name): Excluding patterns with regex: $pattern_excludes_regex" >&2
        fi
        readarray -t files < <(printf "%s\n" "${files[@]}" | grep -vE "$pattern_excludes_regex")
    fi

    # Include only files explicitly specified in the include file list
    if [[ ${#include_files_ref[@]} -gt 0 ]]; then
        local include_files_regex
        include_files_regex=$(build_regex "Include files" "include_files_ref")
        if [[ $debug_level -gt 2 ]]; then
            echo "DEBUG ($my_name): Including files with regex: $include_files_regex" >&2
        fi
        readarray -t files < <(printf "%s\n" "${files[@]}" | grep -E "$include_files_regex")
    fi

    # Passing back the array reference
    files_ref=("${files[@]}")
}

# Function to generate markdown for a source file
generate_markdown() {
    local source_file="$1"
    local markdown_type="$2"

    if [[ "$dry_run" = true ]]; then
        echo "Dry run: Would generate markdown type '$markdown_type' for: $source_file" >&2
        return
    fi

    if [[ "$verbose" = true || $debug_level -gt 0 ]]; then
        echo "INFO ($my_name): Generating markdown for: $source_file" >&2
    fi

    {
        printf "\n\n## Filename ==>  %s\n\`\`\`%s\n" "$source_file" "$markdown_type"
        cat "$source_file"
        printf "\n\`\`\`\n"
    } >> "$output_filename"
}

# Function to generate the filetree markdown
generate_filetree() {
    local output_filename="$1"
    shift
    local exclude_list=("$@")
    if [ $debug_level -gt 0 ]; then
        echo "INFO ($my_name): Generating directory and file structure excluding: ${exclude_list[*]}" >&2
    fi

    if ! command -v filetree >/dev/null 2>&1; then
        printf "Error: 'filetree' command not found. Please install it or use an alternative.\n" >&2
        printf "It should have been included with this script and it should be in your \$PATH.\n" >&2
        exit 2  # (ENOENT: 2): No such file or directory
    fi

    if [[ "$dry_run" = true ]]; then
        echo "Dry run: Generating directory and file structure." >&2
        filetree --exclude "${exclude_list[@]}"
        return
    fi

    {
        printf "\n\n## Project filesystem directory structure\n\`\`\`text\n"
        filetree --exclude "${exclude_list[@]}"
        printf "\n\`\`\`\n"
    } >> "$output_filename"
}

# Function to get the file type using the `file` command
get_unknown_filetype() {
    local file_path="$1"
    local file_description
    file_description=$(file -b "$file_path")
    case "$file_description" in
        *Bourne-Again*) echo "bash";;
        *Bourne*) echo "sh";;
        *HTML*) echo "html";;
        *JSON*) echo "json";;
        *JavaScript*) echo "javascript";;
        *Java*) echo "java";;
        *Markdown*) echo "markdown";;
        *PHP*) echo "php";;
        *[Pp]erl*) echo "perl";;
        *Python*) echo "python";;
        *[Rr]uby*) echo "ruby";;
        *SASS*) echo "sass";;
        *SCSS*) echo "scss";;
        *CSS*) echo "css";;
        *shell*) echo "sh";;
        *Shell*) echo "bash";;
        *[Tt]ext*) echo "text";;
        *YAML*) echo "yaml";;
        *) echo "unknown";;
    esac
}

# Function to process a list of files and generate markdown
process_files(){
    local output_filename="$1"
    local -n files_ref="$2"
    # Iterate over files and generate markdown
    for file in "${files_ref[@]}"; do
        # Determine file type based on extension
        local filetype
        case "$file" in
            *".css") filetype="css";;
            *".html") filetype="html";;
            *".js") filetype="javascript";;
            *".json") filetype="json";;
            *".md") filetype="markdown";;
            *".py") filetype="python";;
            *".rb") filetype="ruby";;
            *".sass") filetype="sass";;
            *".scss") filetype="scss";;
            *".sh") filetype="bash";;
            *".txt") filetype="text";;
            *".yml") filetype="yaml";;
            # Resolve any types which don't have a known extension using file magic
            *) filetype=$(get_unknown_filetype "$file");;
        esac
        if [[ "$filetype" = "unknown" ]]; then
            echo "ERROR ($my_name): Skipping unknown file type: \"$file\"" >&2
            continue
        fi
        generate_markdown "$file" "$filetype"
    done
}

# Function to remove duplicates from an array
remove_duplicates() {
    local -n arr_ref=$1
    declare -A seen=()
    local unique=()
    for item in "${arr_ref[@]}"; do
        if [[ ! -v seen["$item"] ]]; then
            seen["$item"]=1
            unique+=("$item")
        fi
    done
    arr_ref=("${unique[@]}")
}

# Function to save configuration to a .grc file
save_config() {
    local config_file="$config_file_path"
    ensure_directory_exists "$(dirname "$config_file")"

    {
        echo "GENMD_DIR_EXCLUDES=\"${GENMD_DIR_EXCLUDES[*]}\""
        echo "GENMD_FILE_EXCLUDES=\"${GENMD_FILE_EXCLUDES[*]}\""
        echo "GENMD_FILE_INCLUDES=\"${GENMD_FILE_INCLUDES[*]}\""
        echo "GENMD_PATTERN_EXCLUDES=\"${GENMD_PATTERN_EXCLUDES[*]}\""
        echo "GENMD_BASE=\"$GENMD_BASE\""
        echo "output_filename=\"$output_filename\""
        echo "dry_run=$dry_run"
        echo "debug_level=$debug_level"
        echo "verbose=$verbose"
    } > "$config_file"
    echo "INFO ($my_name): Configuration saved to $config_file" >&2
}

# Function to validate patterns (optional enhancement)
validate_pattern() {
    local pattern="$1"
    if ! echo "" | grep -E "$pattern" >/dev/null 2>&1; then
        echo "Error: Invalid pattern '$pattern'." >&2
        exit 1
    fi
}

# Function to log messages based on debug level
log() {
    local level="$1"
    shift
    case "$level" in
        "INFO")
            echo "INFO ($my_name): $*" >&2
            ;;
        "DEBUG")
            if [[ "$debug_level" -gt 1 ]]; then
                echo "DEBUG ($my_name): $*" >&2
            fi
            ;;
        "ERROR")
            echo "ERROR ($my_name): $*" >&2
            ;;
        *)
            echo "$*" >&2
            ;;
    esac
}

# Process command-line options using getopts
# Reset OPTIND in case getopts has been used previously
OPTIND=1

while getopts ":d:he:f:i:p:o:c:s:nv-:" opt; do
    case "$opt" in
        # Short options
        d)
            if [[ "$OPTARG" =~ ^[0-9]$ ]]; then
                debug_level="$OPTARG"
                if [[ "$debug_level" -eq 9 ]]; then
                    set -x
                fi
            else
                echo "Error: Debug level must be between 0 and 9." >&2
                display_help
            fi
            ;;
        e)
            # Split the input string on '|' and add each pattern separately
            IFS='|' read -r -a user_excludes <<< "$OPTARG"
            dir_excludes+=("${user_excludes[@]}")
            ;;
        f)
            # Split the input string on '|' or spaces and add each pattern separately
            IFS='| ' read -r -a user_excludes <<< "$OPTARG"
            file_excludes+=("${user_excludes[@]}")
            ;;
        i)
            if [[ -n "$OPTARG" && ! "$OPTARG" =~ ^- ]]; then
                # Split the input string on '|' or spaces and add each pattern separately
                IFS='| ' read -r -a include_patterns <<< "$OPTARG"
                file_includes+=("${include_patterns[@]}")
            else
                echo "Error: --include requires a pattern string." >&2
                display_help
            fi
            ;;
        p)
            # Split the input string on '|' or spaces and add each pattern separately
            IFS='| ' read -r -a patterns <<< "$OPTARG"
            pattern_excludes+=("${patterns[@]}")
            ;;
        o)
            output_filename="$output_dir/$OPTARG"
            output_basename="$(basename "$output_filename" .md)"
            config_filename="${output_basename}.grc"
            config_file_path="$config_dir/$config_filename"
            # Check if config file exists and source it
            if [[ -f "$config_file_path" ]]; then
                # shellcheck disable=SC1091
                source "$config_file_path"
                log "INFO" "Configuration loaded from \"$config_file_path\""
            fi
            ;;
        c)
            specified_config="$OPTARG"
            # Append .grc or .cfg if not present
            if [[ "$specified_config" != *.grc && "$specified_config" != *.cfg ]]; then
                specified_config="${specified_config}.grc"
            fi
            full_config_path="$config_dir/$specified_config"
            if [[ -f "$full_config_path" ]]; then
                # shellcheck disable=SC1091
                source "$full_config_path"
                log "INFO" "Configuration loaded from \"$full_config_path\""
            else
                echo "Error: Configuration file \"$full_config_path\" not found." >&2
                exit 2
            fi
            ;;
        s)
            # Replace commas with spaces, then split on spaces to handle both separators
            IFS=' ' read -r -a modes <<< "${OPTARG//,/ }"
            settings_modes+=("${modes[@]}")
            ;;
        n)
            dry_run=true
            ;;
        v)
            verbose=true
            ;;
        h)
            display_help
            ;;
        -)
            # Handle long options manually
            case "${OPTARG}" in
                debug=*)
                    debug_level="${OPTARG#*=}"
                    if [[ "$debug_level" =~ ^[0-9]$ ]]; then
                        if [[ "$debug_level" -eq 9 ]]; then
                            set -x
                        fi
                    else
                        echo "Error: Debug level must be between 0 and 9." >&2
                        display_help
                    fi
                    ;;
                help)
                    display_help
                    ;;
                exclude=*)
                    value="${OPTARG#*=}"
                    IFS='|' read -r -a user_excludes <<< "$value"
                    dir_excludes+=("${user_excludes[@]}")
                    ;;
                file=*)
                    value="${OPTARG#*=}"
                    IFS='| ' read -r -a user_excludes <<< "$value"
                    file_excludes+=("${user_excludes[@]}")
                    ;;
                include=*)
                    value="${OPTARG#*=}"
                    IFS='| ' read -r -a include_patterns <<< "$value"
                    file_includes+=("${include_patterns[@]}")
                    ;;
                pattern=*)
                    value="${OPTARG#*=}"
                    IFS='| ' read -r -a patterns <<< "$value"
                    pattern_excludes+=("${patterns[@]}")
                    ;;
                output=*)
                    value="${OPTARG#*=}"
                    output_filename="$output_dir/$value"
                    output_basename="$(basename "$output_filename" .md)"
                    config_filename="${output_basename}.grc"
                    config_file_path="$config_dir/$config_filename"
                    # Check if config file exists and source it
                    if [[ -f "$config_file_path" ]]; then
                        # shellcheck disable=SC1091
                        source "$config_file_path"
                        log "INFO" "Configuration loaded from \"$config_file_path\""
                    fi
                    ;;
                config=*)
                    value="${OPTARG#*=}"
                    specified_config="$value"
                    # Append .grc or .cfg if not present
                    if [[ "$specified_config" != *.grc && "$specified_config" != *.cfg ]]; then
                        specified_config="${specified_config}.grc"
                    fi
                    full_config_path="$config_dir/$specified_config"
                    if [[ -f "$full_config_path" ]]; then
                        # shellcheck disable=SC1091
                        source "$full_config_path"
                        log "INFO" "Configuration loaded from \"$full_config_path\""
                    else
                        echo "Error: Configuration file \"$full_config_path\" not found." >&2
                        exit 2
                    fi
                    ;;
                settings=*)
                    value="${OPTARG#*=}"
                    IFS=' ' read -r -a modes <<< "${value//,/ }"
                    settings_modes+=("${modes[@]}")
                    ;;
                dry-run)
                    dry_run=true
                    ;;
                verbose)
                    verbose=true
                    ;;
                *)
                    echo "Error: Unknown option '--${OPTARG}'" >&2
                    display_help
                    ;;
            esac
            ;;
        \?)
            echo "Error: Invalid option '-$OPTARG'" >&2
            display_help
            ;;
        :)
            echo "Error: Option '-$OPTARG' requires an argument." >&2
            display_help
            ;;
    esac
done

# Shift off the options and optional --
shift $((OPTIND -1))

# Remove duplicates from exclusion and inclusion lists
remove_duplicates dir_excludes
remove_duplicates file_excludes
remove_duplicates pattern_excludes
remove_duplicates file_includes
remove_duplicates settings_modes

# Set default output file if not set via -o/--output
output_filename="${output_filename:-$output_dir/combined_source.md}"

# Truncate the output file only if not in dry_run
if [[ "$dry_run" != true ]]; then
    : > "$output_filename"
else
    echo "Dry run: Skipping truncation of $output_filename" >&2
fi

# After truncating, handle the settings_modes to include info at the top
if [[ ${#settings_modes[@]} -gt 0 ]]; then
    display_settings "${settings_modes[@]}"
fi

# Debug: Show final directory exclusions
if [[ $debug_level -gt 0 ]]; then
    echo "DEBUG ($my_name): Final directory exclusions: ${dir_excludes[*]}" >&2
fi

# Generate file tree markdown
generate_filetree "$output_filename" "${dir_excludes[@]}"

# Build the file list
declare -a final_files
build_file_list final_files file_includes file_excludes dir_excludes pattern_excludes

# Debug: Show final files to be processed
if [[ $debug_level -gt 0 ]]; then
    echo "DEBUG ($my_name): Final files to process:" >&2
    for f in "${final_files[@]}"; do
        echo "  \"$f\"" >&2
    done
fi

# Process the files and generate markdown
process_files "$output_filename" final_files