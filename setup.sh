#!/usr/bin/env bash
#
# setup.sh - Setup and configure venvutil.
#
# This script installs and configures the venvutil tools and utilities.
# It supports installation and removal operations, although the removal and rollback functionality
# is not yet implemented.
#
# This script is a wrapper that sources modular components from the 'setup/' directory.
#
# Usage:
#     setup.sh [-d directory] [-r] [-v] action_name
#
# Actions:
#     install       Install venvutil tools and utilities from the cloned repository.
#     refresh       Refresh the venvutil tools without installing conda or python packages.
#     remove        Remove venvutil tools and utilities from the system.
#     rollback      Rollback the venvutil tools and utilities from the system.
#     verify        Verify the venvutil tools and utilities from the system.
#
# Options:
#     -d directory  Specify the directory path where venvutil will be installed.
#                     The default is read from setup/setup.cf (prefix=$HOME/local/venvutil)
#     -r            Remove venvutil tools and utilities from the system.
#                     The location will be taken from the config.sh file in your $HOME/.venvutil
#                     directory.
#     -v            Enable verbose logging.
#     -h            Show this help message
#
# Author:
#     Michael Sullivan <unixwzrd@unixwzrd.ai>
#     https://unixwzrd.ai/
#     https://github.com/unixwzrd
#
# License:
#     Apache License, Version 2.0
#

# --- Script Initialization ---

# Set script base name and directory
# Using a robust method to find the script's directory
__SETUP_SOURCE="${BASH_SOURCE[0]}"
while [ -h "$__SETUP_SOURCE" ]; do # resolve $__SETUP_SOURCE until the file is no longer a symlink
    __SETUP_BASE="$( cd -P "$( dirname "$__SETUP_SOURCE" )" >/dev/null 2>&1 && pwd )"
    __SETUP_SOURCE="$(readlink "$__SETUP_SOURCE")"
    [[ $__SETUP_SOURCE != /* ]] && __SETUP_SOURCE="$__SETUP_BASE/$__SETUP_SOURCE" # if $__SETUP_SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
__SETUP_BASE="$( cd -P "$( dirname "$__SETUP_SOURCE" )" >/dev/null 2>&1 && pwd )"
__SETUP_NAME=$(basename "${__SETUP_SOURCE}")
__SETUP_DIR="${__SETUP_BASE}/setup"

# --- Source Modules ---

# Source shared libraries from the canonical shinclude directory.
# This avoids drift between setup libs and runtime libs.
__SETUP_SHINCLUDE="${__SETUP_BASE}/bin/shinclude"
if [[ ! -f "${__SETUP_SHINCLUDE}/venvutil_lib.sh" ]]; then
    echo "ERROR ($__SETUP_NAME): Missing shared library: ${__SETUP_SHINCLUDE}/venvutil_lib.sh" >&2
    exit 2
fi
        # shellcheck disable=SC1090
source "${__SETUP_SHINCLUDE}/venvutil_lib.sh"

# Source all modules from the setup directory
for module in "${__SETUP_DIR}"/*.sh; do
    if [ -f "$module" ]; then
        # shellcheck disable=SC1090
        source "$module"
    fi
done

# --- Main Logic ---

main() {
    # Set default values
    # shellcheck disable=SC2034
    VERBOSE=false
    # shellcheck disable=SC2034
    INSTALL_BASE=""
    # shellcheck disable=SC2034
    ACTION=""

    # Parse command-line arguments
    parse_arguments "$@"

    # Initialize configuration
    initialization

    # Main action dispatcher
    case "$ACTION" in
        install)
            log_message "INFO" "Starting venvutil installation..."
            local err_code
            pre_install || { err_code=$?; errno_exit "${err_code}" "Pre-installation checks failed"; }
            install_conda || { err_code=$?; errno_exit "${err_code}" "Conda installation failed"; }
            install_assets || { err_code=$?; errno_exit "${err_code}" "Asset installation failed"; }
            install_python_packages || { err_code=$?; errno_exit "${err_code}" "Python package installation failed"; }
            write_pkg_config || { err_code=$?; errno_exit "${err_code}" "Package configuration write failed"; }
            update_bashrc || { err_code=$?; errno_exit "${err_code}" "Bashrc update failed"; }
            update_bash_login_file || { err_code=$?; errno_exit "${err_code}" "Bash login file update failed"; }
            post_install_user_message || { err_code=$?; errno_exit "${err_code}" "Post-installation message failed"; }
            log_message "INFO" "venvutil installation completed successfully."
            ;;
        refresh)
            log_message "INFO" "Refreshing venvutil tools..."
            install_assets
            log_message "INFO" "venvutil refresh completed successfully."
            ;;
        remove|uninstall)
            log_message "WARNING" "Removal functionality is not yet implemented."
            ;;
        rollback)
            log_message "WARNING" "Rollback functionality is not yet implemented."
            ;;
        verify)
            log_message "WARNING" "Verification functionality is not yet implemented."
            ;;
        *)
            display_help_and_exit "Invalid action: '$ACTION'. Use -h for help."
            ;;
    esac
}

# --- Script Execution ---

declare -ga __SETUP_ORIG_ARGS=("$@")
main "$@"
