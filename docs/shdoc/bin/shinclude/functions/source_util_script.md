## source_util_script
# Function: source_util_script
 `source_util_script` - Sources a utility script from the specified directory.
## Description
- **Purpose**: 
  - Sources a utility script from the specified directory. It's a helper function used within the
   `init_env.sh` script to modularity load additional scripts as needed.
- **Usage**: 
  - `source_util_script "script_name"`
- **Input Parameters**: 
  - `script_name`: The name of the script to source (without the `.sh` extension).
- **Output**: 
  - Sources the specified script if found. Otherwise, outputs an error message and returns with
    an exit code of 1.
- **Exceptions**: 
  - Returns with exit code 1 if the specified script is not found in the directory `__VENV_INCLUDE`.

## Definition 

* [init_env.sh](../init_env_sh.md)
---

Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2024 Michael Sullivan
Apache License, Version 2.0

Generated Markdown Documentation
Generated on: Generated: 2025 01 03 at 02:39:55
