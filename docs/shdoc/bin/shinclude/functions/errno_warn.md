## errno_warn
# Function: errno_warn
 `errno_warn` - Prints a warning message to STDERR and returns the error number.
## Description
- **Purpose**: 
  - Prints a warning message to STDERR using the provided error code and optional message.
  - Sets the return code but does not exit the script.
  - Accepts either POSIX error codes (e.g. EACCES) or error numbers (e.g. 13).
- **Usage**: 
  - `errno_warn <errno_code> [message]`
- **Example**:
  - `errno_warn EACCES "Failed to access file"`
  - `errno_warn 13 "Permission denied"`
- **Input Parameters**: 
  - `errno_code`: The error code to use (POSIX name or number)
  - `message`: (Optional) Additional message to include in the warning
- **Output**: 
  - Prints warning messages to STDERR including:
    - Optional custom message if provided
    - Call stack trace with function name, line number and file
    - Error message corresponding to the error code
- **Return Value**: 
  - Returns the numeric error code

## Definition 

* [errno_lib.sh](../errno_lib_sh.md)
---

Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

Generated Markdown Documentation
Generated on: 2025-02-06 at 19:38:18
