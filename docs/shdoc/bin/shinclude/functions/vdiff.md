## vdiff
# Function: vdiff
`vdiff` - Compare virtual environment package lists.
## Description
- **Purpose**: 
  - Compares package lists between conda virtual environments.
  - With one argument, compares the currently active environment to the named environment.
  - With two arguments, compares the first environment to the second.
- **Usage**: 
  - `vdiff [-h] [other_env]`
  - `vdiff [-h] env1 env2`
- **Options**: 
  - `-h`   Show this help message
  - `-x`   Enable debug mode
- **Input Parameters**: 
  - `other_env` (string, optional) - Environment to compare against the active one.
  - `env1` (string, optional) - First environment when comparing two named environments.
  - `env2` (string, optional) - Second environment when comparing two named environments.
- **Output**: 
  - Side-by-side diff of normalized, sorted `name==version` lines from each environment.
  - Matching package names align on the same row; version differences appear together.
- **Exceptions**: 
  - Errors if no active environment is set when only one name is supplied.
  - Errors if either environment does not exist.

## Defined in Script

* [venv_lib.sh](../venv_lib_sh.md)
Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

---

Generated Markdown Documentation
Generated on: 2026-07-19 at 05:18:04
