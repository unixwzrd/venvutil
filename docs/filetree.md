# `filetree` - Generate a Tree Structure of the Current Directory

## Table of Contents
- [`filetree` - Generate a Tree Structure of the Current Directory](#filetree---generate-a-tree-structure-of-the-current-directory)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Options](#options)
    - [Short Options](#short-options)
    - [Long Options](#long-options)
  - [Environment Variables](#environment-variables)
  - [Examples](#examples)
  - [Author](#author)
  - [License](#license)

---

## Introduction

`filetree` is a Python script used by `genmd` to visualize the directory structure of a project. It generates a tree representation of the current directory, allowing users to exclude or include specific files and directories based on defined patterns. This tool leverages the `rich` library for enhanced console output.

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

3. **Install Required Python Packages:**
   ```bash
   pip install rich
   ```

4. **Make the Script Executable:**
   ```bash
   chmod +x filetree
   ```

5. **(Optional) Move the Script to a Directory in Your PATH:**
   ```bash
   sudo mv filetree /usr/local/bin/
   ```

---

## Usage

```bash
filetree [options]
```

`filetree` scans the current directory and generates a visual tree structure, excluding and including files/directories based on specified patterns.

---

## Options

### Short Options

- `-e [patterns]`: **Exclude**

  **Description:** Exclude directories/files matching the given patterns. Multiple patterns can be separated by `|` or spaces.

  **Example:**
  ```bash
  filetree -e "node_modules|dist" "*.log *.tmp"
  ```

- `-i [patterns]`: **Include**

  **Description:** Include only files matching the given patterns. Multiple patterns can be separated by `|` or spaces.

  **Example:**
  ```bash
  filetree -i "*.py *.js"
  ```

- `-h`: **Help**

  **Description:** Show the help message and exit.

  **Example:**
  ```bash
  filetree -h
  ```

### Long Options

All short options have corresponding long options with double dashes (`--`):

- `--exclude [patterns]`: **Exclude**
  
  **Example:**
  ```bash
  filetree --exclude "node_modules|dist" "*.log *.tmp"
  ```

- `--include [patterns]`: **Include**
  
  **Example:**
  ```bash
  filetree --include "*.py *.js"
  ```

- `--help`: **Help**
  
  **Example:**
  ```bash
  filetree --help
  ```

---

## Environment Variables

`filetree` can utilize environment variables to set default patterns for excluding and including files/directories:

- `GENMD_DIR_EXCLUDES`: **Default Directory Exclusions**
  
  **Description:** A default list of directory patterns to exclude from the tree.

  **Example:**
  ```bash
  export GENMD_DIR_EXCLUDES="node_modules dist"
  ```

- `GENMD_FILE_EXCLUDES`: **Default File Exclusions**
  
  **Description:** A default list of file patterns to exclude from the tree.

  **Example:**
  ```bash
  export GENMD_FILE_EXCLUDES="*.log *.tmp"
  ```

- `GENMD_FILE_INCLUDES`: **Default File Inclusions**
  
  **Description:** A default list of file patterns to include in the tree.

  **Example:**
  ```bash
  export GENMD_FILE_INCLUDES="*.py *.js"
  ```

---

## Examples

1. **Exclude Specific Directories and Files:**
   ```bash
   filetree -e "node_modules|dist" "*.log *.tmp"
   ```

2. **Include Only Python and JavaScript Files:**
   ```bash
   filetree -i "*.py *.js"
   ```

3. **Combine Exclusions and Inclusions:**
   ```bash
   filetree -e "node_modules|dist" "*.log *.tmp" -i "*.py *.js"
   ```

4. **Using Environment Variables for Defaults:**
   ```bash
   export GENMD_DIR_EXCLUDES="node_modules dist"
   export GENMD_FILE_EXCLUDES="*.log *.tmp"
   export GENMD_FILE_INCLUDES="*.py *.js"
   filetree
   ```

5. **Display Help Message:**
   ```bash
   filetree -h
   ```

---

## Author

**Michael Sullivan**  
Email: [unixwzrd@unixwzrd.ai](mailto:unixwzrd@unixwzrd.ai)  
Website: [https://unixwzrd.ai/](https://unixwzrd.ai/)  
GitHub: [https://github.com/unixwzrd](https://github.com/unixwzrd)

---

## License

This project is licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).

---