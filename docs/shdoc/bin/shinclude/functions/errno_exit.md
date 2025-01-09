## errno_exit
# Function: errno_exit
 `errno_exit` - Prints an error to STDERR using the errno function and exits with the error number.
## Description
- **Purpose**: 
  - Prints an error message to STDERR using the `errno` function and exits the script with the corresponding error number.
    You may use the POSIX error code or the error number.
- **Usage**: 
  - `errno_exit <errno_code>`
- **Example**:
  - `errno_exit EACCES`
  - `errno_exit 13`
- **Input Parameters**: 
  - `errno_code`: The errno code to generate an error for.
- **Output**: 
  - Outputs an error message to STDERR with caller info including:
    - Function name that called errno_exit
    - Line number where errno_exit was called
    - Source file where errno_exit was called
    - Function name that called the function that called errno_exit
    - Line number where that function was called
    - Source file containing that function call
- **Exceptions**: 
  - Exits the script with the provided error number.

## Definition 

* [errno.sh](../errno_sh.md)
---

Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2024 Michael Sullivan
Apache License, Version 2.0

Generated Markdown Documentation
Generated on: Generated: 2025 01 09 at 10:30:15
