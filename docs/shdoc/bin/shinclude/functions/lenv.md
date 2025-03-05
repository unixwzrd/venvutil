## lenv
# Function: lenv
`lenv` - List All Current VENVs with last modification date.
## Description
- **Purpose**: 
  - Lists all the currently available conda virtual environments in alphabetical order with
    their last modification date.
  - Options are available to sort by last update time from oldest to newest.
  - Options are available to reverse the sort order for either time or name.
- **Usage**: 
  - `lenv [[-l] [-t] [-r] [-h]]`
- **Options**: 
      - `-l`   Display last modification date and time
      - `-t`   Sort by last update time
      - `-r`   Reverse the sort order
      - `-h`   Show this help message
      - `-x`   Enable debug mode
- **Output**: 
  - A list of all existing conda virtual environments with their last modification date.
  - The active environment is marked with an asterisk.
  ```bash
  2024-11-30    pa1                                  ~/miniconda3/envs/pa1
  2024-11-30    pa1..base-3-10                     * ~/miniconda3/envs/pa1..base-3-10
  2024-11-30    seq311.00.case-analytics             ~/miniconda3/envs/seq311.00.case-analytics
  2024-12-05    pa1.00.case-analytics                ~/miniconda3/envs/pa1.00.case-analytics
  ```
- **Exceptions**: 
  - If no environments are available, the output from `conda info -e` will indicate this.

## Definition 

* [venv_lib.sh](../venv_lib_sh.md)
---

Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

Generated Markdown Documentation
Generated on: 2025-03-05 at 12:30:57
