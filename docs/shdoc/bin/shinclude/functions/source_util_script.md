## source_util_script
# Function: source_util_script
 `source_util_script` - Sources a utility script from the specified directory.
## Description
- **Purpose**: 
  - Sources a utility script from the specified directory. It's a helper function used within the `init_env.sh` script to modularly load additional scripts as needed.
- **Usage**: 
  - `source_util_script "script_name"`
- **Input Parameters**: 
  - `script_name`: The name of the script to source (without the `.sh` extension).
- **Output**: 
  - Sources the specified script if found. Otherwise, outputs an error message and returns with an exit code of 1.
- **Exceptions**: 
  - Returns with exit code 1 if the specified script is not found in the directory `__VENV_INCLUDE`.
## Definition
* [init_env.sh](/docs/shdoc/bin/shinclude/init_env_sh.md)

---
Generated Markdown Documentation
Generated on:Generated: 2024 12 08 at 06:13:13
