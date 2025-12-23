## venv_operation_log
# Function: venv_operation_log
`venv_operation_log` - Logs the details of a virtual environment operation.
## Description
- **Purpose**:
  - Writes detailed log entries for a virtual environment operation to both a venv-specific log file and a global venvutil log.
- **Usage**:
  - `venv_operation_log [status] [log_date] [venv_name] [freeze_state] [cmd] [command_line]`
- **Input Parameters**:
  - `status` (integer) - The exit status of the command.
  - `log_date` (string) - The timestamp for the log entry.
  - `venv_name` (string) - The name of the target virtual environment.
  - `freeze_state` (string) - The path to the pip freeze output file.
  - `cmd` (string) - The base command executed (e.g., 'pip', 'conda').
  - `command_line` (string) - The full command line that was run.
- **Output**:
  - None (writes to log files).
- **Exceptions**:
  - None

## Defined in Script

* [wrapper_lib.sh](../wrapper_lib_sh.md)
Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

---

Generated Markdown Documentation
Generated on: 2025-12-19 at 09:26:19
