#!/usr/bin/env bash
#
# assets.sh - Asset installation functions
#

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
