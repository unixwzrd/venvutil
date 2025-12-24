# venvutil - Manage Conda and Pip VENV's with some simple functions and scripts

This is release v1.0.6. This project is continuously evolving, becoming a catch-all for useful tools and shell functions that facilitate working with Python VENV's and LLM's.

## Table of Contents

- [venvutil - Manage Conda and Pip VENV's with some simple functions and scripts](#venvutil---manage-conda-and-pip-venvs-with-some-simple-functions-and-scripts)
  - [Table of Contents](#table-of-contents)
  - [Project Overview](#project-overview)
    - [Key Features](#key-features)
    - [Why Use Venvutil?](#why-use-venvutil)
    - [Tested on the following systems](#tested-on-the-following-systems)
  - [Installation Instructions](#installation-instructions)
    - [Prerequisites](#prerequisites)
    - [Running the installer](#running-the-installer)
  - [Setup Script Enhancements](#setup-script-enhancements)
  - [Usage](#usage)
    - [Tools Overview](#tools-overview)
    - [Shell Functions](#shell-functions)
  - [Conda and Pip Logging](#conda-and-pip-logging)
  - [LD Pass-Through and NumPy builds](#ld-pass-through-and-numpy-builds)
    - [Recipe for building NumPy with Accelerate Framework optimizations on Apple Silicon](#recipe-for-building-numpy-with-accelerate-framework-optimizations-on-apple-silicon)
    - [Purpose](#purpose)
    - [Explanation](#explanation)
  - [NLTK and Token Count](#nltk-and-token-count)
  - [Recent Changes](#recent-changes)
  - [Project Status](#project-status)
  - [Support My Work](#support-my-work)
  - [License](#license)
  - [Future Improvements](#future-improvements)
    - [High Priority](#high-priority)
    - [Performance and Security](#performance-and-security)
    - [Tools and Integration](#tools-and-integration)
  - [Recent Improvements](#recent-improvements)
    - [Core Functionality](#core-functionality)
    - [Library Organization](#library-organization)
    - [Performance Tools](#performance-tools)
    - [Documentation](#documentation)

## Project Overview

Venvutil is a versatile toolset designed to simplify the management of Python virtual environments (VENV) and enhance the workflow for developers working with Python packages and large language models (LLMs). This project provides a collection of scripts and functions that wrap around common tools like Conda and Pip, offering additional features such as logging, environment state freezing, and streamlined package management.

### Key Features

- **Enhanced VENV Management**: Provides tools to easily create, manage, and replicate Python virtual environments and a few other tools.
- **Conda and Pip Logging**: Utilizes logging to track changes to VENV's and freeze the state of environments for reproducibility.
- **Enhanced Logging**: Maintains a log on any potentially destructive operations to VENV's when using Pip or Conda to make changes to the VENV.
- **Robust Configuration Management**: All configuration changes are logged and a `pip freeze` is done before and after the operation to ensure that the virtual environment is frozen.
- **Git Integration**: Automatically detects deleted files from git status to manage deprecated files in installations.
- **Rollback and Recovery**: Offers tools to rollback changes to VENV's, restoring the state of the environment to a previous state using the freeze log.
- **Cross-Platform Compatibility**: Designed to work seamlessly on macOS and Linux systems, with specific optimizations for Apple Silicon.
- **Additional Tools**: Provides additional tools like `genmd`, `filetree`, including some simple test scripts to check if your GPU is being utilized - specifically for Apple Silicon.
- **Build and Installation Scripts**: Offers scripts to automate the setup of complex environments, including rebuilding NumPy with Apple Silicon optimizations.
- **Comprehensive Documentation**: Includes detailed instructions and [CHANGELOG](CHANGELOG.md) to help users get started and stay updated with the latest features.

### Why Use Venvutil?

- **Simplify Environment Management**: Most common tasks are simplified with this toolset, such as creating, deleting, switching, and cloning environments.
- **Enhanced Logging**: Provides a record of changes to VENV's, making it easy to track and recover from potential issues.
- **Ensure Reproducibility**: By freezing the state of environments, Venvutil helps ensure that your setups are consistent across different machines and setups.
- **Transparent Tool Wrapping**: Provides pass-through wrappers Pip, Conda, and LD to ensure compatibility without compromising security or functionality.

### Tested on the following systems

- macOS 15.4 (Sequoia)
- macOS 13.4 (Monterey)
- Red Hat Enterprise Linus 8
- Redhat Enterprise Linux 9

## Installation Instructions

### Prerequisites

- Xcode command line utilities.
- Bash 4.0 or higher (macOS has Bash 3.2, you will need to build and install or use Brew)
- Python 3.11 (Conda will handle this for you when it installs)
- Conda latest version
- Python packages
  - Rich, ticktoken, nltk
- Ensure that your system meets the necessary requirements for running Python and Conda.

### Running the installer

```bash
git clone https://github.com/unixwzrd/venvutil.git venvutil
cd venvutil
bash ./setup.sh install
```

```bash
# For updates from cloned repo (without Python packages)
./setup.sh refresh
```

By default this installs into `$HOME/local/venvutil` (configured via [`setup/setup.cf`](setup/setup.cf)). You can override this with `-d <directory>` to install anywhere you wish. The installer will download and update Conda if necessary, along with the python packages listed above. NLTK needs data and that will be downloaded into your home directory into the `nltk_data` directory.

Thanks for using Venvutil!

## Setup Script Enhancements

- **Manifest hard links (`h`)**: The installer manifest supports a hard link type (`h`) in addition to symbolic links (`l`). This allows you to specify hard links directly in the manifest file processed by [`setup/assets.sh`](setup/assets.sh).
- **Shared shell libraries**: [`setup/setuplib`](setup/setuplib) is now a real directory whose `.sh` files are **hard links** to the canonical [`bin/shinclude`](bin/shinclude) libraries so setup and runtime never drift.

## Usage

### Tools Overview

- **extract-chat** extracts ChatGPT JSON chatlogs, works with my [Safari extension](https://github.com/unixwzrd/chatgpt-chatlog-export), to extract chat history.
  - Extract in either Markdown or HTML format.
  - Retains code and references where possible along with some internal metadata.
  - May be broken into chunks and fed into a fresh GPT context for continuity.
- **tokencount**: [Detailed Documentation](docs/tokencount.md) *TODO*
  - A tool designed to count tokens in text files, useful for analyzing text data and preparing it for processing with language models.
- **chunkfile**: [Detailed Documentation](docs/chunkfile.md)
  - A versatile tool for splitting files into chunks with configurable overlap:
    - Split by number of files, lines or size in bytes.
    - Support for overlapping content between chunks (-o)
- **warehouse** and **recall**: [Detailed Documentation](docs/warehouse.md)
  - Tools for managing offline storage:
    - Move files/directories to external storage while maintaining symlinks
    - Support custom storage locations
- **numpybench**: [Detailed Documentation](docs/numpybench.md)
  - A benchmarking tool for testing NumPy performance:
    - Tests/validates GPU and Neural Engine acceleration on Apple Silicon with NumPy
- **genmd**: [Detailed Documentation](docs/genmd.md)
  - A script that generates markdown documentation from project files, facilitating easy sharing and collaboration.
- **filetree**: [Detailed Documentation](docs/filetree.md)
  - will produce file hierarchy structure based on file and directories to exclude and include..
- **core functions provided by venvutil_lib.sh**: [Detailed Documentation](docs/shdoc/README.md)
  - Provides a number of useful shell functions for managing aVirtual Environments along with some utility function, such as `ptree`
  - **compile wrappers for C++, G++, and LD**: [Detailed Documentation](docs/compile_wrappers.md)
    - To help compile many things in the macOS Environment which incorrectly pass the linker the --version flag.

### Shell Functions

These are a few of the shell functions provided by venvutil which I find useful.  There is more documentation on the functions in the README of the [venvutil Tools](docs/shdoc/README.md).

To use the functions and tools, simply source in the venvutil_lib.sh file in your .bashrc. The setup.sh script will handle adding the necessary checks and source statements to your .bashrc file.

- **venvutil Tools**: [Detailed Documentation](docs/shdoc/README.md)
  - A collection of shell functions and scripts for managing Python virtual environments and LLMs.
- **vhelp**: [Detailed Documentation](docs/shdoc/bin/shinclude/functions/vhelp.md)
  - Integrated help for scripts and functions. `vhelp` is the main entry point for the help system.
- **ptree**: [Detailed Documentation](docs/shdoc/bin/shinclude/functions/ptree.md)
  - A shell function that displays a file tree structure of a directory, highlighting directories that contain certain files.
- **lenv**: [Detailed Documentation](docs/shdoc/bin/shinclude/functions/lenv.md)
  - Provides a listing of all Pip and Conda managed environments, versions and date last updated.

  ```bash
  (base) [unixwzrd@xanax: ~]$ lenv
  Date        Python   Environment                   Path
  2025-01-27  3.11.11  adv-numpy-daily-pytorch      ~/miniconda3/envs/adv-numpy-daily-pytorch
  2025-01-13  3.12.8   base                       * ~/miniconda3
  2025-01-25  3.11.11  comp-numpy-daily-pytorch     ~/miniconda3/envs/comp-numpy-daily-pytorch
  2025-01-25  3.11.11  comp-numpy-std-pytorch       ~/miniconda3/envs/comp-numpy-std-pytorch
  2025-01-02  3.10.16  python-3.10-PA-dev           ~/miniconda3/envs/python-3.10-PA-dev
  2024-12-30  3.10.16  python-3.10-dev              ~/miniconda3/envs/python-3.10-dev
  ```

- **errfind and errno**: [Detailed Documentation](docs/shdoc/bin/shinclude/errno_sh.md)
  - For locating POSIX return codes and messages and also looking up return code values. Helping you find the best error return code for any condition, no more using `return 1` or other random number.

  ```bash
  (base) [unixwzrd@xanax: ~]$ errfind invalid
  (EINVAL: 22): Invalid argument
  (base) [unixwzrd@xanax: ~]$ errfind file
  (ENOENT: 2): No such file or directory
  (EBADF: 9): Bad file descriptor

  (base) [unixwzrd@xanax: ~]$ sudo
  usage: sudo -h | -K | -k | -V
  usage: sudo -v [-ABkNnS] [-g group] [-h host] [-p prompt] [-u user]
  usage: sudo -l [-ABkNnS] [-g group] [-h host] [-p prompt] [-U user] [-u user] [command [arg ...]]
  usage: sudo [-ABbEHkNnPS] [-C num] [-D directory] [-g group] [-h host] [-p prompt] [-R directory] [-T timeout] [-u user] [VAR=value] [-i | -s] [command [arg ...]]
  usage: sudo -e [-ABkNnS] [-C num] [-D directory] [-g group] [-h host] [-p prompt] [-R directory] [-T timeout] [-u user] file ...
  (base) [unixwzrd@xanax: ~]$ errno $?
  (EPERM: 1): Operation not permitted
  ```

There are many more functions available, check out the documentation for more.

## Conda and Pip Logging

Any potential *destructive* operations on a virtual environment swill be logged, along with the exact command used. Logs are done for the venvutil tools globally, as well as for the virtual environments themselves. A `pip freeze` is done before and after the operation to ensure that the virtual environment is frozen.

This logging combined with the frozen environments can be used to ensure that your virtual environments are consistent and reproducible as well as tracking changes and rolling back to a previous state. There are numerous commands which will work with Conda created and using either Pip or Conda for package management. I would like to add support for other package managers which may be used in a compatible virtual environments. Two useful commands are `lenv` which not only lists the environments, but also their last update date. The `ccln` command will clone the current venv and switch you to the cloned environment. There are many other useful commands and functions available, check out the [venv_funcs.sh](docs/shdoc/bin/shinclude/venv_funcs_sh.md) file for more information.

Configuration options, logs and freezes are found in the `$HOME`

## LD Pass-Through and NumPy builds

Meson was fixed which gave me troubles tracking this down, so I am removing the hard links for c++ and g++, but leaving in the ld script pass-through just in case something else tries to invoke it using the wrong flag for `--version` when it needs to be `-v`, here are the instructions for building NumPy with the optimizations turned on. It also seems that after I built GCC, it conflicted with the Xcode c++ compiler, installing another c++ in /usr/local/bin which was simply a herd link to g++.

### Recipe for building NumPy with Accelerate Framework optimizations on Apple Silicon

This has also been placed in the `numpy-comp` script, just specify version of NumPy you want to build.

```bash
# Build NumPy 1.26
numpy-comp 1.26
```

Or whatever is your particular version of NumPy you want to build.

```bash

# Run PyTorch tests
torch-torture
```

This will build and install NumPy 1.26 into your Python virtual environment. With the Accelerate Framework optimizations on, you can now use NumPy with Apple Silicon. The `numpy-comp` script will take of all teh details. There are several test scripts for NumPy and PyTorch which may be used to compare different builds for performance, these van run on multiple virtual environments for varies size NumPy arrays, PyTorch tensors and varying iterations.  These are useful for seeing what combinations of packages will give the best performance.

### Purpose

- These wrappers ensure that your existing build and compilation processes remain intact while using Venvutil.

### Explanation

- By wrapping these tools, Venvutil provides a seamless integration with your existing toolchain, ensuring compatibility and security.

## NLTK and Token Count

- **NLTK Installation**: The `venvutil` installer bootstraps `nltk`, but if you are running `tokencount` from another virtual environment you may need to add it manually.
- **Missing Tokenizers**: When `tokencount` cannot import `nltk`, it now prints explicit setup instructions. Follow them (or run the commands below) to install the package and download the required corpora:

  ```bash
  pip install nltk
  python <<'PY'
  import nltk
  nltk.download('punkt')
  nltk.download('stopwords')
  PY
  ```

- **Token Count Integration**: `genmd` can invoke `tokencount` with the `-t` flag to append a token count summary to the generated bundle.

## Recent Changes

- **File Tree Improvements**: `filetree` now normalizes regex-style include patterns, respects directory allowlists, and supports `-L/--follow-links` so generated docs can traverse symlinks.
- **Shared Config Loader**: `genmd`, `setup`, and `generate_manifest` all call the same `load_config`/`dump_config` helpers from `config_lib.sh`, reducing drift between workflows.
- **Tokencount Guidance**: Clear runtime instructions for installing `nltk` and fetching the required tokenizers when they are missing.

## Project Status

The project is actively maintained and continuously evolving with new features and improvements. Check out the CHANGELOG.md for recent changes and the docs/ directory for detailed tool documentation.

## Support My Work

If you find Venvutil helpful and would like to support my work, consider sponsoring me on [Patreon](https://www.patreon.com/unixwzrd) or buying me a coffee on [Buy Me a Coffee](https://www.buymeacoffee.com/unixwzrd). Your support helps me continue developing and maintaining this project and other projects. It is greatly appreciated as I pursue contract work opportunities and sponsorships.

Thank you for your support!

## License

```text
This project is licensed under the Apache License
                 Version 2.0, License.

 Copyright 2025 Michael P. Sullivan - unixwzrd@unixwzrd.ai

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```

[Apache License Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

## Future Improvements

### High Priority
- **Testing Framework**: Comprehensive testing suite for shell functions, including unit tests and integration tests
- **Documentation**: Enhanced function reference, troubleshooting guides, and architecture documentation
- **Core Functionality**: Standard package sets for new Virtual Environments and improved package management

### Performance and Security
- **Security Enhancements**: Improved permission handling and secure configuration options
- **Performance Testing**: Enhanced NumPy/PyTorch testing tools with visualization and metrics
- **Optimization**: Improved file handling and parallel processing capabilities

### Tools and Integration
- **Chat Tools**: Enhanced conversation analytics and metadata extraction
- **User Interface**: Interactive modes and improved progress reporting
- **Integration**: Enhanced container support and remote environment management

For a complete list of planned improvements and current status, see the CHANGELOG.md and individual tool documentation in the docs/ directory.

## Recent Improvements

### Core Functionality
- Enhanced virtual environment management with `lenv` Python version display
- Added environment renaming capability with `renv`
- Improved cloning functionality in `ccln`
- Enhanced logging and configuration management

### Library Organization
- Renamed shell libraries to use `_lib.sh` suffix for better clarity
- Created specialized libraries for different functionalities
- Enhanced error handling and type checking
- Improved help system and initialization routines

### Performance Tools
- Added PyTorch and NumPy stress testing tools
- Implemented compilation tools and benchmarking
- Enhanced chat management utilities
- Improved documentation generation

### Documentation
- Added comprehensive performance metrics documentation
- Updated coding standards and file structure documentation
- Enhanced installation guide and function documentation
- Added migration guide for version 20250206-00_R1

For a complete list of changes, see our [CHANGELOG.md](CHANGELOG.md).
