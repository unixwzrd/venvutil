# `filetree` - Generate a Tree Structure of the Current Directory

## Table of Contents

- [`filetree` - Generate a Tree Structure of the Current Directory](#filetree---generate-a-tree-structure-of-the-current-directory)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
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

1. **Find all the `.sh` files in the current directory, excluding `tmp conf functions`**

    ```bash
    (python-3.10-dev) [unixwzrd@xanax: dev]$ filetree -i .sh -e tmp conf functions
    filetree WARNING(30): Configuration file not found: .exclusions.cfg
    Root Directory
    ├── bin/
    │   ├── generate_manifest.sh
    │   ├── numpy-1.26-reinst.sh
    │   ├── shinclude/
    │   │   ├── errno.sh
    │   │   ├── help_sys.sh
    │   │   ├── init_env.sh
    │   │   ├── util_funcs.sh
    │   │   ├── venv_funcs.sh
    │   │   └── wrapper_funcs.sh
    │   └── warehouse.sh
    ├── modules/
    │   └── conda-install.sh
    └── setup.sh
    ```

1. **Exclude Specific Directories and Files:**

    ```bash
    filetree -e "node_modules|dist" "*.log *.tmp"
    ```

1. **Include Only Python and JavaScript Files:**

    ```bash
    filetree -i "*.py *.js"
    ```

1. **Combine Exclusions and Inclusions:**

    ```bash
    filetree -e "node_modules|dist" "*.log *.tmp" -i "*.py *.js"
    ```

1. **Using Environment Variables for Defaults:**

    ```bash
    export GENMD_DIR_EXCLUDES="node_modules dist"
    export GENMD_FILE_EXCLUDES="*.log *.tmp"
    export GENMD_FILE_INCLUDES="*.py *.js"
    filetree
    ```

1. **Display Help Message:**

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
