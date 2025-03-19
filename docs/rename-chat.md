# rename-chat

A utility for renaming JSON chat files based on their content metadata.

## Overview

`rename-chat` is a Python script that processes JSON chat files and renames them using information extracted from the file contents, such as conversation titles and timestamps. This creates more meaningful filenames that make it easier to organize and find specific conversations.

## Usage

```bash
rename-chat [patterns] [-y] [-d DESTINATION]
```

### Arguments

- `patterns`: File patterns to process (wildcards, directories, etc.). If not specified, processes all JSON files in the current directory.

### Options

- `-y, --yes`: Auto-confirm all renames without prompting
- `-d, --destination`: Destination directory for renamed files

### Examples

1. Rename all JSON files in the current directory (with confirmation):

    ```bash
    rename-chat
    ```

2. Rename specific files with auto-confirmation:

    ```bash
    rename-chat conversation1.json conversation2.json -y
    ```

3. Rename all JSON files in a directory and move them to a different location:

    ```bash
    rename-chat path/to/chats/*.json -d path/to/organized/chats
    ```

4. Process all files in a directory:

    ```bash
    rename-chat ./chats/
    ```

## Output

The script renames files using the following pattern:

```
{create_timestamp}_{update_timestamp}-{sanitized_title}.json
```

For example:
- `2024-03-19-153045_2024-03-19-154832-project_discussion.json`

If a file with the same name already exists, a numeric suffix is added (e.g., `-01`, `-02`, etc.).

## Features

### Metadata Extraction

- Extracts conversation title from file content
- Uses creation and modification timestamps from metadata
- Falls back to file system timestamps if metadata is missing
- Sanitizes titles for safe filename usage

### Filename Generation

- Creates timestamps in consistent YYYY-MM-DD-HHMMSS format
- Handles timestamp format conversion automatically
- Generates unique filenames to avoid overwriting
- Supports moving files to a different directory during renaming

### User Experience

- Interactive confirmation for each rename operation
- Option to auto-confirm all renames
- Detailed error handling and informative messages
- Support for processing multiple files at once
- Default behavior to process current directory when no files specified

## Implementation Details

### Timestamp Handling

- Fixes overly large timestamps to standard Unix timestamp range
- Handles missing timestamps with appropriate fallbacks
- Consistent formatting across all renamed files

### Title Sanitization

- Replaces problematic characters with underscores
- Removes redundant punctuation
- Ensures valid and readable filenames
- Falls back to "untitled" for missing or invalid titles

### Destination Support

- Creates destination directory if it doesn't exist
- Supports both relative and absolute paths
- Properly handles path joining for different operating systems
- Maintains original file extension

## Dependencies

- Python 3.6+
- Standard library only (no external dependencies)

## See Also

- `extract-chat`: Extract conversations from JSON files to Markdown/HTML
- `chunkfile`: Split files into manageable chunks 