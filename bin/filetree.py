#!/usr/bin/env python
"""
filetree - Generate a tree structure of the current directory excluding and including specific directories/files.

This script is used by genmd to visualize the directory structure of the project,
excluding and including files based on specified patterns. It supports command-line
arguments and environment variables for configuration.

Usage:
    filetree [options]

Options:
    -e, --exclude [patterns]    Exclude directories/files matching the given patterns.
                                Multiple patterns can be separated by '|' or spaces.
    -i, --include [patterns]    Include only files matching the given patterns.
                                Multiple patterns can be separated by '|' or spaces.
    -h, --help                  Show this help message and exit.
    -l, --log-level             Set the logging level (10=DEBUG, 20=INFO, 30=WARNING, 40=ERROR, 50=CRITICAL)

Environment Variables:
    GENMD_DIR_EXCLUDES          Default list of directory patterns to exclude.
    GENMD_FILE_EXCLUDES         Default list of file patterns to exclude.
    GENMD_FILE_INCLUDES         Default list of file patterns to include.

Examples:
    1. Exclude Specific Directories and Files:
       ```bash
       filetree -e "node_modules|dist" "*.log *.tmp"
       ```

    2. Include Only Python and JavaScript Files:
       ```bash
       filetree -i "*.py *.js"
       ```

    3. Combine Exclusions and Inclusions:
       ```bash
       filetree -e "node_modules|dist" "*.log *.tmp" -i "*.py *.js"
       ```

    4. Using Environment Variables for Defaults:
       ```bash
       export GENMD_DIR_EXCLUDES="node_modules dist"
       export GENMD_FILE_EXCLUDES="*.log *.tmp"
       export GENMD_FILE_INCLUDES="*.py *.js"
       filetree
       ```

    5. Display Help Message:
       ```bash
       filetree -h
       ```

Author:
    Michael Sullivan  
    Email: [unixwzrd@unixwzrd.ai](mailto:unixwzrd@unixwzrd.ai)  
    Website: [https://unixwzrd.ai/](https://unixwzrd.ai/)  
    GitHub: [https://github.com/unixwzrd](https://github.com/unixwzrd)

License:
    This project is licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).
"""

import os
import argparse
import fnmatch
from rich.console import Console
from rich.tree import Tree
import logging

def is_ignored(item_name, exclude_patterns):
    """
    Check if the item should be ignored based on the exclusion patterns.

    :param item_name: The name of the item to check.
    :param exclude_patterns: List of patterns to exclude.
    :return: True if the item should be ignored, False otherwise.
    """
    # Always ignore hidden files/directories
    if item_name.startswith('.'):
        logging.debug(f"Ignoring hidden item: {item_name}")
        return True
    # Check against exclusion patterns
    for pattern in exclude_patterns:
        if pattern.endswith('/'):
            # Directory pattern
            if item_name + '/' == pattern:
                logging.debug(f"Ignoring directory based on pattern: {item_name}")
                return True
        else:
            # File pattern
            if item_name == pattern or fnmatch.fnmatch(item_name, pattern):
                logging.debug(f"Ignoring file based on pattern: {item_name}")
                return True
    logging.debug(f"Including item: {item_name}")
    return False

def is_included(item_name, include_patterns):
    """
    Check if the item should be included based on the inclusion patterns.

    :param item_name: The name of the item to check.
    :param include_patterns: List of patterns to include.
    :return: True if the item should be included, False otherwise.
    """
    # If no include patterns are specified, include all
    if not include_patterns:
        return True
    for pattern in include_patterns:
        if fnmatch.fnmatch(item_name, pattern):
            return True
    return False

def add_items(root_dir, parent_tree, exclude_patterns, include_patterns):
    """
    Recursively add items in the file system to the tree structure.

    :param root_dir: The root directory to start from.
    :param parent_tree: The parent tree node to add items to.
    :param exclude_patterns: List of patterns to exclude.
    :param include_patterns: List of patterns to include.
    """
    try:
        for item_name in sorted(os.listdir(root_dir)):
            item_path = os.path.join(root_dir, item_name)
            if os.path.isdir(item_path):
                if is_included(item_name, include_patterns) and not is_ignored(item_name, exclude_patterns):
                    # Add directory and recurse
                    dir_branch = parent_tree.add(f"{item_name}/")
                    add_items(item_path, dir_branch, exclude_patterns, include_patterns)
            elif os.path.isfile(item_path):
                if is_included(item_name, include_patterns) and not is_ignored(item_name, exclude_patterns):
                    # Add file
                    parent_tree.add(item_name)
    except PermissionError:
        parent_tree.add("[red]Permission Denied[/red]")

def generate_tree(exclude_patterns, include_patterns):
    """
    Generate a tree structure of the current directory excluding and including specific directories/files.

    :param exclude_patterns: List of patterns to exclude.
    :param include_patterns: List of patterns to include.
    """
    console = Console()
    tree = Tree("Root Directory")
    add_items(".", tree, exclude_patterns, include_patterns)
    console.print(tree)

def load_patterns_from_env(var_name):
    """
    Load patterns from an environment variable.

    :param var_name: Name of the environment variable.
    :return: List of patterns.
    """
    patterns = os.getenv(var_name, "")
    return patterns.split() if patterns else []

def main():
    """
    Main function to parse arguments and generate the directory tree.
    """
    parser = argparse.ArgumentParser(
        description="Generate a tree structure of the current directory excluding and including specific directories/files."
    )
    parser.add_argument(
        '-e', '--exclude',
        nargs='+',
        default=[],
        help="Exclude directories/files matching the given patterns. Use '|' or spaces as separators."
    )
    parser.add_argument(
        '-i', '--include',
        nargs='+',
        default=[],
        help="Include only files matching the given patterns. Use '|' or spaces as separators."
    )
    parser.add_argument('-l', '--log-level', type=int, default=logging.INFO,
                        help='Set the logging level (10=DEBUG, 20=INFO, 30=WARNING, 40=ERROR, 50=CRITICAL)')

    # Parse arguments
    args = parser.parse_args()

    # Calculate the logging level by rounding down to the nearest multiple of 10
    logging_level = (args.log_level // 10) * 10
    logging.basicConfig(level=logging_level, format='%(message)s')

    # Load exclude patterns from environment variables
    env_dir_excludes = load_patterns_from_env('GENMD_DIR_EXCLUDES')
    env_file_excludes = load_patterns_from_env('GENMD_FILE_EXCLUDES')
    exclude_patterns = env_dir_excludes + env_file_excludes + args.exclude

    # Load include patterns from environment variables
    env_file_includes = load_patterns_from_env('GENMD_FILE_INCLUDES')
    include_patterns = env_file_includes + args.include

    # Remove duplicates while preserving order
    seen = set()
    exclude_patterns = [x for x in exclude_patterns if not (x in seen or seen.add(x))]
    include_patterns = [x for x in include_patterns if not (x in seen or seen.add(x))]

    generate_tree(exclude_patterns, include_patterns)

if __name__ == "__main__":
    main()