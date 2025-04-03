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
    -L, --follow-links          Follow symlinks when scanning directories.
    -l, --log-level             Set the logging level (10=DEBUG, 20=INFO, 30=WARNING, 40=ERROR, 50=CRITICAL)
    -a, --all                   Display the entire file tree without any filters

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
import sys
import argparse
import re
from pathlib import Path
import logging
from rich.console import Console
from rich.tree import Tree

# Get the program name dynamically
program_name = os.path.basename(sys.argv[0])


# Configure logging to include the program name
def configure_logging():
    logging.basicConfig(
        format=f"{program_name} %(levelname)s(%(levelno)s): %(message)s",
        level=logging.INFO,
    )


# Call the logging configuration function
configure_logging()


def is_ignored(item_relative_path, exclude_patterns, show_all=False):
    """
    Check if the item should be ignored based on the exclusion patterns.

    :param item_relative_path: The relative path of the item to check.
    :param exclude_patterns: List of patterns to exclude.
    :param show_all: If True, do not ignore any items.
    :return: True if the item should be ignored, False otherwise.
    """
    if show_all:
        return False
    # Explicitly ignore .git directory and its contents
    if item_relative_path == ".git" or item_relative_path.startswith(".git/"):
        logging.debug("Ignoring .git directory: %s", item_relative_path)
        return True
    path_obj = Path(item_relative_path)
    for pattern in exclude_patterns:
        if path_obj.match(pattern):
            logging.debug(
                "Ignoring item based on pattern '%s': %s", pattern, item_relative_path
            )
            return True
    return False


def is_included(item_relative_path, include_patterns, show_all=False):
    """
    Check if the item should be included based on the inclusion patterns.

    :param item_relative_path: The relative path of the item to check.
    :param include_patterns: List of patterns to include.
    :param show_all: If True, include all items.
    :return: True if the item should be included, False otherwise.
    """
    if show_all or not include_patterns:
        return True
    path_obj = Path(item_relative_path)
    for pattern in include_patterns:
        if path_obj.match(pattern):
            return True
    return False


def add_items(
    root_dir,
    parent_tree,
    exclude_patterns,
    include_patterns,
    show_all=False,
    relative_path="",
    follow_links=False,
):
    """
    Recursively add items in the file system to the tree structure.

    :param root_dir: The root directory to start from.
    :param parent_tree: The parent tree node to add items to.
    :param exclude_patterns: List of patterns to exclude.
    :param include_patterns: List of patterns to include.
    :param show_all: If True, include all items without filtering.
    :param relative_path: The relative path from the root directory.
    :param follow_links: If True, follow symbolic links.
    :return: True if any items were added to the tree, False otherwise.
    """
    has_included_items = (
        False  # Flag to check if current directory has any included items
    )
    try:
        for item_name in sorted(os.listdir(root_dir)):
            item_path = os.path.join(root_dir, item_name)
            item_relative_path = (
                os.path.join(relative_path, item_name) if relative_path else item_name
            )
            if is_ignored(item_relative_path, exclude_patterns, show_all):
                continue
            if os.path.isdir(item_path) and (
                follow_links or not os.path.islink(item_path)
            ):
                # Recursively add subdirectories
                dir_branch = Tree(f"{item_name}/")
                dir_has_items = add_items(
                    item_path,
                    dir_branch,
                    exclude_patterns,
                    include_patterns,
                    show_all,
                    item_relative_path,
                    follow_links,
                )
                if dir_has_items:
                    parent_tree.add(dir_branch)
                    has_included_items = True
            elif os.path.isfile(item_path):
                if is_included(item_relative_path, include_patterns, show_all):
                    parent_tree.add(item_name)
                    has_included_items = True
    except PermissionError:
        parent_tree.add("[red]Permission Denied[/red]")
        has_included_items = True
    return has_included_items


def generate_tree(
    exclude_patterns, include_patterns, show_all=False, follow_links=False
):
    """
    Generate a tree structure of the current directory excluding and including specific directories/files.

    :param exclude_patterns: List of patterns to exclude.
    :param include_patterns: List of patterns to include.
    :param show_all: If True, display the entire file tree without any filters.
    :param follow_links: If True, follow symbolic links.
    """
    console = Console()
    tree = Tree("Root Directory")
    add_items(
        ".",
        tree,
        exclude_patterns,
        include_patterns,
        show_all,
        follow_links=follow_links,
    )
    console.print(tree)


def load_patterns_from_env(var_name):
    """
    Load patterns from an environment variable.

    :param var_name: Name of the environment variable.
    :return: List of patterns.
    """
    patterns = os.getenv(var_name, "")
    return patterns.split() if patterns else []


