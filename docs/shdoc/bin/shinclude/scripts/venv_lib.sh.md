# Script: venv_lib.sh
`venv_lib.sh` - Virtual Environment Management Functions for Bash Scripts
## Description
- **Purpose**: 
  - This script provides a collection of functions to manage conda virtual environments.
  - Functions include creating, deleting, switching, and cloning environments, among others.
#
## Usage
 - Source this script in other bash scripts to import the virtual environment management functions.
 - For example, in another script: `source venv_funcs.sh`.
#
- **Input Parameters**: 
  - None. All input is handled by the individual functions.
#
- **Output**: 
  - The script provides various virtual environment management functions for use in other bash scripts.
#
- **Exceptions**: 
  - Some functions may return specific error codes or print error messages to STDERR.
  - Refer to individual function documentation for details.
#
- **Internal Variables**
  - __VENV_NUM    The sequence of the venv in a "__VENV_PREFIX" series.
  - __VENV_PREFIX The prefix of the VENV
  - __VENV_DESC   A very short description of the VENV.
#
- **Functions**:
  - `push_venv()`: Specialized push the default VENV onto the stack.
  - `pop_venv()`: Specialized pop the VENV off the stack and decrement.
  - `__set_venv_vars()`: Sets internal VENV variables.
  - `snum()`: Force set the VENV Sequence number.
  - `vpfx()`: Return the current VENV prefix.
  - `vnum()`: Return the current VENV sequence number.
  - `vdsc()`: Return the current VENV description.
  - `cact()`: Change active VENV.
  - `dact()`: Deactivate the current VENV.
  - `pact()`: Switch to the Previous Active VENV.
  - `lenv()`: List All Current VENVs.
  - `lastenv()`: Retrieve the Last Environment with a Given Prefix.
  - `benv()`: Create a New Base Virtual Environment.
  - `nenv()`: Create a New Virtual Environment in a Series.
  - `vren()`: Rename a Virtual Environment
#
## Usage Example
  ```shellscript
  source venv_lib.sh
  benv myenv
  cact myenv
  ```
#
## Dependencies
  - This script depends on the `conda` command-line tool for managing virtual environments.
  - The `util_funcs.sh` script is also required and should be located in the same directory as this script.
#
## Notes
  - This script assumes that the `conda` command is available in the system's PATH.
  - It is recommended to source this script in other scripts rather than executing it directly.
  - Make sure to set the appropriate permissions on this script to allow execution.
#
## Author
  - Michael Sullivan <unixwzrd@unixwzrd.ai>
  - https://unixwzrd.ai/
  - https://github.com/unixwzrd
  - https://github.com/unixwzrd/venvutil
#



## Defined in Script

* [venv_lib.sh](../venv_lib_sh.md)
---

Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

Generated Markdown Documentation
Generated on: 2025-04-07 at 14:15:53
