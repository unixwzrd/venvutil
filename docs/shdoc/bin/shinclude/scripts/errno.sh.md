# Script: errno.sh
`errno.sh` - Provides POSIX errno codes and utilities for Bash scripts
## Description
- **Purpose**:
  - Offers functions to retrieve and manage POSIX error codes within Bash scripts.
- **Usage**:
  - Source this script in your Bash scripts to utilize error code utilities.
    ```bash
    source /path/to/errno.sh
    ```
- **Input Parameters**:
  - None.
- **Output**:
  - Functions that output error codes and messages.
- **Exceptions**:
  - Returns specific error codes if system `errno.h` is not found or invalid errno codes are provided.
- **Initialization**:
  - Ensures the script is sourced only once and initializes necessary variables.
#
## Dependencies
- `util_funcs.sh` (for utility functions like `to_upper`)



## Function Defniitions

* [errno.sh](/bin/shinclude/errno_sh.md)


---

Generated Markdown Documentation

Generated on:Generated: 2024 12 09 at 18:36:57
