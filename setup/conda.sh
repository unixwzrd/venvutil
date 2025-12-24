#!/usr/bin/env bash
#
# conda.sh - Conda related functions
#

miniconda_installer_name() {
    # Compute the Miniconda installer filename from *raw* uname values.
    # Keep all mapping local to this function (avoid polluting global namespace).
    local uname_os uname_arch os arch

    if [[ -z "${UNAME_OS:-}" || -z "${UNAME_ARCH:-}" ]]; then
        if declare -f get_os_config &>/dev/null; then
            get_os_config
        fi
    fi

    uname_os="${UNAME_OS:-$(uname -s)}"
    uname_arch="${UNAME_ARCH:-$(uname -m)}"

    # Miniconda naming uses MacOSX (not Darwin). Linux stays Linux.
    case "${uname_os}" in
        Darwin) os="MacOSX" ;;
        Linux) os="Linux" ;;
        *) os="${uname_os}" ;;
    esac

    arch="${uname_arch}"
    # Linux aarch64 installer sometimes needs mapping from "arm64".
    if [[ "${os}" == "Linux" && "${arch}" == "arm64" ]]; then
        arch="aarch64"
    fi
    # Rare: some macOS environments report aarch64; Miniconda uses arm64 on Mac.
    if [[ "${os}" == "MacOSX" && "${arch}" == "aarch64" ]]; then
        arch="arm64"
    fi

    printf 'Miniconda3-latest-%s-%s.sh' "${os}" "${arch}"
}

get_conda_installer() {
    log_message "INFO" "Getting conda installer..."
    local installer_name
    installer_name="$(miniconda_installer_name)"
    local INSTALLER_URL="https://repo.anaconda.com/miniconda/${installer_name}"
    log_message "INFO" "Miniconda installer: ${installer_name} (uname: ${UNAME_OS:-?}/${UNAME_ARCH:-?})"
    # -f: fail on HTTP errors (e.g. 404); -L: follow redirects.
    if ! curl -fL -o "${installer_name}" "${INSTALLER_URL}"; then
        log_message "ERROR" "Failed to download Miniconda installer (check OS/ARCH mapping): ${INSTALLER_URL}"
        return 5  # EIO: Input/output error
    fi
    printf '%s' "${installer_name}"
}

run_conda_installer() {
    log_message "INFO" "Running conda installer..."
    local installer_name="${1:-}"
    if [[ -z "${installer_name}" ]]; then
        installer_name="$(miniconda_installer_name)"
    fi

    if [[ ! -f "${installer_name}" ]]; then
        log_message "ERROR" "Conda installer not found: ${installer_name}"
        return 2  # ENOENT: No such file or directory
    fi

    if ! bash "${installer_name}" -b -u; then
        log_message "ERROR" "Conda installer failed: ${installer_name}"
        rm -f "${installer_name}"
        return 8  # ENOEXEC: Exec format error
    fi
    rm -f "${installer_name}"
    # Activate the Conda installation
    # shellcheck disable=SC1091
    source "${HOME}/miniconda3/bin/activate"

    # Initialize conda for our shell
    conda init "$(basename "${SHELL}")"
    log_message "INFO" "Conda installed successfully, checking for updates..."
    conda update -n base -c defaults conda -y
    export CONDA_INSTALL_COMPLETE="Y"

    return 0
}

install_conda() {
    # Stop recursion before it starts, this is re-entrant.
    if [ "${CONDA_INSTALL_COMPLETE:-''}" == "Y" ]; then
        # unset CONDA_INSTALL_COMPLETE
        return 0
    fi
    log_message "INFO" "Installing conda..."
    local installer_name __rc__
    if ! installer_name="$(get_conda_installer)"; then
        __rc__=$?
        return "${__rc__}"
    fi
    if ! run_conda_installer "${installer_name}"; then
        __rc__=$?
        return "${__rc__}"
    fi
    restart_shell
    return 0
}
