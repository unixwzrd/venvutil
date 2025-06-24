#!/usr/bin/env python
"""
Refactored script to extract conversations from ChatGPT JSON exports into
Markdown or HTML formats.

This script is designed to be simple, maintainable, and easily extensible.
It uses Pydantic for robust data parsing and validation.

The core logic is to:
1. Parse the input JSON into a structured Pydantic model.
2. Traverse the conversation tree to reconstruct the chronological order.
3. Generate a clean Markdown representation of the conversation.
4. Optionally, convert the generated Markdown to a styled HTML file.
"""

import argparse
import hashlib
import json
import os
import re
import sys
from datetime import datetime
from typing import Dict, List, Literal, Optional, Tuple

import mistune

from pydantic import BaseModel, Field, ValidationError

from pygments.formatters.html import HtmlFormatter


# --- Pydantic Models for ChatGPT JSON Structure ---


class ExtraMetadata(BaseModel):
    """Extra metadata for a citation."""
    cited_message_idx: Optional[int] = None
    search_result_idx: Optional[int] = None
    evidence_text: Optional[str] = None
    start_line_num: Optional[int] = None
    end_line_num: Optional[int] = None


class CitationMetadata(BaseModel):
    """Metadata for a single citation, including URL and text."""
    type: Optional[str] = None
    title: Optional[str] = None
    url: Optional[str] = None
    text: Optional[str] = None
    pub_date: Optional[str] = None
    extra: Optional[ExtraMetadata] = None

    class Config:
        extra = "allow"  # Allow fields like 'og_tags'


class Citation(BaseModel):
    """A single citation, with its position and metadata."""
    start_ix: int
    end_ix: int
    citation_format_type: Optional[str] = None
    metadata: CitationMetadata


class MessageMetadata(BaseModel):
    """Metadata for a message, which may include citations."""
    citations: Optional[List[Citation]] = None

    class Config:
        # Allow other fields not explicitly defined in the model
        extra = "allow"


class Author(BaseModel):
    role: Literal["system", "user", "assistant", "tool"]
    name: Optional[str] = None
    metadata: Dict = Field(default_factory=dict)


class Content(BaseModel):
    content_type: str
    parts: Optional[List[str]] = None
    text: Optional[str] = None  # Some tool messages have 'text' instead of 'parts'
    user_profile: Optional[str] = None
    user_instructions: Optional[str] = None
    language: Optional[str] = None


class Message(BaseModel):
    id: str
    author: Author
    create_time: Optional[float] = None
    content: Content
    status: str
    end_turn: Optional[bool] = None
    weight: float
    metadata: MessageMetadata = Field(default_factory=MessageMetadata)
    recipient: str


class MappingNode(BaseModel):
    id: str
    message: Optional[Message] = None
    parent: Optional[str] = None
    children: List[str] = Field(default_factory=list)

class Conversation(BaseModel):

    title: str
    create_time: float
    update_time: float
    mapping: Dict[str, MappingNode]
    moderation_results: List
    current_node: str


# --- Core Logic ---
def format_content_for_markdown(text: str) -> str:
    # Split by triple backticks, keeping delimiters
    parts = re.split(r'(```)', text)
    output = []
    in_code = False
    for i, part in enumerate(parts):
        if part == '```':
            if not in_code:
                # Opening fence: look ahead to see if there's a language specifier
                # We want to add 'text' ONLY IF not already present
                code_lang = ''
                # If the next part does NOT look like a language specifier, add 'text'
                if i + 1 < len(parts):
                    # Peek at the next part, which is the code content
                    # If it starts with a word (language), keep it, otherwise add text
                    code_content = parts[i+1]
                    first_line = code_content.lstrip().split('\n', 1)[0]
                    # Check if code block starts with a word (e.g., 'python')
                    if re.match(r'^\w+$', first_line):
                        code_lang = first_line
                    else:
                        # Insert 'text' as language
                        output.append('\n\n```text\n')
                        in_code = True
                        continue
                output.append('\n\n```text\n')
            else:
                # Closing fence
                output.append('\n```\n')
            in_code = not in_code
        else:
            output.append(part.strip('\n'))
    result = ''.join(output)
    # Collapse any 3+ newlines into two (for safety)
    result = re.sub(r'\n{3,}', '\n\n', result)
    return result.strip()


