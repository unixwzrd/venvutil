## benv
# Function: benv
`benv` - Create a New Base Virtual Environment.
## Description
- **Purpose**: 
  - Creates a new base conda virtual environment and activates it.
- **Usage**: 
  - `benv ENV_NAME [EXTRA_OPTIONS]`
- **Input Parameters**: 
  - `ENV_NAME` (string) - The name of the new environment to create.
  - `EXTRA_OPTIONS` (string, optional) - Additional options to pass to `conda create`.
- **Output**: 
  - Creates and activates the new environment.
- **Exceptions**: 
  - Errors during environment creation are handled by conda.

