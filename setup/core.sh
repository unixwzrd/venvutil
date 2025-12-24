#!/usr/bin/env bash
#
# core.sh - Core functions for setup
#

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
            v) VERBOSE=true; set -x ;;
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
    # Preserve raw uname outputs for portability/debugging.
    # shellcheck disable=SC2034
    declare -g UNAME_OS UNAME_ARCH

    # shellcheck disable=SC2034
    UNAME_OS="$(uname -s)"
    # shellcheck disable=SC2034
    UNAME_ARCH="$(uname -m)"
    return 0
}

# Installation Initialization
initialization() {

    # Phase 0: bootstrap logging (always available)
    export LOG_PREFIX="${__SETUP_NAME:-setup}"
    export LOG_FILE="${TMPDIR:-/tmp}/${__SETUP_NAME:-setup}.$$.install.log"
    export VERBOSE="${VERBOSE:-false}"
    export LOG_MKDIR=true

    get_os_config

    # check to see if function exists for pkg_config_vars
    if ! declare -f pkg_config_vars &>/dev/null; then
        log_message "ERROR" "pkg_config_vars function not found configuration not loaded."
        exit 2
    fi
    if ! declare -f load_config &>/dev/null; then
        log_message "ERROR" "load_config function not found; shared libraries not loaded."
        exit 2
    fi

    pkg_config_vars
    load_config "${__SETUP_DIR}/setup.cf" pkg_config_actions

    PKG_NAME=${Name:-${PKG_NAME:-DEFAULT}}
    PKG_VERSION=${PKG_VERSION:-$Version}
    INSTALL_BASE=${INSTALL_BASE:-$prefix}
    if declare -f expand_variable &>/dev/null; then
        INSTALL_BASE="$(expand_variable "${INSTALL_BASE}")"
    fi
    if [[ -z "${INSTALL_BASE}" || "${INSTALL_BASE}" == "/" ]]; then
        log_message "ERROR" "INSTALL_BASE resolved to '${INSTALL_BASE:-<empty>}' (unsafe). Use -d <dir> or fix prefix in setup/setup.cf."
        exit 64
    fi

    INSTALL_CONFIG="$HOME/.${PKG_NAME}"

    # Phase 1: switch to final log
    local _bootstrap_log="$LOG_FILE"
    export LOG_FILE="${INSTALL_CONFIG}/install.log"
    export LOG_MKDIR=true

    # pull bootstrap log forward (optional but very useful)
    mkdir -p "$INSTALL_CONFIG" 2>/dev/null || true
    if [[ -f "$_bootstrap_log" ]]; then
        cat "$_bootstrap_log" >>"$LOG_FILE" 2>/dev/null || true
    fi

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
    # Preserve xtrace across the exec/re-entry when enabled.
    case "$-" in
        *x*) export __SETUP_EXEC_XTRACE=1 ;;
        *) unset __SETUP_EXEC_XTRACE ;;
    esac

    local shell_bin=""
    shell_bin="$(command -v "$(basename "${SHELL:-bash}")" 2>/dev/null || true)"
    if [[ -z "${shell_bin}" ]]; then
        shell_bin="$(command -v bash 2>/dev/null || true)"
    fi
    if [[ -z "${shell_bin}" ]]; then
        shell_bin="/bin/bash"
    fi

    # Build shell options: always use login shell (-l), add -x if xtrace was enabled
    local shell_opts="-l"
    if [[ -n "${__SETUP_EXEC_XTRACE:-}" ]]; then
        shell_opts="-lx"
    fi

    # Re-run setup in a login shell, preserving the original argv where possible.
    if declare -p __SETUP_ORIG_ARGS >/dev/null 2>&1; then
        exec "$shell_bin" $shell_opts "${__SETUP_BASE}/${__SETUP_NAME}" "${__SETUP_ORIG_ARGS[@]}"
    else
        exec "$shell_bin" $shell_opts "${__SETUP_BASE}/${__SETUP_NAME}" "${ACTION}"
    fi
}
