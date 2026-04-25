## vpmg
# Function: vpmg
`vpmg` - Migrate the active virtual environment to a different Python version.
## Description
- **Purpose**:
  - Rebuilds the currently active conda virtual environment with a requested Python version.
  - Captures the installed pip package names, renames the current environment to a backup name,
    recreates the original environment with the requested Python version, and reinstalls the
    captured packages into the rebuilt environment.
  - By default, removes the backup environment after the migration succeeds.
- **Usage**:
  - `vpmg -v VERSION [-p]`
- **Options**:
  - `-v VERSION`  Python version to install in the rebuilt environment, such as `3.12`.
  - `-p`          Preserve the backup environment after a successful migration.
  - `-h`          Show this help message.
  - `-x`          Enable debug mode.
- **Input Parameters**:
  - None. The command operates on the currently active conda environment.
- **Output**:
  - Recreates the active environment with the requested Python version and reinstalls pip packages.
  - Creates a temporary backup environment named `<current_env>_bak` during the migration.
- **Exceptions**:
  - Returns `EINVAL` if no conda environment is active or no Python version is supplied.
  - Restores the backup environment name if environment creation or package installation fails.

## Defined in Script

* [venv_lib.sh](../venv_lib_sh.md)
Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

---

Generated Markdown Documentation
Generated on: 2026-04-25 at 12:54:17
