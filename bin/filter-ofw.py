#!/usr/bin/env python3

import re
import json
import argparse
import sys
import logging

# Configure logging to capture debug information
logging.basicConfig(
    filename='parser_debug.log',
    filemode='w',
    level=logging.DEBUG,
    format='%(asctime)s %(levelname)s:%(message)s'
)

# Regular expressions for detecting patterns
MESSAGE_RE = re.compile(r'^Message\s+(\d{1,8})\s+of\s+(\d{1,8})', re.IGNORECASE)
PAGE_RE = re.compile(r'^Page\s+(\d{1,8})\s+of\s+(\d{1,8})', re.IGNORECASE)
HEADER_RE = re.compile(r'^\s*(Sent|From|To|Subject|Attachments):\s*(.*)', re.IGNORECASE)  # Allows leading whitespace

# List of headers to extract
HEADERS = ['Sent', 'From', 'To', 'Subject', 'Attachments']

def normalize_text(text):
    """
    Replace or remove non-UTF8 characters and other problematic characters.
    """
    replacements = {
        '\u2019': "'",  # Right single quotation mark
        '\u2018': "'",  # Left single quotation mark
        '\u201c': '"',  # Left double quotation mark
        '\u201d': '"',  # Right double quotation mark
        '\u2014': '-',   # Em dash
        '\u2026': '...', # Ellipsis
        '\u00ad': '',    # Soft hyphen
        '\x92': "'",     # Windows-1252 right single quotation mark
        '\x93': '"',     # Windows-1252 left double quotation mark
        '\x94': '"',     # Windows-1252 right double quotation mark
        '\u00a0': ' ',   # Non-breaking space
        '\xef\xbf\xbd': '',  # Replacement character sequence
    }
    for key, value in replacements.items():
        text = text.replace(key, value)
    return text

def parse_file(input_file):
    """
    Parse the input file and extract messages into a list of dictionaries.
    Each message includes line_start and message_number for debugging.
    """
    messages = []
    current_message = {}
    inside_message = False
    inside_headers = False
    internal_count = 0  # Sequential count of parsed messages

    for line_number, raw_line in enumerate(input_file, 1):
        # Decode the line using 'utf-8' with 'replace' for errors
        try:
            decoded_line = raw_line.decode('utf-8', errors='replace').strip()
            decoded_line = normalize_text(decoded_line)
        except UnicodeDecodeError as e:
            logging.error(f"Line {line_number}: Unicode decode error: {e}")
            continue

        # Detect the start of a new message
        message_match = MESSAGE_RE.match(decoded_line)
        if message_match:
            # If already inside a message, save the previous one
            if inside_message and current_message:
                messages.append(current_message)
                logging.info(f"Saved Message {current_message['message_number']} starting at line {current_message['line_start']} with internal_count {current_message['internal_count']}")
                current_message = {}

            # Initialize a new message
            message_number = int(message_match.group(1))
            total_messages = int(message_match.group(2))
            internal_count += 1  # Increment internal count

            current_message = {
                'line_start': line_number,
                'message_number': message_number,
                'total_messages': total_messages,
                'internal_count': internal_count,
                'Sent': None,
                'From': None,
                'To': None,
                'Subject': None,
                'Attachments': [],
                'Body': ""
            }

            logging.info(f"Detected Message {message_number} of {total_messages} at line {line_number}")
            inside_message = True
            inside_headers = True
            continue  # Move to the next line

        # Detect and skip "Page" tokens
        page_match = PAGE_RE.match(decoded_line)
        if page_match:
            # Skip page lines
            logging.debug(f"Skipped Page token '{decoded_line}' at line {line_number}")
            continue

        # If inside a message, parse headers or body
        if inside_message:
            if inside_headers:
                header_match = HEADER_RE.match(decoded_line)
                if header_match:
                    header_name = header_match.group(1)
                    header_value = header_match.group(2)

                    if header_name.lower() == 'attachments':
                        # Handle multiple attachments separated by commas
                        attachments = [att.strip() for att in header_value.split(',')]
                        for att in attachments:
                            # Extract filename and size if available
                            att_match = re.match(r'(.+?)\s*\((\d+)\s*(KB|MB)\)', att, re.IGNORECASE)
                            if att_match:
                                filename = att_match.group(1).strip()
                                size = int(att_match.group(2))
                                unit = att_match.group(3).upper()
                                size_bytes = size * 1024 if unit == 'KB' else size * 1024 * 1024
                                current_message['Attachments'].append({
                                    'filename': filename,
                                    'size_bytes': size_bytes
                                })
                                logging.debug(f"Parsed Attachment: {filename} ({size_bytes} bytes)")
                            else:
                                # If size info is missing
                                current_message['Attachments'].append({
                                    'filename': att,
                                    'size_bytes': None
                                })
                                logging.debug(f"Parsed Attachment without size: {att}")
                    else:
                        # Directly assign the header value
                        current_message[header_name] = header_value
                        logging.debug(f"Parsed Header: {header_name} = {header_value}")
                elif decoded_line == "":
                    # Blank line signifies the end of headers
                    logging.debug(f"End of headers for Message {current_message['message_number']} at line {line_number}")
                    inside_headers = False
                else:
                    # Line doesn't match header; assume end of headers and start of body
                    logging.warning(f"Unexpected line in headers, treating as body for Message {current_message['message_number']} at line {line_number}")
                    inside_headers = False
                    current_message['Body'] += decoded_line + "\n"
            else:
                # Append to body
                current_message['Body'] += decoded_line + "\n"

    # After reading all lines, save the last message if any
    if inside_message and current_message:
        messages.append(current_message)
        logging.info(f"Saved Message {current_message['message_number']} starting at line {current_message['line_start']} with internal_count {current_message['internal_count']}")

    return messages

def main():
    parser = argparse.ArgumentParser(description='Robust Message Parser with Detailed Debugging')
    parser.add_argument('-i', '--input', type=argparse.FileType('rb'), required=True,
                        help='Input messages.txt file path')
    parser.add_argument('-o', '--output', type=argparse.FileType('w', encoding='utf-8'), default='output.json',
                        help='Output JSON file path (default: output.json)')
    args = parser.parse_args()

    messages = parse_file(args.input)

    # Post-process messages to clean up and structure them
    for msg in messages:
        # Strip trailing newline from body
        msg['Body'] = msg['Body'].rstrip()

    # Write to JSON
    json.dump(messages, args.output, ensure_ascii=False, indent=2)
    print(f"Parsed {len(messages)} messages. Output written to {args.output.name}")
    print("Detailed logs can be found in 'parser_debug.log'.")

if __name__ == "__main__":
    main()