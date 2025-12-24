# Script: helpsys_lib.sh
`helpsys_lib.sh` - Help System Functions for Bash Scripts
## Description
- **Purpose**: 
  - Provides a dynamic help system for all sourced bash scripts.
  - It can list available functions, provide detailed information about each function, and list sourced scripts.
 ## Usage
  - Source this script in other bash scripts to enable the dynamic help system.
    ```bash
    source helpsys_lib.sh
    ```
## Input Parameters
  - None. All input is handled by the individual functions.
## Output
  - Enables a help system that can be accessed by calling `help` in the terminal.
  - Supports generating Markdown documentation.
## Exceptions
  - Some functions may return specific error codes or print error messages to STDERR.
  - Refer to individual function documentation for details.
## Environment
  - **MD_PROCESSOR**: Set to the markdown processor of your choice. If `glow` is in your path, it will use that.



## Script Documentation

* [helpsys_lib.sh](../helpsys_lib_sh.md)
Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

---

Generated Markdown Documentation
Generated on: 2025-12-24 at 06:14:02
