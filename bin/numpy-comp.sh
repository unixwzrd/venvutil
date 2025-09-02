#!/usr/bin/env bash

# Code to install a version of NumPy greater than 1.26.0. This si code which takes version of
# NumPy as an argument and installs that version and validates that the version is greater than 1.26.0.
# If the version is not greater than 1.26.0, the script will exit with a message. If no version is provided,
# The script will default to the highest stable version of 1.26 and supply the use with a message warning
# that version 1.26 will be installed and verify if this is what they want to do before proceeding.

DEFAULT_VERSION="1.26.*"

if [ -z "$1" ]; then
    echo -e "No version specified. Would you like to install NumPy version ${DEFAULT_VERSION}? [y/N]"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        VERSION=$DEFAULT_VERSION
    else
        echo "Installation cancelled. Please specify a version greater than 1.26.0"
        exit 1
    fi
else
    VERSION=$1
fi

# Function to compare semantic versions
compare_versions() {
    local version1=$1
    local version2=$2
    
    # Remove any wildcards and split into components
    local v1_clean=$(echo "$version1" | sed 's/\*//g')
    local v2_clean=$(echo "$version2" | sed 's/\*//g')
    
    # Split versions into arrays
    IFS='.' read -ra V1_PARTS <<< "$v1_clean"
    IFS='.' read -ra V2_PARTS <<< "$v2_clean"
    
    # Pad shorter array with zeros
    local max_len=${#V1_PARTS[@]}
    if [ ${#V2_PARTS[@]} -gt $max_len ]; then
        max_len=${#V2_PARTS[@]}
    fi
    
    # Compare each component
    for ((i=0; i<max_len; i++)); do
        local v1_part=${V1_PARTS[i]:-0}
        local v2_part=${V2_PARTS[i]:-0}
        
        if [ "$v1_part" -lt "$v2_part" ]; then
            return 1  # version1 < version2
        elif [ "$v1_part" -gt "$v2_part" ]; then
            return 0  # version1 > version2
        fi
    done
    
    return 2  # versions are equal
}

# Check if version is greater than or equal to 1.26.0
MIN_VERSION="1.26.0"

# If version contains wildcard, treat it as equal to minimum version
if [[ "$VERSION" == *"*"* ]]; then
    VERSION_CLEAN=$(echo "$VERSION" | sed 's/\*//g')
    compare_versions "$VERSION_CLEAN" "$MIN_VERSION"
    result=$?
    if [ $result -eq 1 ]; then
        echo "Error: Version must be greater than or equal to 1.26.0"
        echo "Specified version: $VERSION"
        exit 1
    fi
else
    compare_versions "$VERSION" "$MIN_VERSION"
    result=$?
    if [ $result -eq 1 ]; then
        echo "Error: Version must be greater than or equal to 1.26.0"
        echo "Specified version: $VERSION"
        exit 1
    fi
fi

echo "Installing NumPy version $VERSION..."
CFLAGS="-I/System/Library/Frameworks/vecLib.framework/Headers -Wl,-framework -Wl,Accelerate -framework Accelerate" pip install numpy=="$VERSION" --force-reinstall --no-deps --no-cache --no-binary :all: --no-build-isolation --compile -Csetup-args=-Dblas=accelerate -Csetup-args=-Dlapack=accelerate -Csetup-args=-Duse-ilp64=true