#!/usr/bin/env python

import os
import re
import json
from datetime import datetime
from typing import Dict, Optional, List
import argparse
import glob

# Date/time formats
FILENAME_DATE_FORMAT = "%Y-%m-%d-%H%M%S"
DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S"


def fix_timestamp(ts: Optional[float]) -> Optional[float]:
    """
    Fix overly large timestamps by moving the decimal so
    they're in the ~10-digit Unix timestamp range.
    Returns None if input is None.
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
    Format a numeric timestamp into YYYY-MM-DD HH:MM:SS, after fixing if necessary.
    Returns an empty string if None or invalid.
    """
    ts_fixed = fix_timestamp(ts)
    if ts_fixed is None:
        return ""
    dt = datetime.fromtimestamp(ts_fixed)
    return dt.strftime(DATETIME_FORMAT)


def parse_datetime_string(dt_str: str) -> datetime:
    """
    Parse 'YYYY-MM-DD HH:MM:SS' into a datetime object.
    On error, return datetime.now() as a fallback.
    """
    try:
        return datetime.strptime(dt_str, DATETIME_FORMAT)
    except ValueError:
        return datetime.now()


def sanitize_title(title: str) -> str:
    """
    Replace problematic characters with underscores, remove extra underscores,
    strip leading/trailing punctuation, and ensure non-empty.
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
    Generate a unique filename of form:
        YYYY-MM-DD-HHMMSS_YYYY-MM-DD-HHMMSS-TITLE.ext

    - Fix timestamps if necessary.
    - Use create_time if update_time is missing.
    - Check for collisions, append -NN if needed (max 99 collisions).

    Raises ValueError if we fail after 99 collisions.
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
    Load JSON data from a file, returning a dict or None if invalid.
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


def confirm_and_rename(old_path: str, new_path: str, auto_yes: bool) -> None:
    print(f"Would rename:\n  {old_path}\n-> {new_path}")
    if auto_yes or input("Proceed with rename? (y/n): ").lower().strip() == "y":
        try:
            os.rename(old_path, new_path)
            print(f"Renamed to: {new_path}")
        except OSError as e:
            print(f"Error renaming {old_path}: {e}")
    else:
        print("Rename cancelled")


def process_files(patterns: List[str], auto_yes: bool, destination_dir: Optional[str] = None) -> None:
    """
    Process files matching the given patterns and rename them.
    
    Args:
        patterns: List of file patterns to process
        auto_yes: Whether to automatically confirm renames
        destination_dir: Optional directory to move renamed files to
    """
    files_to_rename = []
    
    # Default to current directory's JSON files if no patterns provided
    if not patterns:
        patterns = [os.path.join(os.getcwd(), "*.json")]
    
    for pattern in patterns:
        if os.path.isdir(pattern):
            files_to_rename.extend(glob.glob(os.path.join(pattern, "*.json")))
        else:
            matched = glob.glob(pattern)
            if not matched:
                print(f"No files match: {pattern}")
            files_to_rename.extend(matched)

    if not files_to_rename:
        print("No files found to process.")
        return

    print(f"Found {len(files_to_rename)} files.")
    for path in files_to_rename:
        if os.path.isfile(path) and path.lower().endswith(".json"):
            print(f"\nProcessing: {path}")
            rename_one_json(path, auto_yes, destination_dir)


def rename_one_json(file_path: str, auto_yes: bool, destination_dir: Optional[str] = None) -> None:
    """
    Rename a single JSON file based on its metadata.
    
    Args:
        file_path: Path to the JSON file
        auto_yes: Whether to automatically confirm renames
        destination_dir: Optional directory to move renamed files to
    """
    data = load_json_file(file_path)
    if not data:
        return

    title = data.get("title", "").strip()
    ctime = data.get("create_time")
    utime = data.get("update_time")

    if not title:
        print(f"Skipping {file_path}: Missing or empty title.")
        return
    if not ctime:
        print(f"Skipping {file_path}: Missing create_time.")
        return

    try:
        new_name = generate_unique_filename(
            file_path, title, ctime, utime, extension="json", out_dir=destination_dir
        )
        confirm_and_rename(file_path, new_name, auto_yes)
    except ValueError as e:
        # Possibly creation time is invalid, fallback to file stat times
        print(f"Error generating name for {file_path}: {e}")
        try:
            st = os.stat(file_path)
            ctime = st.st_ctime
            utime = st.st_mtime
            print("Using file system timestamps as fallback.")
            new_name = generate_unique_filename(
                file_path, title, ctime, utime, extension="json", out_dir=destination_dir
            )
            confirm_and_rename(file_path, new_name, auto_yes)
        except (OSError, ValueError) as e2:
            print(f"Failed fallback for {file_path}: {e2}")


def main():
    parser = argparse.ArgumentParser(description="Rename JSON files based on title and timestamps.")
    parser.add_argument("patterns", nargs="*", 
                        help="File patterns (wildcards, directories, etc.). Defaults to *.json in current directory.")
    parser.add_argument("-y", "--yes", action="store_true", 
                        help="Auto-confirm all renames.")
    parser.add_argument("-d", "--destination", 
                        help="Destination directory for renamed files.")
    args = parser.parse_args()
    
    process_files(args.patterns, args.yes, args.destination)


# Fix linter error: add two blank lines after function definition
if __name__ == "__main__":
    main()
