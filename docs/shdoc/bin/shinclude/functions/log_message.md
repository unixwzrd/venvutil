## log_message
 `log_message` - Prints a message to STDERR based on the provided log level.
## Description
- **Purpose**: 
  - Prints a message to STDERR if the provided log level is greater than or equal to the current debug level.
- **Usage**: 
  - `log_message <log_level> <message>`
- **Input Parameters**: 
  - `log_level`: The log level to check against the debug level. Supported log levels are:
    - `TRACE`
    - `DEBUG8`-`DEBUG0`
    - `DEBUG`
    - `INFO`
    - `WARNING`
    - `ERROR`
    - `CRITICAL`
    - `SILENT`
  - `message`: The message to print if the log level is greater than or equal to the current debug level.
- **Output**: 
  - Prints a message to STDERR if the provided log level is greater than or equal to the current debug level.

## Defniition 

* [errno.sh](/bin/shinclude/errno.sh/errno_sh.md)


---

Generated Markdown Documentation

Generated on:Generated: 2024 12 09 at 18:36:57
