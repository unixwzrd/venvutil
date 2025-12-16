## handle_variable
# Function: handle_variable
`handle_variable` - Manage variable assignments based on predefined actions
## Description
- **Purpose**:
  - Controls how variables are assigned based on a predefined action table.
  - Supports merging, setting, preserving config values, or discarding changes.
- **Usage**:
  - `handle_variable "var_name" "value_ref"`
- **Input Parameters**:
  - `var_name`: The name of the variable to handle.
  - `value_ref`: Name reference to the value to potentially assign.
- **Output**:
  - None. Modifies the target variable according to its action rule.
- **Exceptions**:
  - Exits with code 2 if the action for the variable is unknown.
- **Required Global Variables**:
  - `var_actions`: Associative array mapping variable names to actions:
    - "merge": Combines existing value with new value
    - "set": Uses the new value
    - "config": Preserves the config file value
    - "discard": Keeps the original value

## Defined in Script

* [type_lib.sh](../type_lib_sh.md)
Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

---

Generated Markdown Documentation
Generated on: 2025-12-16 at 09:52:55
