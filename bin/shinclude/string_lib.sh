#!/usr/bin/env bash
# # Script: string_lib.sh
# `string_lib.sh` - Consolidated string sanitization & variable expansion library
#
# ## Description
# - **Purpose**:
#   - Provides functions for:
#     - Sanitizing strings with a custom "allowed character set"
#     - Escaping specific characters with a backslash
#     - Expanding shell variables in a string (handling $VAR or ${VAR})
# ## Usage
#   - Source this script in your Bash scripts to utilize its functions. 
#     ```bash
#     source_lib string_lib
#     ```
# ## Input Parameters
#   - None
# ## Output
#   - None
# ## Exceptions
#   - None

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

# Get the init_lib.sh script
# shellcheck source=/dev/null
#  ource "${__VENV_INCLUDE}/init_lib.sh"

# Get the type_lib.sh script
# source_lib type_lib

# Add internal functions to the __VENV_INTERNAL_FUNCTIONS array.
if ! declare -p __VENV_INTERNAL_FUNCTIONS >/dev/null 2>&1; then declare -ga __VENV_INTERNAL_FUNCTIONS; fi
# Quote to prevent word splitting/globbing, or split robustly with mapfile or read -a
# shellcheck disable=SC2206
__VENV_INTERNAL_FUNCTIONS=(
    ${__VENV_INTERNAL_FUNCTIONS[@]}
    "colortext"
)

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

# # Function: sanitize
# `sanitize` - Removes every character not in the specified allowed set.
#
# ## Description
# - **Purpose**:
#   - Removes every character not in the specified allowed set.
# - **Usage**:
#   - `sanitized_value=$(sanitize "Hello? *" 'a-zA-Z0-9._*\- ')`
# - **Input Parameters**:
#   - `dirty_string`: The string to sanitize.
#   - `allowed_chars`: The characters to keep in the string.
# - **Output**:
#   - The sanitized string.
# - **Examples**:
#   - `sanitize "Hello? *" 'a-zA-Z0-9._*\- '`
#   - `sanitize "Hello? *" 'a-zA-Z0-9._*\- '`
# - **Exceptions**:
#   - None.
#
sanitize() {
    local dirty_string="$1"
    local allowed_chars="$2"
    local clean_string

    # Use sed or parameter expansion:
    # If you have special bracket-chars in allowed_chars, you may need to escape them before sed.
    clean_string="$(echo "$dirty_string" | sed "s/[^${allowed_chars}]//g")"

    log_message "DEBUG" "Dirty string:   '$dirty_string'"
    log_message "DEBUG" "Clean string:   '$clean_string'"

    echo "$clean_string"
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
    _deprecated "Use: \`sanitize \"${str}\" \"[^a-zA-Z0-9]\"\` instead."
    sanitize "${str}" "[^a-zA-Z0-9]"
}

# # Function: escape_string
# `escape_string` - Escape Special Characters in a String
#
# ## Description
# - **Purpose**:
#   - Escapes special characters in a string to make it safe for shell commands.
# - **Usage**: 
#   - `escaped_str=$(escape_string "Hello & goodbye!" '&"<>;')`
# - **Input Parameters**: 
#   - `dirty_string`: The string to escape.
#   - `chars_to_escape`: The characters to escape.
# - **Output**: 
#   - The escaped string.
# - **Exceptions**: 
#   - None.
#
escape_string() {
    local dirty_string="$1"
    local chars_to_escape="$2"

    # Escape sed special chars in the bracket expression
    local safe_pattern
    safe_pattern="$(echo "$chars_to_escape" \
        | sed 's/\\/\\\\/g; s/\-/\\-/g; s/\]/\\]/g; s/\^/\\^/g')"

    local escaped
    escaped="$(echo "$dirty_string" | sed "s/\\([$safe_pattern]\\)/\\\\\\1/g")"
    echo "$escaped"
}

