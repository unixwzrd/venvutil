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

# Remove wildcard for comparison
VERSION_CLEAN=$(echo "$VERSION" | sed 's/\*//g')

# Convert version numbers into comparable format
min_version="1.26.0"
if [[ "$VERSION_CLEAN" == "$DEFAULT_VERSION" ]]; then
    VERSION_CLEAN=$min_version
fi

# Compare using Bash version sorting
if [[ "$(printf '%s\n' "$min_version" "$VERSION_CLEAN" | sort -V | head -n 1)" != "$min_version" ]]; then
    echo "Error: Version must be greater than or equal to 1.26.0"
    echo "Specified version: $VERSION_CLEAN"
    exit 1
fi

echo "Proceeding with NumPy version $VERSION_CLEAN..."

echo "Installing NumPy version $VERSION..."
CFLAGS="-I/System/Library/Frameworks/vecLib.framework/Headers -Wl,-framework -Wl,Accelerate -framework Accelerate" pip install numpy=="$VERSION" --force-reinstall --no-deps --no-cache --no-binary :all: --no-build-isolation --compile -Csetup-args=-Dblas=accelerate -Csetup-args=-Dlapack=accelerate -Csetup-args=-Duse-ilp64=true