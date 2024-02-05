# help_sys.sh - Help System Functions for Bash Scripts
- **Purpose**: 
  - This script provides a dynamic help system for all sourced bash scripts.
  - It can list available functions, provide detailed information about each function, and list sourced scripts.
- **Usage**: 
  - Source this script in other bash scripts to enable the dynamic help system.
  - For example, in another script: `source help_sys.sh`.
- **Input Parameters**: 
  - None. All input is handled by the individual functions.
- **Output**: 
  - Enables a help system that can be accessed by calling `help` in the terminal.
  - Also supports generating Markdown documentation.
- **Exceptions**: 
  - Some functions may return specific error codes or print error messages to STDERR.
  - Refer to individual function documentation for details.
- **Environment**:
  - **MD_PROCESSOR**: Set to the markdown processor of your choice, if `glow`
      is in your path this will use that.

