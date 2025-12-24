## load_config
# Function: load_config
`load_config` - Loads package configuration from setup.cf file.
## Description
- **Purpose**:
  - This function reads the setup.cf file and sets variables for package installation.
- **Usage**:
  - `load_config <config_file> <var_actions>`
- **Input Parameters**:
  - `config_file`: The path to the configuration file.
  - `var_actions`: The associative array of variable actions.
- **Output**:
  - Sets variables from the setup.cf file for package installation.
- **Exceptions**:
  - Returns specific error codes if the setup.cf file is not found or invalid.
- **Examples** setup.cf file:
    ```  
    # Package Configuration File for venvutil
    ## Define variables
    prefix=$HOME/local/venvutil
    exec_prefix=${prefix}
    libdir=${exec_prefix}/lib
    includedir=${prefix}/include
    bindir=${exec_prefix}/bin
    datadir=${prefix}/share
    sysconfdir=${prefix}/etc
    include_dirs=("bin" "docs" "conf")
    include_files=("README.md" "LICENSE" "setup.sh" "setup.cf" "manifest.lst")
    # Package metadata
    Name: venvutil
    Description: Virtual Environment Utilities
    Version: 0.4.0
    Repository: https://github.com/unixwzrd/venvutil
    License: Apache License, Version 2.0
    Support: https://github.com/unixwzrd/venvutil/issues
    Contribute: https://patreon.com/unixwzrd
    Contribute: https://www.ko-fi.com/unixwzrd
    # Dependencies (if any)
    Requires: python >= 3.10
    Requires: bash >= 4.0
    Requires: Conda >= 22.11
    Requires: macOS
    Requires: Linux
    Conflicts:
    # Compiler and linker flags (if applicable)
    # Cflags: -I${includedir}
    # Libs: -L${libdir} -lvenvutil
    ```

## Defined in Script

* [config_lib.sh](../config_lib_sh.md)
Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

---

Generated Markdown Documentation
Generated on: 2025-12-24 at 07:50:31
