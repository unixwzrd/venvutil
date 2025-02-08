#!/usr/bin/env bash
#
# setup.sh - Setup and configure venvutil.
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
# NOTE: Yeah I do know this looks a bit like a Python script... just changing styles a bit
# to try a different way of structuring things.
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
        echo "($__SETUP_NAME) [$message_level] $message_out" 2>&1 | tee -a "$INSTALL_CONFIG/install.log" >&2
        return 0
    fi

    # Write message to log file
    echo "($__SETUP_NAME) [$message_level] $message_out" >> "$INSTALL_CONFIG/install.log" 2>&1
}

# Function to display help extracted from the script
display_help_and_exit() {
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

# Parse command-line arguments
parse_arguments() {
    while getopts ":d:vh" opt; do
        case $opt in
            d) INSTALL_BASE="$OPTARG" ;;
            v) VERBOSE=true ;;
            h) display_help_and_exit "Usage: $__SETUP_NAME [options] {install|remove|rollback}" ;;
            \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
            :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
        esac
    done
    shift $((OPTIND -1))

    # Ensure at least one action is specified
    ACTION="${1:-}"
    if [ -z "$ACTION" ]; then
        display_help_and_exit "Usage: $__SETUP_NAME [options] {install|remove|rollback}"
    fi

    return 0
}

