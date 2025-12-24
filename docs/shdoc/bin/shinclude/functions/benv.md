## benv
# Function: benv
`benv` - Create a New Base Virtual Environment.
## Description
- **Purpose**: 
  - Creates a new base conda virtual environment and activates it.
  - If no packages specified, creates environment with latest Python and pip.
- **Usage**: 
  - `benv [-h] ENV_NAME [PACKAGES...] [OPTIONS...]
- **Options**: 
  - `-h`   Show this help message
  - `-x`   Enable debug mode
- **Input Parameters**: 
  - `ENV_NAME` (string) - The name of the new environment to create.
  - `PACKAGES` (string, optional) - Packages to install. Defaults to latest Python and pip.
  - `OPTIONS` (string, optional) - Additional options to pass to `conda create`.
- ** Examples**: 
  - `benv pa1` - Creates env with latest Python and pip
  - `benv pa1 python=3.11 numpy pandas` - Creates env with specific packages
  - `benv pa1 -c conda-forge python=3.11` - Uses conda-forge channel
- **Output**: 
  - Creates and activates the new environment.
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
Generated on: 2025-12-24 at 06:14:04
