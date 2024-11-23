# venvutil - Manage Conda and Pip VENV's with some simple functions and scripts

(*Still under development*) This project is continuously evolving, becoming a catch-all for useful tools and shell functions that facilitate working with Python VENV's and LLLM's.

- [venvutil - Manage Conda and Pip VENV's with some simple functions and scripts](#venvutil---manage-conda-and-pip-venvs-with-some-simple-functions-and-scripts)
  - [Project Overview](#project-overview)
    - [Key Features](#key-features)
    - [Why Use Venvutil?](#why-use-venvutil)
  - [Installation Instructions](#installation-instructions)
    - [Prerequisites](#prerequisites)
    - [Running the installer](#running-the-installer)
  - [Usage](#usage)
    - [Tools Overview](#tools-overview)
  - [Additional Resources](#additional-resources)
  - [Support and Contribution](#support-and-contribution)
  - [License](#license)
  - [C++, G++, and LD Pass-Throughs](#c-g-and-ld-pass-throughs)
    - [Purpose](#purpose)
    - [Explanation](#explanation)
  - [NLTK Installation Guide](#nltk-installation-guide)
    - [Library Installation](#library-installation)
    - [Data Installation](#data-installation)
  - [Support My Work](#support-my-work)
  - [License](#license-1)

## Project Overview

Venvutil is a versatile toolset designed to simplify the management of Python virtual environments (VENV) and enhance the workflow for developers working with Python packages and large language models (LLMs). This project provides a collection of scripts and functions that wrap around common tools like Conda and Pip, offering additional features such as logging, environment state freezing, and streamlined package management.

### Key Features

- **Enhanced VENV Management**: Provides tools to easily create, manage, and replicate Python virtual environments.
- **Conda and Pip Wrappers**: Includes wrapper scripts for Conda and Pip that log actions and freeze the state of environments for reproducibility.
- **Cross-Platform Compatibility**: Designed to work seamlessly on macOS and Linux systems, with specific optimizations for Apple Silicon.
- **Build and Installation Scripts**: Offers scripts to automate the setup of complex environments, including rebuilding NumPy with Apple Silicon optimizations.
- **Comprehensive Documentation**: Includes detailed instructions and changelogs to help users get started and stay updated with the latest features.

### Why Use Venvutil?

- **Simplify Environment Management**: Automate the tedious tasks of setting up and maintaining Python environments, saving time and reducing errors.
- **Ensure Reproducibility**: By freezing the state of environments, Venvutil helps ensure that your setups are consistent across different machines and setups.
- **Transparent Tool Wrapping**: Provides pass-through wrappers for C++, G++, and LD to ensure compatibility without compromising security or functionality.

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

## Usage

### Tools Overview

- **tokencount**: [Detailed Documentation](#)
  - A tool designed to count tokens in text files, useful for analyzing text data and preparing it for processing with language models.
- **chunkfile**: [Detailed Documentation](#)
  - A script for breaking large files into smaller, manageable chunks for easier processing.
- **genmd**: [Detailed Documentation](#)
  - A script that generates markdown documentation from project files, facilitating easy sharing and collaboration.
- **filetree**: [Detailed Documentation](#)
  - will produce file hierarchy structure based on file and directories to exclude and include..
- **core functions provided by init_env.sh**: [Detailed Documentation](#)
  - Provides a number of useful shell functions for managing aVirtual Environments along with some utility function, such as `ptree`
  - **compile wrappers for C++, G++, and LD**: [Detailed Documentation](#)
    - To help compile many things in the macOS Environment which incorrectly pass the linker the --version flag.
  
## Additional Resources

- Explore additional projects and tools that complement Venvutil.

## Support and Contribution

- Information on how to support the ongoing development of Venvutil.

## License

- Licensing information for the project.

## C++, G++, and LD Pass-Throughs

These are specific wrappers for C++, G++, and LD that ensure compatibility without compromising security or functionality, but are necessary work-arounds on macOS  in order to take advantage of Apple Silicon optimizations for NumPy and other packages. This will allow them to take advantage of the GPU and NEON optimizations. This was necessary due to the Meson integration into the Pip recompile.

briefly, here are the instructions for building NumPy with the optimizations turned on.

```bash
CFLAGS="-I/System/Library/Frameworks/vecLib.framework/Headers -Wl,-framework -Wl,Accelerate -framework Accelerate" pip install numpy==1.26.* --force-reinstall --no-deps --no-cache --no-binary :all: --no-build-isolation --compile -Csetup-args=-Dblas=accelerate -Csetup-args=-Dlapack=accelerate -Csetup-args=-Duse-ilp64=true
```

That will build and install NumPy 1.26 into your Python virtual environment.

### Purpose

- These wrappers ensure that your existing build and compilation processes remain intact while using Venvutil.

### Explanation

- By wrapping these tools, Venvutil provides a seamless integration with your existing toolchain, ensuring compatibility and security.

## NLTK Installation Guide

### Library Installation

- Install the NLTK library within a Python virtual environment using Conda:

```bash
conda install -n myenv nltk
```

### Data Installation

- The NLTK data can be installed separately and shared across different library versions.
- Consider installing the data in `/usr/local/share` or the user's home directory for efficiency.
- For detailed instructions, visit the [NLTK website](https://www.nltk.org/data.html).

This README provides a comprehensive overview of the Venvutil project, its features, and usage instructions. For more detailed information, refer to the documentation files included in the project.

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
