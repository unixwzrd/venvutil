# Documentation Generation

Ok, we have a lot of problems,

- that change did not fix parsing which is now very broken.
- the directories written to should be:
  - BASE_DORdocs/shdoc/bin
     Contains the head/top markdown documentation for each script in the bin directory. 
  - BASE_DORdocs/shdoc/bin/[scriptname]
     Contains the function markdown documentation for the functions in that script.
  - BASE_DORdocs/shdoc/bin/shinclude/
     Contains the head/top markdown documentation foe the scripts in the  bin/shinclude directory
  - BASE_DORdocs/shdoc/bin/shinclude/[scriptname]
     ONtains the function documentation for the functions in the script.

Script documentation begins at the first `#` after the `#!` until the first blank line or non-comment `#` line.
- example
```bash
#1/usr/bin/env bash
# Script: help_sys.sh
# `help_sys.sh` - Help System Functions for Bash Scripts
# ## Description
# - **Purpose**:
# - **Usage**:
# - **Input Parameters**:   
# - **Output**:
# - **Exceptions**:

# Capture the fully qualified path of the sourced script
[ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
```

Function documentation is from the end of the previous function to the continuous lines preceded by `#`  up to the function definition.
- example
```bash
    esac
    echo "$(zero_pad ${sn})"
}



# # Function: sort_2d_array
# `sort_2d_array` - Sort a Two-Dimensional Array
#
# ## Description
# - **Purpose**:
#   - Sorts a two-dimensional array in Bash. It's particularly useful for organizing data that is stored in a format of paired elements.
# - **Usage**: 
#   - This function can be used to sort arrays where each element consists of a pair of values (e.g., key-value pairs). It's beneficial in scenarios where data needs to be sorted based on one of the dimensions.
# - **Input Parameters**: 
#   - `array_name`: The name of the array variable that needs to be sorted.
# - **Output**: 
#   - The original array sorted based on the specified criteria.
# - **Exceptions**: 
#   - Handles exceptions or errors that may arise during the sorting process (to be detailed based on function's implementation).
#
sort_2d_array() {
```

We need to strip off the leading `# ` and then the remaining portion of the line should be in markdown format.

There is one markdown file per script and one markdown file per function organized in the directory structure as above.