# Changelog

## 2025-04-26: Bug Fixes and Improvements

### chunkfile.py Bug Fix
- Fixed a TypeError in `chunkfile.py` when chunking files by lines:
  - Resolved issue where line-based chunking attempted to join a list of str as bytes, causing a crash.
  - Updated type hints and runtime checks to ensure line-based chunks are handled as lists of str, not bytes.
  - Improved type safety and compatibility for line-based chunking mode.
- No changes to CLI or output format; this is a bugfix for stability and correctness.

## 2025-04-07: genmd Enhancements

### genmd Enhancements
- Enhanced `display_settings` function:
  - Added support for markdown documentation generation
  - Added support for configuration file generation
  - Added support for environment variable export
- improved condiguration variable handling and storage
  - added `config_variables` array to manage configuration variables
  - added `dump_config` function to dump configuration variables
  - added `write_config` function to write configuration variables to a file
- Consolidated functionality
  - moved functions into other libraries for reuse.
- Fixed `pre-commit` hook to work with worktrees
- Fixed genmd command line handling for multiple parameters for -e -1 -f -d -s
  
## 2025-04-06: Core Library Enhancements and Bug Fixes

### Core Library Improvements
- Enhanced `type_lib.sh`:
  - Deprecated `handle_variable` function in favor of new `update_variable`
  - Added support for variable handling tables
  - Improved portability across shell environments
  - Enhanced error handling and validation
- Improved `config_lib.sh`:
  - Integrated with new `update_variable` function
  - Enhanced associative array handling
  - Improved configuration validation
  - Better error reporting for invalid configurations
- Enhanced `errno_lib.sh`:
  - Changed default message level from WARNING to INFO
  - Improved function name reporting in error messages
  - Enhanced error message formatting

### Setup and Installation
- Enhanced `setup.sh`:
  - Added new `refresh` option for updating from cloned repo:
    - Skips Python package installation
    - Updates only shell scripts and configuration
    - Preserves existing virtual environments
  - Fixed bashrc modification issue:
    - Improved handling of venvutil removal
    - Added safety checks for file modifications
    - Enhanced backup and restore functionality
  - Improved configuration handling:
    - Better variable validation
    - Enhanced error reporting
    - Added support for new update_variable function

### File Management
- Fixed `filetree.py`:
  - Improved configuration file handling:
    - Better error handling for missing files
    - Enhanced logging for configuration issues
    - Added fallback mechanisms
  - Enhanced pattern processing:
    - Better handling of empty patterns
    - Improved pattern validation
    - Added support for both file extensions and patterns
  - Fixed issues with include/exclude lists:
    - Proper handling of pattern splitting
    - Better validation of pattern formats
    - Enhanced logging for pattern processing

### Documentation and Logging
- Removed redundant debug level documentation from `genmd`
- Enhanced help messages and usage documentation
- Improved error messages and logging
- Updated configuration documentation

## 2025-03-19: Tool Enhancements and Bug Fixes

### Chat Tools Enhancements
- Enhanced `extract_chat.py`:
  - Added code fence normalization to handle nested code blocks
  - Improved command line arguments with short form `-f` for format
  - Enhanced text processing for more consistent output
- Improved `rename-chat.py`:
  - Added destination directory support for renamed files (-d, --destination)
  - Improved default behavior to handle current directory when no files specified
  - Enhanced error handling and fallback mechanisms
  - Better argument parsing and help messages

### File Handling Improvements
- Fixed bug in `chunkfile.py` when writing chunks:
  - Fixed file opening mode handling for text vs. binary data
  - Improved handling of UTF-8 encoded content

### System Utility Enhancements
- Enhanced `numpy-comp.sh`:
  - Improved version number handling and validation
  - Better wildcard (*) version support
  - Enhanced user feedback messages
  - Cleaner command-line output and error reporting

## 2025-02-10 - Documentation Overhaul and Process Improvements

### Documentation Structure and Organization
- Established standardized documentation format across all components
- Enhanced core library documentation with detailed API references
- Improved cross-referencing between related documentation files
- Added comprehensive examples and use cases for all major features

### Process Improvements
- Implemented new periodic review process with clear guidelines
- Added structured approach for tracking and documenting changes
- Enhanced changelog management with better categorization
- Improved worklog organization for technical details

