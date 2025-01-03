## errval
# Function: errval
`errval` - Returns the numeric value associated with a log level.
## Description
- **Purpose**: 
  - Converts a text log level (like "DEBUG", "INFO", etc.) to its corresponding numeric value.
  - Used internally to compare log levels for filtering messages.
- **Usage**: 
  - `errval <log_level>`
- **Input Parameters**: 
  - `log_level`: The text log level to convert. Supported values:
    - DEBUG0-DEBUG9: Values 9-1 respectively
    - DEBUG: Value 10
    - INFO: Value 20
    - WARNING/WARN: Value 30 
    - ERROR: Value 40
    - CRITICAL: Value 50
    - SILENT: Value 99
- **Output**: 
  - Returns the numeric value corresponding to the provided log level.
- **Exceptions**: 
  - Returns empty if an invalid log level is provided.

## Definition 

* [errno.sh](../errno_sh.md)
---

Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2024 Michael Sullivan
Apache License, Version 2.0

Generated Markdown Documentation
Generated on: Generated: 2025 01 03 at 02:39:54
