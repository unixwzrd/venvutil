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
    - [Using .gitignore with genmd](#using-gitignore-with-genmd)
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

One of the main purposes of this is to create a markdown file containing the directory hierarchy and source code for anything which is plain text. Handy for taking related files you are working on and grouping them together in a single markdown file which has your files wrapped in markdown tags indicating their name and location in the project followed by a block quote containing the type of file and contents. This makes it easier for a Large Language Model (LLM) to consume and work with, and you don't have to copy and paste your files.

By saving the configuration and settings of any particular run of the command, you can re-run it again to capture the same files for review as they change. This is especially handy for feeding models with large context windows your project organization and code.

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

You may want to find a location and just make symlinks to the utilities in the bin directory since many of the scripts depend on some of the included scripts in the `shinclude` directory. Just create the symlinks in your favorite bin directory and the scripts will find the proper included scripts. It also depends on the `filetree` script, also in the bin directory of this repository.

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
  - `0`: SILENT
  - `10`: TRACE
  - `21`: DEBUG8
  - `22`: DEBUG7
  - `23`: DEBUG6
  - `24`: DEBUG5
  - `25`: DEBUG4
  - `26`: DEBUG3
  - `27`: DEBUG2
  - `28`: DEBUG1
  - `29`: DEBUG0/DEBUG
  - `30`: INFO
  - `40`: WARN/WARNING
  - `50`: ERROR
  - `60`: CRITICAL

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
  - **Description:** Loads configuration from a `.grc` file.
  - **Note:** If the filename does not end with `.grc`, `.grc` will be appended automatically. The configuration file should reside in the `GENMD_BASE/utils/etc` directory.

- `-g`: **Ignore .gitignore**
  - **Description:** By default, `genmd` uses patterns from `.gitignore` to exclude files and directories. Use this flag to disable this behavior.

- `-C`: **No Configuration**
  - **Description:** Run without sourcing the `.grc` configuration file. This allows you to execute `genmd` using only the provided command-line options and `.gitignore` patterns (if enabled).

- `-s [modes]`: **Show Settings**
  - **Description:** Displays or saves settings based on the specified modes.
  - **Modes:** `info`, `cfg`, `md`, `env`, `all`

- `-n`: **Dry Run**
  - **Description:** Simulates the actions without writing to any files; outputs the files that would be processed.

- `-b`: **Remove Lines with Whitespace Only**
  - **Description:** Removes all lines containing only whitespace from the Markdown file.

- `-l`: **Add Line Numbers**
  - **Description:** Adds line numbers to each file in the Markdown file.

- `-z [tool]`: **Compress Output**
  - **Description:** Compresses the final output using the specified compression utility (e.g., gzip, xz, bzip2).
  - **Note:** The compressed file will be named as `output.md.<extension>` where extension is the default extension for the compression tool.

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
- `--no-gitignore`
- `--no-config`
- `--settings [modes]`
- `--dry-run`
- `--remove-blanks`
- `--line-numbers`
- `--compress [tool]`

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
   genmd -s info,md -d 25
   ```
4. **Generate Markdown with Default Settings (Using .grc and .gitignore):**
   ```bash
   genmd -d 4 -e "utils _includes _data _posts js collaborates projects" \
         -f "*impression* professional.md *.png" \
         -i "css liquid" \
         -s all \
         -o my_test_file
   ```
5. **Generate Markdown Without Sourcing .grc Configuration (Using Only .gitignore and Command-Line Options):**
   ```bash
   genmd -d 4 -e "utils _includes _data _posts js collaborates projects" \
         -f "*impression* professional.md *.png" \
         -i "css liquid" \
         -s all \
         -o my_test_file \
         --no-config
   ```

6. **Generate Markdown Without Using .gitignore (Using Only .grc Configuration and Command-Line Options):**
   ```bash
   genmd -d 4 -e "utils _includes _data _posts js collaborates projects" \
         -f "*impression* professional.md *.png" \
         -i "css liquid" \
         -s all \
         -o my_test_file \
         --no-gitignore
   ```

7. **Generate Markdown Using Only Command-Line Options (Ignoring Both .grc and .gitignore):**
   ```bash
   genmd -d 4 -e "utils _includes _data _posts js collaborates projects" \
         -f "*impression* professional.md *.png" \
         -i "css liquid" \
         -s all \
         -o my_test_file \
         --no-config \
         --no-gitignore
   ```

---

## Environment Variables
`genmd` utilizes several environment variables to set default patterns and directories:

- `GENMD_BASE`: **Base Directory**
  - **Description:** The base directory to search for files.
  - **Default:** Current directory (`.`)

- `GENMD_DIR_EXCLUDES`: **Default Directory Exclusions**
  - **Description:** A default list of directory patterns to exclude from the generated Markdown.
  - **Default Value:** `tmp .git log __pycache__ .vscode`

- `GENMD_FILE_EXCLUDES`: **Default File Exclusions**
  - **Description:** A default list of file patterns to exclude from the generated Markdown.
  - **Default Value:** `*.ico *.svg *.png *.pdf *.jpg *.htaccess *.webp *.jekyll .DS_Store *.JPG`

- `GENMD_PATTERN_EXCLUDES`: **Default Additional Pattern Exclusions**
  - **Description:** A default list of additional patterns to exclude from the generated Markdown.
  - **Default Value:** *(Empty)*

- `GENMD_FILE_INCLUDES`: **Default File Inclusions**
  - **Description:** A default list of file patterns to include in the generated Markdown.
  - **Default Value:** *(Empty)*

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
  - Use the `cfg` mode with the `-s` option to save current settings to a configuration file, output will be written to `STDOUT`.
  - When using the `-o` option to specify an output file, a corresponding `.grc` file will be created in the `GENMD_BASE/utils/etc` directory, matching the output filename.

### Using .gitignore with genmd

With the integration of `.gitignore` patterns by default, `genmd` simplifies exclusion patterns, leveraging existing Git configurations to reduce redundancy in your `.grc` files.

To integrate your project's `.gitignore` patterns into the markdown generation process, use the `--no-gitignore` flag. This allows `genmd` to automatically exclude files and directories as specified in `.gitignore`, reducing the need to duplicate exclusion patterns in your `.grc` files.

- **Example Command:**
   ```bash
  genmd -d 4 -e "utils _includes _data _posts js collaborates projects" -f "*impression* professional.md *.png" -i "css liquid" -s all -o my_test_file --no-gitignore
  ```

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
  - **Default:** `30`
  - **Levels:** `0` (SILENT) to `60` (CRITICAL)
  - **Usage:**
    ```bash
    genmd -d 29
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

- **Example .grc Configuration File:**
  
This will preserve the existing settings and merged settings from the command line. It will be written to the utils/etc directory

```bash
export GENMD_DIR_EXCLUDES=".git utils _includes _site conf docs _data _posts js collaborates projects"
export GENMD_FILE_EXCLUDES="*impression* professional.md *.png"
export GENMD_FILE_INCLUDES=".sh genmd filettree"
export GENMD_PATTERN_EXCLUDES=""
export GENMD_BASE="."
output_filename="./utils/output/yet-another-test.md"
settings_modes="info md cfg env"
dry_run=false
debug_level=40
verbose=false
use_gitignore=true
remove_blanks=false
add_line_numbers=false
compress=false
compression_tool=gzip
```

---

## Dependencies

`genmd` requires the following dependencies to function correctly:

- **Bash:** Version 4.0 or higher.
  
- **`filetree` Command:**
  - **Description:** Used to generate a visual representation of the project's directory structure.
  - **Location:** Included in this repository.
  - **Repository:** [https://github.com/unixwzrd/venvutil](https://github.com/unixwzrd/venvutil)
  - Requires the Rich Python library to be installed.
 
- **Included Scripts:**
  - **errno.sh** and **util_funcs.sh** are required scripts included in this repository.
  
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