### Tool Documentation
- Enhanced documentation for all Python and shell tools:
  - `chunkfile.py`: Complete rewrite with detailed API docs
  - `warehouse.sh`: Added comprehensive usage guide
  - `generate_manifest.sh`: Enhanced with git integration details
- Added visual guides for complex operations
- Updated all command-line help messages

### Technical Documentation
- Added detailed architecture documentation
- Enhanced troubleshooting guides
- Improved installation and setup instructions
- Added performance considerations and best practices

## 2025-02-06 - Major Release: Library Reorganization and New Tools

### Core Library Reorganization
- Renamed all shell library files to use `_lib.sh` suffix for better organization
- Added new core libraries and new functionality:
  - `config_lib.sh`: Configuration management functions
  - `type_lib.sh`: Type checking and validation
  - `string_lib.sh`: String manipulation utilities
  - `errno_lib.sh`: Enhanced error handling
  - `helpsys_lib.sh`: Improved help system
  - `init_lib.sh`: Initialization routines
  - `venvutil_lib.sh`: Virtual environment utilities
  - `wrapper_lib.sh`: Command wrapping functions

### Virtual Environment Enhancements
- Enhanced `lenv` function with new capabilities:
  - Added column headers for better readability
  - Added Python version display for each environment
  - Improved sorting by time or name (forward/reverse)
  - Enhanced long format time display with date and time
  - Added environment status indicators
- Improved `ccln` (clone) function:
  - Added support for cloning without sequence number
  - Enhanced error handling during clone operations
  - Added automatic environment activation after cloning
- Added virtual environment renaming capability:
  - New `renv` function for renaming environments
  - Preserves all packages and configurations
  - Handles both sequenced and non-sequenced environments
  - Updates environment references in configuration
  - Maintains environment history and logs
- Added new environment management features:
  - Better environment variable handling
  - Improved error recovery mechanisms
  - Enhanced logging for all venv operations

### New Tools and Utilities
- Added performance testing tools:
  - `torch_torture.py`: PyTorch stress testing
  - `numpy_torture.py`: NumPy stress testing
  - `numpy-comp` and `numpy-comp.sh`: NumPy compilation tools
  - `compare_test`: General performance comparison framework
- Added chat management utilities:
  - `extract-chat` and `extract_chat.py`: Chat extraction tools
  - `rename-chat` and `rename-chat.py`: Chat renaming utilities

### Core System Improvements
- Enhanced `setup.sh` with improved Conda integration and error handling
- Updated `setup.cf` with new configuration options
- Modified core utilities for better performance:
  - `purgevenv`: Enhanced cleanup operations
  - `genmd`: Better documentation generation
- Enhanced `requirements.txt` with latest dependencies

### Documentation Enhancements
- Added new documentation:
  - `Metrics_Layout.md`: Performance metrics documentation
- Updated existing documentation:
  - `Standards.md`: Updated coding standards
  - `filetree.md`: New file structure documentation
  - `installer-manifest.md`: Updated installation guide
- Comprehensive updates to function documentation in `docs/shdoc/`

### Technical Improvements
- Enhanced error handling across all utilities:
  - Better POSIX errno code handling
  - Improved error message formatting
  - Enhanced error context for debugging
- Improved virtual environment management:
  - Better state tracking
  - Enhanced environment switching
  - Improved environment cleanup
- Better type checking and validation:
  - Added robust type checking functions
  - Enhanced input validation
  - Improved error reporting
- Enhanced string manipulation functions:
  - Added new string cleaning utilities
  - Improved pattern matching
  - Better text formatting
- Improved configuration management:
  - Enhanced config file handling
  - Better default value management
  - Improved configuration validation
- Better help system organization:
  - Enhanced function documentation
  - Improved command-line help
  - Better cross-referencing

## 2025-01-09 - Script Sourcing and Directory Handling Improvements

### Shell Include Files Enhancements

- Implemented consistent script sourcing tracking across all function include scripts
- Fixed bug in script sourcing prevention mechanism
- Improved directory creation handling
- Streamlined directory operations with optimized `mkdir -p` usage

### Core Script Updates

