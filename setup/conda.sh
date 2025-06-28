#!/usr/bin/env bash
#
# conda.sh - Conda related functions
#

get_conda_installer() {
    log_message "INFO" "Getting conda installer..."
    # Find host OS and architecture
    local INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-${OS}-${ARCH}.sh"
    curl -k -O "$INSTALLER_URL"
    return 0
}

run_conda_installer() {
    log_message "INFO" "Running conda installer..."
    bash "Miniconda3-latest-${OS}-${ARCH}.sh" -b -u
    rm "Miniconda3-latest-${OS}-${ARCH}.sh"
    # Activate the Conda installation
    # shellcheck disable=SC1091
    source "${HOME}/miniconda3/bin/activate"

    # Initialize conda for our shell
    conda init "$(basename "${SHELL}")"
    log_message "INFO" "Conda installed successfully, checking for updates..."
    conda update -n base -c defaults conda -y

    return 0
}

install_conda() {
    # Stop recursion before it starts, this is re-entrant.
    if [ "${CONDA_INSTALL_COMPLETE:-''}" == "Y" ]; then
        unset CONDA_INSTALL_COMPLETE
        return 0
    fi
    log_message "INFO" "Installing conda..."
    get_conda_installer
    run_conda_installer
    restart_shell
    return 0
}
