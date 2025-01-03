## ccln
# Function: clan
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
- **Input Parameters**: 
  - `new_env_name` (string) - The name of the new cloned environment.
- **Output**: 
  - Creates a clone of the specified environment.
- **Exceptions**: 
  - Errors if the source environment does not exist.

## Definition 

* [venv_funcs.sh](../venv_funcs_sh.md)
---

Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2024 Michael Sullivan
Apache License, Version 2.0

Generated Markdown Documentation
Generated on: Generated: 2025 01 03 at 02:39:55
