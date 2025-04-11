## ccln
# Function: ccln
`ccln` - Clone current Virtual Environment
## Description
- **Purpose**: 
  - Clones the current Virtual Environment to a new environment. It will
    increment the sequence number if it is not already set. If there is no
    sequence number, none will be added and the new environment will be named
    the new environment will have the specified name.
- **Usage**: 
  - `ccln [-h] [new_env_name]`
- **Options**: 
  - `-h`   Show this help message
  - `-x`   Enable debug mode
- **Input Parameters**: 
  - `new_env_name` (string) - The name of the new cloned environment.
- **Output**: 
  - Creates a clone of the specified environment.
- **Exceptions**: 
  - Errors if the source environment does not exist.

## Defined in Script

* [venv_lib.sh](../venv_lib_sh.md)
Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

---

Generated Markdown Documentation
Generated on: 2025-04-11 at 06:03:53
