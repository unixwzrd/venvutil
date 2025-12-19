## nenv
# Function: nenv
`nenv` - Create a New Virtual Environment in a Series.
## Description
- **Purpose**: 
  - Creates a new conda virtual environment in a series identified by a prefix as a clone of the current venv.
- **Usage**: 
  - `nenv [-h] PREFIX [EXTRA_OPTIONS]`
- **Options**: 
  - `-h`   Show this help message
  - `-x`   Enable debug mode
- **Input Parameters**: 
  - `PREFIX` (string) - The prefix to identify the series of environments.
  - `EXTRA_OPTIONS` (string, optional) - Additional options to pass to the environment creation.
- **Output**: 
  - Creates and activates the new environment with sequence number "00".
- **Exceptions**: 
  - Errors during environment creation are handled by conda.

## Defined in Script

* [venv_lib.sh](../venv_lib_sh.md)
Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

---

Generated Markdown Documentation
Generated on: 2025-12-19 at 09:37:18
