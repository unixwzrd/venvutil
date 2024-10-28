# `genmd` - Combined Source Code Markdown Generator

## Table of Contents
- [`genmd` - Combined Source Code Markdown Generator](#genmd---combined-source-code-markdown-generator)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Options](#options)
    - [Short Options](#short-options)
    - [Long Options](#long-options)
  - [Examples](#examples)
  - [Environment Variables](#environment-variables)
  - [Configuration Files](#configuration-files)
  - [Settings Modes](#settings-modes)
  - [Dry Run](#dry-run)
  - [Verbose and Debug Levels](#verbose-and-debug-levels)
  - [Files and Directories](#files-and-directories)
  - [Dependencies](#dependencies)
  - [Author](#author)
  - [License](#license)

---

## Introduction

`genmd` is a versatile Bash script designed to generate comprehensive Markdown documentation from your source code files. It scans directories, includes or excludes files based on specified patterns, and consolidates the content into a structured Markdown file. Additionally, it can generate a visual directory structure and manage configurations through dedicated files.

---

## Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/unixwzrd/venvutil.git
   ```
2. **Navigate to the Script Directory:**
   ```bash
   cd genmd
   ```
3. **Make the Script Executable:**
   ```bash
   chmod +x genmd
   ```
4. **Move the Script to a Directory in Your PATH (Optional):**
   ```bash
   sudo mv genmd /usr/local/bin/
   ```

---

## Usage

```bash
genmd [options]
```

`genmd` scans the specified directory (default is the current directory) and generates a Markdown file containing the source code and directory structure based on the provided options.

---

## Options

### Short Options

- `-d [level]`: **Set Debug Level**
  - **Description:** Sets the debug level for the script's output.
  - **Levels:**
    - `0`: No debug output
    - `1`: Show informational messages
    - `2`: Show debug messages
    - `3`: Show regex commands and patterns
    - `9`: Show xtrace messages

- `-h`: **Show Help**
  - **Description:** Displays the help message with usage instructions.

- `-e [patterns]`: **Exclude Directories**
  - **Description:** Excludes directories matching the given patterns.
  - **Separator:** Multiple patterns can be separated by `|`.

- `-f [patterns]`: **Exclude Files**
  - **Description:** Excludes files matching the given patterns.
  - **Separators:** Multiple patterns can be separated by `|` or spaces.

- `-p [patterns]`: **Exclude Additional Patterns**
  - **Description:** Excludes additional patterns matching the given strings.
  - **Separators:** Multiple patterns can be separated by `|` or spaces.

- `-i [patterns]`: **Include Files**
  - **Description:** Includes only files matching the given patterns.
  - **Separators:** Multiple patterns can be separated by `|` or spaces.

- `-o [filename]`: **Output File**
  - **Description:** Specifies the output Markdown file.
  - **Default:** `combined_source.md`
  - **Note:** If specified, a corresponding `.grc` configuration file will be used or created in the `GENMD_BASE/utils/etc` directory.

- `-c [filename]`: **Load Configuration**
  - **Description:** Loads configuration from a `.grc` or `.cfg` file.
  - **Note:** If the filename does not end with `.grc` or `.cfg`, `.grc` will be appended automatically. The configuration file should reside in the `GENMD_BASE/utils/etc` directory.

- `-s [modes]`: **Show Settings**
  - **Description:** Displays or saves settings based on the specified modes.
  - **Modes:**
    - `info`: Show current settings
    - `cfg`: Write to configuration file
    - `md`: Include settings in Markdown output
    - `env`: Output settings as environment variables
    - `all`: Perform `info`, `md`, and `env` actions

- `-n`: **Dry Run**
  - **Description:** Simulates the actions without writing to any files; outputs the files that would be processed.

- `-v`: **Verbose Output**
  - **Description:** Enables verbose output for more detailed information during execution.

### Long Options

All short options have corresponding long options with double dashes (`--`):

- `--debug [level]`
- `--help`
- `--exclude [patterns]`
- `--file [patterns]`
- `--pattern [patterns]`
- `--include [patterns]`
- `--output [filename]`
- `--config [filename]`
- `--settings [modes]`
- `--dry-run`
- `--verbose`

---

## Examples

1. **Basic Usage with Exclusions and Inclusions:**
   ```bash
   genmd -e "node_modules|dist" -f "*.log *.tmp" -i "*css *.js" -s "info,md" -o project_overview.md
   ```

2. **Using Long Options and Dry Run:**
   ```bash
   genmd --exclude "node_modules|dist" --file "*.log *.tmp" --include "info" --dry-run
   ```

3. **Setting Multiple Modes and Debug Level:**
   ```bash
   genmd -s info,md -d 2
   ```

---

## Environment Variables

`genmd` utilizes several environment variables to set default patterns and directories:

- `GENMD_BASE`: **Base Directory**
  - **Description:** The base directory to search for files.
  - **Default:** Current directory (`.`)

- `GENMD_DIR_EXCLUDES`: **Default Directory Exclusions**
  - **Description:** A default list of directory patterns to exclude from the generated Markdown.
  - **Default Value:** `tmp .git`

- `GENMD_FILE_EXCLUDES`: **Default File Exclusions**
  - **Description:** A default list of file patterns to exclude from the generated Markdown.
  - **Default Value:** `*.ico *.svg *.png *.pdf *.jpg *.htaccess *.webp *.jekyll .DS_Store *.JPG *.png`

- `GENMD_PATTERN_EXCLUDES`: **Default Additional Pattern Exclusions**
  - **Description:** A default list of additional patterns to exclude from the generated Markdown.
  - **Default Value:** \*(Empty)*

- `GENMD_FILE_INCLUDES`: **Default File Inclusions**
  - **Description:** A default list of file patterns to include in the generated Markdown.
  - **Default Value:** \*(Empty)*

- `PAGER`: **Pager for Output**
  - **Description:** The pager to use for output.
  - **Default Value:** `less -R`

---

## Configuration Files

`genmd` supports loading configurations from `.grc` files, allowing you to save and reuse your settings:

- **Loading a Configuration File:**
  ```bash
  genmd -c myconfig
  ```
  - If `myconfig` does not end with `.grc`, `.grc` will be appended automatically.
  - The configuration file should reside in the `GENMD_BASE/utils/etc` directory.

- **Saving Configuration:**
  - Use the `cfg` mode with the `-s` option to save current settings to a configuration file, output will be written to `STDEOUT`.
  - When using the `-o` option to specify an output file, a corresponding `.grc` file will be created in the `GENMD_BASE/utils/etc` directory, matching the output filename.

---

## Settings Modes

The `-s` or `--settings` option allows you to manage how settings are displayed or saved:

- **Modes:**
  - `info`: Displays the current settings to `STDERR`.
  - `cfg`: Saves the current settings to a `.grc` configuration file.
  - `md`: Appends the current settings to the output Markdown file.
  - `env`: Outputs the current settings as environment variables to a separate script (`genmd_env.sh`).
  - `all`: Performs `info`, `md`, and `env` actions simultaneously.

- **Example:**
  ```bash
  genmd -s all
  ```

---

## Dry Run

The `-n` or `--dry-run` option allows you to simulate the actions of the script without making any changes. It will display the files that would be processed and the actions that would be taken.

- **Example:**
  ```bash
  genmd --dry-run -e "node_modules|dist" --file "*.log *.tmp" --include "info"
  ```

---

## Verbose and Debug Levels

- **Verbose Output (`-v` or `--verbose`):**
  - **Description:** Enables detailed output messages to help you understand what the script is doing.
  - **Usage:**
    ```bash
    genmd -v
    ```

- **Debug Levels (`-d` or `--debug`):**
  - **Description:** Sets the level of debugging information.
  - **Levels:**
    - `0`: No debug output
    - `1`: Show informational messages
    - `2`: Show debug messages
    - `3`: Show regex commands and patterns
    - `9`: Show xtrace messages (traces commands as they are executed)
  - **Usage:**
    ```bash
    genmd -d 2
    ```

---

## Files and Directories

`genmd` organizes its files and directories within the `GENMD_BASE` directory. The default structure includes:

- **Configuration Files:**
  - `utils/etc/genmd.grc`: Default configuration file.
  - `utils/etc`: Default directory for configuration files.

- **Output Files:**
  - `utils/output`: Default directory for output Markdown files.

- **Custom Configurations:**
  - When using the `-o` option to specify an output file, a corresponding `.grc` configuration file will be created or used in the `GENMD_BASE/utils/etc` directory, matching the output filename.

---

## Dependencies

`genmd` requires the following dependencies to function correctly:

- **Bash:** Version 4.0 or higher.
  
- **`filetree` Command:**
  - **Description:** Used to generate a visual representation of the project's directory structure.
  - **Location:** Included in this repository.
  - **Repository:** [https://github.com/unixwzrd/venvutil](https://github.com/unixwzrd/venvutil)
  
- **Other Utilities:**
  - Ensure that all required utilities used within the script are installed and accessible in your system's PATH.

---

## Author

**Michael Sullivan**  
Email: [unixwzrd@unixwzrd.ai](mailto:unixwzrd@unixwzrd.ai)  
Website: [https://unixwzrd.ai/](https://unixwzrd.ai/)  
GitHub: [https://github.com/unixwzrd](https://github.com/unixwzrd)

---

## License

This project is licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).