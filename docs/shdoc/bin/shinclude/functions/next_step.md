next_step - Increment a given sequence number by 1 and pad it with a zero if needed.
- **Purpose**:
  - Increment a given sequence number by 1 and pad it with a zero if needed.
- **Usage**: 
  - next_step "[0-99]"
- **Scope**: Local. Modifies no global variables.
- **Input Parameters**: 
  1. `sequenceNum` (integer) - The sequence number to increment. Must be between 00 and 99.
- **Output**: 
  - The next sequence number as a string, zero-padded if necessary.
- **Exceptions**: 
  - Returns an error code 22 if the sequence number is not between 00 and 99. Error 22 means "Invalid Argument".

