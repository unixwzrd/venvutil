# ChatGPT Log Management Tools

## Overview
The chat log management tools work in conjunction with the [ChatGPT Chat Log Export Safari Extension](https://github.com/unixwzrd/chatgpt-chatlog-export) to provide a complete solution for exporting, processing, and managing ChatGPT conversations.

## Tools

### extract-chat
A Python script for converting ChatGPT JSON chat logs to readable Markdown or HTML format.

#### Features
- Supports both Markdown and HTML output formats
- Preserves conversation structure and formatting
- Handles system messages, user messages, and tool outputs
- Maintains timestamps and metadata
- Supports batch processing of multiple files

#### Usage
```bash
extract-chat [-h] [-o OUTPUT_DIR] [--format {markdown,html}] patterns [patterns ...]
```

The chat markdown or html files will be placed in the specified directory and use the naming convention START_TIME_END_TIME_Chat_name.[html|md].

#### Parameters
- `patterns`: One or more JSON files or directories to process
- `-o, --output-dir`: Output directory for converted files
- `--format`: Output format (markdown or html, default: markdown)

#### Example Usage
```bash
# Convert a single file
extract-chat conversation.json

# Convert all JSON files in a directory to HTML
extract-chat ./chats/*.json --format html --output-dir ./converted/

# Process specific files
extract-chat chat1.json chat2.json --format markdown
```

### rename-chat
Utilities for managing and organizing chat log files.

#### Features
- Rename chat files based on content
- Extract titles and dates
- Organize files into directories
- Handle duplicate files

The Python (`rename-chat.py`) may also be invoked using `rename-chat`.

This will rename the chat logs from the OpenAI naming convention to the START_TIME_END_TIME_Chat_name.json format. In the event of collisions, it will increment a counter and prepend it before the .json extension.

## Integration with Safari Extension

1. Install the [ChatGPT Chat Log Export Extension](https://github.com/unixwzrd/chatgpt-chatlog-export)
2. Export conversations from ChatGPT using the extension
3. Process the exported JSON files using these tools

## Output Formats

### Markdown
- Clean, readable format
- Compatible with most Markdown viewers
- Preserves code blocks and formatting
- Includes metadata and timestamps

### HTML
- Rich formatting with syntax highlighting
- Dark mode support
- Collapsible sections for tool outputs
- Responsive design for better readability
- Using a web browser they may be searched and printed to PDF.

## Future Improvements

Planned enhancements:
- Conversation analytics and statistics
- Tag-based organization
- Integration with other chat platforms
- Enhanced metadata extraction 