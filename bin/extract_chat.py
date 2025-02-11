#!/usr/bin/env python
"""
This script extracts conversation logs from JSON files and saves them as Markdown or HTML files.

The script processes JSON files containing chat conversations and converts them to either Markdown
or HTML format while preserving the conversation structure, timestamps, and special message types.

Key features:
- Supports both Markdown and HTML output formats
- Handles system, user, assistant and tool messages
- Preserves message timestamps and ordering
- Processes code blocks and embedded markdown
- Generates unique filenames based on conversation metadata
- Supports batch processing of multiple files

Example usage:
    python extract_chat.py input.json --format html --output-dir ./output/
    python extract_chat.py ./chats/*.json --format markdown
"""

import argparse
import glob
import html
import json
import os
import re
import unicodedata
from datetime import datetime
from typing import Dict, List, Optional, Tuple

import ftfy
import mistune

# Date/time formats
FILENAME_DATE_FORMAT = "%Y-%m-%d-%H%M%S"
DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S"
VALID_MESSAGE_ROLES = {"assistant", "system", "user"}
HTML_TEMPLATE_HEADER = """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{title}</title>
    <style>
body {{
    color: #e8e8e8;
    background-color: #111111;
    font-family: Arial, sans-serif;
    line-height: 1.2;
    max-width: 900px;
    margin: 0 auto;
    padding: 20px;
    font-size: 12pt;
}}

p {{
    margin: 5px 0;
}}

h1 {{
    color: #f8f8f8;
    font-size: 24pt;
}}

h2 {{
    color: #efefef;
    margin-top: 30px;
    font-size: 18pt;
}}

pre {{
    background-color: #303030;
    padding: 5px;
    border-radius: 5px;
    overflow-x: auto;
    font-size: 10pt;
    line-height: 1;
    margin: 0.5em 0;
    font-family: monospace;
    white-space-collapse: preserve;
    text-wrap-mode: wrap;
}}

code {{
    font-family: 'Courier New', Courier, monospace;
    font-size: 10pt;
    line-height: 1.0;
    display: block;
    white-space-collapse: preserve;
    text-wrap-mode: wrap;
}}

.timestamp {{
    color: #cecece;
    font-size: 9pt;
}}

.tool-message {{
    background-color: #222244;
    border: 1px solid #c8e1ff;
    padding: 10px;
    margin: 10px 0;
    border-radius: 5px;
}}

.tool-message summary {{
    cursor: pointer;
    color: #92c1f7;
}}

details {{
    margin: 10px 0;
}}
    </style>
</head>
<body>
<h1>{title}</h1>
<p class="timestamp">Starting: {start_time}<br>Ending: {end_time}</p>
"""
HTML_TEMPLATE_FOOTER = """</body></html>"""


def fix_timestamp(ts: Optional[float]) -> Optional[float]:
    """
    Fix overly large timestamps by moving the decimal point to get a valid Unix timestamp.

    Args:
        ts: Input timestamp that may need fixing

    Returns:
        Fixed timestamp in Unix timestamp range (~10 digits), or None if input was None

    Example:
        >>> fix_timestamp(1234567890)  # Already valid
        1234567890
        >>> fix_timestamp(1234567890123)  # Too large
        1234567.890123
    """
    if ts is None:
        return None
    # Convert to string to count digits before decimal
    ts_str = str(float(ts))
    whole_digits = ts_str.split('.', maxsplit=1)[0]
    # If more than 10 digits before decimal, adjust
    if len(whole_digits) > 10:
        power = len(whole_digits) - 10
        return float(ts) / (10**power)
    return float(ts)


def format_timestamp(ts: Optional[float]) -> str:
    """
    Format a numeric timestamp into a human-readable date/time string.

    Args:
        ts: Unix timestamp to format

    Returns:
        Formatted string in YYYY-MM-DD HH:MM:SS format, or empty string if invalid

    Example:
        >>> format_timestamp(1234567890)
        '2009-02-13 23:31:30'
        >>> format_timestamp(None)
        ''
    """
    ts_fixed = fix_timestamp(ts)
    if ts_fixed is None:
        return ""
    dt = datetime.fromtimestamp(ts_fixed)
    return dt.strftime(DATETIME_FORMAT)


