# Configuration Files

## Manifest file for installation

### Assets

This described the manifest file for the installer. The types are

- c - Cancel (cremate), remove a deprecated file. Can be added manually or automatically detected from git status.
- d - Directory, create a directory.
- f - File, create a file.
- h - Hard Link, create a hard link.
- l - Symbolic Link, create a symbolic link.

- Data Structure

    | field number |     name      | required/optional |     default      |                                    description                                    |
    |------------|:------------|:------------------:|----------------|-------------------------------------------------------------------------------|
    |      1       |    `type`     |     required      | no default    | c, d, f, h, l, - Cancel, directory, file, hard link, or symbolic link       |
    |      2       | `destination` |     required      | no default    | Destination location of the object                         |
    |      3       |   `source`    |     required      | no default    | Source location of the object for a link this is the file or directory to link to |
    |      4       |    `name`     |     required      | no default    | Name of the object                                 |
    |      5       | `permissions` |     required      | no default    | Permissions of the object                             |
    |      6       |    `owner`    |     optional      | `/usr/bin/id -u` | Owner of the object                                |
    |      7       |    `group`    |     optional      | `/usr/bin/id -g` | Group of the object                                |
    |      8       |    `size`     |     optional      | no default    | Size of the object                                 |
    |      9       |  `checksum`   |     optional      | no default    | Checksum of the object                               |

- Layout

    | type | destination |   source   |    name    | permissions | owner | group | size  |   checksum   |
    |:----:|-------------|-----------|-----------|-------------|--------|-------|------|--------------|
    |  c  |     bin     | asset_name | link_name  |     755     | user  | staff |  30   | 3a2c0c5d7b5e |
    |  d  |     bin     |    bin     |  lib_dir   |    2755     | user  | staff |  30   |              |
    |  f  |             |            | README.md  |     644     | user  | staff |  30   | 3a2c0c5d7b5e |
    |  h  |     bin     | asset_name | link_name  |     755     | user  | staff |  30   | 3a2c0c5d7b5e |
    |  l  |     bin     |            | asset_name |             |       |       |       |              |

- Example

    ```data
    # This is a comment for the package manifest
    # This file uses tab separated fields
    c | bin | | old_file | | | | | 
    f | / | / | README.md | 644 | user | staff | 30 | 3a2c0c5d7b5e
    # The next line is a blank line

    h | bin | asset_name | link_name | 755 | user | staff | 30 | 3a2c0c5d7b5e
    l | bin | asset_name | link_name | 755 | user | staff | 30 | 
    d | bin | bin | shinclude | 2755 | user | staff | 30 | 
    ```

The manifest will be \t or tab separated values with # being a comment.
Blank lines will also be ignored.

### Cancel Entries

Cancel entries (`c` type) can be created in two ways:

1. **Automatically from Git**: When running `generate_manifest`, files that have been deleted from git (detected using `git diff --name-status main`) are automatically added as cancel entries.

2. **Manually**: You can manually add cancel entries for files that should be removed during installation.

Example of cancel entries:

```config
# Automatically added from git status
c | bin | | deleted_script | | | | |

# Manually added
c | docs | | old_doc.md | | | | |
```

## Installer Configuration File

Uses a pkg-config syntax allowing tools like pkg-config to get metadata for the application.

### Multi-user, Non-admin Installation

`pkg-config` retrieves information about packages from special metadata files. These files are named after the package, and has a .pc extension.  On most systems, `pkg-config` looks in `/usr/lib/pkgconfig`, `/usr/share/pkgconfig`, `/usr/local/lib/pkgconfig` and `/usr/local/share/pkgconfig` for these files.  It will additionally look in the colon-separated list of directories specified by the PKG_CONFIG_PATH environment variable.

### Non-privileged User Installation

For a non-privileged user, `pkg-config` data will be written to the user's $HOME/.pkgconfig directory.

### Metadata File Syntax

To add a library to the set of packages pkg-config knows about, simply install a .pc file. You should install this file to `libdir/pkgconfig`.

- Example pkg-config file

```conf
# Package Configuration File for venvutil

# Define variables
    # Note: in this repo the installer config lives at `setup/setup.cf`, and the installer
    # manifest is generated to `setup/manifest.lst` (not the project root).
    prefix=$HOME/local/venvutil
exec_prefix=${prefix}
libdir="${exec_prefix}/lib"
includedir=${prefix}/include
bindir=${exec_prefix}/bin
datadir=${prefix}/share
sysconfdir=${prefix}/etc
    include_files=("README.md" "LICENSE" "setup.sh" "setup.cf" "manifest.lst")
    include_dirs=("bin" "docs" "conf" "modules")

# Package metadata
Name: venvutil
Description: Virtual Environment Utilities
Description: "${TERM} Virtual Environment Utilities"
Version: 0.4.0
Repository: https://github.com/unixwzrd/venvutil
License: Apache License, Version 2.0
Support: https://github.com/unixwzrd/venvutil/issues
Contribute: https://patreon.com/unixwzrd
Contribute: https://www.ko-fi.com/unixwzrd

# Dependencies (if any)
Requires: python >= 3.10
Requires: bash >= 4.0
Requires: Conda >= 22.11
Requires: macOS
Requires: Linux
Conflicts:

# Compiler and linker flags (if applicable)
# Cflags: -I${includedir}
# Libs: -L${libdir} -lvenvutil
```

You would normally generate the file using configure, so that the prefix, etc. are set to the proper values.  The GNU Autoconf manual recommends generating files like .pc files at build time rather than configure time, so when you build the .pc file is a matter of taste and preference.

Files have two kinds of line: keyword lines start with a keyword plus a colon, and variable definitions start with an alphanumeric string plus an equals sign. Keywords are defined in advance and have special meaning to pkg-config; variables do not, you can have any variables that you wish (however, users may expect to retrieve the usual directory name variables).

- **Note** that variable references are written `"${foo}"`; you can escape literal `"${"` as `"$${"`.
- **Note** Array variables may be written as `include_dir=("bin" "docs" "conf" "modules")` or `include_dir=(${include_dir[@]})`
- **Note** Keywords which are repeated with different values will be merged into a single array using the keyword as the variable name.
- **Note** Key Value consist of the Keyword followed by a `:` and then the value, which may contain any characters.
- **Note** If there is a space between the `:` and the value, it is ignored.
- **Note** The value may or may not have "quotes" around it.
- **Note** There may be variables in any location in the values.
