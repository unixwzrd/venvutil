#!/usr/bin/env bash
#
# pre-flight.sh - Pre-flight checks for setup
#

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
    log_message "INFO" "Pre-installation tasks..."
    # Custom pre-install tasks can be added here
    check_deps
    # This may be used for verification or rollback/removal later.
    write_pkg_info
}