def parse_datetime_string(dt_str: str) -> datetime:
    """
    Parse a datetime string in YYYY-MM-DD HH:MM:SS format.

    Args:
        dt_str: Datetime string to parse

    Returns:
        Parsed datetime object, or current time if parsing fails

    Example:
        >>> parse_datetime_string('2023-01-01 12:00:00')
        datetime.datetime(2023, 1, 1, 12, 0)
    """
    try:
        return datetime.strptime(dt_str, DATETIME_FORMAT)
    except ValueError:
        return datetime.now()


def sanitize_title(title: str) -> str:
    """
    Sanitize a title string for use in filenames.

    Args:
        title: Input title string

    Returns:
        Sanitized title with problematic characters replaced by underscores

    Example:
        >>> sanitize_title('Hello, World!')
        'Hello_World'
        >>> sanitize_title('')
        'untitled'
    """
    s = re.sub(r"[^\w\-.]", "_", title)
    s = re.sub(r"_+", "_", s).strip("._-")
    return s or "untitled"


def generate_unique_filename(
    input_file: str,
    title: str,
    create_time: Optional[float],
    update_time: Optional[float],
    extension: str = "json",
    out_dir: Optional[str] = None
) -> str:
    """
    Generate a unique filename for the output file.

    Args:
        input_file: Original input filename
        title: Title for the output file
        create_time: Creation timestamp
        update_time: Last update timestamp
        extension: File extension (default: 'json')
        out_dir: Optional output directory

    Returns:
        Generated unique filename in format: YYYY-MM-DD-HHMMSS_YYYY-MM-DD-HHMMSS-TITLE.ext

    Raises:
        ValueError: If create_time is invalid or too many filename collisions occur

    Example:
        >>> generate_unique_filename('input.json', 'Test', 1234567890, 1234567890)
        '2009-02-13-233130_2009-02-13-233130-Test.json'
    """
    # Fix both timestamps
    ctime_fixed = fix_timestamp(create_time)
    utime_fixed = fix_timestamp(update_time)

    if ctime_fixed is None:
        raise ValueError("Invalid or missing create_time")

    # If update_time is missing, use create_time
    if utime_fixed is None:
        utime_fixed = ctime_fixed

    # Convert each to string
    ctime_str = datetime.fromtimestamp(ctime_fixed).strftime(FILENAME_DATE_FORMAT)
    utime_str = datetime.fromtimestamp(utime_fixed).strftime(FILENAME_DATE_FORMAT)
    cleaned_title = sanitize_title(title)

    dir_path = out_dir if out_dir else os.path.dirname(input_file)
    os.makedirs(dir_path, exist_ok=True)

    base_name = f"{ctime_str}_{utime_str}-{cleaned_title}"
    filename = os.path.join(dir_path, f"{base_name}.{extension}")

    counter = 0
    while os.path.exists(filename):
        counter += 1
        if counter > 99:
            raise ValueError(f"Too many duplicates for {filename}")
        filename = os.path.join(dir_path, f"{base_name}-{counter:02d}.{extension}")
    return filename


def load_json_file(file_path: str) -> Optional[Dict]:
    """
    Load and parse a JSON file.

    Args:
        file_path: Path to JSON file to load

    Returns:
        Parsed JSON data as dict, or None if loading/parsing fails

    Example:
        >>> data = load_json_file('valid.json')
        >>> type(data)
        <class 'dict'>
        >>> load_json_file('invalid.json')
        None
    """
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        if isinstance(data, dict):
            return data
        print(f"Error: {file_path} did not contain a JSON object.")
    except Exception as e:
        print(f"Error reading JSON from {file_path}: {e}")
    return None


def is_tool_message(message_role: str) -> bool:
    """
    Check if a message role represents a tool message.

    Args:
        message_role: Message role string to check

    Returns:
        True if role is not one of the standard roles (user/system/assistant)

    Example:
        >>> is_tool_message('user')
        False
        >>> is_tool_message('code_interpreter')
        True
    """
    return message_role not in VALID_MESSAGE_ROLES


