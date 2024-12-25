# Generate Manifest

## Overview

The `generate_manifest` script is a utility that generates a manifest file for the venvutil project. It creates a detailed listing of all project files and directories, including their types, permissions, sizes, and checksums. The script is essential for tracking project assets and is used by the installer to ensure proper file placement and integrity.

## Features

- Generates a pipe-separated manifest file (`manifest.lst`)
- Supports multiple file types:
  - `c` - Cancel (cremate), remove a deprecated file
  - `d` - Directory
  - `f` - File
  - `h` - Hard Link
  - `l` - Symbolic Link
- Automatically detects deleted files from git status
- Calculates file checksums using `shasum` or `sha1sum`
- Handles both GNU and BSD `stat` commands (Linux and macOS compatibility)
- Excludes hidden files and directories by default
- Supports custom inclusion of specific hidden directories
- Automatically sorts entries for consistency

## Usage

```bash
./generate_manifest
```

The script should be run from the root directory of the project. It will create or update the `manifest.lst` file.

## Manifest Format

Each entry in the manifest file follows this format:

| Field       | Description           | Required | Example   |
| ----------- | --------------------- | -------- | --------- |
| type        | File type (c/d/f/h/l) | Yes      | f         |
| destination | Target location       | Yes      | bin       |
| source      | Source location       | Yes      | bin       |
| name        | Object name           | Yes      | script.sh |
| permissions | Unix permissions      | No       | 755       |
| owner       | File owner            | No       | user      |
| group       | File group            | No       | staff     |
| size        | File size in bytes    | No       | 1024      |
| checksum    | SHA1 checksum         | No       | abc123... |

Example entries:

```config
# Manifest file for venvutil project
# This file uses pipe-separated fields

d |  |  | bin | 755 |  |  | 1088 | 
f |  |  | README.md | 644 |  |  | 14866 | f1f104b4cd8b74b18ee324021df6e84fafde9a9b
l | bin | warehouse.sh | recall | 755 |  |  | 12 | 
c | bin | | old_script | | | | |
```

## Implementation Details

The script performs the following operations:

1. Checks for Bash version 4.0 or higher
2. Determines the appropriate `stat` command for the system
3. Checks git status for deleted files and adds them as cancel entries
4. Processes specified files and directories:
    - `README.md`, `LICENSE`, `setup.sh`, `setup.cf`, `manifest.lst`
    - `bin`, `docs`, `conf` directories
5. Generates entries for each file/directory:
    - Determines file type
    - Calculates permissions and size
    - Generates checksums for files
    - Formats and writes entries to manifest
6. Sorts the final manifest file

## Handling Deprecated Files

The script handles deprecated files in two ways:

1. **Git Status Integration**: Automatically detects files that have been deleted from git (using `git status --porcelain`) and adds them as cancel entries in the manifest. This ensures that files removed from the repository will also be removed during installation.

2. **Manual Cancel Entries**: Supports manually adding `c` (cancel) type entries for files that should be removed during installation.

Example of cancel entries:

```config
# Automatically added from git status
c | bin | | deleted_script | | | | |

# Manually added
c | docs | | old_doc.md | | | | |
```

## Dependencies

- Bash 4.0 or higher
- `stat` command (GNU or BSD version)
- `shasum` or `sha1sum` for checksum generation
- `git` for deleted files detection (optional)
- Standard Unix tools: `find`, `sort`

## See Also

- [installer-manifest](installer-manifest.md) - Detailed manifest format specification
- [setup.sh](../setup.sh) - Installation script that uses the manifest
