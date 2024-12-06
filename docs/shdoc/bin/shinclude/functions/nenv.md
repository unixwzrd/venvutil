## nenv
# Function: nenv
`nenv` - Create a New Virtual Environment in a Series.
## Description
- **Purpose**: 
  - Creates a new conda virtual environment in a series identified by a prefix as a clone of the current venv.
- **Usage**: 
  - `nenv PREFIX [EXTRA_OPTIONS]`
- **Input Parameters**: 
  - `PREFIX` (string) - The prefix to identify the series of environments.
  - `EXTRA_OPTIONS` (string, optional) - Additional options to pass to the environment creation.
- **Output**: 
  - Creates and activates the new environment with sequence number "00".
- **Exceptions**: 
  - Errors during environment creation are handled by conda.