def normalize_newlines(input_text: str) -> str:
    """
    Normalize multiple consecutive newlines to single newlines.

    Args:
        input_text: Input text to normalize

    Returns:
        Text with consecutive newlines collapsed to single newlines

    Example:
        >>> normalize_newlines('line1\\n\\n\\nline2')
        'line1\\nline2'
    """
    return re.sub(r"\n{2,}", "\n", input_text)


# -----------------------------------------------------------------------------
# Markdown Utilities
# -----------------------------------------------------------------------------
def detect_markdown(input_text: str) -> List[Tuple[int, int, str]]:
    """
    Detect markdown segments within text using Mistune parser.

    Args:
        input_text: Input text to analyze for markdown

    Returns:
        List of tuples containing:
        - Start position in text
        - End position in tex
        - Raw markdown content

    Example:
        >>> detect_markdown('Normal text **bold** more text')
        [(12, 18, '**bold**')]
    """
    markdown_segments: List[Tuple[int, int, str]] = []
    current_position = 0

    try:
        markdown_parser = mistune.create_markdown()
        abstract_syntax_tree = markdown_parser.parse(input_text)

        def process_token(token):
            nonlocal current_position
            if not isinstance(token, dict):
                return

            # If 'raw' is present, we can attempt to locate it in the original text.
            if token.get("type") != "text" and "raw" in token:
                raw_markdown = token["raw"]
                start_index = input_text.find(raw_markdown, current_position)
                if start_index != -1:
                    end_index = start_index + len(raw_markdown)
                    markdown_segments.append((start_index, end_index, raw_markdown))
                    current_position = end_index

            # Recurse over children
            for child_token in token.get("children", []):
                process_token(child_token)

        for token in abstract_syntax_tree:
            process_token(token)

        return sorted(markdown_segments, key=lambda x: x[0])
    except Exception as error:
        print(f"Warning: Error parsing markdown: {error}")
        return []


def format_text_block(text_content: str, output_format: str) -> List[str]:
    """
    Format a text block for output in HTML or Markdown.

    Args:
        text_content: Text content to format
        output_format: Output format ('html' or 'markdown')

    Returns:
        List of formatted text lines

    Example:
        >>> format_text_block('Hello **world**', 'html')
        ['<p>Hello <strong>world</strong></p>\\n', '\\n\\n']
    """
    formatted_lines = []
    if output_format == "html":
        html_content = mistune.create_markdown(
            plugins=["strikethrough", "footnotes", "table"], escape=True
        )(text_content)
        formatted_lines.append(html_content)
    else:
        formatted_lines.append(text_content)
    formatted_lines.append("\n\n")
    return formatted_lines


def format_code_block(
    code_content: str, programming_language: str, output_format: str
) -> List[str]:
    """
    Format a code block for output in HTML or Markdown.

    Args:
        code_content: Code content to format
        programming_language: Programming language for syntax highlighting
        output_format: Output format ('html' or 'markdown')

    Returns:
        List of formatted code block lines

    Example:
        >>> format_code_block('print("hello")', 'python', 'markdown')
        ['```python\\nprint("hello")\\n```\\n\\n']
    """
    formatted_lines = []
    if output_format == "html":
        escaped_code = html.escape(code_content)
        formatted_lines.append(
            f'<pre><code class="language-{programming_language}">{escaped_code}</code></pre>\n'
        )
    else:
        formatted_lines.append(f"```{programming_language}\n{code_content}\n```\n\n")
    return formatted_lines


