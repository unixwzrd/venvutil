# Changelog

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

Watch this spot, more to come, and you can always buy me a coffee.
