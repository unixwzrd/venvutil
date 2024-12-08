## lenv
# Function: lenv
`lenv` - List All Current VENVs with last modification date.
## Description
- **Purpose**: 
  - Lists all the currently available conda virtual environments with their last modification date.
- **Usage**: 
  - `lenv`
- **Input Parameters**: 
  - None
- **Output**: 
  - A list of all existing conda virtual environments with their last modification date.
  ```bash
  2024-11-30    pa1                                 ~/miniconda3/envs/pa1
  2024-11-30    pa1..base-3-10                      ~/miniconda3/envs/pa1..base-3-10
  2024-11-30    seq311.00.case-analitics            ~/miniconda3/envs/seq311.00.case-analitics
  2024-12-05    pa1.00.case-analytics               ~/miniconda3/envs/pa1.00.case-analytics
  ```
- **Exceptions**: 
  - If no environments are available, the output from `conda info -e` will indicate this.
## Definition
* [venv_funcs.sh](/docs/shdoc/bin/shinclude/venv_funcs_sh.md)

---
Generated Markdown Documentation
Generated on:Generated: 2024 12 08 at 06:13:13
