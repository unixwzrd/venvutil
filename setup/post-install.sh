#!/usr/bin/env bash
#
# post-install.sh - Post-installation functions
#

post_install_user_message() {
    log_message "INFO" "Provide user instructions..."
    # Custom post-install message can be added here
    cat <<_EOT_

    The package $PKG_NAME has been installed to $INSTALL_BASE.
    To use the package, the following line was added to your .bashrc file:

    if [[ ! "\$PATH" =~ "$INSTALL_BASE/bin:" ]]; then export PATH="$INSTALL_BASE/bin:\$PATH"; fi
    if [[ -f "${INSTALL_BASE}/bin/shinclude/venvutil_lib.sh" ]]; then source \"${INSTALL_BASE}/bin/shinclude/venvutil_lib.sh\"; fi

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
