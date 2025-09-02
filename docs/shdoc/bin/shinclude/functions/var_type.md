## var_type
# Function: var_type
`var_type` - Get the Type of a Variable
## Description
- **Purpose**:
  - Retrieves the type of a variable.
- **Usage**:
  - `var_type [-h] "var_name"`
- **Options**:
  - `-h`   Show this help message
- **Examples**:
  - `var_type "my_variable"`
  - `var_type=$(var_type "my_variable")
- **Input Parameters**:
  - `var_name`: The name of the variable.
- **Output**:
  - The type of the variable as a string. Can be one of `array`, `associative`, `scalar`, or `unknown`.
- **Exceptions**:
  - None.

## Defined in Script

* [type_lib.sh](../type_lib_sh.md)
Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

---

Generated Markdown Documentation
Generated on: 2025-09-02 at 16:56:56
