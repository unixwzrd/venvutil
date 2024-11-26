#!/usr/bin/env bash
#
# venvutil_setup.sh - Setup and configure venvutil.
#
# This script installs and configures the venvutil tools and utilities.
# It supports installation and removal operations, although the removal and rollback functionality is not yet implemented.
#
# Usage:
#     venvutil_setup.sh [-d directory] [-r] [-v] {install|remove}
#
# Options:
#     -d directory     Specify the directory path where venvutil will be installed.
#                      The default is $HOME/local
#     -r               Remove venvutil tools and utilities from the system.
#                      The location will be taken from the config.sh file in your $HOME/.venvutil directory.
#     -v               Enable verbose logging.
#     -h               Show this help message
#
# Description:
#     Install venvutil tools and utilities from the cloned repository.
#     Configure venvutil for use.
#
# Output:
#     Initializes the environment, sets up venvutil, and configures it for use.
#
# Exceptions:
#     Functions may return specific error codes based on their internal logic.
#     If an error occurs during execution, the script will remove itself from the system.
#
# Initialization:
#     Ensure the script is executed in a bash shell.
#     Check if the script is already running and exit if it is.
#
# Configuration:
#     Load configuration variables from the config.sh file in the .venvutil directory.
#     Use the default install location $HOME/local/venvutil if the configuration file is not found.
#
# Dependencies:
# - bash 4.0 or higher
# - Python 3.10 or higher
#
# Author:
#     Michael Sullivan <unixwzrd@unixwzrd.ai>
#     https://unixwzrd.ai/
#     https://github.com/unixwzrd
#
# License:
#     Apache License, Version 2.0

set -euo pipefail

