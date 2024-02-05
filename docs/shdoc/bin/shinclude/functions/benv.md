benv - Create a New Base Virtual Environment
- **Purpose**:
  - Create a new base conda virtual environment and activate it.
- **Usage**: 
  - benv ENV_NAME [EXTRA_OPTIONS]
- **Input Parameters**: 
  1. `ENV_NAME` (string) - The name of the new environment to create.
  2. `EXTRA_OPTIONS` (string, optional) - Additional options to pass to `conda create`.
- **Output**: 
  - Creates and activates the new environment.
- **Exceptions**: 
  - Errors during environment creation are handled by conda.

