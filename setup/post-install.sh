#!/usr/bin/env bash
#
# post-install.sh - Post-installation functions
#

update_bashrc() {
    log_message "INFO" "Updating .bashrc for package ${PKG_NAME}..."
    local bashrc="$HOME/.bashrc"
    local start_marker="# VENVUTIL START"
    local end_marker="# VENVUTIL END"

    # Create a backup before modifying
    if [ -f "$bashrc" ]; then
        local backup_file
        backup_file="$bashrc.$(date +%Y%m%d%H%M%S).bak"
        cp "$bashrc" "$backup_file"
        log_message "INFO" "Created backup of .bashrc at ${backup_file}"
    else
        : >"$bashrc" || { log_message "ERROR" "Failed to create ${bashrc}"; return 1; }
        log_message "INFO" "Created .bashrc file as it did not exist."
    fi

    # Remove existing venvutil block to prevent duplicates. Using a temp file for portability (sed -i varies).
    if grep -Fxq "$start_marker" "$bashrc"; then
        sed "/^${start_marker}$/,/^${end_marker}$/d" "$bashrc" > "$bashrc.tmp" && mv "$bashrc.tmp" "$bashrc"
        log_message "INFO" "Removed existing venvutil configuration from .bashrc to apply updates."
    fi

    # Add the new venvutil block to the end of the file
    {
        echo ""
        echo "$start_marker"
        echo "if [[ ! \"\$PATH\" =~ \"${INSTALL_BASE}/bin:\" ]]; then export PATH=\"${INSTALL_BASE}/bin:\$PATH\"; fi"
        echo "if [[ -f \"${INSTALL_BASE}/bin/shinclude/venvutil_lib.sh\" ]]; then source \"${INSTALL_BASE}/bin/shinclude/venvutil_lib.sh\" ; fi"
        echo "cact venvutil"
        echo "$end_marker"
    } >> "$bashrc"
    log_message "INFO" "Updated .bashrc with venvutil configuration."

    return 0
}

post_install_user_message() {
    log_message "INFO" "Provide user instructions..."
    # Custom post-install message can be added here
    cat <<_EOT_

    The package $PKG_NAME has been installed to $INSTALL_BASE.
    The installer updated your $HOME/.bashrc with a Venvutil block:

    # VENVUTIL START
    if [[ ! "\$PATH" =~ "$INSTALL_BASE/bin:" ]]; then export PATH="$INSTALL_BASE/bin:\$PATH"; fi
    if [[ -f "${INSTALL_BASE}/bin/shinclude/venvutil_lib.sh" ]]; then source \"${INSTALL_BASE}/bin/shinclude/venvutil_lib.sh\"; fi
    cact venvutil
    # VENVUTIL END

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
