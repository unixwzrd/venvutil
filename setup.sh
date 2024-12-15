#!/usr/bin/env bash
#
# venvutil_setup.sh - Setup and configure venvutil.
#
# This script installs and configures the venvutil tools and utilities.
# It supports installation and removal operations, although the removal and rollback functionality
# is not yet implemented.
#
# Usage:
#     venvutil_setup.sh [-d directory] [-r] [-v] {install|remove}
#
# Options:
#     -d directory  Specify the directory path where venvutil will be installed.
#                     The default is $HOME/local
#     -r            Remove venvutil tools and utilities from the system.
#                     The location will be taken from the config.sh file in your $HOME/.venvutil
#                     directory.
#     -v            Enable verbose logging.
#     -h            Show this help message
#
# Description:
#     Install venvutil tools and utilities from the cloned repository.
#     Configure venvutil for use.
#
# Output:
#     Initializes the environment, sets up venvutil, and configures it for use.
#
# Exceptions:
#     Functions may return specific error codes based on their internal logic.
#     If an error occurs during execution, the script will remove itself from the system.
#
# Initialization:
#     Ensure the script is executed in a bash shell.
#     Check if the script is already running and exit if it is.
#
# Configuration:
#     Load configuration variables from the config.sh file in the .venvutil directory.
#     Use the default install location $HOME/local/venvutil if the configuration file is not found.
#
# Environment Variables:
#     DEBUG_SETUP: If set to "ON", enables debug mode for the script.
#
# Dependencies:
# - bash 4.0 or higher
# - Python 3.10 or higher
#
# Author:
#     Michael Sullivan <unixwzrd@unixwzrd.ai>
#     https://unixwzrd.ai/
#     https://github.com/unixwzrd
#
# License:
#     Apache License, Version 2.0
#

[ "${DEBUG_SETUP:-""}" = "ON" ] && set -x
set -euo pipefail

