# venvutil - Manage Conda and Pip VENV's with some simple functions and scripts

(*Still under development*) This project is continuously evolving, becoming a catch-all for useful tools and shell functions that facilitate working with Python VENV's and LLLM's.

- [venvutil - Manage Conda and Pip VENV's with some simple functions and scripts](#venvutil---manage-conda-and-pip-venvs-with-some-simple-functions-and-scripts)
  - [Project Overview](#project-overview)
    - [Key Features](#key-features)
    - [Why Use Venvutil?](#why-use-venvutil)
  - [Installation Instructions](#installation-instructions)
    - [Prerequisites](#prerequisites)
    - [Running the installer](#running-the-installer)
  - [Setup Script Enhancements](#setup-script-enhancements)
  - [Usage](#usage)
    - [Tools Overview](#tools-overview)
    - [Shell Functions](#shell-functions)
  - [Conda and Pip Logging](#conda-and-pip-logging)
  - [~~C++, G++, and~~ LD Pass-Through](#c-g-and-ld-pass-through)
    - [Purpose](#purpose)
    - [Explanation](#explanation)
  - [NLTK and Token Count](#nltk-and-token-count)
  - [Recent Changes](#recent-changes)
  - [Project Status](#project-status)
  - [Support My Work](#support-my-work)
  - [License](#license)
  - [Future Improvements](#future-improvements)

## Project Overview

Venvutil is a versatile toolset designed to simplify the management of Python virtual environments (VENV) and enhance the workflow for developers working with Python packages and large language models (LLMs). This project provides a collection of scripts and functions that wrap around common tools like Conda and Pip, offering additional features such as logging, environment state freezing, and streamlined package management.

### Key Features

- **Enhanced VENV Management**: Provides tools to easily create, manage, and replicate Python virtual environments and a few other tools.
- **Conda and Pip Logging**: Utilizes logging to track changes to VENV's and freeze the state of environments for reproducibility.
- **Enhanced Logging**: Maintains a log on any potentially destructive operations to VENV's when using Pip or Conda to make changes to the VENV.
- **Robust Configuration Management**:All configuration changes are logged and a `pip freeze` is done before and after the operation to ensure that the virtual environment is frozen.
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

## Installation Instructions

### Prerequisites

- Xcode command line utilities.
- Bash 4.0 or higher (macOS has Bash 3.2, you will need to build and install or use Brew)
- Python 3.11 (Conda will handle this for you when it installs)
- Conda latest version
- Python packages
  - Rich, ticktoken
- Ensure that your system meets the necessary requirements for running Python and Conda.

### Running the installer

```bash
git clone https://github.com/unixwzrd/venvutil.git venvutil
cd venvutil
bash ./setup.sh install
```

By default this installs in $HOME/local/venvutil. You can override this with the -d flag. To any location you wish. The installer will download and update Conda if necessary, along with the python packages listed above. NLTK needs data and that will be downloaded into your home directory into the nltk_data directory.

More updates will come in the next few days.

Thanks for using Venvutil!

## Setup Script Enhancements

- **Hard Link Creation**: Updated `setup.sh` to include functionality for creating hard links. This change addresses issues with C++/G++/ld symlink handling, ensuring that the correct executable is called.
- **Manifest Update**: The installer manifest now supports a hard link type (`h`) in addition to symbolic links (`l`). This allows for the specification of hard links directly in the manifest file.
- **Compatibility**: The hard link creation functionality has been tested on macOS and RedHat Linux, ensuring cross-platform compatibility.
- **Usage**: Use the `-h` flag in `setup.sh` to create hard links. This feature is currently untested, so proceed with caution.

## Usage

### Tools Overview

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
- **core functions provided by init_env.sh**: [Detailed Documentation](docs/shdoc/README.md)
  - Provides a number of useful shell functions for managing aVirtual Environments along with some utility function, such as `ptree`
  - **compile wrappers for C++, G++, and LD**: [Detailed Documentation](docs/compile_wrappers.md)
    - To help compile many things in the macOS Environment which incorrectly pass the linker the --version flag.

### Shell Functions

These are a few of the shell functions provided by venvutil which I find useful.  There is more documentation on the functions in the README of the [venvutil Tools](docs/shdoc/README.md). 

- **venvutil Tools**: [Detailed Documentation](docs/shdoc/README.md)
  - A collection of shell functions and scripts for managing Python virtual environments and LLMs.
- **vhelp**: [Detailed Documentation](docs/shdoc/bin/shinclude/functions/vhelp.md)
  - Integrated help for scripts and functions. `vhelp` is the main entry point for the help system.
- **ptree**: [Detailed Documentation](docs/shdoc/bin/shinclude/functions/ptree.md)
  - A shell function that displays a file tree structure of a directory, highlighting directories that contain certain files.
- **lenv**: [Detailed Documentation](docs/shdoc/bin/shinclude/functions/lenv.md)
  Provides a listing of all Pip and Conda managed environments, versions and date last updated.

  ```bash
  (base) [unixwzrd@xanax: ~]$ lenv | sort
  2024-10-16    seq311..base                        ~/miniconda3/envs/seq311..base
  2024-11-16  * base                                ~/miniconda3
  2024-11-30    pa1                                 ~/miniconda3/envs/pa1
  2024-11-30    pa1..base-3-10                      ~/miniconda3/envs/pa1..base-3-10
  2024-11-30    seq311.00.case-analitics            ~/miniconda3/envs/seq311.00.case-analitics
  2024-12-05    pa1.00.case-analytics               ~/miniconda3/envs/pa1.00.case-analytics
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

This logging combined with the frozen environments can be used to ensure that your virtual environments are consistent and reproducible as well as tracking changes and rolling back to a previous state. There are numerous commands which will work with Conda created and using either Pip or Conda for package management. I would like to add support for other package managers which may be used in a compatible virtual environments. Two useful commands are `lenv` which not only lists the environments, but also their last update date. The `ccln` command will clone the current venv and switch you to the cloned environment. There are many other useful commands and functions available, check out the [venv_functs.sh](docs/shdoc/bin/shinclude/venv_funcs_sh.md) file for more information.

Configuration options, logs and freezes are found in the `$HOME`

## ~~C++, G++, and~~ LD Pass-Through

Meson was fixed which gave me troubles tracking this down, so I am removing the hard links for c++ and g++, but leaving in the ld script pass-through just in case something else tries to invoke it using the wrong flag for `--version` when it needs to be `-v`, here are the instructions for building NumPy with the optimizations turned on. It also seems that after I built GCC, it conflicted with the Xcode c++ compiler, installing another c++ in /usr/local/bin which was simply a herd link to g++.

```bash
CFLAGS="-I/System/Library/Frameworks/vecLib.framework/Headers -Wl,-framework -Wl,Accelerate -framework Accelerate" pip install numpy==1.26.* --force-reinstall --no-deps --no-cache --no-binary :all: --no-build-isolation --compile -Csetup-args=-Dblas=accelerate -Csetup-args=-Dlapack=accelerate -Csetup-args=-Duse-ilp64=true
```

This will build and install NumPy 1.26 into your Python virtual environment. With the Accelerate Framework optimizations on, you can now use NumPy with Apple Silicon.

### Purpose

- These wrappers ensure that your existing build and compilation processes remain intact while using Venvutil.

### Explanation

- By wrapping these tools, Venvutil provides a seamless integration with your existing toolchain, ensuring compatibility and security.

## NLTK and Token Count

- **NLTK Installation**: The `venvutil` installation process includes the NLTK packages and `nltk_data`, which are necessary for the `tokencount` program.
- **Token Count**: The `tokencount` program can be invoked by `genmd` using the `-t` option to provide a token count of the markdown bundle.

## Recent Changes

- **Logging Enhancements**: Improved logging with dynamic program names and lazy formatting.
- **Configuration Management**: Introduced global variable declarations and robust configuration handling in `genmd`.

## Project Status

The project is actively maintained and continuously evolving with new features and improvements.

## Support My Work

If you find Venvutil helpful and would like to support my work, consider sponsoring me on [Patreon](https://www.patreon.com/) or buying me a coffee on [Buy Me a Coffee](https://www.buymeacoffee.com/). Your support helps me continue developing and maintaining this project and other projects. It is greatly appreciated as I pursue contract work opportunities and sponsorships.

Thank you for your support!

## License

```text
This project is licensed under the Apache License
                 Version 2.0, License.

 Copyright 2024 Michael P. Sullivan - unixwzrd@unixwzrd.ai

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

- **Chunkfile Enhancements**: 
  - Add support for custom chunk naming patterns
  - Add compression support for output chunks
  - Add support for automatic chunk size calculation based on available memory
  - Add support for paries.
- **l processing of chunks Virtual Environment Tools**: Continue to expand the collection of tools for managing virtual environments.
  - High on the list is `vinfo` and `venvdiff`
- **Additional Documentation**: Expand the documentation to include more examples and examples of using the tools.
- **Overall Enhancements**: Additional improvements and documentation are needed, but focus is shifting to other projects for now.
