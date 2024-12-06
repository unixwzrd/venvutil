## errno_warn
# Function: errno_warn
 `errno_warn` - Prints a warning using the errno function to STDERR and returns the error number.
## Description
- **Purpose**: 
  - Prints a warning message to STDERR using the `errno` function and sets the return code. It will report the error without exiting the script.
- **Usage**: 
  - `errno_warn <errno_code>`
- **Input Parameters**: 
  - `errno_code`: The errno code to generate a warning for.
- **Output**: 
  - Outputs a warning message to STDERR.
- **Exceptions**: 
  - Returns the error number associated with the provided errno code.