# Initialize script variables
THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[$((${#BASH_SOURCE[@]} -1))]}")
MY_NAME="$(basename "${THIS_SCRIPT}")"
MY_PATH="$(dirname "${THIS_SCRIPT}")"

[[ "${BASH_VERSINFO[0]}" -lt 4 ]] \
    && echo "($MY_NAME) ERROR: This script requires Bash version 4 or higher." >&2 \
    && exit 75 

# Default values
PKG_NAME="DEFAULT"
PKG_VERSION=""
INSTALL_BASE=""
INSTALL_CONFIG="$HOME/.${PKG_NAME}"
INSTALL_MANIFEST="manifest.lst"
ACTION=""
VERBOSE=false

declare -g -A pkg_config_values=()
declare -g -a pkg_config_set_vars=()
declare -g -a pkg_config_desc_vars=()

# Logging function
log_message() {
    local message_level="$1"; shift
    local message_out="$*"

#    declare -A message_class=(
#            ["INFO"]=30
#            ["WARNING"]=40
#            ["ERROR"]=50
#            ["CRITICAL"]=60
#    )

    # Print message to STDERR and log file
    if [ "$VERBOSE" = true ]; then
        echo "($MY_NAME) [$message_level] $message_out" 2>&1 | tee -a "$INSTALL_CONFIG/install.log" >&2
        return 0
    fi

    # Write message to log file
    echo "($MY_NAME) [$message_level] $message_out" >> "$INSTALL_CONFIG/install.log" 2>&1
}

# Function to display help extracted from the script
display_help() {
    # Initialize a variable to hold the help text
    local message=$1
    local help_text=""

    # Read the script file line by line
    help_text+="$message"$'\n\n'
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip the shebang line
        if [[ "$line" =~ ^#!/ ]]; then
            continue
        fi
        # Stop at the first non-comment line (end of help section)
        if [[ ! "$line" =~ ^# ]]; then
            break
        fi
        # Remove leading '#' and spaces
        help_text+="${line#\# }"$'\n'
    done < "$0"

    printf "%s" "$help_text" | ${PAGER:-cat}
    exit 0
}

expand_variables() {
    local input="$1"

    # Validate the input: Allow only valid variable names and values
    if [[ ! "$input" =~ ^[A-Za-z_][A-Za-z0-9_]*=.* ]]; then
        return 1
    fi

    # Sanitize the input by escaping special characters if necessary
    # For example, you might want to escape quotes or backslashes
    sanitized_input=$(echo "$input" | sed 's/[&;|<>\*]/\\&/g')

    # Use eval to expand variables safely
    eval "echo \"$sanitized_input\""
}

# Load package configuration from .cf file
load_pkg_config() {
    local config_file="$MY_PATH/setup.cf"
    if [ ! -f "$config_file" ]; then
        echo "ERROR: Configuration file $config_file not found." >&2
        exit 2
    fi

    local key=""
    local value=""
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Trim leading and trailing whitespace
        line="$(sed 's/^[[:space:]]*//; s/[[:space:]]*$//' <<< "$line")"

        # Skip comments and blank lines
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^# ]] && continue

        # Check for Key: Value pattern
        if [[ "$line" =~ ^([A-Za-z_]+):[[:space:]]*(.*)$ ]]; then
            key="${BASH_REMATCH[1]}"
            if ! value=$(expand_variables "${BASH_REMATCH[2]}"); then
                log_message "ERROR" "ERROR: Invalid variable assignment: '$input' - skipping."
                continue
            fi
            # Set shell variable
            declare -g "$key"="$value"
            # Append or initialize array entry
            if [[ -z "${pkg_config_values[$key]:-}" ]]; then
                pkg_config_values[$key]="$value"
                pkg_config_desc_vars+=("$key")
            else
                pkg_config_values[$key]+=$'\n'"$value"
            fi
            continue
        fi

        # Check for Key=Value pattern
        if [[ "$line" =~ ^([A-Za-z_]+)=(.*)$ ]]; then
            key="${BASH_REMATCH[1]}"
            if ! value=$(expand_variables "${BASH_REMATCH[2]}"); then
                log_message "ERROR" "ERROR: Invalid variable assignment: '$input' - skipping."
                continue
            fi
            # Set shell variable
            declare -g "$key"="$value"
            # Append or initialize array entry
            if [[ -z "${pkg_config_values[$key]:-}" ]]; then
                pkg_config_values[$key]="$value"
                pkg_config_set_vars+=("$key")
            else
                pkg_config_values[$key]+=$'\n'"$value"
            fi
            continue
        fi

        # If a line doesn't match either pattern, assume it’s an additional value for the last key
        # If no previous key is known, just ignore.
        if [[ -n "$key" ]]; then
            # Treat as another line for the current key
            declare -g "$key"="${!key:-}\n${line}"
            pkg_config_values[$key]+=$'\n'"$line"
        fi
    done < "$config_file"
}

# Create package configuration directory
create_pkg_config_dir() {
    if [ ! -d "${INSTALL_CONFIG}" ]; then
        mkdir -p "${INSTALL_CONFIG}"
        mkdir -p "$INSTALL_CONFIG/log" "$INSTALL_CONFIG/freeze" 
        log_message "INFO" "Created ${INSTALL_CONFIG} directories..."
    fi
    # Create application configuration directory
    return 0
}

# Parse manifest metadata
parse_manifest_metadata() {
    if [ ! -f "$INSTALL_MANIFEST" ]; then
        echo "ERROR: Manifest file $INSTALL_MANIFEST not found." >&2
        exit 2
    fi
    echo "Parsing manifest metadata..." >&2
    local manifest_file="$INSTALL_MANIFEST"
    while IFS='| ' read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ ^#.*$ ]] && continue    # Skip comments
        [[ -z "$line" ]] && break             # Stop at first blank line (end of metadata)
        if [[ "$line" =~ ^[A-Za-z_]+=.*$ ]]; then
            eval "$line"
        fi
    done < "$manifest_file"
    return 0
}

# Initialization
initialization() {

    load_pkg_config

    # Set PKG_NAME early to load config
    PKG_NAME=${Name:-${PKG_NAME:-"DEFAULT"}}
    # Set default values if not already set
    PKG_VERSION=${PKG_VERSION:-$Version}
    INSTALL_BASE=${INSTALL_BASE:-$prefix}
    INSTALL_CONFIG="$HOME/.${PKG_NAME}"

    create_pkg_config_dir

    # Set default manifest path
    INSTALL_MANIFEST="$MY_PATH/manifest.lst"

    log_message "INFO" "Configuring $PKG_NAME for initialization..."

    # Parse manifest metadata
    parse_manifest_metadata

    return 0

}

# Parse command-line arguments
parse_arguments() {
    while getopts ":d:vh" opt; do
        case $opt in
            d) INSTALL_BASE="$OPTARG" ;;
            v) VERBOSE=true ;;
            h) display_help "Usage: $MY_NAME [options] {install|remove|rollback}" ;;
            \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
            :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
        esac
    done
    shift $((OPTIND -1))

    # Ensure at least one action is specified
    ACTION="${1:-}"
    if [ -z "$ACTION" ]; then
        display_help "Usage: $MY_NAME [options] {install|remove|rollback}" 
        exit 1
    fi

    return 0
}

# Dependency checks
check_deps() {
    # Check for Bash version 4+
    if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
        log_message "ERROR" "$MY_NAME requires Bash version 4 or higher."
        exit 75
    fi

    # Check Operating System (Linux or macOS)
    if [ "$(uname -s)" != "Darwin" ] && [ "$(uname -s)" != "Linux" ]; then
        log_message "ERROR" "$MY_NAME is only supported on macOS and Linux."
        exit 75
    fi

    # Check for essential commands
    for cmd in curl tar gzip; do
        if ! command -v $cmd &> /dev/null; then
            log_message "ERROR" "$cmd is not installed. Please install $cmd."
            exit 2
        fi
    done

    # Check if manifest file exists
    if [ ! -f "${INSTALL_MANIFEST}" ]; then
        log_message "ERROR" "Manifest file not found at ${INSTALL_MANIFEST}"
        exit 2
    fi

    return 0
}

# Package information
write_pkg_info() {
    install_log="${INSTALL_CONFIG}/${PKG_NAME}.pc"
    INSTALL_DATE=$(date '+%Y-%m-%d %H:%M:%S')
    log_message "INFO" "Package Information: Name=$PKG_NAME, Version=$PKG_VERSION, Date=$INSTALL_DATE"
    echo "# Package Information: Name=$PKG_NAME, Version=$PKG_VERSION, Date=$INSTALL_DATE" > "${install_log}"

    # shellcheck disable=SC2068
    for key in ${pkg_config_set_vars[@]}; do
        echo "$key=${pkg_config_values[$key]}" >> "${install_log}"
    done
    # shellcheck disable=SC2068
    for key in ${pkg_config_desc_vars[@]}; do
        echo "$key: ${pkg_config_values[$key]}" >> "${install_log}"
    done

    return 0
}

install_conda() {
    log_message "INFO" "Installing conda..."
    # Check if conda is already installed
    if command -v conda &> /dev/null; then
        log_message "INFO" "Conda is already installed. Skipping installation."
        return 0
    fi

    # Find host OS and architecture
    local OS ARCH
    OS=$(uname -s)
    [ "$OS" == "Darwin" ] && OS="MacOSX"
    [ "$OS" == "Linux" ] && OS="Linux"
    ARCH=$(uname -m)
    ARCH=${ARCH//aarch64/arm64}

    # Download and install conda
    log_message "INFO" "Downloading and installing Conda..."
    local INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-${OS}-${ARCH}.sh"
    curl -k -O "$INSTALLER_URL"
    # do a non-destructive install
    bash "Miniconda3-latest-${OS}-${ARCH}.sh" -b -u
    rm "Miniconda3-latest-${OS}-${ARCH}.sh"
    # Activate the Conda installation
    # shellcheck disable=SC1091
    source "${HOME}/miniconda3/bin/activate"
    # Initialize conda for our shell
    conda init "$(basename "${SHELL}")"
    log_message "INFO" "Conda installed successfully, checking for updates..."
    conda update -n base -c defaults conda -y
    # Because Red Hat Enterprise Linux defines, sets it, but doesn't export it BASHSOURCED...
    export BASHSOURCED=Y
    # So we con't recurse.
    export PRE_INSTALL_COMPLETE=Y
    SHELL=$(which "$(basename "$SHELL")")
    # Wheeeeee!!!!!!
    exec "$SHELL" -l -c "${THIS_SCRIPT} ${ACTION}"
    return 0
}

# Pre-installation tasks
pre_install() {
    # Check if pre-installation tasks have already been completed
    # Stop recursion before it starts, this is re-entrant.
    if [ "${PRE_INSTALL_COMPLETE:-""}" == "Y" ]; then
        return 0
    fi
    log_message "INFO" "Pre-installation tasks..."
    # Custom pre-install tasks can be added here
    check_deps
    write_pkg_info
    install_conda
    unset PRE_INSTALL_COMPLETE
}

install_assets() {
    # Implement package installation logic here
    log_message "INFO" "Installing packages..."

    # Set default owner and group if not specified
    owner=${owner:-$(id -u)}
    group=${group:-$(id -g)}

    readarray -t lines < <(grep -v '^#' "$INSTALL_MANIFEST" | grep -v '^\s*$')
    for line in "${lines[@]}"; do

        # Skip metadata lines
        if [[ "$line" =~ ^[A-Za-z_]+=.*$ ]]; then
            continue
        fi

        IFS=$'| ' read -r asset_type destination source name permissions owner group size checksum <<< "$line"

        destination="${INSTALL_BASE}/${destination}"
        source_path="${MY_PATH}/${source}/${name}"
        dest_path="${destination}/${name}"

        mkdir -p "$destination"

        case "$asset_type" in
            d) # Create directory
                mkdir -p "$dest_path"
                chown "$owner":"$group" "$dest_path"
                chmod "$permissions" "$dest_path"
                ;;
            f) # Copy file
                cp "$source_path" "$dest_path"
                chown "$owner":"$group" "$dest_path"
                chmod "$permissions" "$dest_path"
                ;;
            h) # Create hard link
                cd "$destination"
                ln "$source" "$name"
                cd -
                ;;
            l) # Create symbolic link
                cd "$destination"
                ln -sf "$source" "$name"
                cd -
                ;;
            *)
                log_message "ERROR" "Unknown asset type: $asset_type"
                ;;
        esac
    done
}

install_python_packages() {
    log_message "INFO" "Installing NLTK data..."
    pip install -r "$MY_PATH/requirements.txt" 2>&1 | tee -a "$INSTALL_CONFIG/install.log" >&2
    python <<_EOT_
import nltk
nltk.download('punkt')
nltk.download('stopwords')
_EOT_
    log_message "INFO" "NLTK data installed successfully."
}

# Update .bashrc
update_bashrc() {
    log_message "INFO" "Updating .bashrc for package $PKG_NAME in PATH..."
    local bashrc="$HOME/.bashrc"
    # Expressions don't expand in single quotes, use double quotes for that.
    # shellcheck disable=SC2016
    local path_line="if [[ ! \"\$PATH\" =~ \"$INSTALL_BASE/bin:\" ]]; then export PATH=\"$INSTALL_BASE/bin:\$PATH\"; fi"

    if ! grep -Fxq "$path_line" "$bashrc"; then
        echo "$path_line" >> "$bashrc"
        log_message "INFO" "Updated $bashrc added package $PKG_NAME bin directory."
    fi
    return 0
}

write_pkg_config() {
    log_message "INFO" "Writing package configuration..."
    echo "$PKG_NAME.pc.in" > "$INSTALL_CONFIG/$PKG_NAME.pc"
    for var in "${pkg_config_vars[@]}"; do
        echo "$var=\"${!var}\""
    done >> "$INSTALL_CONFIG/$PKG_NAME.pc"
    return 0
}

post_install_user_message() {
    log_message "INFO" "Provide user instructions..."
    # Custom post-install message can be added here
    cat <<_EOT_
    The package $PKG_NAME has been installed to $INSTALL_BASE.
    To use the package, the following line was added to your .bashrc file:

    if [[ ! "\$PATH" =~ "$INSTALL_BASE/bin:" ]]; then export PATH="$INSTALL_BASE/bin:\$PATH"; fi

    If you wish to use it in the current shell, run the following command:

    exec $SHELL -l

    or exit the terminal and start a new one. To verify the installation files
    for correct location and file integrity run the following command:

    $MY_NAME verify (not implemented yet)

    If you wish to uninstall the packages associated with $PKG_NAME, run the
    following command:

    $MY_NAME uninstall (not implemented yet)

    This will only remove the files associated with the package, not the
    Conda installation, its installed packages or any other dependencies. If
    you wish to uninstall everything associated with the package, run the
    following command:

    $MY_NAME remove_all (not implemented yet)

    The documentation may be found in the $INSTALL_BASE/README.md file. Please
    contact the package maintainers for any issues or feature requests or file them on
    GitHub: ${Support:-https://github.com/unixwzrd/venvutil/issues}
    Please help sponsor my projects on Patreon: ${Contribute:-https://patreon.com/unixwzrd}

_EOT_
    return 0
}

post_install() {
    log_message "INFO" "Post-installation tasks..."
    install_python_packages
    # Example: Update .bashrc if necessary
    update_bashrc
    write_pkg_config
    post_install_user_message
    log_message "INFO" "Installation for $PKG_NAME complete."
    return 0
}

# Installation function
install() {
    log_message "INFO" "Installing package: $PKG_NAME..."
    pre_install
    install_assets
    post_install
    return 0
}

# Pre-removal tasks
pre_remove() {
    log_message "INFO" "Pre-removal tasks..."
    # Custom pre-remove tasks can be added here
}

# Removal function
remove_assets() {
    log_message "INFO" "Removal tasks..."
    readarray -t lines < <(grep -v '^#' "$INSTALL_MANIFEST" | grep -v '^\s*$' | sort -r)

    for line in "${lines[@]}"; do
        # Skip metadata lines
        if [[ "$line" =~ ^[A-Za-z_]+=.*$ ]]; then
            continue
        fi

        # size appears unused. Verify use (or export if used externally).
        # shellcheck disable=SC2034
        IFS=$'\t' read -r type destination source name permissions owner group size checksum <<< "$line"

        dest_path="${INSTALL_BASE}/${destination}/${name}"

        case "$type" in
            d) # Remove directory if empty
                if [ -d "$dest_path" ] && [ -z "$(ls -A "$dest_path")" ]; then
                    rmdir "$dest_path"
                fi
                ;;
            f|l|h) # Remove file or symbolic link
                rm -f "$dest_path"
                ;;
            *)
                log_message "ERROR" "Unknown type: $type"
                ;;
        esac
    done

    post_remove
}

