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

import argparse
import fnmatch
import logging
import os
import re
import sys
from typing import List, Sequence

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


def _split_pattern_tokens(raw_pattern: str) -> List[str]:
    """Split a raw pattern string on pipe characters and whitespace."""

    return [
        token.strip()
        for token in re.split(r"[| ]+", raw_pattern.strip())
        if token.strip()
    ]


def collect_pattern_tokens(patterns: Sequence[str]) -> List[str]:
    """Expand user-supplied pattern arguments into individual pattern tokens."""

    collected: List[str] = []
    for raw_pattern in patterns:
        if not raw_pattern:
            continue
        normalized_input = raw_pattern.strip()
        if not normalized_input:
            continue

        if os.path.exists(normalized_input):
            if os.path.isfile(normalized_input):
                _, extension = os.path.splitext(normalized_input)
                if extension:
                    collected.append(f"*{extension}")
            else:
                collected.append(os.path.basename(normalized_input))
            continue

        split_tokens = _split_pattern_tokens(normalized_input)
        if split_tokens:
            collected.extend(split_tokens)
        else:
            collected.append(normalized_input)
    return collected


def extract_directory_allowlist(pattern_tokens: Sequence[str]) -> List[str]:
    """Identify directory-only patterns that should constrain traversal."""

    directories: List[str] = []
    for token in pattern_tokens:
        candidate = token.strip()
        if not candidate:
            continue

        normalized = candidate

        escape_replacements = {
            r"\.": ".",
            r"\*": "*",
            r"\?": "?",
        }
        for escape_pattern, replacement in escape_replacements.items():
            normalized = normalized.replace(escape_pattern, replacement)

        normalized = normalized.replace("\\", "/")
        while "//" in normalized:
            normalized = normalized.replace("//", "/")

        if normalized.startswith("./"):
            normalized = normalized[2:]

        if normalized.startswith("/"):
            normalized = normalized[1:]

        if normalized.endswith("/"):
            normalized = normalized[:-1]

        if not normalized or normalized in {".", "/"}:
            continue

        if any(char in normalized for char in "*?[]"):
            continue

        if os.path.splitext(normalized)[1]:
            continue

        if normalized not in directories:
            directories.append(normalized)

    return directories


def _expand_pattern_variants(pattern: str, treat_as_include: bool) -> List[str]:
    """Normalize a pattern and add variants that cover nested paths."""

    if not pattern:
        return []

    original = pattern.strip()
    if not original:
        return []

    canonical = original

    # Normalize escaped tokens before handling path separators
    escape_replacements = {
        r"\.": ".",
        r"\*": "*",
        r"\?": "?",
    }
    for escape_pattern, replacement in escape_replacements.items():
        canonical = canonical.replace(escape_pattern, replacement)

    canonical = canonical.replace("\\", "/")
    while "//" in canonical:
        canonical = canonical.replace("//", "/")

    if canonical.startswith("./"):
        canonical = canonical[2:]

    if canonical not in {"", "/"}:
        canonical = canonical.rstrip("/")

    canonical = canonical.replace(r"\.", ".")
    canonical = re.sub(
        r"(^|/)\.\*(?=[^/])",
        lambda match: f"{match.group(1)}*",
        canonical,
    )

    if not canonical:
        canonical = original

    variants: List[str] = []

    def add_variant(value: str) -> None:
        if value and value not in variants:
            variants.append(value)

    add_variant(canonical)

    add_extension_variant = treat_as_include or ".*" in original

    if canonical.startswith(".") and not canonical.startswith("..") and "/" not in canonical:
        if add_extension_variant:
            add_variant(f"*{canonical}")
            add_variant(f"**/*{canonical}")
    elif canonical.startswith("*") and not canonical.startswith("**/") and "/" not in canonical:
        add_variant(f"**/{canonical}")
    elif "/" not in canonical and not canonical.startswith("**"):
        add_variant(f"**/{canonical}")

    return variants


def normalize_patterns(patterns: Sequence[str], treat_as_include: bool = False) -> List[str]:
    """Normalize patterns and remove duplicates while preserving order."""

    normalized: List[str] = []
    for pattern in patterns:
        for variant in _expand_pattern_variants(pattern=pattern, treat_as_include=treat_as_include):
            if variant and variant not in normalized:
                normalized.append(variant)
    return normalized


def is_path_within_allowlist(
    relative_path: str,
    directory_allowlist: Sequence[str],
) -> bool:
    """Check whether a path belongs to a directory allowlist."""

    normalized_path = relative_path.replace("\\", "/")

    for allowed in directory_allowlist:
        if normalized_path == allowed or normalized_path.startswith(f"{allowed}/"):
            return True

    return False