- `init_env.sh`: Enhanced script sourcing control with improved tracking
- `help_sys.sh`: Improved directory handling and path management
- `errno.sh`: Cleaned up code organization and removed redundant sections
- `util_funcs.sh`: Enhanced directory operations and error handling
- `venv_funcs.sh`: Updated script sourcing mechanism for better reliability
- `wrapper_funcs.sh`: Improved function loading control and consistency
- `buildvenvs`: Updated directory handling for better efficiency (experimental)
- `modules/conda-install.sh`: Enhanced installation process and error handling (experimental)

### Technical Improvements

- Removed redundant directory existence checks before mkdir operations
- Standardized script sourcing prevention across all include files
- Enhanced error handling for directory operations
- Improved code organization and cleanup

## 2024-12-30 - Help System and Documentation Enhancements

### Help System Improvements

- Fixed directory handling in `process_scripts` function
- Improved variable naming for better code clarity
- Enhanced error handling for directory operations
- Updated documentation generation process

### Documentation Updates

- Comprehensive update of function documentation in `docs/shdoc`
- Enhanced markdown generation for all shell functions
- Improved cross-referencing between documentation files
- Updated core functionality documentation

### Shell Function Enhancements

- Enhanced error handling and logging in utility functions
- Improved virtual environment management functions
- Updated documentation generation system

### General Improvements

- Added new requirements.txt file
- Updated manifest.lst with latest changes
- Enhanced overall documentation structure

## 2024-12-30 - Fixed a bug in `errno.sh` `errno` function

- Bug in `errno.sh` `errno` function number 7, E2BIG failed to parse.
- Simplified logic and dead code when no argument passed.

## 2024-12-29 - Shell Include Files Enhancements

### errno.sh

- Enhanced error handling with improved POSIX errno codes.
- Added better error message formatting and logging categorization.
- Introduced new functionality for more descriptive error messages.

### util_funcs.sh

- Improved utility functions for better performance and reliability.
- Enhanced logging and error checking mechanisms.
- Streamlined common tasks in Bash scripting.

### venv_funcs.sh

- Enhanced virtual environment management functions.
- Improved error recovery and logging for VENV operations.
- Added new features for better environment variable handling.

## 2024-12-28 - Warehouse Tool Improvements

- handled if higher level directories don't exist at destination.
- Added additional information to err_warn and er_exit messages
- Picked lint and corrected spelling and other documentation issues.

## 2024-12-23 - Core Functionality Enhancements

### Setup Script Improvements

- Enhanced error handling with proper exit codes
- Added validation for critical operations
- Improved package configuration management
- Enhanced logging with descriptive messages
- Added support for deprecated file removal
- Improved manifest handling
- Added rollback capability framework

### Shell Function Include Files

- venv_funcs.sh:
  - Enhanced virtual environment management
    - `lenv` sorting VENV's by time or name in forward or reverse order
    - Long format time with date and time also added
    - `ccln` cloning of the current VENV may be done without sequence number
  - Improved environment variable handling
  - Added better error recovery
  - Enhanced logging for venv operations
- errno.sh:
  - Improved POSIX errno codes handling
  - Enhanced error message formatting
  - Added better logging categorization
  - Improved error context for debugging
- help_sys.sh:
  - Added new docs_base_path function
  - Updated function naming convention
  - Improved file path handling
  - Enhanced help message formatting

### Warehouse Tool Improvements

- Enhanced error handling in `warehouse.sh` with better symlink validation
- Added protection against pathological symlink situations
- Improved handling of source and destination path validation
- Added detailed error reporting for tar operations
- Enhanced directory path handling and normalization

### Chunkfile Enhancements

- Improved type hints and documentation in `chunkfile.py`
- Enhanced error handling for edge cases in chunk processing
- Added validation for chunk size and overlap parameters
- Improved handling of partial reads and end-of-file conditions
- Added support for proper UTF-8 handling in line mode
- Enhanced progress reporting and file naming consistency

### Error Handling and Logging

- Enhanced error handling in shell scripts with proper exit codes
- Improved logging with more descriptive error messages
- Added validation for critical operations
- Enhanced error recovery mechanisms
- Added detailed error context for debugging

### Documentation Updates

- Added comprehensive documentation for warehouse functionality
- Created detailed visual guide for chunk operations
- Updated implementation details for all core functions
- Added examples and use cases for each tool
- Enhanced cross-referencing between related documentation

