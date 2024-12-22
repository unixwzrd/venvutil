# chunkfile

A utility for splitting files into chunks with optional overlap.

## Overview

`chunkfile` is a Python script that splits files into multiple chunks based on various criteria. It supports three modes of operation:

1. Split by number of chunks (-n)
2. Split by chunk size (-s)
3. Split by number of lines (-l)

Each mode supports overlapping content between chunks to preserve context across chunk boundaries.

## Usage

```bash
chunkfile filename [-n NUM_CHUNKS] [-s SIZE] [-l LINES] [-o OVERLAP]
```

### Arguments

- `filename`: The file to split

### Options

- `-n, --num_chunks`: Number of chunks to create
- `-s, --size`: Size of each chunk in bytes
- `-l, --lines`: Number of lines per chunk
- `-o, --overlap`: Number of bytes/lines to overlap between chunks (default: 0)

You must specify exactly one of: `-n`, `-s`, or `-l`.

### Examples

1. Split a file into 10 chunks with 100-byte overlap:

    ```bash
    chunkfile large_file.txt -n 10 -o 100
    ```

2. Split a file into 2048-byte chunks with 50-byte overlap:

    ```bash
    chunkfile large_file.txt -s 2048 -o 50
    ```

3. Split a file into chunks of 1000 lines with 10-line overlap:

    ```bash
    chunkfile large_file.txt -l 1000 -o 10
    ```

## Output

The script creates numbered chunks with the following naming pattern:

```
{original_name}_{number:02}{extension}
```

For example, splitting `input.txt` would create:

- `input_01.txt`
- `input_02.txt`
- etc.

## Features

### Line-based Chunking (-l)

- Splits file into chunks with exact number of lines
- Preserves complete lines
- Supports line overlap between chunks
- Removes trailing newlines to prevent extra blank lines

### Byte-based Chunking (-n, -s)

- Splits file into chunks of exact byte size
- Supports byte overlap between chunks
- Handles partial reads and end-of-file conditions
- Preserves binary content

### Overlap Support (-o)

- Maintains context between chunks
- Configurable overlap size
- Works with both line and byte modes
- Ensures consistent chunk sizes

## Error Handling

The script validates inputs and provides clear error messages for:

- Missing required arguments
- Invalid chunk sizes
- Overlap larger than chunk size
- Non-positive numbers
- File access issues

## Implementation Details

### Line Mode

- Reads file line by line
- Maintains overlap buffer
- Handles UTF-8 and binary files
- Preserves line endings except for trailing newline

### Byte Mode

- Uses efficient block reading
- Maintains overlap buffer
- Handles partial reads
- Preserves binary content exactly

## Dependencies

- Python 3.6+
- Standard library only (no external dependencies)

## See Also

- `genmd`: Generate markdown documentation
- `filetree`: Display directory structure