# -----------------------------------------------------------------------------
# Heading and Tool Message Helpers
# -----------------------------------------------------------------------------
def generate_heading(
    message_role: str, timestamp: str, output_format: str
) -> List[str]:
    """
    Generate appropriate heading for a message based on role.

    Args:
        message_role: Message role (user/system/assistant/tool)
        timestamp: Message timestamp string
        output_format: Output format ('html' or 'markdown')

    Returns:
        List of formatted heading lines

    Example:
        >>> generate_heading('user', '2023-01-01 12:00:00', 'markdown')
        ['## **USER**\\n\\n', '<sub>2023-01-01 12:00:00</sub>\\n\\n']
    """
    heading_lines: List[str] = []
    if is_tool_message(message_role):
        if output_format == "html":
            heading_lines.append(
                f'<details class="tool-message">\n<summary>Tool Message: {message_role}</summary>\n'
            )
            if timestamp:
                heading_lines.append(f'<span class="timestamp">{timestamp}</span>\n')
        else:
            heading_lines.append(
                f"## **TOOL - {message_role.replace('_', ' ').title()}**\n"
            )
            if timestamp:
                heading_lines.append(f"<sub>{timestamp}</sub>\n")
            heading_lines.append("<details>\n<summary>\nContents:\n</summary>\n\n")
    else:
        # Standard role headings
        if output_format == "html":
            heading_lines.append(f"<h2>{message_role.upper()}</h2>\n")
            if timestamp:
                heading_lines.append(f'<span class="timestamp">{timestamp}</span>\n')
        else:
            heading_lines.append(f"## **{message_role.upper()}**\n\n")
            if timestamp:
                heading_lines.append(f"<sub>{timestamp}</sub>\n\n")
    return heading_lines


def close_tool_message_block(message_role: str, output_format: str) -> str:
    """
    Generate closing tags for tool message blocks if needed.

    Args:
        message_role: Message role
        output_format: Output format ('html' or 'markdown')

    Returns:
        Closing tags string if role is tool message, empty string otherwise

    Example:
        >>> close_tool_message_block('code_interpreter', 'html')
        '</details>\\n'
    """
    if not is_tool_message(message_role):
        return ""
    return "</details>\n" if output_format == "html" else "</details>\n\n"


# -----------------------------------------------------------------------------
# Handling Tool Message Content
# -----------------------------------------------------------------------------
def process_file_listing(listing_content: str, timestamp: str) -> List[str]:
    """
    Process file listing content into details blocks.

    Args:
        listing_content: File listing text content
        timestamp: Message timestamp string

    Returns:
        List of formatted lines with details blocks for each file

    Example:
        >>> process_file_listing('- **file.txt**\\ncontents', '2023-01-01')
        ['<details>\\n', '<summary>\\n', '- **file.txt**\\n', '<sub>2023-01-01</sub>\\n',
         '</summary>\\n\\n', 'contents\\n', '</details>\\n\\n']
    """
    formatted_lines: List[str] = []
    currently_in_file_block = False
    for line in listing_content.split("\n"):
        line_stripped = line.strip()
        if not line_stripped:
            continue

        if line_stripped.startswith("- **") and line_stripped.endswith("**"):
            # Start a new details block if needed
            if currently_in_file_block:
                formatted_lines.append("</details>\n\n")
            formatted_lines.append("<details>\n<summary>\n")
            formatted_lines.append(f"{line_stripped}\n")
            if timestamp:
                formatted_lines.append(f"<sub>{timestamp}</sub>\n")
            formatted_lines.append("</summary>\n\n")
            currently_in_file_block = True
        elif currently_in_file_block:
            # Continue the listing
            formatted_lines.append(f"{line_stripped}\n")

    if currently_in_file_block:
        formatted_lines.append("</details>\n\n")
    return formatted_lines


def process_tool_content(content_data: Dict, timestamp: str) -> List[str]:
    """
    Process specialized tool message content.

    Args:
        content_data: Tool message content dictionary
        timestamp: Message timestamp string

    Returns:
        List of formatted content lines

    The function handles different content types:
    - tether_browsing_display: Search results
    - tether_quote: Quoted content with title/URL
    - Generic tool content in parts
    """
    formatted_lines: List[str] = []
    content_type = content_data.get("content_type", "")

    if content_type == "tether_browsing_display":
        search_result = content_data.get("result", "")
        if search_result:
            formatted_lines.append("<details>\n<summary>Search Results</summary>\n\n")
            formatted_lines.append(f"{normalize_newlines(search_result)}\n")
            formatted_lines.append("</details>\n\n")
        return formatted_lines

    if content_type == "tether_quote":
        quote_title = content_data.get("title", "")
        quote_url = content_data.get("url", "")
        quote_text = content_data.get("text", "")

        if not any([quote_title, quote_url, quote_text]):
            return formatted_lines

        formatted_lines.append("<details>\n<summary>\n")
        if quote_title:
            formatted_lines.append(f"**{quote_title}**\n")
        if timestamp:
            formatted_lines.append(f"<sub>{timestamp}</sub>\n")
        formatted_lines.append("</summary>\n\n")

        if quote_url:
            formatted_lines.append(f"Source: {quote_url}\n\n")
        if quote_text:
            formatted_lines.append(f"{normalize_newlines(quote_text)}\n")

        formatted_lines.append("</details>\n\n")
        return formatted_lines

    # Default: generic tool content in 'parts'
    for content_part in content_data.get("parts", []):
        if not isinstance(content_part, str) or not content_part.strip():
            continue
        formatted_lines.extend(
            process_file_listing(normalize_newlines(content_part), timestamp)
        )

    return formatted_lines