### Core Script Improvements

- Refactored shell functions for better modularity
- Enhanced path handling and validation
- Improved error recovery mechanisms
- Added protection against common failure modes
- Enhanced logging and debugging capabilities

## 2024-12-22 - Documentation Updates

### Added Git Integration

- Enhanced `generate_manifest` script to automatically detect deleted files using `git status --porcelain`
- Added automatic creation of cancel entries for files deleted from git
- Updated documentation to reflect new git integration features

### Documentation Updates

- Added comprehensive documentation for the `generate_manifest` script.
- Documented manifest file format and handling of deprecated files.
- Clarified the use of `c` (cancel) type entries for file removal.
- Added cross-references to related documentation.
- Improved documentation for handling deprecated files
- Added examples of both automatic and manual cancel entries
- Updated implementation details section with git status integration
- Added git as an optional dependency

## 2024-12-20 - Major Updates and Tool Improvements

### Tool Changes and Renames

- Renamed `chunktext` to `chunkfile` for better clarity
- Removed `c++` and `g++` pass-through scripts (no longer needed after Meson fix)
- Modified `numpybench` to use `-o/--output` instead of `-d/--datafile`
- Updated `warehouse.sh` with improved functionality

### New Tools and Scripts

- Added `generate_manifest` utility
- Created `numpy-1.26-reinst.sh` for optimized NumPy installation
- Added `chunkfile.py` implementation

### Documentation Improvements

- Created new documentation files:
  - `docs/chunk-offsets.md`: Visual guide for chunk operations
  - `docs/chunkfile.md`: Documentation for the renamed chunk utility
  - `docs/numpybench.md`: Comprehensive guide for NumPy benchmarking
  - `docs/warehouse.md`: Documentation for storage management utilities
- Updated all function documentation in `docs/shdoc/`
- Enhanced core documentation files for better clarity

### Core Script Updates

- Modified `bin/buildvenvs` for better environment handling
- Enhanced `bin/filetree.py` with improved functionality
- Updated `bin/genmd` for better document generation
- Improved `bin/numpybench` with cleaner output options

### Shell Include Files

- Updated all shell include files with improved functionality:
  - `errno.sh`: Enhanced error handling
  - `help_sys.sh`: Improved help system
  - `init_env.sh`: Better initialization
  - `util_funcs.sh`: Additional utility functions
  - `venv_funcs.sh`: Enhanced venv management
  - `wrapper_funcs.sh`: Updated wrapper functionality

### Configuration and Requirements

- Removed `build-requirements.txt` in favor of `requirements-build.txt`
- Updated `requirements.txt` with current dependencies
- Modified `manifest.lst` to reflect current file structure

## 2024-12-10 - Function Name Changes and New Functions

### ***help_sys.sh*** Tested and working as expected

- **Function Name Changes**:
  - Updated function names to follow a consistent naming convention.

- **New Functions**:
  - Added `docs_base_path`: Retrieves the base path for documentation files.

- **Function Modifications**:
  - `get_system_readme_file`: Updated to accept an optional directory path for the README file.
  - `write_system_readme_header`: Writes the header section of the README for system scripts.
  - `write_system_readme_entry`: Creates an entry in the README for a script or function.

- **Code Improvements**:
  - Improved the handling of file paths and added more descriptive comments for better clarity.
  - Adjusted echo statements for better formatting and consistency.

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
- Added symlink following along with token counting for markdown bundles.
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

- Refactored `setup.sh` for modularity and error handling.
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
- [chunkfile](docs/chunktext.md): Splits a file into chunks of text for ingestion by a new GPT instance while maintaining context.

## 2024-07-09 - Fixed recursion bug in pip wrapper

All functions are working properly, though cleanup and documentation updates are still needed. The wrapper functions for conda and pip are functioning as intended.

## Misc Items from the old oobabooga-macOS repository

This collection includes build scripts, benchmarking tools, and regression testing tools for various venv builds primarily focused on AI performance.

If you find any of my work here helpful, please reach out. I would like to have a dialog with anyone else interested.

Watch this spot, more to come, and you can always [buy me a coffee.](https://www.buymeacoffee.com/venvutil)
