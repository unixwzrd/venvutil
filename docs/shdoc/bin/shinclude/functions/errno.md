Function: errno
Provides POSIX errno codes and values for use in scripts or lookup of error codes on th ecommand line.
Description: This function takes an errno code or errno number and prints the corresponding error message to STDOUT. Sets the exit code to the errno value and returns, unless there is an internal error.
Usage: errno [errno_code|errno_number]
Example: errno EACCES
Returns: "error_code: error_text"
Errors: 2, 22
  2: Could not find system errno.h
 22: Invalid errno name

