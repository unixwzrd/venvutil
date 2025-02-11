#!/usr/bin/env bash
# # Script: venvutil_lib.sh
# `venvutil_lib.sh` - Primary Entry Point for VenvUtil Library System
#
# ## Description
# - **Purpose**:
#   - Primary entry point and initialization for the VenvUtil library system
#   - Manages library loading sequence and dependencies
#   - Provides core environment management functionality
#
# ## Usage
#   - Direct source: `source /path/to/venvutil_lib.sh`
#   - Via helper: `source_lib venvutil_lib`
#
# ## Library Loading Sequence
#   1. config_lib - Configuration management
#   2. errno_lib - Error handling and codes
#   3. helpsys_lib - Help system functionality
#   4. string_lib - String manipulation and display
#   5. type_lib - Type checking and validation
#   6. util_lib - Utility functions
#   7. venv_lib - Virtual environment management
#   8. wrapper_lib - Command wrapping and logging
#
# ## Dependencies
#   - Bash 4.0 or higher
#   - Core library files in same directory
#   - Python package managers (pip/conda) for some functionality
#
# ## Environment Variables
#   - `__VENV_SOURCED` - Tracks loaded libraries
#   - `__VENV_BASE` - Base directory for VenvUtil
#   - `__VENV_BIN` - Binary directory location
#   - `__VENV_INCLUDE` - Library include directory
#
# ## Debug Support
#   - Set `DEBUG_VENVUTIL=ON` for debug output
#   - Individual functions support -x flag for debug mode
#
# ## Return Codes
#   - 0: Success
#   - Non-zero: Various error conditions (see errno_lib.sh)
#
# ## Examples
#   ```bash
#   # Direct usage
#   source /path/to/venvutil_lib.sh
#   
#   # Enable debug mode
#   DEBUG_VENVUTIL=ON source /path/to/venvutil_lib.sh
#   ```
#
# ## Notes
#   - This is the primary entry point for the VenvUtil system
#   - All other libraries should be loaded through this file
#   - Direct sourcing of other libraries is discouraged

## Initialization
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
if ! declare -p __VENV_SOURCED >/dev/null 2>&1; then declare -g -A __VENV_SOURCED; fi
if [[ "${__VENV_SOURCED[${THIS_SCRIPT}]:-}" == 1 ]]; then 
    # echo "************************* SKIPPED SKIPPED SKIPPED SKIPPED             ************************* -----> $(basename "${THIS_SCRIPT}")" >&2
    return 
fi
__VENV_SOURCED["${THIS_SCRIPT}"]=1

# shellcheck disable=SC2034
MY_NAME=$(basename "${THIS_SCRIPT}")
__VENV_BIN=$(dirname "$(dirname "${THIS_SCRIPT}")")
__VENV_BASE=$(dirname "${__VENV_BIN}")
__VENV_INCLUDE="${__VENV_BASE}/bin/shinclude"

# Get the init_lib.sh script
# shellcheck source=/dev/null
source "${__VENV_INCLUDE}/init_lib.sh"

# Add internal functions to the __VENV_INTERNAL_FUNCTIONS array.
if ! declare -p __VENV_INTERNAL_FUNCTIONS >/dev/null 2>&1; then declare -ga __VENV_INTERNAL_FUNCTIONS; fi
# Quote to prevent word splitting/globbing, or split robustly with mapfile or read -a.
# shellcheck disable=SC2206
__VENV_INTERNAL_FUNCTIONS=(
    ${__VENV_INTERNAL_FUNCTIONS[@]}
)

source_lib config_lib
source_lib errno_lib
source_lib helpsys_lib
source_lib string_lib
source_lib type_lib
source_lib util_lib
source_lib venv_lib
source_lib wrapper_lib

__rc__=0
return ${__rc__}
