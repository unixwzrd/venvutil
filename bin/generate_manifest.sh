#!/usr/bin/env bash

#set -euo pipefail

# Script to generate a manifest file for the venvutil project


# Function to process entries and generate the manifest
process_and_generate_manifest() {
    local asset="$1"
    local type="$2"
    local asset_name=""
    local permissions=""
    local size=""
    local checksum=""
    local target_location=""
    local source_location=""

    # Exclude certain files
    if [[ "$asset" == *.DS_Store ]]; then
        return
    fi

    # Strip leading './' if present
    # asset="${asset//.\//}"

    # Extract the base name and directory name
    asset_name=$(basename "$asset")
    source_location=$(dirname "$asset")
    target_location=${source_location}

    source_location=${source_location/#.\//}
    source_location=${source_location/#./}
    target_location=${target_location/#.\//}
    target_location=${target_location/#./}

        # Determine the type of the entry
    if [ -L "$asset" ]; then
        type="l"
        source_location=$(readlink "$asset")
    elif [ -d "$asset" ]; then
        type="d"
    elif [ -f "$asset" ]; then
        type="f"
    else
        type="unknown"
    fi

    # Get permissions and size
    if [ -n "$asset" ]; then
        permissions=$($PERMISSIONS_CMD "$asset")
        size=$($SIZE_CMD "$asset")
    fi

    # Check if commands were successful
    if [ -z "$permissions" ] || [ -z "$size" ]; then
        echo "Error: Failed to get file information for $asset"
        return
    fi

    # Get checksum for files
    if [ "$type" == "f" ]; then
        if command -v shasum >/dev/null 2>&1; then
            # Use shasum if available
            checksum=$(shasum "$asset" | awk '{ print $1 }')
        elif command -v sha1sum >/dev/null 2>&1; then
            # Use sha1sum as fallback
            checksum=$(sha1sum "$asset" | awk '{ print $1 }')
        else
            checksum="Unavailable"
            echo "Warning: No checksum utility found for $asset"
        fi
    fi

    # Write entry to manifest with consistent format
    echo "$type | $target_location | $source_location | $asset_name | $permissions |  |  | $size | $checksum" >> "$OUTPUT_FILE"
}

# Function to get deleted files from git status
get_deleted_files() {
    if ! command -v git >/dev/null 2>&1; then
        echo "Warning: git not found, skipping deleted files check" >&2
        return
    fi
    
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Warning: not in a git repository, skipping deleted files check" >&2
        return
    fi
    
    # Get deleted, renamed and untracked files compared to main branch
    git diff --name-status main | grep -e '^D' | sed 's/D.[[:space:]]*//'
}


## Initialization
# Check if the script is running in Bash >= 4.0
if ((BASH_VERSINFO[0] < 4)); then
    echo "This script requires Bash version 4.0 or higher."
    exit 1
fi

# Determine the real path of the script
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
# Extract script name, directory, and arguments
# MY_NAME appears unused. Verify use (or export if used externally).
# shellcheck disable=SC2034
MY_NAME=$(basename "${THIS_SCRIPT}")
__SETUP_BIN="$(dirname "${THIS_SCRIPT}")"
__SETUP_BASE=$(dirname "${__SETUP_BIN}")
__SETUP_INCLUDE="${__SETUP_BASE}/bin/shinclude"

SHINCLUDE="${SHINCLUDE:-""}"
for try in "${SHINCLUDE}" "$(dirname "${THIS_SCRIPT}")/shinclude" "${__SETUP_INCLUDE}" "${HOME}/bin/shinclude"; do
    [ -f "${try}/config_lib.sh" ] && { SHINCLUDE="${try}"; break; }
done
[ -z "${SHINCLUDE}" ] && {
    cat<<_EOT_ >&2
ERROR ($MY_NAME): Could not locate \`config_lib.sh\` file.
ERROR ($MY_NAME): Please set install config_lib.sh which came with this repository in one of
    the following locations:
        - $(dirname "${THIS_SCRIPT}")/shinclude
        - $HOME/shinclude
        - $HOME/bin/shinclude
    or set the environment variable SHINCLUDE to the directory containing config_lib.sh

_EOT_
    exit 2     # (ENOENT: 2): No such file or directory
}
echo "INFO ($MY_NAME): Using SHINCLUDE directory - ${SHINCLUDE}" >&2
# shellcheck source=/dev/null
source "${SHINCLUDE}/config_lib.sh"

pkg_config_vars
# Specify the files and directories to include
load_pkg_config "${__SETUP_BASE}/setup.cf"
# shellcheck disable=SC2206
include_files=(${include_files[@]:-("README.md" "LICENSE" "setup.sh" "setup.cf" "manifest.lst")})
# shellcheck disable=SC2206
include_dirs=(${include_dirs[@]:-("bin" "docs" "conf")})
# shellcheck disable=SC2206
exclude_dirs=(".vscode" ".venvutil" "tmp")
# Output file
OUTPUT_FILE="manifest.lst"

# Check which 'stat' command is available and set commands accordingly
if stat --version >/dev/null 2>&1; then
    # GNU stat
    PERMISSIONS_CMD="stat -c %a"
    SIZE_CMD="stat -c %s"
else
    # Assume BSD stat (macOS)
    PERMISSIONS_CMD="stat -f %A"
    SIZE_CMD="stat -f %z"
fi

# Start fresh
# Add a header to the manifest file
echo "# This file uses pipe-separated fields" > "$OUTPUT_FILE"

# Add deleted files as cancel entries
while read -r deleted_file; do
    if [ -n "$deleted_file" ]; then
        dir=$(dirname "$deleted_file")
        name=$(basename "$deleted_file")
        echo "c | $dir | | $name | | | | |" >> "$OUTPUT_FILE"
    fi
done < <(get_deleted_files)

# Construct the prune condition
prune_conditions=()
if [[ ${#exclude_dirs[@]} -gt 0 ]]; then
    prune_conditions+=( "(" )
    prune_conditions+=( "-path" "*/.*" )
    for dir in "${exclude_dirs[@]}"; do
        prune_conditions+=( "-path" "./$dir" "-o" "-path" "./$dir/*" "-o" )
    done
    unset 'prune_conditions[-1]'  # Remove the last "-o"
    prune_conditions+=( ")" )
    prune_conditions+=( "-prune" )
else
    # If no hidden directories to include, prune all hidden directories
    prune_conditions+=( "-path" "*/.*" "-prune" )
fi

# Build the find command
find_args=( "." )

# Add prune conditions
find_args+=( "(" "${prune_conditions[@]}" ")" )

# Add '-o' to separate prune conditions from other conditions
find_args+=( "-o" "(" )

# Add files to the find arguments
for file in "${include_files[@]}"; do
    find_args+=( "-name" "$file" "-o" )
done

# Add visible directories and their contents to the find arguments
for dir in "${include_dirs[@]}"; do
    find_args+=( "-path" "./$dir" "-o" "-path" "./$dir/*" "-o" )
done

unset 'find_args[-1]'  # Remove the last "-o"

# Close the grouping and add -print
find_args+=( ")" "-print" )

# Execute the find command
find "${find_args[@]}" | while read -r asset; do
    # Process entries
    process_and_generate_manifest "$asset"
done

# Sort the manifest file
mv "$OUTPUT_FILE" "$$OUTPUT_FILE"
sort -o "$OUTPUT_FILE" "$$OUTPUT_FILE"
rm "$$OUTPUT_FILE"
