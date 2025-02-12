## next_step
# Function: next_step
`next_step` - Increment a Given Sequence Number by 1 and Pad it with a Zero if Needed
## Description
- **Purpose**:
  - Increments a given sequence number by 1 and pads it with a zero if necessary.
- **Usage**: 
  - `next_step "09"`
- **Scope**: 
  - Local. Modifies no global variables.
- **Input Parameters**: 
  1. `sequenceNum` (integer) - The sequence number to increment. Must be between 00 and 99.
- **Output**: 
  - The next sequence number as a string, zero-padded if necessary.
- **Exceptions**: 
  - Returns an error code 22 if the sequence number is not between 00 and 99. Error 22 means "Invalid Argument".

## Definition 

* [util_lib.sh](../util_lib_sh.md)
---

Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

Generated Markdown Documentation
Generated on: 2025-02-12 at 06:10:02
