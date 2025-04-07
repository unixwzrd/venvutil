## sanitize
# Function: sanitize
`sanitize` - Removes every character not in the specified allowed set.
## Description
- **Purpose**:
  - Removes every character not in the specified allowed set.
- **Usage**:
  - `sanitized_value=$(sanitize "Hello? *" 'a-zA-Z0-9._*\- ')`
- **Input Parameters**:
  - `dirty_string`: The string to sanitize.
  - `allowed_chars`: The characters to keep in the string.
- **Output**:
  - The sanitized string.
- **Examples**:
  - `sanitize "Hello? *" 'a-zA-Z0-9._*\- '`
  - `sanitize "Hello? *" 'a-zA-Z0-9._*\- '`
- **Exceptions**:
  - None.

## Definition 

* [string_lib.sh](../string_lib_sh.md)
---

Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

Generated Markdown Documentation
Generated on: 2025-04-07 at 14:21:19
