## benv
# Function: benv
`benv` - Create a New Base Virtual Environment.
## Description
- **Purpose**: 
  - Creates a new base conda virtual environment and activates it.
- **Usage**: 
  - `benv [-h] ENV_NAME [EXTRA_OPTIONS]`
- **Options**: 
  - `-h`   Show this help message
- **Input Parameters**: 
  - `ENV_NAME` (string) - The name of the new environment to create.
  - `EXTRA_OPTIONS` (string, optional) - Additional options to pass to `conda create`.
- ** Examples**: 
  - `benv pa1`
  - `benv pa1 -c conda-forge`
  - `benv pa1 python=3.11`
- **Output**: 
  - Creates and activates the new environment.
- **Exceptions**: 
  - Errors during environment creation are handled by conda.

## Definition 

* [venv_lib.sh](../venv_lib_sh.md)
---

Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

Generated Markdown Documentation
Generated on: 2025-02-06 at 19:22:37
