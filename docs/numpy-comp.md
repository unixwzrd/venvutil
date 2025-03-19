# numpy-comp

A utility for compiling optimized NumPy installations with Apple Accelerate framework.

## Overview

`numpy-comp` is a Bash script that facilitates the installation of specific versions of NumPy compiled with optimizations for macOS using the Apple Accelerate framework. The script ensures that only compatible versions (1.26.0 or higher) are installed and provides clear feedback throughout the process.

## Usage

```bash
numpy-comp [VERSION]
```

### Arguments

- `VERSION`: (Optional) The NumPy version to install. If not specified, defaults to the latest 1.26.x version.

### Examples

1. Install the default version (latest 1.26.x):

    ```bash
    numpy-comp
    ```

2. Install a specific version:

    ```bash
    numpy-comp 1.26.2
    ```

3. Install the latest version in a specific series:

    ```bash
    numpy-comp 1.26.*
    ```

## Features

### Version Handling

- **Version Validation**: Ensures only NumPy 1.26.0 or higher is installed
- **Wildcard Support**: Handles wildcard notation (e.g., `1.26.*`) for latest in a series
- **Default Version**: Uses latest 1.26.x if no version is specified
- **User Confirmation**: Prompts for confirmation before proceeding with default

### Optimized Compilation

- **Apple Accelerate Integration**: Compiles NumPy with Apple's Accelerate framework
- **BLAS/LAPACK Optimization**: Uses accelerated math libraries
- **ILP64 Support**: Enables large array support
- **Clean Installation**: Reinstalls from source without cached packages

### User Experience

- **Clear Messaging**: Provides descriptive status and error messages
- **Validation Feedback**: Shows version comparison information
- **Installation Status**: Displays progress information

## Implementation Details

### Version Parsing

- Handles wildcard version specifications
- Converts version strings to numeric format for comparison
- Validates version formats and ranges
- Provides helpful error messages for invalid versions

### Compilation Flags

- Sets appropriate compiler flags for Accelerate framework
- Configures NumPy to use optimized BLAS/LAPACK implementations
- Ensures proper header inclusion from vecLib framework
- Enables 64-bit integer support for large arrays

### Installation Process

- Forces clean reinstallation to avoid cached binaries
- Disables build isolation for consistent environment
- Uses pip flags to ensure proper compilation from source
- Applies consistent configuration across installations

## Requirements

- macOS with Accelerate framework
- Python and pip installed
- Development tools (compiler, etc.)

## Limitations

- Only compatible with NumPy 1.26.0 and higher
- Specifically optimized for macOS
- May require additional setup for certain Python environments

## See Also
 
- Python's NumPy package: https://numpy.org/
- Apple's Accelerate framework documentation 