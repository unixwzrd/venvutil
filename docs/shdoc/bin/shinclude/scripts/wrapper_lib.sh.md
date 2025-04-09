# Script: wrapper_lib.sh
`wrapper_lib.sh` - Python Package Manager Wrapper Functions
## Description
- **Purpose**:
  - Provides enhanced functionality for managing Python package commands by wrapping pip and conda.
  - Intercepts and logs changes to virtual environments for rollback, auditing, and future use in venvdiff or vdiff.
## Usage
  - Source this script in your command line environment to import the wrapper functions.
  - For example, in another script: `source wrapper_lib.sh`.
## Features
  - Saves a `pip freeze` before any potentially destructive changes to a virtual environment.
  - Logs the complete command line to a log file for both conda and pip.
  - Persists logs in the `$HOME/.venvutil` directory, even after virtual environments are deleted.
## Dependencies
  - Requires Bash and the Python package managers pip and conda.
## Exceptions
  - Some functions may return specific error codes or print error messages to STDERR.
  - Refer to individual function documentation for details.



## Defined in Script

* [wrapper_lib.sh](../wrapper_lib_sh.md)
---

Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

Generated Markdown Documentation
Generated on: 2025-04-09 at 11:04:19