# Post-removal tasks
post_remove() {
    log_message "INFO" "Post-removal tasks..."
    # Example: Remove package bin directory from .bashrc
    remove_bashrc_entries
}

# Remove entries from .bashrc
remove_bashrc_entries() {
    local bashrc="$HOME/.bashrc"
    # Expressions don't expand in single quotes, use double quotes for that.
    # shellcheck disable=SC2016
    local path_line="if [[ ! \"\$PATH\" =~ \"$INSTALL_BASE/bin:\" ]]; then export PATH=\"$INSTALL_BASE/bin:\$PATH\"; fi"

    if grep -Fxq "$path_line" "$bashrc"; then
        sed -i.bak "/$path_line/d" "$bashrc"
        log_message "INFO" "Removed package bin directory from $bashrc."
    fi
}

# Rollback function
rollback() {
    log_message "CRITICAL" "Rollback initiated..."
    # Implement rollback logic based on actions logged during installation
    # For example, read a log file and undo actions
}

remove() {
    log_message "INFO" "Removing package: $PKG_NAME tasks..."
    pre_remove
    remove_assets
    post_remove
    return 0
}


Verify() {
    log_message "INFO" "Verifying package: $PKG_NAME tasks..."
    # Implement verification logic here
    return 0
}

# Main function
main() {
    parse_arguments "$@"
    initialization

    case "$ACTION" in
        install)
            install
            ;;
        remove)
            echo "Not implemented at this time." && exit 1
            remove
            ;;
        rollback)
            echo "Not implemented at this time." && exit 1
            rollback
            ;;
        verify)
            echo "Not implemented at this time." && exit 1
            verify
            ;;
        *)
            echo "Invalid action: $ACTION"
            display_help "Usage: $MY_NAME [options] {install|remove|rollback}"
            ;;
    esac
}

main "$@"