def should_descend_directory(
    relative_path: str,
    directory_allowlist: Sequence[str],
    show_all: bool,
) -> bool:
    """Determine whether a directory is eligible for traversal."""

    if show_all or not directory_allowlist:
        return True

    return is_path_within_allowlist(relative_path, directory_allowlist)


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

    # Check if any part of the path matches an exclude pattern
    path_parts = item_relative_path.split(os.sep)
    for pattern in exclude_patterns:
        # First check if the pattern is a substring of any part of the path
        for part in path_parts:
            if pattern in part:
                logging.debug(
                    "Ignoring item because pattern '%s' is in path part '%s': %s",
                    pattern, part, item_relative_path
                )
                return True
        # Then check if the pattern matches as a glob pattern
        for part in path_parts:
            if fnmatch.fnmatch(part, pattern):
                logging.debug(
                    "Ignoring item based on pattern '%s' matching part '%s': %s",
                    pattern, part, item_relative_path
                )
                return True
        # Also check if the full path matches the pattern
        if fnmatch.fnmatch(item_relative_path, pattern):
            logging.debug(
                "Ignoring item based on pattern '%s' matching full path: %s",
                pattern, item_relative_path
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
    # Check if any part of the path matches an include pattern
    path_parts = item_relative_path.split(os.sep)
    for pattern in include_patterns:
        # Check if pattern matches any part of the path
        for part in path_parts:
            if fnmatch.fnmatch(part, pattern):
                logging.debug(
                    "Including item based on pattern '%s' matching part '%s': %s",
                    pattern, part, item_relative_path
                )
                return True
        # Also check if the full path matches the pattern
        if fnmatch.fnmatch(item_relative_path, pattern):
            logging.debug(
                "Including item based on pattern '%s' matching full path: %s",
                pattern, item_relative_path
            )
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
    directory_allowlist=None,
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
    has_included_items = False
    if directory_allowlist is None:
        directory_allowlist = []

    try:
        # Process all items in the current directory
        for item_name in sorted(os.listdir(root_dir)):
            item_path = os.path.join(root_dir, item_name)
            item_relative_path = (
                os.path.join(relative_path, item_name) if relative_path else item_name
            )

            # Skip if the item is in the exclude list
            if is_ignored(item_relative_path, exclude_patterns, show_all):
                logging.debug("Skipping excluded item: %s", item_relative_path)
                continue

            if os.path.isfile(item_path):
                # For files, check if they match the include patterns
                if directory_allowlist and not is_path_within_allowlist(
                    item_relative_path,
                    directory_allowlist,
                ):
                    logging.debug(
                        "Skipping file outside allowlist: %s",
                        item_relative_path,
                    )
                    continue

                if is_included(item_relative_path, include_patterns, show_all):
                    parent_tree.add(item_name)
                    has_included_items = True
                    logging.debug("Added file: %s", item_relative_path)
            elif os.path.isdir(item_path) and (
                follow_links or not os.path.islink(item_path)
            ):
                if not should_descend_directory(
                    item_relative_path,
                    directory_allowlist,
                    show_all,
                ):
                    logging.debug(
                        "Skipping directory outside allowlist: %s",
                        item_relative_path,
                    )
                    continue

                # For directories, always traverse them unless explicitly excluded
                logging.debug("Entering directory: %s", item_relative_path)
                dir_branch = Tree(f"{item_name}/")
                dir_has_items = add_items(
                    item_path,
                    dir_branch,
                    exclude_patterns,
                    include_patterns,
                    show_all,
                    item_relative_path,
                    follow_links,
                    directory_allowlist,
                )
                if dir_has_items:
                    parent_tree.add(dir_branch)
                    has_included_items = True
                    logging.debug("Added directory with items: %s", item_relative_path)

    except PermissionError:
        parent_tree.add("[red]Permission Denied[/red]")
        has_included_items = True
    return has_included_items


def generate_tree(
    exclude_patterns,
    include_patterns,
    show_all=False,
    follow_links=False,
    directory_allowlist=None,
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
        directory_allowlist=directory_allowlist,
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

    # Built-in default exclusion patterns
    DEFAULT_EXCLUDES = [".git", ".git/", ".jekyll-cache", ".DS_Store"]

    cli_exclude_tokens = collect_pattern_tokens(args.exclude)
    env_dir_exclude_tokens = collect_pattern_tokens(
        load_patterns_from_env("GENMD_DIR_EXCLUDES")
    )
    env_file_exclude_tokens = collect_pattern_tokens(
        load_patterns_from_env("GENMD_FILE_EXCLUDES")
    )
    config_exclude_tokens = collect_pattern_tokens(
        load_exclusions_from_file(".exclusions.cfg")
    )
    default_exclude_tokens = collect_pattern_tokens(DEFAULT_EXCLUDES)

    combined_exclude_tokens = (
        cli_exclude_tokens
        + env_dir_exclude_tokens
        + env_file_exclude_tokens
        + default_exclude_tokens
        + config_exclude_tokens
    )
    exclude_patterns = normalize_patterns(
        combined_exclude_tokens,
        treat_as_include=False,
    )
    logging.debug("Final exclusion patterns: %s", exclude_patterns)

    cli_include_tokens = collect_pattern_tokens(args.include)
    env_include_tokens = collect_pattern_tokens(
        load_patterns_from_env("GENMD_FILE_INCLUDES")
    )
    include_pattern_tokens = cli_include_tokens + env_include_tokens
    include_patterns = normalize_patterns(
        include_pattern_tokens,
        treat_as_include=True,
    )
    include_directory_allowlist = extract_directory_allowlist(include_pattern_tokens)

    if include_directory_allowlist:
        directory_patterns = set(include_directory_allowlist)
        directory_patterns.update(f"**/{directory}" for directory in include_directory_allowlist)
        include_patterns = [
            pattern
            for pattern in include_patterns
            if pattern not in directory_patterns
        ]

    logging.debug("Final inclusion patterns: %s", include_patterns)

    # Process follow_links argument
    follow_links = args.follow_links

    if args.all:
        logging.debug("Displaying the entire file tree without any filters")
        exclude_patterns = []
        include_patterns = []
        generate_tree(
            exclude_patterns,
            include_patterns,
            show_all=True,
            follow_links=follow_links,
            directory_allowlist=[],
        )
    else:
        generate_tree(
            exclude_patterns,
            include_patterns,
            show_all=args.all,
            follow_links=follow_links,
            directory_allowlist=include_directory_allowlist,
        )


if __name__ == "__main__":
    main()