# -----------------------------------------------------------------------------
# Main Conversation Processing
# -----------------------------------------------------------------------------
def build_message_sequence(message_mapping: Dict[str, Dict]) -> List[str]:
    """
    Create ordered list of message IDs using stack-based traversal.

    Args:
        message_mapping: Dictionary of message data keyed by message ID

    Returns:
        List of message IDs in conversation order

    Example:
        >>> build_message_sequence({'msg1': {'children': ['msg2']}, 'msg2': {}})
        ['msg1', 'msg2']
    """
    message_sequence: List[str] = []
    visited_messages = set()

    # Root messages have no 'parent'
    root_messages = [
        msg_id
        for msg_id, msg_data in message_mapping.items()
        if not msg_data.get("parent")
    ]
    message_stack = root_messages[::-1]

    while message_stack:
        current_message_id = message_stack.pop()
        if current_message_id in visited_messages:
            continue
        visited_messages.add(current_message_id)
        message_sequence.append(current_message_id)

        child_messages = message_mapping[current_message_id].get("children", [])
        # Reverse them so they appear in correct order when popped
        for child_id in reversed(child_messages):
            message_stack.append(child_id)

    return message_sequence


def clean_text(text: str) -> str:
    """
    Clean text by normalizing using NFC and removing problematic sequences
    that optionally start with '0x', followed by 'EE88' and between 2 to 6 hexadecimal digits.

    Args:
        text: The input text to clean.

    Returns:
        The cleaned text with problematic sequences removed.
    """
    # Let ftfy handle known weirdness
    text = ftfy.fix_text(text)

    # Normalize to NFC
    text = unicodedata.normalize('NFC', text)

    # Optionally remove control chars, private-use chars, etc.
    cleaned = []
    for ch in text:
        cat = unicodedata.category(ch)
        # Keep standard controls like newlines, tabs, and otherwise discard control chars
        # Keep everything else unless it’s a private-use area or other undesired code point
        if cat.startswith('C'):
            # Keep linefeed, carriage return, and tab if you want them
            if ch not in ('\n', '\r', '\t'):
                continue
        # You could add further checks if you don’t want private-use areas, etc.
        cleaned.append(ch)

    return ''.join(cleaned)


def handle_regular_message(message_content: Dict, output_format: str) -> List[str]:
    """
    Process standard message content (code or text).

    Args:
        message_content: Message content dictionary
        output_format: Output format ('html' or 'markdown')

    Returns:
        List of formatted content lines

    The function handles different content types:
    - code: Programming code with language specification
    - multimodal_text: Text content with multiple parts
    - text: Plain text content
    """
    formatted_lines: List[str] = []
    content_type = message_content.get("content_type")

    if content_type == "code":
        code_text = message_content.get("text", "")
        programming_language = message_content.get("language", "python")
        formatted_lines.extend(
            format_code_block(code_text, programming_language, output_format)
        )
        return formatted_lines

    if content_type in ("multimodal_text", "text", "model_editable_context"):
        # Get text parts based on content type
        text_parts = message_content.get("parts", [])
        if not text_parts and content_type == "text":
            text_parts = [message_content.get("text", "")]

        for text_segment in text_parts:
            # Skip empty or dictionary segments
            if not text_segment or isinstance(text_segment, dict):
                continue

            # Clean the text segment
            text_segment = clean_text(text_segment)

            if output_format == "markdown":
                formatted_lines.append(text_segment + "\n\n")
            else:
                # For HTML, let Mistune handle the conversion
                markdown_parser = mistune.create_markdown(
                    plugins=['strikethrough', 'footnotes', 'table']
                )
                html_content = markdown_parser(text_segment)
                formatted_lines.append(html_content + "\n")

    return formatted_lines


