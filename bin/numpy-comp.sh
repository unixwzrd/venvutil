#!/usr/bin/env bash

# Code to install a version of NumPy greater than 1.26.0. This si code which takes version of
# NumPy as an argument and installs that version and validates that the version is greater than 1.26.0.
# If the version is not greater than 1.26.0, the script will exit with a message. If no version is provided,
# The script will default to the highest stable version of 1.26 and supply the use with a message warning
# that version 1.26 will be installed and verify if this is what they want to do before proceeding.

DEFAULT_VERSION="1.26.*"
MIN_VERSION="1.26.0"

# Get user input
if [ -z "$1" ]; then
    echo -e "No version specified. Would you like to install NumPy version '${DEFAULT_VERSION}'? [y/N]"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        VERSION=$DEFAULT_VERSION
    else
        echo "Installation cancelled. Please specify a version greater than ${MIN_VERSION}."
        exit 1
    fi
else
    VERSION=$1
fi

# If wildcard (*) version is used, allow it without comparison
if [[ "$VERSION" == *"*"* ]]; then
    echo "Proceeding with NumPy version: $VERSION (latest for specified range)"
else
    # Convert versions to numeric values for comparison
    version_numeric=$(echo "$VERSION" | awk -F. '{ printf("%d%03d%03d\n", $1,$2,$3) }')
    min_numeric=$(echo "$MIN_VERSION" | awk -F. '{ printf("%d%03d%03d\n", $1,$2,$3) }')

    # Ensure that input version is valid
    if [[ ! "$version_numeric" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid version format '$VERSION'. Please specify a valid version like 1.26.2 or 2.0.1."
        exit 1
    fi

    # Compare the numeric version values
    if [[ "$version_numeric" -lt "$min_numeric" ]]; then
        echo "Error: Version must be greater than or equal to ${MIN_VERSION}"
        echo "Specified version: $VERSION"
        exit 1
    fi
fi

echo "Proceeding with NumPy version: $VERSION"

# CFLAGS="-I/System/Library/Frameworks/vecLib.framework/Headers -Wl,-framework -Wl,Accelerate -framework Accelerate" pip install numpy=="$VERSION" --force-reinstall --no-deps --no-cache --no-binary :all: --no-build-isolation --compile -Csetup-args=-Dblas=accelerate -Csetup-args=-Dlapack=accelerate -Csetup-args=-Duse-ilp64=true
PATH="/usr/bin:${PATH}" CFLAGS="-I/System/Library/Frameworks/vecLib.framework/Headers -fno-strict-aliasing -DHAVE_BLAS_ILP64 -DACCELERATE_NEW_LAPACK=1 -DACCELERATE_LAPACK_ILP64=1" pip install numpy=="$VERSION" --force-reinstall --no-deps --no-cache --no-binary :all: --no-build-isolation --compile -Csetup-args=-Dblas=accelerate -Csetup-args=-Dlapack=accelerate -Csetup-args=-Duse-ilp64=true