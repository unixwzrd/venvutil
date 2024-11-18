#!/usr/bin/env python

import nltk
import sys
import argparse

#nltk.download('punkt')  # Download the Punkt tokenizer models

def tokenize_text(text):
    """
    Tokenize the input text and return the number of tokens.

    :param text: The text to tokenize.
    :return: The number of tokens in the text.
    """
    tokens = nltk.word_tokenize(text)
    return len(tokens)

def main():
    """
    Main function to parse command-line arguments and count tokens in a text file
    or from standard input (STDIN).
    """
    parser = argparse.ArgumentParser(description="Count the number of tokens in a text file or from STDIN.")
    parser.add_argument('-f', '--file', type=str, help='Path to the text file to be tokenized')
    args = parser.parse_args()

    if args.file:
        with open(args.file, 'r', encoding='utf-8') as file:
            text = file.read()
    else:
        print("Reading from STDIN. Press Ctrl+D (Linux/Mac) or Ctrl+Z (Windows) to end input.")
        text = sys.stdin.read()

    num_tokens = tokenize_text(text)
    if args.file:
        print(f"Number of tokens in file '{args.file}': {num_tokens}")
    else:
        print(f"Number of tokens from STDIN: {num_tokens}")

if __name__ == "__main__":
    main()
