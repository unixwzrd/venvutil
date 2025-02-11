## log_message
## Function: log_message
 `log_message` - Prints a message to STDERR based on the provided log level.
## Description
- **Purpose**: 
  - Prints a message to STDERR if the provided log level is greater than or equal to the current
    debug level. The lower the level, the more verbose the messages will be. 
- **Usage**: 
  - `log_message [-h] <log_level> <message>`
- **Options**: 
  - `-h`   Show this help message, though not usually used from the command line.
- **Input Parameters**: 
  - `log_level`: The log level to check against the debug level. Supported log levels are:
    - `TRACE`
    - `DEBUG10`-`DEBUG0`
    - `DEBUG`  - used as a synonym for DEBUG10
    - `INFO`
    - `WARNING`
    - `ERROR`
    - `CRITICAL`
    - `SILENT`
  - `message`: The message to print if the log level is greater than or equal to the current debug level.
- **Output**: 
  - Prints a message to STDERR if the provided log level is greater than or equal to the current debug level.

## Definition 

* [errno_lib.sh](../errno_lib_sh.md)
---

Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

Generated Markdown Documentation
Generated on: 2025-02-10 at 22:04:27
