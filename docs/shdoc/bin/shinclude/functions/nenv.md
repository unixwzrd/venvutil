nenv - Create a New Virtual Environment in a Series
- **Purpose**:
  - Create a new conda virtual environment in a series identified by a prefix as a clone of the current venv. Resets and starts the sequence number from "00".
- **Usage**: 
  - nenv PREFIX [EXTRA_OPTIONS]
- **Input Parameters**: 
  1. `PREFIX` (string) - The prefix to identify the series of environments.
  2. `EXTRA_OPTIONS` (string, optional) - Additional options to pass to the environment creation.
- **Output**: 
  - Creates and activates the new environment with sequence number "00".
- **Exceptions**: 
  - Errors during environment creation are handled by conda.

