# # Function: Function Name
#  `function_name` - brief description of the function
# ## Description
# - **Purpose**: 
# - **Usage**: 
# - **Input Parameters**: 
# - **Output**: 
# - **Exceptions**: 
# 
# ## Dependencies
# - List of dependencies
# 
# ## Return Value
# - Description of the return value, if any
# 
# ## Examples
# ```bash
# # Example usage of the function
# ```
# 
# ## Version
# - Version details
# 


# Example
The documentation should be written in markdown and then each line should be proceeded by a `# ` to comment the script and then be removed by the help_sys functions to generate the markdown documentation for the system. This is an example from the errno.sh script errno function with the leading `# ` removed.


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
