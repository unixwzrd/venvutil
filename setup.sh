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
#                     The default is $HOME/local
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

# Source all shared libraries from the setuplib directory
for lib in "${__SETUP_DIR}"/setuplib/*.sh; do
    if [ -f "$lib" ]; then
        # shellcheck disable=SC1090
        source "$lib"
    fi
done

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
    VERBOSE=false
    INSTALL_BASE=""
    ACTION=""

    # Parse command-line arguments
    parse_arguments "$@"

    # Initialize configuration
    initialization

    # Main action dispatcher
    case "$ACTION" in
        install)
            log_message "INFO" "Starting venvutil installation..."
            pre_install
            install_assets
            install_conda
            install_python_packages
            write_pkg_config
            post_install_user_message
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

# Execute the main function with all script arguments
main "$@"


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
source "${SH_LIB}/venvutil_lib.sh"

main "$@"
