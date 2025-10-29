## errno_exit
# Function: errno_exit
 `errno_exit` - Prints an error message to STDERR and exits with the error number.
## Description
- **Purpose**: 
  - Prints an error message to STDERR using the provided error code and optional message.
  - Exits the script with the corresponding error number.
  - Accepts either POSIX error codes (e.g. EACCES) or error numbers (e.g. 13).
- **Usage**: 
  - `errno_exit <errno_code> [message]`
- **Example**:
  - `errno_exit EACCES "Failed to access file"`
  - `errno_exit 13 "Permission denied"`
- **Input Parameters**: 
  - `errno_code`: The error code to use (POSIX name or number)
  - `message`: (Optional) Additional message to include in the error
- **Output**: 
  - Prints error messages to STDERR including:
    - Optional custom message if provided
    - Call stack trace with function name, line number and file
    - Error message corresponding to the error code
- **Exit Status**: 
  - Exits with the numeric error code

## Defined in Script

* [errno_lib.sh](../errno_lib_sh.md)
Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

---

Generated Markdown Documentation
Generated on: 2025-10-29 at 03:59:09