def slugify(text: str) -> str:
    """Converts a string to a slug for URL/anchor generation."""
    text = str(text).lower()
    text = re.sub(r'[^a-z0-9\s-]', '', text)
    text = re.sub(r'[\s-]+', '-', text).strip('-')
    return text


def extract_system_context(conversation: Conversation) -> Dict[str, str]:
    """Extracts the raw text for the four specific system context sections, without formatting."""
    context = {}
    for node in conversation.mapping.values():
        if not (node.message and node.message.content):
            continue
        
        message = node.message
        content = message.content

        if content.content_type == "user_editable_context":
            if content.user_profile:
                context['user_profile'] = content.user_profile
            if content.user_instructions:
                context['user_instructions'] = content.user_instructions

        metadata = message.metadata.model_dump() if message.metadata else {}
        user_data = metadata.get('user_context_message_data', {})
        if isinstance(user_data, dict):
            if user_data.get('about_user_message'):
                context['about_user_message'] = user_data['about_user_message']
            if user_data.get('about_model_message'):
                context['about_model_message'] = user_data['about_model_message']
                
    return context

def generate_markdown(conversation: Conversation) -> str:
    """Generates a Markdown string from the conversation data based on new requirements."""
    final_parts = []

    # --- 1. Title and Timestamps ---
    title = f"# {conversation.title}"
    create_time = datetime.fromtimestamp(conversation.create_time).strftime('%Y-%m-%d %H:%M:%S')
    update_time = datetime.fromtimestamp(conversation.update_time).strftime('%Y-%m-%d %H:%M:%S')
    timestamps = f"**Created:** {create_time} | **Last Updated:** {update_time}"
    final_parts.extend([title, timestamps, "---"])

    # --- 2. System Context ---
    system_context = extract_system_context(conversation)
    if system_context:
        final_parts.append("## System Context")
        context_key_map = {
            'user_profile': '### User Profile',
            'user_instructions': '### User Instructions',
            'about_user_message': '### About The User',
            'about_model_message': '### About The Model',
        }
        for key, header in context_key_map.items():
            if key in system_context:
                formatted_content = format_content_for_markdown(system_context[key])
                final_parts.append(f"{header}\n\n{formatted_content}")

    final_parts.extend(["---", "## Conversation"])

    # --- 3. Chronological Conversation Traversal ---
    root_node_id = next((nid for nid, node in conversation.mapping.items() if not node.parent), None)
    if not root_node_id:
        return "\n\n".join(final_parts)

    chronological_nodes = []
    current_node_id = root_node_id
    while current_node_id:
        node = conversation.mapping.get(current_node_id)
        if not node:
            break
        if node.message and node.message.author.role != 'system':
            chronological_nodes.append(node)
        current_node_id = node.children[0] if node.children else None

    # --- 4. Process and Format Each Message ---
    citation_ref_map = {}
    global_citation_counter = 1
    i = 0
    while i < len(chronological_nodes):
        node = chronological_nodes[i]
        message = node.message

        if not message or not (message.content and (message.content.parts or message.content.text or message.author.role == 'tool')):
            i += 1
            continue

        # --- Render User/Assistant Messages and their Citations ---
        if message.author.role in ['user', 'assistant']:
            author_role = message.author.role.capitalize()
            create_time = datetime.fromtimestamp(message.create_time).strftime('%H:%M:%S') if message.create_time else ''
            msg_metadata = message.metadata.model_dump(exclude_none=True) if message.metadata else {}

            author_line = f"### {author_role}"
            metadata_parts = [p for p in [create_time, f"Model: `{msg_metadata.get('model_slug')}`" if msg_metadata.get('model_slug') else None] if p]
            if metadata_parts:
                author_line += f" ({' | '.join(metadata_parts)})"
            final_parts.append(author_line)

            # --- Message Content & Citation Processing ---
            content_parts = []
            raw_content_for_citation_search = ""
            if message.content.content_type == 'code' and message.content.text:
                lang = message.content.language or ""
                content_parts.append(f"```{lang}\n{message.content.text.strip()}\n```")
            else:
                raw_content_for_citation_search = "\n".join(message.content.parts or [message.content.text or ""])
                formatted_content = format_content_for_markdown(raw_content_for_citation_search)
                content_parts.append(formatted_content)

            message_content_str = "\n".join(content_parts)
            local_citations = []
            if 'citations' in msg_metadata:
                def citation_replacer(match):
                    nonlocal global_citation_counter
                    marker = match.group(0)
                    match_start_pos = match.start()

                    # Find the corresponding citation data by its position in the raw text
                    found_c_data = None
                    for c_data in msg_metadata['citations']:
                        if c_data['start_ix'] <= match_start_pos < c_data['end_ix']:
                            found_c_data = c_data
                            break
                    if not found_c_data:
                        return marker

                    # Parse the marker for line info, etc.
                    marker_match = re.match(r'【(\d+)†(L\d+-L\d+|source)】', marker)
                    if not marker_match:
                        return marker
                    original_json_index = int(marker_match.group(1))
                    line_info = marker_match.group(2)

                    title = found_c_data['metadata'].get('title', 'No Title')
                    url = found_c_data['metadata'].get('url')
                    quote_text = found_c_data['metadata'].get('text', 'No quote available.')

                    # A unique citation is most robustly defined by its source URL and the specific quote.
                    citation_key = (url, quote_text)

                    if citation_key not in citation_ref_map:
                        header_anchor_text = f"Citation {global_citation_counter} ({original_json_index}, {line_info})"
                        slug = slugify(header_anchor_text)
                        citation_ref_map[citation_key] = (global_citation_counter, slug, header_anchor_text)
                        global_citation_counter += 1
                    
                    citation_num, slug, header_anchor_text = citation_ref_map[citation_key]

                    if not any(c[0] == citation_num for c in local_citations):
                        local_citations.append((citation_num, found_c_data['metadata'], slug, header_anchor_text, line_info, quote_text))
                    
                    # Return a raw HTML link to ensure it works in both MD and HTML output
                    return f"<a href='#{slug}'><sup>{citation_num}</sup></a>"

                citation_pattern = re.compile(r'【\d+†(?:L\d+-L\d+|source)】')
                message_content_str = citation_pattern.sub(citation_replacer, message_content_str)

            final_parts.append(message_content_str)

            # --- Citation List Rendering ---
            if local_citations:
                citation_list_str = "<details><summary>Citations</summary>\n\n"
                for num, meta, slug, header_anchor_text, line_info, quote_text in sorted(local_citations, key=lambda x: x[0]):
                    title = meta.get('title', 'No Title')
                    url = meta.get('url', '#')
                    # Use a raw HTML header with the ID for a robust anchor
                    citation_list_str += f"<h5 id='{slug}'>{header_anchor_text}</h5>\n"
                    # Use raw HTML for the link to ensure it's not misinterpreted by the MD converter
                    citation_list_str += f"<strong><a href='{url}' target='_blank'>{title}</a></strong>\n"
                    if line_info != 'source':
                        citation_list_str += f"> {line_info}: {quote_text}\n\n"
                    else:
                        citation_list_str += f"> {quote_text}\n\n"
                citation_list_str += "</details>"
                final_parts.append(citation_list_str)

        # --- Look ahead for and Render Tool Calls ---
        if message.author.role == 'assistant':
            tool_calls_processed = 0
            next_index = i + 1
            while next_index < len(chronological_nodes):
                next_node = chronological_nodes[next_index]
                if next_node.message and next_node.message.author.role == 'tool':
                    tool_msg = next_node.message
                    tool_metadata = tool_msg.metadata.model_dump(exclude_none=True) if tool_msg.metadata else {}
                    tool_name = tool_msg.author.name or 'Unknown Tool'
                    tool_output = tool_msg.content.text or "".join(tool_msg.content.parts or [])
                    
                    if not tool_output.strip() and 'async_task_prompt' in tool_metadata:
                        tool_output = f"Kicked off async task: {tool_metadata.get('async_task_title', 'Untitled Task')}\nPrompt: {tool_metadata['async_task_prompt']}"

                    tool_details = (
                        f"<details><summary>Tool Call: <code>{tool_name}</code></summary>\n\n"
                        f"```\n{tool_output.strip()}\n```\n"
                        f"</details>"
                    )
                    final_parts.append(tool_details)
                    tool_calls_processed += 1
                    next_index += 1
                else:
                    break # Not a tool message, so stop looking ahead
            i += tool_calls_processed

        i += 1

    return "\n\n".join(final_parts)


