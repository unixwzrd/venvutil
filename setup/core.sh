#!/usr/bin/env bash
#
# core.sh - Core functions for setup
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
        if [[ "$line" =~ ^#[[:space:]]*$ ]]; then
            help_text+=$'\n'
        else
            help_text+="${line#\# }"$'\n'
        fi
    done < "$0"

    printf "%s" "$help_text" | ${PAGER:-cat}
    exit 0
}

# Parse command-line arguments
parse_arguments() {
    while getopts ":d:vh" opt; do
        case $opt in
            d) INSTALL_BASE="$OPTARG" ;;
            v) VERBOSE=true, set -x ;;
            h) display_help_and_exit "Usage: $__SETUP_NAME [options] {install|refresh|update|remove|rollback|verify}" ;;
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

get_os_config() {
    # Find host OS and architecture
    declare -g OS ARCH
    OS=$(uname -s)
    [ "$OS" == "Darwin" ] && OS="MacOSX"
    [ "$OS" == "Linux" ] && OS="Linux"
    ARCH=$(uname -m)
    ARCH=${ARCH//aarch64/arm64}
    return 0
}

# Installation Initialization
initialization() {

    get_os_config

    # check to see if function exists for pkg_config_vars
    if ! declare -f pkg_config_vars &>/dev/null; then
        log_message "ERROR" "pkg_config_vars function not found configuration not loaded."
        exit 2
    fi

    pkg_config_vars
    load_pkg_config "${__SETUP_DIR}/setup.cf" pkg_config_actions

    PKG_NAME=${Name:-${PKG_NAME:-DEFAULT}}
    PKG_VERSION=${PKG_VERSION:-$Version}
    INSTALL_BASE=${INSTALL_BASE:-$prefix}
    INSTALL_CONFIG="$HOME/.${PKG_NAME}"

    create_pkg_config_dir

    INSTALL_MANIFEST="${__SETUP_DIR}/manifest.lst"

    log_message "INFO" "Configuring $PKG_NAME for initialization..."

    # Parse manifest metadata
    parse_manifest_metadata "${INSTALL_MANIFEST}"
    return 0

}

# Create package configuration directory
#
# TODO use check_directory in config_lib.sh
#
create_pkg_config_dir() {
    if [ ! -d "${INSTALL_CONFIG}" ]; then
        mkdir -p "$INSTALL_CONFIG/log" "$INSTALL_CONFIG/freeze"
        log_message "INFO" "Created ${INSTALL_CONFIG} directories..."
    fi
    return 0
}

# Write package information
#
# TODO fix this to write to the log file all information

write_pkg_info() {
    install_log="${INSTALL_CONFIG}/${PKG_NAME}.log"
    INSTALL_DATE=$(date '+%Y-%m-%d %H:%M:%S')
    log_message "INFO" "Package : Name=$PKG_NAME, Version=$PKG_VERSION, Date=$INSTALL_DATE"
    echo "# Package Information: Name=$PKG_NAME, Version=$PKG_VERSION, Date=$INSTALL_DATE" > "${install_log}"

    # shellcheck disable=SC2068
    for key in ${pkg_config_set_vars[@]}; do
        echo "$key=${pkg_config_values[$key]}" >> "${install_log}"
    done
    # shellcheck disable=SC2068
    for key in ${pkg_config_desc_vars[@]}; do
        echo "$key: ${pkg_config_values[$key]}" >> "${install_log}"
        phg_config_set_vars+="$key"
    done

    return 0
}

write_pkg_config() {
    log_message "INFO" "Writing package configuration..."
    config_file="$INSTALL_CONFIG/$PKG_NAME.pc"
    write_config "$config_file" pkg_config_set_vars
    return 0
}

restart_shell() {
    log_message "INFO" "Restarting shell..."
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