# Installation Initialization
initialization() {

    pkg_config_vars

    load_pkg_config "${__SETUP_BASE}/setup.cf"

    # Set PKG_NAME early to load config
    PKG_NAME=${Name:-${PKG_NAME:-"DEFAULT"}}
    # Set default values if not already set
    PKG_VERSION=${PKG_VERSION:-$Version}
    INSTALL_BASE=${INSTALL_BASE:-$prefix}
    INSTALL_CONFIG="$HOME/.${PKG_NAME}"

    create_pkg_config_dir

    # Set default manifest path
    INSTALL_MANIFEST="$__SETUP_BASE/manifest.lst"

    log_message "INFO" "Configuring $PKG_NAME for initialization..."

    # Parse manifest metadata
    parse_manifest_metadata "${INSTALL_MANIFEST}"

    return 0

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


install_conda() {
    log_message "INFO" "Installing conda..."
    # Check if conda is already installed
    if which conda &> /dev/null; then
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
    # Prevents /etc/bashrc from being sourced again on Red Hat Enterprise Linux.
    export BASHSOURCED=Y
    # So we don't recurse.
    export CONDA_INSTALL_COMPLETE=Y
    SHELL=$(which "$(basename "$SHELL")")
    # Wheeeeee!!!!!!
    exec "$SHELL" -l -c "${__SETUP_BASE}/${__SETUP_NAME}  ${ACTION}"
    return 0
}

# Write package information
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

# Check dependencies
check_deps() {
    # Check for Bash version 4+
    if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
        log_message "ERROR" "$__SETUP_NAME requires Bash version 4 or higher."
        exit 75
    fi

    # Check Operating System (Linux or macOS)
    if [ "$(uname -s)" != "Darwin" ] && [ "$(uname -s)" != "Linux" ]; then
        log_message "ERROR" "$__SETUP_NAME is only supported on macOS and Linux."
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

# Pre-installation tasks
pre_install() {
    # Check if pre-installation tasks have already been completed
    # Stop recursion before it starts, this is re-entrant.
    if [ "${CONDA_INSTALL_COMPLETE:-""}" == "Y" ]; then
        return 0
    fi
    log_message "INFO" "Pre-installation tasks..."
    # Custom pre-install tasks can be added here
    check_deps
    # This may be used for verification or rollback/removal later.
    write_pkg_info
    install_conda
    unset CONDA_INSTALL_COMPLETE
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
        source_path="${__SETUP_BASE}/${source}/${name}"
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
                # shellcheck disable=SC2164
                cd "$destination"
                ln "$source" "$name"
                # shellcheck disable=SC2164
                cd - > /dev/null
                ;;
            l) # Create symbolic link
                # shellcheck disable=SC2164
                cd "$destination"
                ln -sf "$source" "$name"
                # shellcheck disable=SC2164
                cd - > /dev/null
                ;;
            c) # Remove the asset
                # shellcheck disable=SC2164
                cd "$destination"
                rm -rf "$name"
                # shellcheck disable=SC2164
                cd - > /dev/null
                ;;
            *)
                log_message "ERROR" "Unknown asset type: $asset_type"
                ;;
        esac
    done
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

    $__SETUP_NAME verify (not implemented yet)

    If you wish to uninstall the packages associated with $PKG_NAME, run the
    following command:

    $__SETUP_NAME uninstall (not implemented yet)

    This will only remove the files associated with the package, not the
    Conda installation, its installed packages or any other dependencies. If
    you wish to uninstall everything associated with the package, run the
    following command:

    $__SETUP_NAME remove_all (not implemented yet)

    The documentation may be found in the $INSTALL_BASE/README.md file. Please
    contact the package maintainers for any issues or feature requests or file them on
    GitHub: ${Support:-https://github.com/unixwzrd/venvutil/issues}
    Please help sponsor my projects on Patreon: ${Contribute:-https://patreon.com/unixwzrd}

_EOT_
    return 0
}

write_pkg_config() {
    log_message "INFO" "Writing package configuration..."
    echo "$PKG_NAME.pc.in" > "$INSTALL_CONFIG/$PKG_NAME.pc"
    for var in "${pkg_config_set_vars[@]}"; do
        echo "$var=\"${!var}\""
    done >> "$INSTALL_CONFIG/$PKG_NAME.pc"
    echo "" >> "$INSTALL_CONFIG/$PKG_NAME.pc"
    for var in "${pkg_config_desc_vars[@]}"; do
        echo "$var: ${!var}"
    done >> "$INSTALL_CONFIG/$PKG_NAME.pc"
    return 0
}

# Update .bashrc
update_bashrc() {
    log_message "INFO" "Updating .bashrc for package $PKG_NAME in PATH..."
    local bashrc="$HOME/.bashrc"
    # Expressions don't expand in single quotes, use double quotes for that.
    # shellcheck disable=SC2016
    local path_line="if [[ ! \"\$PATH\" =~ \"$INSTALL_BASE/bin:\" ]]; then export PATH=\"$INSTALL_BASE/bin:\$PATH\"; fi"
    local source_line="if [[ -f "${INSTALL_BASE}/bin/shinclude/init_lib.sh" ]]; then source \"${INSTALL_BASE}/bin/shinclude/init_lib.sh\"; fi"

    for line in "${path_line}" "${source_line}"; do
        if ! grep -Fxq "$line" "$bashrc"; then
            echo "$line" >> "$bashrc"
        fi
        log_message "INFO" "Updated $bashrc added package $PKG_NAME bin directory."
        log_message "INFO" "Updated $bashrc added package $PKG_NAME initialization."
    done
    return 0
}

install_python_packages() {
    benv venvutil
    read -p "Press Enter to continue"
    log_message "INFO" "Installing NLTK data..."
    pip install -r "$__SETUP_BASE/requirements.txt" 2>&1 | tee -a "$INSTALL_CONFIG/install.log" >&2
    python <<_EOT_
import nltk
nltk.download('punkt')
nltk.download('stopwords')
_EOT_
    log_message "INFO" "NLTK data installed successfully."
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
    benv venvutil python=3.11
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
            c) # Asset should already be deleted, but to make sure...
                [ -d "$dest_path" ] && rmdir "$dest_path"
                [ -e "$dest_path" ] && rm -f "$dest_path"
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


verify() {
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
            display_help_and_exit "Usage: $__SETUP_NAME [options] {install|remove|rollback}"
            ;;
    esac
}

## Initialization
[ "${DEBUG_SETUP:-""}" == "ON" ] && set -x
#set -eo pipefail
# start fresh
(cd ; rm -rf local .venvutil  nltk_data .conda miniconda3 )

[[ "${BASH_VERSINFO[0]}" -lt 4 ]] \
    && echo "($__SETUP_NAME) ERROR: This script requires Bash version 4 or higher." >&2 \
    && exit 75

# Determine the real path of the script
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
# Extract script name, directory, and arguments
# __SETUP_NAME appears unused. Verify use (or export if used externally).
# shellcheck disable=SC2034
# Initialize script variables
THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[$((${#BASH_SOURCE[@]} -1))]}")
__SETUP_NAME="$(basename "${THIS_SCRIPT}")"
__SETUP_BASE="$(dirname "${THIS_SCRIPT}")"
__SETUP_BIN="${__SETUP_BASE}/bin"
__SETUP_INCLUDE="${__SETUP_BIN}/shinclude"

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

SH_LIB="${SH_LIB:-""}"
for try in "${SH_LIB}" "$(dirname "${THIS_SCRIPT}")/shinclude" "${__SETUP_INCLUDE}" "${HOME}/bin/shinclude"; do
    [ -f "${try}/init_lib.sh" ] && { SH_LIB="${try}"; break; }
done
[ -z "${SH_LIB}" ] && {
    cat<<_EOT_ >&2
ERROR ($__SETUP_NAME): Could not locate \`init_lib.sh\` file.
ERROR ($__SETUP_NAME): Please set install init_lib.sh which came with this repository in one of
    the following locations:
        - $(dirname "${THIS_SCRIPT}")/bin/shinclude
        - $HOME/shinclude
        - $HOME/bin/shinclude
    or set the environment variable SH_LIB to the directory containing init_lib.sh

_EOT_
    exit 2     # (ENOENT: 2): No such file or directory
}
echo "INFO ($__SETUP_NAME): Using SH_LIB directory - ${SH_LIB}" >&2
# shellcheck source=/dev/null
source "${SH_LIB}/init_lib.sh"

main "$@"