def load_exclusions_from_file(config_file):
    """
    Load exclusion patterns from a configuration file.
    :param config_file: Path to the configuration file.
    :return: A list of exclusion patterns.
    """
    try:
        with open(config_file, "r", encoding="utf-8") as file:
            return [
                line.strip()
                for line in file
                if line.strip() and not line.startswith("#")
            ]
    except FileNotFoundError:
        logging.warning("Configuration file not found: %s", config_file)
        return []


def main():
    """
    Main function to parse arguments and generate the directory tree.
    """
    parser = argparse.ArgumentParser(
        description="Generate a tree structure of the current directory excluding and including specific directories/files."
    )
    parser.add_argument(
        "-e",
        "--exclude",
        nargs="*",
        default=[],
        help="Exclude directories/files matching the given patterns. Use '|' or spaces as separators.",
    )
    parser.add_argument(
        "-i",
        "--include",
        nargs="*",
        default=[],
        help="Include only files matching the given patterns. Use '|' or spaces as separators.",
    )
    parser.add_argument(
        "-L",
        "--follow-links",
        action="store_true",
        help="Follow symbolic links when scanning directories.",
    )
    parser.add_argument(
        "-l",
        "--log-level",
        type=int,
        default=logging.INFO,
        help="Set the logging level (10=DEBUG, 20=INFO, 30=WARNING, 40=ERROR, 50=CRITICAL)",
    )
    parser.add_argument(
        "-a",
        "--all",
        action="store_true",
        help="Display the entire file tree without any filters",
    )

    # Parse arguments
    args = parser.parse_args()

    # Calculate the logging level
    logging_level = (args.log_level // 10) * 10
    logging.basicConfig(level=logging_level, format=f"{program_name} %(message)s")

    # Process exclude patterns
    exclude_patterns = []
    for pattern in args.exclude:
        patterns = [p.strip() for p in re.split(r"[| ]+", pattern.strip()) if p.strip()]
        exclude_patterns.extend(patterns)

    # Load exclude patterns from environment variables
    env_dir_excludes = load_patterns_from_env("GENMD_DIR_EXCLUDES")
    env_file_excludes = load_patterns_from_env("GENMD_FILE_EXCLUDES")
    exclude_patterns += env_dir_excludes + env_file_excludes

    # Built-in default exclusion patterns
    DEFAULT_EXCLUDES = [".git", ".git/", ".jekyll-cache", ".DS_Store"]

    # Load exclusion patterns from a configuration file
    config_excludes = load_exclusions_from_file(".exclusions.cfg")
    exclude_patterns.extend(DEFAULT_EXCLUDES + config_excludes)

    # Ensure no duplicates or empty patterns in the exclusion patterns
    exclude_patterns = list(set(p for p in exclude_patterns if p))
    logging.debug("Exclusion patterns before adjustment: %s", exclude_patterns)

    # Adjust patterns to include both the pattern and '**/' + pattern
    adjusted_exclude_patterns = []
    for pattern in exclude_patterns:
        if not pattern:  # Skip empty patterns
            continue
        adjusted_exclude_patterns.append(pattern)
        if not pattern.startswith("**/"):
            adjusted_exclude_patterns.append("**/%s" % pattern)
    exclude_patterns = list(set(p for p in adjusted_exclude_patterns if p))
    logging.debug("Adjusted exclusion patterns: %s", exclude_patterns)

    # Process include patterns
    include_patterns = []
    for pattern in args.include:
        split_patterns = [p.strip() for p in re.split(r"[| ]+", pattern.strip()) if p.strip()]
        for pat in split_patterns:
            if pat.startswith("."):
                # Assume it's a file extension
                include_patterns.append("*%s" % pat)
                include_patterns.append("**/*%s" % pat)
            else:
                include_patterns.append(pat)
                if not pat.startswith("**/"):
                    include_patterns.append("**/%s" % pat)
    include_patterns = list(set(p for p in include_patterns if p))
    logging.debug("Adjusted include patterns: %s", include_patterns)

    # Load include patterns from environment variables
    env_file_includes = load_patterns_from_env("GENMD_FILE_INCLUDES")
    include_patterns += env_file_includes

    # Process follow_links argument
    follow_links = args.follow_links

    if args.all:
        logging.debug("Displaying the entire file tree without any filters")
        exclude_patterns = []
        include_patterns = []
        generate_tree(
            exclude_patterns, include_patterns, show_all=True, follow_links=follow_links
        )
    else:
        generate_tree(
            exclude_patterns,
            include_patterns,
            show_all=args.all,
            follow_links=follow_links,
        )


if __name__ == "__main__":
    main()
