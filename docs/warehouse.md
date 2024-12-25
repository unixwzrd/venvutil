# warehouse and recall

Utilities for managing offline storage of files and directories.

## Overview

The `warehouse` and `recall` utilities provide a simple way to move files and directories to and from offline storage while maintaining access through symbolic links. This is particularly useful for:

- Moving large files or directories to external storage
- Freeing up space on the main drive
- Maintaining easy access to archived content
- Managing project archives

## Usage

```bash
warehouse file_or_directory    # Move to warehouse storage
recall file_or_directory      # Retrieve from warehouse storage
```

### Arguments

- `file_or_directory`: The name of the file or directory to warehouse/recall

### Environment Variables

- `ARCHIVE`: Override the default warehouse location (defaults to `/Volumes/ExtraSpace00/Warehouse`)

## How It Works

### Warehousing (`warehouse`)

1. When you warehouse a file or directory:
   - The content is copied to the warehouse location using tar
   - The original is removed from its location
   - A symbolic link is created in the original location pointing to the warehoused content

### Recalling (`recall`)

1. When you recall a file or directory:
   - The content is copied back from the warehouse using tar
   - The symbolic link is removed
   - The content is restored to its original location

## Features

- **Universal Handling**: Works with both individual files and entire directories
- **Symlink Management**: Automatically creates and manages symbolic links
- **Error Handling**: Validates operations and provides clear error messages
- **Path Handling**: Supports both relative and absolute paths
- **Reversible Operations**: Easy movement between active and warehouse storage
- **Data Integrity**: Uses tar for reliable content transfer
- **Link Protection**: Prevents operations that could corrupt symlinks

## Examples

1. Move a large project directory to warehouse:

   ```bash
   warehouse large-project
   ```

   This creates a symlink `large-project` pointing to `/Volumes/ExtraSpace00/Warehouse/large-project`

2. Warehouse a large file:

   ```bash
   warehouse huge-dataset.csv
   ```

   This moves the file to the warehouse and creates a symlink in its place

3. Recall a warehoused file:

   ```bash
   recall huge-dataset.csv
   ```

   This restores the file and removes the symlink

4. Use custom warehouse location:

   ```bash
   ARCHIVE=/path/to/storage warehouse large-file.dat
   ```

## Error Handling

The script handles various error conditions:

- Invalid number of arguments
- Failed tar operations
- Pathological symlink situations (symlinks in both source and destination)
- Failed moves or copies

## Implementation Details

- Uses tar for reliable content transfer
- Preserves file permissions and attributes
- Handles both individual files and directories
- Supports custom warehouse locations
- Maintains symbolic links for transparent access

## See Also

- `genmd`: Generate markdown documentation
- `filetree`: Display directory structure
