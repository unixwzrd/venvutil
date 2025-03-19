# extract_chat

A utility for extracting conversations from JSON chat files to Markdown or HTML format.

## Overview

`extract_chat` is a Python script that processes JSON files containing chat conversations and converts them to either Markdown or HTML format while preserving the conversation structure, message roles, timestamps, and special message types.

## Usage

```bash
extract_chat patterns [-o OUTPUT_DIR] [-f FORMAT]
```

### Arguments

- `patterns`: File patterns for JSON input files (e.g., `*.json` or specific filenames)

### Options

- `-o, --output-dir`: Output directory for the generated files
- `-f, --format`: Output format, either "markdown" or "html" (default: "markdown")

### Examples

1. Extract a single conversation to HTML format:

    ```bash
    extract_chat input.json -f html -o ./output/
    ```

2. Process multiple files at once to markdown:

    ```bash
    extract_chat ./chats/*.json -f markdown
    ```

3. Process all JSON files in current directory with default format (markdown):

    ```bash
    extract_chat *.json
    ```

## Output

The script creates files in the specified format with the following naming pattern:

```
{sanitized_title}_{timestamp}{extension}
```

For example:
- `project_discussion_2024-03-19-153045.md`
- `debugging_session_2024-03-19-153045.html`

## Features

### Message Role Handling

- **User Messages**: Formatted as user prompts with timestamps
- **Assistant Messages**: Formatted as responses with timestamps
- **System Messages**: Formatted as system instructions or notes
- **Tool Messages**: Formatted as collapsible sections in HTML or clearly marked sections in Markdown

### Content Processing

- **Code Block Handling**: Preserves code formatting with syntax highlighting hints
- **Code Fence Normalization**: Ensures consistent handling of code blocks with any number of backticks
- **Markdown Processing**: Detects and properly formats embedded markdown
- **Special Character Handling**: Properly escapes and handles special characters
- **UTF-8 Support**: Full Unicode character support

### File Handling

- **Batch Processing**: Process multiple files matching specified patterns
- **Custom Output Directory**: Specify where to save the generated files
- **Multiple Format Support**: Generate either Markdown or HTML output
- **Timestamp Preservation**: Include creation and update times in output

## Implementation Details

### Code Fence Normalization

The script includes a special `normalize_code_fences` function that ensures code blocks with any number of backticks (including nested code blocks) are properly rendered:

- Detects code fences with 4 or more backticks
- Normalizes them to exactly 3 backticks
- Preserves language identifiers
- Applies normalization at multiple processing stages:
  - During code block formatting
  - In regular message processing
  - During markdown detection and processing

This helps prevent rendering issues in both HTML and Markdown output, especially when dealing with nested code blocks.

### Text Cleaning

- Removes control characters while preserving essential whitespace
- Handles line endings consistently
- Normalizes Unicode characters as needed
- Preserves message structure and formatting

### Metadata Handling

- Extracts conversation titles for naming files
- Preserves creation and update timestamps
- Formats dates consistently
- Includes metadata in the document header

## Dependencies

- Python 3.6+
- ftfy: For text encoding fixes
- mistune: For Markdown processing
- Standard library: json, re, glob, datetime, etc.

## See Also

- `rename-chat`: Rename chat JSON files based on content
- `chunkfile`: Split files into manageable chunks 