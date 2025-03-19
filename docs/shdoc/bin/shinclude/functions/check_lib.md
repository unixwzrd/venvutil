## check_lib
TODO Figure out why this function does not work in the other lib scripts.
# Function: _source_check
`_source_check` - Guard against re-sourcing the same script
## Description
- **Purpose**: 
  - Prevents re-sourcing the same script multiple times.
- **Usage**: 
  - `_source_check "${BASH_SOURCE[0]}"`
- **Input Parameters**: 
  - `file_to_source`: The path to the script to source.
- **Output**: 
  - Returns 1 if the script has already been sourced, otherwise returns 0.
- **Exceptions**: 
  - None.

## Definition 

* [init_lib.sh](../init_lib_sh.md)
---

Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

Generated Markdown Documentation
Generated on: 2025-03-19 at 16:08:52
