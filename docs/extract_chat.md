# extract_chat

A utility for extracting conversations from JSON chat files to Markdown or fully interactive HTML format, with advanced support for tool calls and citations.

## Overview

`extract_chat` is a Python script that processes JSON files containing chat conversations and converts them to either Markdown or HTML. It is designed to preserve the conversation structure, message roles, timestamps, and special message types, with a focus on producing traceable and readable output for legal and analytical purposes.

## Usage

```bash
extract_chat patterns [-o OUTPUT_DIR] [--html]
```

### Arguments

- `patterns`: File patterns for JSON input files (e.g., `*.json` or specific filenames).

### Options

- `-o, --output-dir`: Output directory for the generated files.
- `--html`: Generate HTML output instead of the default Markdown.

## Output

The script creates files in the specified format with the following naming pattern:

```
{sanitized_title}_{timestamp}{extension}
```

## Features

### Advanced Rendering

- **Tool Call Rendering**: Tool calls are rendered inline immediately following the assistant message that triggered them. Each tool call is enclosed in its own collapsible `<details>` block, creating a "window-shaded" view that keeps the main conversation flow clean while providing easy access to tool details.
- **Interactive HTML**: The generated HTML is fully interactive, with working collapsible sections for tool calls and clickable citation links.

### Robust Citation System

The script features a sophisticated, single-pass citation system designed for accuracy and traceability:

- **Global Numbering**: Citations are numbered sequentially based on their first appearance across the entire document, ensuring consistent references.
- **Reliable Linking**: In-text citations are rendered as superscript links (e.g., `<sup>1</sup>`) that navigate directly to the corresponding entry in the citation list. This works in both Markdown and the final HTML output.
- **Formatted Citation Lists**: A list of citations is automatically generated after each message that contains them.
- **Traceable Anchors**: Each citation in the list is an anchor with a unique ID, formatted to include the citation number, source JSON index, and line numbers (e.g., `Citation 1 (index, L10-L20)`), providing precise traceability back to the source.
- **Source Links**: Each citation entry includes a link to the original source URL.

### Content Processing

- **Code Block Handling**: Preserves code formatting with syntax highlighting hints.
- **Code Fence Normalization**: Ensures consistent handling of code blocks with any number of backticks.
- **UTF-8 Support**: Full Unicode character support.

## Dependencies

- Python 3.6+
- `pydantic`: For data validation.
- `mistune`: For Markdown to HTML conversion.
- `pygments`: For syntax highlighting CSS.

## See Also

- `rename-chat`: Rename chat JSON files based on content.
- `chunkfile`: Split files into manageable chunks.