#!/usr/bin/env python
"""
tokencount.py - Count tokens in text files or standard input

This script uses NLTK to tokenize and count words in text. It can process input from
either a file specified with the -f/--file argument, or from standard input (STDIN).

Usage:
    tokencount.py [-f FILE]
    tokencount.py < input.txt

Options:
    -f, --file FILE    Path to text file to tokenize
    -h, --help         Show this help message

Examples:
    1. Count tokens in a file:
        tokencount.py -f myfile.txt

    2. Count tokens from stdin:
        echo "Some text" | tokencount.py
        
    3. Interactive stdin mode:
        tokencount.py
        (Type text, press Ctrl+D/Ctrl+Z when done)

Author:
    Michael Sullivan
    Email: unixwzrd@unixwzrd.ai
    Website: https://unixwzrd.ai/
    GitHub: https://github.com/unixwzrd

License:
    Apache License, Version 2.0
"""

import nltk
import sys
import argparse

# nltk.download('punkt')  # Download the Punkt tokenizer models


def tokenize_text(text):
    """
    Tokenize the input text and return the number of tokens.

    Uses NLTK's word_tokenize() function to split text into tokens based on
    standard tokenization rules. This handles contractions, punctuation, and
    other special cases appropriately.

    Args:
        text (str): The text string to tokenize

    Returns:
        int: The total number of tokens found in the text

    Example:
        >>> tokenize_text("Hello, world!")
        3  # Tokenizes to ["Hello", ",", "world", "!"]
    """
    tokens = nltk.word_tokenize(text)
    return len(tokens)


def main():
    """
    Main function to parse command-line arguments and count tokens in text.

    Handles both file input via -f/--file argument and standard input (STDIN).
    For STDIN, supports both piped input and interactive input terminated by
    Ctrl+D (Linux/Mac) or Ctrl+Z (Windows).

    Returns:
        None: Prints token count to stdout and exits
    """
    parser = argparse.ArgumentParser(
        description="Count the number of tokens in a text file or from STDIN.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__.split("\n\n", 1)[1],
    )
    parser.add_argument(
        "-f", "--file", type=str, help="Path to the text file to be tokenized"
    )
    args = parser.parse_args()

    if args.file:
        with open(args.file, "r", encoding="utf-8") as file:
            text = file.read()
    else:
        print(
            "Reading from STDIN. Press Ctrl+D (Linux/Mac) or Ctrl+Z (Windows) to end input."
        )
        text = sys.stdin.read()

    num_tokens = tokenize_text(text)
    if args.file:
        print(f"Number of tokens in file '{args.file}': {num_tokens}")
    else:
        print(f"Number of tokens from STDIN: {num_tokens}")


if __name__ == "__main__":
    main()
