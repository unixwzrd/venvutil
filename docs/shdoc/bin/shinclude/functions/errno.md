## errno
# Function: errno
 `errno` - Provides POSIX errno codes and values for use in scripts or lookup of error codes on the command line.
## Description
- **Purpose**: 
  - This function takes an errno code or errno number and prints the corresponding error message to STDOUT. Sets the exit code to the errno value and returns, unless there is an internal error.
- **Usage**: 
  - `errno [errno_code|errno_number]`
- **Input Parameters**: 
  - `errno_code|errno_number`: The errno code (e.g., EACCES) or number.
- **Output**: 
  - Outputs the error code and message in the format `(errno_code: errno_num): errno_text`.
- **Exceptions**: 
  - 2: Could not find system errno.h
  - 22: Invalid errno name

## Defniition 

* [errno.sh](../errno_sh.md)

---

Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutils](https://github.com/unixwzrd/venvutils)
Copyright (c) 2024 Michael Sullivan
Apache License, Version 2.0

Generated Markdown Documentation
Generated on: Generated: 2024 12 18 at 06:51:41
