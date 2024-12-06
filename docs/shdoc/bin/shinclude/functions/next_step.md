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

