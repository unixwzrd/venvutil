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

# Handle wildcard versions by using the minimum version number
VERSION_NUM=$(echo "$VERSION" | sed 's/\*//g' | tr -d '.')
MIN_VERSION_NUM=1260

# If version contains wildcard, treat it as equal to minimum version
if [[ "$VERSION" == *"*"* ]]; then
    VERSION_NUM=$MIN_VERSION_NUM
fi

if [ "$VERSION_NUM" -lt "$MIN_VERSION_NUM" ]; then
    echo "Error: Version must be greater than or equal to 1.26.0"
    echo "Specified version: $VERSION"
    exit 1
fi

echo "Installing NumPy version $VERSION..."
CFLAGS="-I/System/Library/Frameworks/vecLib.framework/Headers -Wl,-framework -Wl,Accelerate -framework Accelerate" pip install numpy=="$VERSION" --force-reinstall --no-deps --no-cache --no-binary :all: --no-build-isolation --compile -Csetup-args=-Dblas=accelerate -Csetup-args=-Dlapack=accelerate -Csetup-args=-Duse-ilp64=true