def process_text_with_markdown(text_segment: str, output_format: str) -> List[str]:
    """
    Process text content with embedded markdown.

    Args:
        text_segment: Text content to process
        output_format: Output format ('html' or 'markdown')

    Returns:
        List of formatted lines with markdown properly handled

    Example:
        >>> process_text_with_markdown('Text with **bold**', 'markdown')
        ['Text with **bold**']
    """
    formatted_lines: List[str] = []
    processed_text_chunks: List[str] = []
    last_segment_end = 0

    try:
        markdown_segments = detect_markdown(text_segment)
        if not markdown_segments:
            # No embedded markdown found, just format normally
            formatted_lines.extend(format_text_block(text_segment, output_format))
            return formatted_lines

        # Build a raw string that has the embedded segments fenced
        for segment_start, segment_end, raw_markdown in markdown_segments:
            if segment_start > last_segment_end:
                processed_text_chunks.append(
                    text_segment[last_segment_end:segment_start]
                )
            processed_text_chunks.append("```markdown\n")
            processed_text_chunks.append(raw_markdown)
            processed_text_chunks.append("\n```\n")
            last_segment_end = segment_end

        # Remainder after last segment
        if last_segment_end < len(text_segment):
            processed_text_chunks.append(text_segment[last_segment_end:])

        # We just append the processed string as-is
        # since we do not want to re-parse it again with Mistune.
        formatted_lines.append("".join(processed_text_chunks))
    except Exception as error:
        print(f"Warning: Error processing markdown: {error}")
        # On error, just output as standard text block
        formatted_lines.extend(format_text_block(text_segment, output_format))

    return formatted_lines


def process_messages(message_mapping: Dict[str, Dict], output_format: str) -> List[str]:
    """
    Process all messages in conversation order.

    Args:
        message_mapping: Dictionary of message data keyed by message ID
        output_format: Output format ('html' or 'markdown')

    Returns:
        List of formatted lines for complete conversation

    This function:
    1. Builds the message sequence
    2. Processes each message in order
    3. Handles role transitions and tool message blocks
    4. Formats content according to message type and output format
    """
    message_sequence = build_message_sequence(message_mapping)
    formatted_lines: List[str] = []
    previous_message_role: Optional[str] = None

    for message_id in message_sequence:
        mapping_data = message_mapping.get(message_id, {})
        message_data = mapping_data.get("message", mapping_data)
        if not message_data:
            continue

        message_role = message_data.get("author", {}).get("role", "")
        message_content = message_data.get("content", {})
        message_metadata = message_data.get("metadata", {})
        is_user_system_message = message_metadata.get("is_user_system_message")

        # Skip empty messages or messages with no role
        if not message_role:
            continue

        # Skip empty system messages
        if (
            message_role == "system"
            and message_content.get("content_type") == "text"
            and message_content.get("parts") == [""]
            and not is_user_system_message
        ):
            continue

        message_timestamp = format_timestamp(message_data.get("create_time", 0))

        # If role changed, close the old block if it was tool => non-tool
        if message_role != previous_message_role:
            if (
                previous_message_role
                and is_tool_message(previous_message_role)
                and not is_tool_message(message_role)
            ):
                formatted_lines.append("</details>\n\n")

            if formatted_lines and formatted_lines[-1].strip():
                formatted_lines.append("\n")
            formatted_lines.extend(
                generate_heading(message_role, message_timestamp, output_format)
            )

        # For system/user messages with context, use the context data as content
        user_context_message_data = message_metadata.get("user_context_message_data", {})
        if (
            message_role in ("system", "user")
            and is_user_system_message
            and user_context_message_data
        ):
            about_user = user_context_message_data.get("about_user_message", "")
            about_model = user_context_message_data.get("about_model_message", "")
            message_role = "system"

            message_content = {
                    "content_type": "text",
                    "parts": [
                        f"### About User:\n{about_user}\n\n### About Assistant:\n{about_model}"
                    ]
                }
            formatted_lines.extend(
                generate_heading(message_role, message_timestamp, output_format)
            )

        # Handle message content based on type
        if is_tool_message(message_role):
            # tool messages remain open until we switch roles
            formatted_lines.extend(
                process_tool_content(message_content, message_timestamp)
            )
        else:
            formatted_lines.extend(
                handle_regular_message(message_content, output_format)
            )

        previous_message_role = message_role

    # Close final tool message if needed
    if previous_message_role and is_tool_message(previous_message_role):
        formatted_lines.append("</details>\n\n")

    return formatted_lines


