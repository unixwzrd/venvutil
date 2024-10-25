#!/usr/bin/env python
"""
Generate a tree structure of the current directory excluding specific directories/files.
"""

import os
import argparse as Ap
from rich.console import Console
from rich.tree import Tree

def is_ignored(item_name, exclude_patterns):
    """
    Check if the item should be ignored based on the exclusion patterns.

    :param item_name: The name of the item to check.
    :param exclude_patterns: List of directory patterns to exclude.
    :return: True if the item should be ignored, False otherwise.
    """
    return item_name.startswith('.') or item_name in exclude_patterns

def add_items(root_dir, parent_tree, exclude_patterns):
    """
    Recursively add items in the file system to the tree structure.

    :param root_dir: The root directory to start from.
    :param parent_tree: The parent tree node to add items to.
    :param exclude_patterns: List of directory patterns to exclude.
    """
    for item_name in sorted(os.listdir(root_dir)):
        item_path = os.path.join(root_dir, item_name)
        if is_ignored(item_name, exclude_patterns):
            continue

        if os.path.isdir(item_path):
            # Add directory with custom format and recursively add subdirectories
            dir_branch = parent_tree.add(f"{item_name}/")
            add_items(item_path, dir_branch, exclude_patterns)
        elif item_name.endswith(('.html', '.md', '.py', '.js', '.css', '.sass', '.scss', '.sh', '.png', '.yml')):
            # Add file with custom format for files
            parent_tree.add(item_name)

def generate_tree(exclude_patterns):
    """
    Generate a tree structure of the current directory excluding specific directories/files.
    """
    console = Console()
    tree = Tree("Root Directory")
    add_items(".", tree, exclude_patterns)
    console.print(tree)

if __name__ == "__main__":
    # Argument parser setup to allow exclusions from command line
    parser = Ap.ArgumentParser(description="Generate a tree structure excluding specific directories/files.")
    parser.add_argument('--exclude', nargs='+', default=[],
                        help='List of directories/files to exclude.')
    args = parser.parse_args()

    # Load exclude patterns from environment variable if set
    env_excludes = os.getenv('GENMD_DIR_EXCLUDES')
    if env_excludes:
        env_excludes_list = env_excludes.split()
        args.exclude.extend(env_excludes_list)

    # Remove duplicates while preserving order
    seen = set()
    exclude_patterns = []
    for pattern in args.exclude:
        if pattern not in seen:
            seen.add(pattern)
            exclude_patterns.append(pattern)

    generate_tree(exclude_patterns)