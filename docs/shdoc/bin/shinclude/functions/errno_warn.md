## errno_warn
# Function: errno_warn
 `errno_warn` - Prints a warning using the errno function to STDERR and returns the error number.
## Description
- **Purpose**: 
  - Prints a warning message to STDERR using the `errno` function and sets the return code. It
    will report the error without exiting the script. You may use the POSIX error code or the 
    error number.
- **Usage**: 
  - `errno_warn <errno_code>`
- **Example**:
  - `errno_warn EACCES`
  - `errno_warn 13`
- **Input Parameters**: 
  - `errno_code`: The errno code to generate a warning for.
- **Output**: 
  - Outputs a warning message to STDERR with caller info including:
    - Function name that called errno_warn
    - Line number where errno_warn was called
    - Source file where errno_warn was called
    - Function name that called the function that called errno_warn
    - Line number where that function was called
    - Source file containing that function call
- **Exceptions**: 
  - Returns the error number associated with the provided errno code.

## Definition 

* [errno.sh](../errno_sh.md)
---

Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2024 Michael Sullivan
Apache License, Version 2.0

Generated Markdown Documentation
Generated on: Generated: 2024 12 29 at 04:28:17