# # Function: colortext
# `colortext` - Prints a message to STDERR with ANSI color codes.
#
# ## Description
# - **Purpose**: 
#   - Prints a message to STDERR with ANSI color codes.
# - **Usage**: 
#   - `colortext <text_color> <background_color> <style_code> <message>`
# - **Options**: 
#   - `-h`   Show this help message
# - **Input Parameters**: 
#   - `text_color`: The text color to use.
#   - `background_color`: The background color to use.
#   - `style_code`: The style code to use.
#   - `message`: The message to print.
# - **Output**: 
#   - Prints a message to STDERR with ANSI color codes.
#
colortext() {
    # TODO - NOT WORKING
    local OPTIND=1
    # Parse options
    while getopts "h" opt; do
        case $opt in
            h) vhelp "${FUNCNAME[0]}"; return 0 ;;
            \?) echo "Invalid option: -$OPTARG" >&2; vhelp "${FUNCNAME[0]}"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    # ANSI COLOR CODES
    declare -A FOREGROUND_COLORS=(
        ["BLACK"]="\033[0;30m"
        ["RED"]="\033[0;31m" 
        ["GREEN"]="\033[0;32m"
        ["YELLOW"]="\033[0;33m"
        ["BLUE"]="\033[0;34m"
        ["MAGENTA"]="\033[0;35m"
        ["CYAN"]="\033[0;36m"
        ["WHITE"]="\033[0;37m"
        ["BRIGHT_BLACK"]="\033[0;90m"
        ["BRIGHT_RED"]="\033[0;91m"
        ["BRIGHT_GREEN"]="\033[0;92m" 
        ["BRIGHT_YELLOW"]="\033[0;93m"
        ["BRIGHT_BLUE"]="\033[0;94m"
        ["BRIGHT_MAGENTA"]="\033[0;95m"
        ["BRIGHT_CYAN"]="\033[0;96m"
        ["BRIGHT_WHITE"]="\033[0;97m"
    )

    declare -A BACKGROUND_COLORS=(
        ["BLACK"]="\033[0;40m"
        ["RED"]="\033[0;41m"
        ["GREEN"]="\033[0;42m"
        ["YELLOW"]="\033[0;43m" 
        ["BLUE"]="\033[0;44m"
        ["MAGENTA"]="\033[0;45m"
        ["CYAN"]="\033[0;46m"
        ["WHITE"]="\033[0;47m"
        ["BRIGHT_BLACK"]="\033[0;100m"
        ["BRIGHT_RED"]="\033[0;101m"
        ["BRIGHT_GREEN"]="\033[0;102m"
        ["BRIGHT_YELLOW"]="\033[0;103m"
        ["BRIGHT_BLUE"]="\033[0;104m"
        ["BRIGHT_MAGENTA"]="\033[0;105m"
        ["BRIGHT_CYAN"]="\033[0;106m"
        ["BRIGHT_WHITE"]="\033[0;107m"
    )

    declare -A STYLE_CODES=(
        ["BOLD"]="\033[1m"
        ["DIM"]="\033[2m"
        ["ITALIC"]="\033[3m"
        ["UNDERLINE"]="\033[4m"
        ["BLINK"]="\033[5m"
        ["REVERSE"]="\033[7m"
        ["HIDDEN"]="\033[8m"
        ["STRIKE"]="\033[9m"
        ["DOUBLE_UNDERLINE"]="\033[21m"
        ["OVERLINE"]="\033[53m"
        ["RESET"]="\033[0m"
        ["CLEAR"]="\033[2J"
    )

    # ANSI COLOR END CODE
    declare -g ANSI_END="\033[0m"

    local text_color=""
    local background_color=""
    local style_code=""
    local message=""

    # Check if first arg is a valid text color
    if [[ -n "$1" && "${FOREGROUND_COLORS[$1]}" ]]; then
        text_color="$1"
        shift
    fi

    # Check if next arg is a valid background color
    if [[ -n "$1" && "${BACKGROUND_COLORS[$1]}" ]]; then
        background_color="$1"
        shift
    fi

    # Check if next arg is a valid style code
    if [[ -n "$1" && "${STYLE_CODES[$1]}" ]]; then
        style_code="$1"
        shift
    fi

    # Remaining args form the message
    message="$*"

    message="${ANSI_END}${text_color}${background_color}${style_code}${message}${ANSI_END}"
    echo -e "${message}"
}


__rc__=0
return ${__rc__}