def to_html(markdown_text: str, css_content: str, title: str) -> str:
    """
    Convert a Markdown string to a styled HTML document.

    This function uses mistune with `escape=False` to ensure that raw HTML tags
    (like <details>, <sup>, and <a id...>) used for citations and tool calls
    are rendered correctly in the final HTML output.
    """
    # Create a mistune instance that allows raw HTML tags to pass through.
    markdown_converter = mistune.create_markdown(escape=False)
    html_body = markdown_converter(markdown_text)

    # The HTML template includes a <style> tag for the CSS.
    return f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title}</title>
    <style>
        {css_content}
    </style>
</head>
<body>
    <div class="main-container">
        {html_body}
    </div>
</body>
</html>
"""


# --- Main Application Logic ---
def get_css_content(css_file_path: Optional[str]) -> str:
    """
    Loads CSS content from a specified file or creates/loads a default CSS file
    from the user's configuration directory.
    """
    config_dir = os.path.join(os.path.expanduser("~/.venvutil"))
    default_css_filename = "extract_chat_default.css"
    default_css_path = os.path.join(config_dir, default_css_filename)

    default_css_content = "body {\n    color: #e8e8e8;\n    background-color: #111111;\n    font-family: Arial, sans-serif;\n    line-height: 1.2;\n    max-width: 900px;\n    margin: 0 auto;\n    padding: 20px;\n    font-size: 12pt;\n}\n\nh1 {\n    color: #f8f8f8;\n    font-size: 24pt;\n}\n\nh2 {\n    color: #efefef;\n    margin-top: 30px;\n    font-size: 18pt;\n}\n\npre {\n    background-color: #303030;\n    padding: 5px;\n    border-radius: 5px;\n    overflow-x: auto;\n    font-size: 10pt;\n    line-height: 1;\n    margin: 0.5em 0;\n    font-family: monospace;\n    white-space-collapse: preserve;\n    text-wrap-mode: wrap;\n}\n\ncode {\n    font-family: 'Courier New', Courier, monospace;\n    font-size: 10pt;\n    line-height: 1.0;\n    display: block;\n    white-space-collapse: preserve;\n    text-wrap-mode: wrap;\n}\n\ntable {\n    border-collapse: collapse;\n    width: 100%;\n    margin: 10px 0;\n    background-color: #222;\n}\n\nth, td {\n    border: 1px solid #444;\n    padding: 8px;\n    text-align: left;\n}\n\nth {\n    background-color: #333;\n    color: #fff;\n}\n\ntr:nth-child(even) {\n    background-color: #2a2a2a;\n}\n\ntr:nth-child(odd) {\n    background-color: #222;\n}\n\n.timestamp {\n    color: #cecece;\n    font-size: 9pt;\n    margin: 5px 0;\n}\n\ndetails {\n    margin: 10px 0;\n    padding: 10px;\n    background-color: #222244;\n    border: 1px solid #444;\n    border-radius: 5px;\n}\n\ndetails summary {\n    cursor: pointer;\n    color: #92c1f7;\n    font-weight: bold;\n    margin: -10px;\n    padding: 10px;\n    background-color: #1a1a2a;\n    border-bottom: 1px solid #444;\n}\n\ndetails[open] summary {\n    margin-bottom: 10px;\n}\n\n.tool-message {\n    background-color: #222244;\n    border: 1px solid #444;\n    padding: 10px;\n    margin: 10px 0;\n    border-radius: 5px;\n}\n\n.error-message {\n    background-color: #442222;\n    border: 1px solid #844;\n    padding: 10px;\n    margin: 10px 0;\n    border-radius: 5px;\n}"
    # Generate Pygments CSS for a dark theme (e.g., 'monokai') and append it
    pygments_css = HtmlFormatter(style='monokai').get_style_defs('.codehilite')
    default_css_content += f"\n{pygments_css}"

    if css_file_path:
        # User specified a CSS file, try to load it
        try:
            with open(css_file_path, 'r', encoding='utf-8') as f:
                print(f"Loading custom CSS from: {css_file_path}", file=sys.stderr)
                return f.read()
        except FileNotFoundError:
            print(f"Warning: Custom CSS file not found at {css_file_path}. "
                  f"Falling back to default CSS.", file=sys.stderr)

    # If no custom CSS is provided or if it fails to load, use the default.
    # Check if the default CSS file exists, and create it if it doesn't.
    if not os.path.exists(default_css_path):
        print(f"Default CSS file not found. Creating at {default_css_path}", file=sys.stderr)
        os.makedirs(os.path.dirname(default_css_path), exist_ok=True)
        with open(default_css_path, 'w', encoding='utf-8') as f:
            f.write(default_css_content)
        return default_css_content
    else:
        # Load the existing default CSS file.
        with open(default_css_path, 'r', encoding='utf-8') as f:
            return f.read()


def main():
    """Main function to parse arguments and run the script."""
    parser = argparse.ArgumentParser(
        description="Extract a ChatGPT conversation from a JSON export.",
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument(
        "input_file",
        help="Path to the input JSON file."
    )
    parser.add_argument(
        "-o", "--output_file",
        help="Base path for the output file(s). Extensions will be added automatically.\nIf not provided, it will be derived from the conversation title."
    )
    parser.add_argument(
        "--md",
        action="store_true",
        help="Generate Markdown output."
    )
    parser.add_argument(
        "--html",
        action="store_true",
        help="Generate HTML output."
    )
    parser.add_argument(
        "-c", "--css-file",
        help="Path to a custom CSS file for HTML output."
    )

    args = parser.parse_args()

    # If no format flags are specified, default to generating both.
    generate_md = args.md
    generate_html = args.html
    if not generate_md and not generate_html:
        print("No output format specified. Defaulting to generate both Markdown and HTML.")
        generate_md = True
        generate_html = True

    # --- Load and Validate JSON ---
    try:
        with open(args.input_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"Error: Input file not found at {args.input_file}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: Could not decode JSON from {args.input_file}", file=sys.stderr)
        sys.exit(1)

    try:
        conversation = Conversation.model_validate(data)
        print(f"Successfully parsed conversation: '{conversation.title}'")
    except ValidationError as e:
        print(f"Error: JSON file does not match expected schema.\n{e}", file=sys.stderr)
        sys.exit(1)

    # --- Generate Base Markdown Content ---
    markdown_output = generate_markdown(conversation)

    # --- Determine Output Base Path ---
    output_base = args.output_file
    if not output_base:
        create_date = datetime.fromtimestamp(conversation.create_time).strftime('%Y-%m-%d')
        safe_title = re.sub(r'[^\w\-]+', '_', conversation.title).strip('_')
        output_base = f"{create_date}_{safe_title}"
    else:
        # Strip extension if user provided one, as we'll be adding our own.
        output_base = os.path.splitext(output_base)[0]

    # --- Write Markdown File ---
    if generate_md:
        md_path = f"{output_base}.md"
        with open(md_path, 'w', encoding='utf-8') as f:
            f.write(markdown_output)
        print(f"Successfully wrote Markdown output to {md_path}")

    # --- Write HTML File ---
    if generate_html:
        html_path = f"{output_base}.html"

        html_content = to_html(markdown_output, get_css_content(args.css_file), conversation.title)
        with open(html_path, 'w', encoding='utf-8') as f:
            f.write(html_content)
        print(f"Successfully wrote HTML output to {html_path}")





if __name__ == "__main__":
    main()
