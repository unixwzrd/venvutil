# venvutil - Manage Conda and Pip VENV's with some simple functions and scripts.
(*Still under development*) This project is continuously evolving, becoming a catch-all for useful tools and shell functions that facilitate working with Python VENV's and LLLM's.
- [venvutil - Manage Conda and Pip VENV's with some simple functions and scripts.](#venvutil---manage-conda-and-pip-venvs-with-some-simple-functions-and-scripts)
  - [Project Overview](#project-overview)
    - [Key Features](#key-features)
    - [Why Use Venvutil?](#why-use-venvutil)
  - [Installation Instructions](#installation-instructions)
    - [Prerequisites](#prerequisites)
    - [Download and Install Miniconda](#download-and-install-miniconda)
    - [Step 1: Create a Conda Environment](#step-1-create-a-conda-environment)
    - [VENV Management](#venv-management)
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

### Download and Install Miniconda

To install Miniconda, follow these steps:

```bash
mkdir -p "${HOME}/local/bin"
# Define the line to be appended
path_line='if [[ "$PATH" =~ "${HOME}/local/bin:" ]]; then PATH="${HOME}/local/bin:${PATH}"; fi'

# Check if the line already exists in .bashrc
if ! grep -Fxq "$path_line" ~/.bashrc; then
    # Append the line if it doesn't exist
    echo "$path_line" >> ~/.bashrc
fi
# Determine the OS and architecture to get the latest miniconda installer for this architecture from the official website.
  OS=$(uname -s)
  [ "$OS" == "Darwin" ] && OS="MacOSX"
  [ "$OS" == "Linux" ] && OS="Linux"
  ARCH=$(uname -m)
  ARCH=${ARCH//aarch64/arm64}
# Construct the URL for the miniconda installer
  INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-${OS}-${ARCH}.sh"
# Download the miniconda installer
  curl $INSTALLER_URL -o miniconda.sh
# Run the installer in non-destructive mode to preserve any existing installation.
  sh miniconda.sh -b -u
# Activate the Conda installation
  . "${HOME}/miniconda3/bin/activate"
# Initialize conda for your shell, this will update your .profile/.bashrc/.bash_profile or other profile for different shells.
  conda init $(basename "${SHELL}")
# Update the Conda base environment
  conda update -n base -c defaults conda -y
# Get a new login shell with th eupdated environment variables for Conda base environment.
  exec env -i bash -l
```

### Step 1: Create a Conda Environment
```bash
conda create -n myenv python=3.x
```

### VENV Management
- Use the provided scripts to manage your virtual environments efficiently.

## Usage

### Tools Overview
- **tokencount**: [Detailed Documentation](#)
  - A tool designed to count tokens in text files, useful for analyzing text data and preparing it for processing with language models.
- **chunkfile**: [Detailed Documentation](#)
  - A script for breaking large files into smaller, manageable chunks for easier processing.
- **genmd**: [Detailed Documentation](#)
  - A script that generates markdown documentation from project files, facilitating easy sharing and collaboration.

## Additional Resources
- Explore additional projects and tools that complement Venvutil.

## Support and Contribution
- Information on how to support the ongoing development of Venvutil.

## License
- Licensing information for the project.

## C++, G++, and LD Pass-Throughs

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