# Initialize script variables
THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[$((${#BASH_SOURCE[@]} -1))]}")
MY_NAME="$(basename "${THIS_SCRIPT}")"
MY_PATH="$(dirname "${THIS_SCRIPT}")"

# Default values
PKG_NAME="venvutil"
PKG_VERSION=""
INSTALL_BASE=""
INSTALL_CONFIG="$HOME/.${PKG_NAME}"
INSTALL_MANIFEST="manifest.lst"
ACTION=""
VERBOSE=false

# Logging function
log_message() {
  local message_level="$1"; shift
  local message_out="$*"

#  declare -A message_class=(
#      ["INFO"]=30
#      ["WARNING"]=40
#      ["ERROR"]=50
#      ["CRITICAL"]=60
#  )

  # Print message to STDERR and log file
  if [ "$VERBOSE" = true ]; then
    echo "($MY_NAME) [$message_level] $message_out" | tee -a "$INSTALL_CONFIG/install.log" >&2
    return 0
  fi

  # Write message to log file
  echo "($MY_NAME) [$message_level] $message_out" > "$INSTALL_CONFIG/install.log" 2>&1
}

# Function to display help extracted from the script
display_help() {
  # Initialize a variable to hold the help text
  local message=$1
  local help_text=""

  # Read the script file line by line
  help_text+="$message"$'\n\n'
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip the shebang line
    if [[ "$line" =~ ^#!/ ]]; then
      continue
    fi
    # Stop at the first non-comment line (end of help section)
    if [[ ! "$line" =~ ^# ]]; then
      break
    fi
    # Remove leading '#' and spaces
    help_text+="${line#\# }"$'\n'
  done < "$0"

  printf "%s" "$help_text" | ${PAGER:-cat}
  exit 0
}

# Load package configuration from .cf file
load_pkg_config() {
  log_message "INFO" "Loading package configuration..."
  local config_file="$MY_PATH/setup.cf"
  if [ -f "$config_file" ]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
      [[ "$line" =~ ^#.*$ ]] && continue  # Skip comments
      [[ -z "$line" ]] && continue        # Skip blank lines
      if [[ "$line" =~ ^([A-Za-z_]+):[[:space:]]*(.*)$ ]]; then
        IFS=':' read -r key value <<< "$line"
        eval "$key=\"\$(echo \$value | xargs)\""
      elif [[ "$line" =~ ^[A-Za-z_]+=.*$ ]]; then
        eval "$line"
      fi
    done < "$config_file"
  else
    log_message "ERROR" "Configuration file $config_file not found."
    return 1
  fi
}

# Parse manifest metadata
parse_manifest_metadata() {
  local manifest_file="$INSTALL_MANIFEST"
  while IFS='| ' read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^#.*$ ]] && continue  # Skip comments
    [[ -z "$line" ]] && break           # Stop at first blank line (end of metadata)
    if [[ "$line" =~ ^[A-Za-z_]+=.*$ ]]; then
      eval "$line"
    fi
  done < "$manifest_file"
}

# Initialization
initialization() {

  # Load package configuration
  mkdir -p "$INSTALL_CONFIG"
  mkdir -p "$INSTALL_CONFIG/log" "$INSTALL_CONFIG/freeze"

  log_message "INFO" "Initialization..."

  load_pkg_config

  # Set PKG_NAME early to load config
  PKG_NAME=${PKG_NAME:-$Name}

  # Set default values if not already set
  PKG_VERSION=${PKG_VERSION:-$Version}
  INSTALL_BASE=${INSTALL_BASE:-$prefix}
  INSTALL_CONFIG=${INSTALL_CONFIG:-"$HOME/.${PKG_NAME}"}

  # Set default manifest path
  INSTALL_MANIFEST="$MY_PATH/manifest.lst"

  # Parse manifest metadata
  parse_manifest_metadata

}

# Parse command-line arguments
parse_arguments() {
  while getopts ":d:vh" opt; do
    case $opt in
      d) INSTALL_BASE="$OPTARG" ;;
      v) VERBOSE=true ;;
      h) display_help "Usage: $MY_NAME [options] {install|remove|rollback}" ;;
      \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
      :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
    esac
  done
  shift $((OPTIND -1))

  # Ensure at least one action is specified
  ACTION="${1:-}"
  if [ -z "$ACTION" ]; then
    display_help "Usage: $MY_NAME [options] {install|remove|rollback}" 
    exit 1
  fi
}

# Dependency checks
check_deps() {
  # Check for Bash version 4+
  if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    log_message "ERROR" "$MY_NAME requires Bash version 4 or higher."
    exit 75
  fi

  # Check Operating System (Linux or macOS)
  if [ "$(uname -s)" != "Darwin" ] && [ "$(uname -s)" != "Linux" ]; then
    log_message "ERROR" "$MY_NAME is only supported on macOS and Linux."
    exit 75
  fi

  # Check for essential commands
  for cmd in curl tar gzip; do
    if ! command -v $cmd &> /dev/null; then
      log_message "ERROR" "$cmd is not installed. Please install $cmd."
      exit 2
    fi
  done

  # Check if manifest file exists
  if [ ! -f "${INSTALL_MANIFEST}" ]; then
    log_message "ERROR" "Manifest file not found at ${INSTALL_MANIFEST}"
    exit 2
  fi
}

# Package information
pkg_info() {
  PKG_DATE=$(date '+%Y-%m-%d %H:%M:%S')
  log_message "INFO" "Package Information: Name=$PKG_NAME, Version=$PKG_VERSION, Date=$PKG_DATE"
}

install_conda() {
  log_message "INFO" "Installing conda..."
  # Check if conda is already installed
  if command -v conda &> /dev/null; then
    echo "INFO ($MY_NAME): conda is already installed. Skipping installation."
    return 0
  fi

  # Find host OS and architecture
  local OS ARCH
  OS=$(uname -s)
  [ "$OS" == "Darwin" ] && OS="MacOSX"
  [ "$OS" == "Linux" ] && OS="Linux"
  ARCH=$(uname -m)
  ARCH=${ARCH//aarch64/arm64}

  # Download and install conda
  echo "INFO ($MY_NAME): Downloading and installing conda..."
  local INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-${OS}-${ARCH}.sh"
  curl -O "$INSTALLER_URL"
  # do a non-destructive install
  bash "Miniconda3-latest-${OS}-${ARCH}.sh" -b -u
  rm "Miniconda3-latest-${OS}-${ARCH}.sh"
  # Activate the Conda installation
  # shellcheck disable=SC1091
  source "${HOME}/miniconda3/bin/activate"
  # Initialize conda for our shell
  conda init "$(basename "${SHELL}")"
  echo "INFO ($MY_NAME): conda installed successfully, checking for updates..."
  conda update -n base -c defaults conda -y
  # Because Red Hat Enterprise Linux defines, sets it, but doesn't export it BASHSOURCED...
  export BASHSOURCED=Y
  # So we con't recurse.
  export PRE_INSTALL_COMPLETE=Y
  # Wheeeeee!!!!!!
  exec $SHELL -l -c "${THIS_SCRIPT} ${ACTION}; exec $SHELL -l"
  return 0
}

# Pre-installation tasks
pre_install() {
  # Check if pre-installation tasks have already been completed
  # Stop recursion before it starts, this is re-entrant.
  if [ "${PRE_INSTALL_COMPLETE:-""}" == "Y" ]; then
    return 0
  fi
  log_message "INFO" "Pre-installation tasks..."
  # Custom pre-install tasks can be added here
  check_deps
  install_conda
}

install_assets() {
  # Implement package installation logic here
  log_message "INFO" "Installing packages..."

  readarray -t lines < <(grep -v '^#' "$INSTALL_MANIFEST" | grep -v '^\s*$')
  for line in "${lines[@]}"; do

    # Skip metadata lines
    if [[ "$line" =~ ^[A-Za-z_]+=.*$ ]]; then
      continue
    fi

    IFS=$'| ' read -r type destination source name permissions owner group size checksum <<< "$line"

    # Set default owner and group if not specified
    owner=${owner:-$(id -u)}
    group=${group:-$(id -g)}

    destination="${INSTALL_BASE}/${destination}"
    source_location="${source}"
    source_path="${MY_PATH}/${source_location}/${name}"
    dest_path="${destination}/${name}"

    mkdir -p "$destination"

    case "$type" in
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
        cd "$destination"
        ln "$source" "$name"
        cd -
        ;;
      l) # Create symbolic link
        cd "$destination"
        ln -sf "$source" "$name"
        cd -
        ;;
      *)
        log_message "ERROR" "Unknown asset type: $type"
        ;;
    esac
  done
}

install_python_packages() {
  log_message "INFO" "Installing NLTK data..."
  pip install -r "$MY_PATH/requirements.txt" | tee -a "$INSTALL_CONFIG/install.log"
  python <<_EOT_
import nltk
nltk.download('punkt')
nltk.download('stopwords')
_EOT_
  log_message "INFO" "NLTK data installed successfully."
}

# Update .bashrc
update_bashrc() {
  log_message "INFO" "Updating .bashrc..."
  local bashrc="$HOME/.bashrc"
  # Expressions don't expand in single quotes, use double quotes for that.
  # shellcheck disable=SC2016
  local path_line='if [[ "$PATH" =~ "$INSTALL_BASE/bin:" ]]; then PATH="$INSTALL_BASE/bin:${PATH}"; fi'

  if ! grep -Fxq "$path_line" "$bashrc"; then
    echo "$path_line" >> "$bashrc"
    log_message "INFO" "Updated $bashrc with package bin directory."
  fi
  return 0
}

post_install() {
  log_message "INFO" "Post-installation tasks..."
  install_python_packages
  # Example: Update .bashrc if necessary
  update_bashrc
  return 0
}

# Installation function
install() {
  log_message "INFO" "Installation tasks..."
  pre_install
  install_assets
  post_install
}

# Pre-removal tasks
pre_remove() {
  log_message "INFO" "Pre-removal tasks..."
  # Custom pre-remove tasks can be added here
}

# Removal function
remove_assets() {
  log_message "INFO" "Removal tasks..."
  readarray -t lines < <(grep -v '^#' "$INSTALL_MANIFEST" | grep -v '^\s*$' | sort -r)

  for line in "${lines[@]}"; do
    # Skip metadata lines
    if [[ "$line" =~ ^[A-Za-z_]+=.*$ ]]; then
      continue
    fi

    # size appears unused. Verify use (or export if used externally).
    # shellcheck disable=SC2034
    IFS=$'\t' read -r type destination source name permissions owner group size checksum <<< "$line"

    dest_path="${INSTALL_BASE}/${destination}/${name}"

    case "$type" in
      d) # Remove directory if empty
        if [ -d "$dest_path" ] && [ -z "$(ls -A "$dest_path")" ]; then
          rmdir "$dest_path"
        fi
        ;;
      f|l|h) # Remove file or symbolic link
        rm -f "$dest_path"
        ;;
      *)
        log_message "ERROR" "Unknown type: $type"
        ;;
    esac
  done

  post_remove
}

# Post-removal tasks
post_remove() {
  log_message "INFO" "Post-removal tasks..."
  # Example: Remove package bin directory from .bashrc
  remove_bashrc_entries
}

# Remove entries from .bashrc
remove_bashrc_entries() {
  local bashrc="$HOME/.bashrc"
  # Expressions don't expand in single quotes, use double quotes for that.
  # shellcheck disable=SC2016
  local path_line='if [[ "$PATH" =~ "$INSTALL_BASE/bin:" ]]; then PATH="$INSTALL_BASE/bin:${PATH}"; fi'

  if grep -Fxq "$path_line" "$bashrc"; then
    sed -i.bak "/$path_line/d" "$bashrc"
    log_message "INFO" "Removed package bin directory from $bashrc."
  fi
}

# Rollback function
rollback() {
  log_message "CRITICAL" "Rollback initiated..."
  # Implement rollback logic based on actions logged during installation
  # For example, read a log file and undo actions
}

# Main function
main() {
  parse_arguments "$@"
  initialization
  pkg_info

  case "$ACTION" in
    install)
      install
      ;;
    remove)
      pre_remove
      remove
      ;;
    rollback)
      rollback
      ;;
    *)
      echo "Invalid action: $ACTION"
      display_help "Usage: $MY_NAME [options] {install|remove|rollback}"
      ;;
  esac
}

main "$@"