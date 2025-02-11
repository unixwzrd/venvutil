# Documentation and Naming Conventions for Bash Scripts

## Documentation

### Script-Level Documentation

At the top of each script, include a Markdown-formatted comment block that outlines:

A template for [Script Documentation Style](/doc/Script_Doc_Templ.md) is found here.

- **Purpose**: What the script is intended for.
- **Usage**: How to use the script.
- **Input Parameters**: Any parameters or environment variables needed.
- **Output**: What the script will output or modify.
- **Exceptions**: Any errors the script can throw or reasons it might fail.
- **Initialization**: All scripts, even included ones in the project should include the following lines at the beginning for proper operation.

    ```bash
    ## Initialization
    [ -L "${BASH_SOURCE[0]}" ] && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}") || THIS_SCRIPT="${BASH_SOURCE[0]}"
    # shellcheck disable=SC2034
    MY_NAME=$(basename "${THIS_SCRIPT}")
    __VENV_BIN=$(dirname "$(dirname "${THIS_SCRIPT}")")
    __VENV_BASE=$(dirname "${__VENV_BIN}")
    __VENV_INCLUDE="${__VENV_BASE}/bin/shinclude"

    # Get the init_lib.sh script
    # shellcheck source=/dev/null
    source "${__VENV_INCLUDE}/init_lib.sh"

    # Get the errno_lib.sh script
    source_lib errno_lib

    __rc__=0
    return ${__rc__}
    ```

### Function-Level Documentation

Each function should also have a Markdown-formatted comment block with similar information:

A template for [Function Documentation Style](/doc/Function_Doc_Templ.md) is found here.

- **Purpose**: What the function does.
- **Usage**: How to use the function.
- **Input Parameters**: Any parameters the function takes.
- **Output**: What the function will return or modify.
- **Exceptions**: Any errors the function can throw.

## Naming Conventions

### Variables

- **Locally Scoped Variables**: Use lowercase with underscores to separate words.  
  Example: `local_variable_name`
  
- **Global Variables**: Use UPPERCASE with underscores to separate words.  
  Example: `__PREFIX_GLOBAL_VARIABLE_NAME`
  
- **System Prefix Variables**: Use a prefix followed by the variable name, separated by an underscore.  
  Example: `__PREFIX_VARIABLE_NAME`
