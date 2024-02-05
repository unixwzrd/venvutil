snum - Force set the VENV Sequence number.
- **Purpose**:
  - Force set the VENV Sequence number.
- **Usage**: 
  - snum NN
- **Input Parameters**: 
  1. `NN` (integer) - The VENV Sequence number to set. Must be a numeric value between 00 and 99.
- **Output**: 
  - Sets the global variable `__VENV_NUM` to the zero-padded sequence number.
  - Prints an error message to STDERR and returns with status code 1 if unsuccessful.
- **Exceptions**: None