def extract_one_file(input_path: str, out_dir: Optional[str], out_fmt: str) -> None:
    """
    Extract a single JSON file into a Markdown or HTML file.

    Args:
        input_path: Path to the JSON file
        out_dir: Optional output directory
        out_fmt: Output format ('markdown' or 'html')

    This function:
    1. Loads the JSON file
    2. Extracts metadata (title, timestamps)
    3. Generates unique output filename
    4. Processes all messages
    5. Writes formatted output file
    """
    data = load_json_file(input_path)
    if not data:
        return

    msg_map = data.get("mapping", {})
    if not msg_map:
        return

    title = data.get("title", "Untitled")
    ctime = data.get("create_time")
    utime = data.get("update_time")

    # Use the same logic for generating the name, but with md/html extension
    extension = "html" if out_fmt == "html" else "md"
    try:
        out_path = generate_unique_filename(
            input_path, title, ctime, utime, extension=extension, out_dir=out_dir
        )
    except ValueError as e:
        print(f"Cannot generate filename for {input_path}: {e}")
        return

    print(f"Processing: {input_path}")
    print(f"Writing to: {out_path}")

    ctime_str = format_timestamp(ctime)
    utime_str = format_timestamp(utime)

    lines: List[str] = []

    # Header
    if out_fmt == "html":
        lines.append(HTML_TEMPLATE_HEADER.format(
            title=html.escape(title),
            start_time=html.escape(ctime_str or "Unknown"),
            end_time=html.escape(utime_str or "Unknown"),
        ))
    else:
        lines.append(f"# {title}\nStarting: {ctime_str}\nEnding: {utime_str}\n\n")

    # Body
    lines.extend(process_messages(msg_map, out_fmt))

    # Footer
    if out_fmt == "html":
        lines.append(HTML_TEMPLATE_FOOTER)

    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    try:
        with open(out_path, "w", encoding="utf-8") as f:
            f.writelines(lines)
    except Exception as err:
        print(f"Error writing {out_path}: {err}")


def process_file_patterns(patterns: List[str], out_dir: Optional[str], out_fmt: str) -> None:
    """
    Process multiple file patterns and extract conversations from matching files.

    Args:
        patterns: List of file/directory patterns to process
        out_dir: Optional output directory for extracted files
        out_fmt: Output format ('markdown' or 'html')

    For each pattern:
    - If it's a directory, process all .json files in it
    - If it's a file pattern, process all matching files
    - Skip non-JSON files
    """
    all_files: List[str] = []
    for pat in patterns:
        if os.path.isdir(pat):
            all_files.extend(glob.glob(os.path.join(pat, "*.json")))
        else:
            matched = glob.glob(pat)
            if not matched:
                print(f"No files match: {pat}")
            all_files.extend(matched)

    for f in all_files:
        if os.path.isfile(f) and f.lower().endswith(".json"):
            extract_one_file(f, out_dir, out_fmt)


def main():
    """
    Main entry point for the script.

    Parses command line arguments and processes the specified files:
    - Takes one or more file patterns as input
    - Optional output directory
    - Optional output format (markdown or html)
    """
    parser = argparse.ArgumentParser(description="Extract conversation logs to Markdown/HTML.")
    parser.add_argument("patterns", nargs="+", help="File patterns for JSON input")
    parser.add_argument("-o", "--output-dir", help="Output directory")
    parser.add_argument("--format", choices=["markdown", "html"], default="markdown", help="Output format")
    args = parser.parse_args()

    process_file_patterns(args.patterns, args.output_dir, args.format)


if __name__ == "__main__":
    main()
