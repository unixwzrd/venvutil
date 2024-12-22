#!/usr/bin/env bash

# Script to generate a manifest file for the venvutil project

# Output file
OUTPUT_FILE="manifest.lst"

# Check if the script is running in Bash >= 4.0
if ((BASH_VERSINFO[0] < 4)); then
    echo "This script requires Bash version 4.0 or higher."
    exit 1
fi

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

# Assuming the script is run from the root of the project
SCRIPT_DIR=$(pwd)

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
    
    git status --porcelain | grep '^ D\|^D ' | sed 's/^ D //;s/^D //'
}

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

# Specify the files and directories to include
include_files=("README.md" "LICENSE" "setup.sh" "setup.cf" "manifest.lst")
include_dirs=("bin" "docs" "conf")

# Initialize arrays
hidden_include_dirs=()
visible_include_dirs=()

# Separate include_dirs into hidden and visible directories
for dir in "${include_dirs[@]}"; do
    if [[ "$dir" == .* ]]; then
        hidden_include_dirs+=("$dir")
    else
        visible_include_dirs+=("$dir")
    fi
done

# Construct the prune condition
prune_conditions=()
if [[ ${#hidden_include_dirs[@]} -gt 0 ]]; then
    prune_conditions+=( "-path" "*/.*" )
    prune_conditions+=( "-a" )
    prune_conditions+=( "-not" )
    prune_conditions+=( "(" )
    for dir in "${hidden_include_dirs[@]}"; do
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
for dir in "${visible_include_dirs[@]}"; do
    find_args+=( "-path" "./$dir" "-o" "-path" "./$dir/*" "-o" )
done

# Add hidden directories and their contents to the find arguments
for dir in "${hidden_include_dirs[@]}"; do
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
