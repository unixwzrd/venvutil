#!/usr/bin/env bash

# # Script: vsetup.sh
# `vsetup.sh` - setup venvutil installation and configuration
# ## Description
# - **Purpose**: 
#   - Install venvutil tools and utilities from the cloned repository.
#   - Run the script to install and configure venvutil.
# - **Usage**: 
#   - Run the script to install and configure venvutil.
# - **Input Parameters**:
#   `-d`: Specify the directory path where venvutil will be installed.
#         The default is $HOME/local
#   `-r`: Remove venvutil tools and utilities from the system.
#         The location will be taken from the config.sh file in your $HOME.venvutil directory.
# - **Output**:
#   - Initialize the environment, set up venvutil, and configure it for use.
# - **Exceptions**:
#   - Some functions within the script may return specific error codes depending on their internal logic. Refer to the individual function documentation for detailed exception handling.
#   - If an error occurs during the execution of the script, it will remove itself from the system.
# - **Initialization**:
#   - Ensure the script is executed in a bash shell.
#   - Check if the script is already running and exit if it is.
# - **Configuration**:
#   - Load the configuration variables from the config.sh file in the .venvutil directory.
#   - If the configuration file is not found, the initial default install location $HOME/local/venvutil will be used.
#
# ## Dependencies
# - bash 4.0 or higher
# - Python 3.10 or higher
# - Xcode Command Line Tools
#
# ## Author
# - Michael Sullivan <unixwzrd@unixwzrd.ai>
#     https://unixwzrd.ai/
#     https://github.com/unixwzrd
#
# ## License
# - Apache License, Version 2.0

THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[$((${#BASH_SOURCE[@]} -1))]}")
MY_NAME="$(basename "${THIS_SCRIPT}")"
MY_PATH="$(dirname "${THIS_SCRIPT}")"

VENVUTIL_CONFIG="${HOME}/.venvutil"
source "${VENVUTIL_CONFIG}/config.sh"
# Options processing
while getopts "d:r" opt; do
  case $opt in
    d) VENVUTIL_CONFIG="$OPTARG"
       VENVUTIL_MANIFEST="${MY_PATH}/conf/manifest.lst}"
       INSTALL=true ;;
    r) REMOVE=true
       VENVUTIL_MANIFEST="${VENVUTIL_CONFIG}/manifest.sh" ;;
    *) echo "Usage: $0 [-d directory] [-r]" >&2
       exit 1 ;;
  esac
done

check_deps() {
  # Check for Bash version 4+
  if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "ERROR ($MY_NAME): vsetup.sh requires Bash version 4 or higher." >&2
    exit 75     # (EPROGMISMATCH: 75): Program version wrong
  fi
  # Check Operating System (Linux or macOS)
  if [ "$(uname -s)" != "Darwin" ] && [ "$(uname -s)" != "Linux" ]; then
    echo "ERROR ($MY_NAME): vsetup.sh is only supported on macOS and Linux." >&2
    exit 75     # (EPROGMISMATCH: 75): Program version wrong
  fi
  # Check for curl
  if ! command -v curl &> /dev/null; then
    echo "ERROR ($MY_NAME): curl is not installed. Please install curl." >&2
    exit 2    # (ENOENT: 2): No such file or directory
  fi
  # Locate our manifest file
  if [ ! -f "${VENVUTIL_MANIFEST}" ]; then
    echo "ERROR ($MY_NAME): Manifest file not found at ${VENVUTIL_MANIFEST}" >&2
    exit 2    # (ENOENT: 2): No such file or directory
  fi
  return 0
}

install_conda() {
  # Check if conda is already installed
  if command -v conda &> /dev/null; then
    echo "INFO ($MY_NAME): conda is already installed. Skipping installation."
    return 0
  fi

  # Find host OS and architecture
    OS=$(uname -s)
    [ "$OS" == "Darwin" ] && OS="MacOSX"
    [ "$OS" == "Linux" ] && OS="Linux"
    ARCH=$(uname -m)
    ARCH=${ARCH//aarch64/arm64}

  # Download and install conda
  echo "INFO ($MY_NAME): Downloading and installing conda..."
  INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-${OS}-${ARCH}.sh"
  curl -O $INSTALLER_URL
  # do a non-destructive install
  bash Miniconda3-latest-${OS}-${ARCH}.sh -b -u
  rm Miniconda3-latest-${OS}-${ARCH}.sh
  # Activate the Conda installation
  . "${HOME}/miniconda3/bin/activate"
  # IInitialize conda for our SHELL
  conda init $(basename "${SHELL}")
  echo "INFO ($MY_NAME): conda installed successfully, checking for updates..."
  conda update -n base -c defaults conda -y
  return 0
}

# our version of teh install command
install(){
  # The steps required for install, if we get hung up on any one fo the steps
  # we will call remove to cleanup and exit.
  check_deps
  install_conda
  return 0
}

remove(){
  # The steps required for remove, if we get hung up on any one fo the steps
  # we will exit the script.
  # remove_conda #nah, not going to remove conda, they may have it alrady installed and we don't want to remove it.

  return 0
}

main() {
  # Check whether install or remove
  if [ "${INSTALL}" = true ]; then
    install
  elif [ "${REMOVE}" = true ]; then
    remove
  fi
  return 0
}

main