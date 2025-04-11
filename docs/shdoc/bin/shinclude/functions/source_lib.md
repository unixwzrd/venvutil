## source_lib
# Function: source_lib
 `source_lib` - Sources a utility script from the specified directory.
## Description
- **Purpose**: 
  - Sources a utility script from the specified directory. It's a helper function used within the
   `init_env.sh` script to modularity load additional scripts as needed.
  - Try to locate the SH_LIB directory which contains included scripts and functions in a
    "standard" fashion. places we could look are, in this order:
    - $(dirname "${THIS_SCRIPT}")
    - $(dirname "${THIS_SCRIPT}")/shinclude
    - $HOME/shinclude
    - $HOME/bin directory
    - $HOME/bin/shinclude directory
    - from the environment variable `SH_LIB`
- **Usage**: 
  - `source_lib "script_name"`
- **Input Parameters**: 
  - `script_name`: The name of the script to source (without the `.sh` extension).
- **Output**: 
  - Sources the specified script if found. Otherwise, outputs an error message and returns with
    an exit code of 1.
- **Exceptions**: 
  - Returns with exit code 1 if the specified script is not found in the directory `__VENV_INCLUDE`.

## Defined in Script

* [init_lib.sh](../init_lib_sh.md)
Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

---

Generated Markdown Documentation
Generated on: 2025-04-11 at 05:57:56
