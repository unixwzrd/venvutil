# Changelog

## 2024-12-08 - Documentation and Script Enhancements

- **General Updates**:
  - Updated script headers and descriptions across multiple scripts for consistency and clarity.
  - Improved logging and error handling in `errno.sh` and `help_sys.sh`.
  - Enhanced documentation for shell functions, ensuring detailed descriptions, usage, and examples.

- **Specific Changes**:
  - `venv_funcs.sh`: Enhanced virtual environment management functions with additional examples and usage scenarios.
  - `wrapper_funcs.sh`: Enhanced functionality for managing Python package commands by wrapping `pip` and `conda`.
    - Improved error checking and logging for `pip` and `conda` operations.
    - Added robust logging to track changes in virtual environments for rollback, auditing, and future use in `venvdiff`.
  - `util_funcs.sh`: Updated utility functions to streamline common tasks in Bash scripting.
  - `help_sys.sh`: Refined help system functions for better integration and user experience.
  - `errno.sh`: Improved POSIX errno codes and utilities with better error message formatting.

- **Markdown Documentation**:
  - Added new markdown files for function documentation, such as `errno.md`, `errfind.md`, and more.
  - Updated links in markdown files to use absolute paths for better navigation.

## 2024-12-06 - Latest Updates

- Refactored `genmd` script to streamline file tree generation and improve handling of debug levels.
- Added symlink following along with token counting for makedown bundles.
- Still minor config file issues to work out.
- Improved logging in `genmd` and `help_sys.sh` for better debugging and information tracking.
- Enhanced documentation for functions in markdown files, providing detailed descriptions, usage, input parameters, output, and exceptions.
- Deleted outdated markdown files: `venv.md` and `venv_funcs.md`.
- Added new markdown files for function documentation, such as `__venv_conda_check.md`, `create_readme.md`, etc.

## 2024-11-27 - Refactor and Update

- Refactored `wrapper_funcs.sh` to improve command argument handling and logging.
- Enhanced `setup.sh` with better comments, debug mode activation, and default package name changes.
- Updated `setup.sh` to set `PKG_NAME` with a default value of "DEFAULT" if not provided.
- Adjusted `INSTALL_CONFIG` assignment for consistency.

## 2024-11-26 - Setup Script and Manifest Updates

- Addressed issues in `setup.sh` script identified during testing on macOS and Linux.
- Improved logging verbosity and error handling in `setup.sh`.
- Updated `manifest.lst` to align with the latest setup configuration changes.

## 2024-11-25 - Documentation Completion

- Completed Markdown documentation for all functions in `venv_funcs.sh`.
- Updated the checklist in `.project-planning/doc-tasks/venv_funcs.md` to mark all functions as documented.
- Enhanced documentation process guidelines in `documentation_tasks.md` for better tracking and management.

## 2024-11-24 - Debugging and Stabilization

- Implemented global variable declarations in `genmd` for configuration and settings management.
- Introduced `handle_variable` function for robust variable handling in `genmd`.
- Enhanced logging in `filetree.py` to include program names and lazy formatting.
- Refactored functions in `genmd` for improved readability and maintainability.
- Conducted comprehensive testing to ensure stability and correctness of recent changes.

## 2024-11-24 - Setup Script Update

- **Setup Script Update**: Added functionality to create hard links in `setup.sh` to address issues with C++/G++/ld symlink handling.
- **Manifest Update**: Added support for hard link type in the installer manifest.
- **Compatibility Note**: Hard link creation feature tested on macOS and RedHat Linux.

## 2024-11-20 - Codebase Enhancements and Logging Improvements

- Refactored the `log_message` function in `errno.sh` to adjust logging levels in the `message_class` associative array for better log categorization.
- Enhanced the `ptree` function in `util_funcs.sh` for better terminal output handling by dynamically calculating effective width.
- Updated `filetree.py` to add logging functionality with a new command-line argument to set logging levels.
- Modified `genmd` to introduce a `create_date` configuration variable and improve pattern sanitization and filetree generation logic.

## 2024-11-20 - Successful Testing and Installation

- Completed testing and installation of the project.
- Verified that `generate_manifest.sh` and the installer work as expected.
- Rollback/remove functionality for the installer is pending as a low priority task.

## 2024-11-18 - Refactored Installer Script and Documentation Updates

- Refactored `vsetup.sh` for modularity and error handling.
- Introduced `pkg_info` function to manage package metadata.
- Added `check_return_code` function for error handling with rollback capability.
- Enhanced logging with `log_message` function for consistent message formatting.
- Updated `post_install` tasks to include directory creation, requirements installation, and PATH updates.
- Completed documentation review and updated `README.md` and `CHANGELOG.md`.
- Created a shell script to automate the Conda environment setup and package installation.
- Documented the manifest layout and parsing logic.

## 2024-11-17 - Updates to Wrapper Scripts

- Created `ld`, `g++`, and `c++` scripts to handle the `-Wl,--version` flag correctly for macOS, specifically Meson builds which pass this incorrectly.
- Improved the logic for finding executables using the `PATH` variable, excluding the script's directory.
- Enhanced error messaging and handling with a POSIX return code of 2 when executables are not found.

## 2024-11-15 - `genmd` Now updated to with a few more options

The `genmd` script has been updated with additional options for the command line and config file. Key enhancements include:

- Logging has been moved to a separate file for error reporting and additional logging levels.
- The -v/--verbose option has been removed; use -d/--debug instead.
- Added options to remove blank lines or lines containing only whitespace.
- Introduced an option to add line numbers to each file.
- Compression options available: gzip, xz, or bzip2.

## 2024-10-30 - `genmd` Now pre-populates exclusions with .gitignore

New options `-C` and `-g` have been added to limit included and excluded files and directories. The .gitignore will be included in exclusions and inclusions by default.

## 2024-10-28 - Updates and stability enhancements to `genmd`

### Refactor option handling and improve configuration loading

- Centralized handling of -c and -o options.
- Enhanced display_help function to capture all help comments.
- Established configuration loading precedence: defaults, ENV, system .grc, command-line .grc.
- Improved array management and duplicate removal.
- Enhanced logging and debugging capabilities.
- Added comprehensive error handling and exit codes.
- Fixed duplicate handling in patterns written to config files.

## 2024-10-25 - Added useful markdown wrapper script, well several scripts actually

The script scans a project directory and creates a markdown document with specified directory and file patterns from the config file. Documentation is available in the docs directory.

- [filetree](docs/filetree.md): Generates a file hierarchy tree from the current directory based on specified patterns.
- [genmd](docs/genmd.md): Groups related files wrapped in markdown for easy uploading to ChatGPT. Configurations may be saved for later use.
- [chunktext](docs/chunktext.md): Splits a file into chunks of text for ingestion by a new GPT instance while maintaining context.

## 2024-07-09 - Fixed recursion bug in pip wrapper

All functions are working properly, though cleanup and documentation updates are still needed. The wrapper functions for conda and pip are functioning as intended.

## Misc Items from the old oobabooga-macOS repository

This collection includes build scripts, benchmarking tools, and regression testing tools for various venv builds primarily focused on AI performance.

If you find any of my work here helpful, please reach out. I would like to have a dialog with anyone else interested.

Watch this spot, more to come, and you can always [buy me a coffee.](https://www.buymeacoffee.com/venvutil)
