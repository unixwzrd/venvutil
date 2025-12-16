# Script: venvutil_lib.sh
`venvutil_lib.sh` - Primary Entry Point for VenvUtil Library System
#
## Description
- **Purpose**:
  - Primary entry point and initialization for the VenvUtil library system
  - Manages library loading sequence and dependencies
  - Provides core environment management functionality
#
## Usage
  - Direct source: `source /path/to/venvutil_lib.sh`
  - Via helper: `source_lib venvutil_lib`
#
## Library Loading Sequence
  1. config_lib - Configuration management
  2. errno_lib - Error handling and codes
  3. helpsys_lib - Help system functionality
  4. string_lib - String manipulation and display
  5. type_lib - Type checking and validation
  6. util_lib - Utility functions
  7. venv_lib - Virtual environment management
  8. wrapper_lib - Command wrapping and logging
#
## Dependencies
  - Bash 4.0 or higher
  - Core library files in same directory
  - Python package managers (pip/conda) for some functionality
#
## Environment Variables
  - `__VENV_SOURCED` - Tracks loaded libraries
  - `__VENV_BASE` - Base directory for VenvUtil
  - `__VENV_BIN` - Binary directory location
  - `__VENV_INCLUDE` - Library include directory
#
## Debug Support
  - Set `DEBUG_VENVUTIL=ON` for debug output
  - Individual functions support -x flag for debug mode
#
## Return Codes
  - 0: Success
  - Non-zero: Various error conditions (see errno_lib.sh)
#
## Examples
  ```bash
  # Direct usage
  source /path/to/venvutil_lib.sh
  
  # Enable debug mode
  DEBUG_VENVUTIL=ON source /path/to/venvutil_lib.sh
  ```
#
## Notes
  - This is the primary entry point for the VenvUtil system
  - All other libraries should be loaded through this file
  - Direct sourcing of other libraries is discouraged



## Script Documentation

* [venvutil_lib.sh](../venvutil_lib_sh.md)
Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

---

Generated Markdown Documentation
Generated on: 2025-12-16 at 09:11:38
