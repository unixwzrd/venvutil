#!/usr/bin/env python3

"""
Split files into chunks based on various criteria.

This script provides functionality to split a file into multiple chunks based on:
- Number of chunks (-n)
- Size of each chunk (-s)
- Number of lines per chunk (-l)

Each mode supports overlapping content between chunks (-o) to ensure context is preserved
across chunk boundaries.
"""

import argparse
import os
from typing import List, Optional, Union


def validate_inputs(
    num_chunks: Optional[int],
    chunk_size: Optional[int],
    num_lines: Optional[int],
    overlap: int,
    file_size: int,
) -> None:
    """Validate input parameters for file chunking.

    Args:
        num_chunks: Number of chunks to create.
        chunk_size: Size of each chunk in bytes.
        num_lines: Number of lines per chunk.
        overlap: Number of bytes/lines to overlap between chunks.
        file_size: Size of the input file in bytes.

    Raises:
        ValueError: If input parameters are invalid or incompatible.
    """
    # Check that exactly one chunking mode is specified
    modes = [num_chunks, chunk_size, num_lines]
    active_modes = sum(1 for mode in modes if mode is not None)
    if active_modes != 1:
        raise ValueError(
            "You must specify exactly one of: num_chunks, chunk_size, or num_lines."
        )

    # Validate overlap
    if overlap < 0:
        raise ValueError("Overlap must be non-negative.")

    # Validate chunk size for -n mode
    if num_chunks:
        if num_chunks <= 0:
            raise ValueError("Number of chunks must be positive.")
        total = file_size + (num_chunks - 1) * overlap
        calculated_size = total // num_chunks
        if calculated_size <= overlap:
            raise ValueError(
                "Chunk size would be smaller than overlap. "
                "Reduce number of chunks or overlap size."
            )

    # Validate chunk size for -s mode
    if chunk_size:
        if chunk_size <= 0:
            raise ValueError("Chunk size must be positive.")
        if chunk_size <= overlap:
            raise ValueError("Chunk size must be larger than overlap.")

    # Validate line count for -l mode
    if num_lines:
        if num_lines <= 0:
            raise ValueError("Number of lines must be positive.")
        if num_lines <= overlap:
            raise ValueError("Number of lines must be larger than overlap.")


def process_line_based_chunk(
    file, num_lines: int, overlap: int, is_first: bool, prev_lines: List[str]
) -> tuple[List[str], List[str], bool]:
    """Process a chunk when splitting by lines.

    Args:
        file: The input file object.
        num_lines: Number of lines per chunk.
        overlap: Number of lines to overlap.
        is_first: Whether this is the first chunk.
        prev_lines: Lines from previous chunk for overlap.

    Returns:
        Tuple of (current chunk lines, lines for next overlap, whether to stop).
    """
    lines = []
    if overlap > 0 and prev_lines:
        lines.extend(prev_lines)

    # Calculate how many new lines to read
    needed = num_lines - (0 if is_first else overlap)
    for _ in range(needed):
        line = file.readline()
        if not line:
            break
        lines.append(line)

    if not lines:
        return [], [], True

    # Store lines for next chunk's overlap
    next_overlap = lines[-overlap:] if overlap > 0 else []

    return lines, next_overlap, False


def process_byte_based_chunk(
    file,
    chunk_size: int,
    overlap: int,
    is_first: bool,
    prev_overlap: bytes,
    total_read: int,
    file_size: int,
) -> tuple[Optional[bytes], bytes, int, bool]:
    """Process a chunk when splitting by bytes or number of chunks.

    Args:
        file: The input file object.
        chunk_size: Size of each chunk in bytes.
        overlap: Number of bytes to overlap.
        is_first: Whether this is the first chunk.
        prev_overlap: Bytes from previous chunk for overlap.
        total_read: Total bytes read so far.
        file_size: Total size of input file.

    Returns:
        Tuple of (current chunk, next overlap, new total read, whether to stop).
    """
    to_read = chunk_size if is_first else chunk_size - overlap
    chunk = file.read(to_read)
    if not chunk:
        return None, b"", total_read, True

    total_read += len(chunk)
    actual = prev_overlap + chunk

    if len(actual) < chunk_size:
        if total_read >= file_size:
            return actual, b"", total_read, False
        return None, prev_overlap, total_read - len(chunk), False
    current = actual[:chunk_size]
    next_overlap = actual[chunk_size - overlap:chunk_size]
    return current, next_overlap, total_read, False


def write_chunk(
    chunk: Union[bytes, List[str]],
    input_file: str,
    part_num: int,
    is_lines: bool = False,
) -> None:
    """Write a chunk to a file.

    Args:
        chunk: The chunk data to write.
        input_file: Original input filename (for naming chunks).
        part_num: Current chunk number.
        is_lines: Whether the chunk is line-based.
    """
    name, ext = os.path.splitext(input_file)
    base = os.path.basename(name)
    out_file = f"{base}_{part_num:02}{ext}"

<<<<<<< HEAD
    with open(out_file, "wb", encoding="utf-8") as chunk_file:
        if is_lines:
=======
    mode = "w" if is_lines else "wb"
    if is_lines:
        # Ensure chunk is a list of str for line mode
        if not isinstance(chunk, list) or (chunk and not isinstance(chunk[0], str)):
            chunk = [str(line) for line in chunk]
        with open(out_file, mode, encoding="utf-8") as chunk_file:
>>>>>>> origin/dev
            # For line mode, join lines and remove trailing newline
            data = "".join(chunk)
            chunk_file.write(data.rstrip("\n"))
    else:
        with open(out_file, mode) as chunk_file:
            chunk_file.write(chunk)  # type: ignore
    print(f"Created: {out_file}")


def split_file(
    input_file: str,
    num_chunks: Optional[int] = None,
    chunk_size: Optional[int] = None,
    overlap: int = 0,
    num_lines: Optional[int] = None,
) -> None:
    """Split a file into chunks based on specified parameters.

    The file can be split based on:
    - Number of chunks (-n)
    - Size of each chunk (-s)
    - Number of lines per chunk (-l)

    Each mode supports overlapping content between chunks to preserve context.

    Args:
        input_file: Path to the file to split.
        num_chunks: Number of chunks to create.
        chunk_size: Size of each chunk in bytes.
        overlap: Number of bytes/lines to overlap between chunks.
        num_lines: Number of lines per chunk.

    Raises:
        ValueError: If input parameters are invalid.
    """
    file_size = os.path.getsize(input_file)
    validate_inputs(num_chunks, chunk_size, num_lines, overlap, file_size)

    # Calculate chunk size if splitting by number of chunks
    if num_chunks:
        total = file_size + (num_chunks - 1) * overlap
        chunk_size = total // num_chunks

    if num_lines:
        # For line-based chunking, use text mode with UTF-8 encoding
        with open(input_file, "r", encoding="utf-8") as file:
            part_num = 1
            prev_lines: List[str] = []

            while True:
                is_first = part_num == 1
                lines, prev_lines, should_stop = process_line_based_chunk(
                    file, num_lines, overlap, is_first, prev_lines
                )
                if should_stop:
                    break
                write_chunk(lines, input_file, part_num, is_lines=True)
                if len(lines) < (num_lines - (0 if is_first else overlap)):
                    break
                part_num += 1
    else:
        # For byte-based chunking, use binary mode without encoding
        with open(input_file, "rb") as file:
            part_num = 1
            prev_overlap = b""
            total_read = 0

            while True:
                is_first = part_num == 1
                assert chunk_size is not None  # for type checker
                result = process_byte_based_chunk(
                    file,
                    chunk_size,
                    overlap,
                    is_first,
                    prev_overlap,
                    total_read,
                    file_size,
                )
                current, prev_overlap, total_read, should_stop = result
                if should_stop:
                    break
                if current is None:
                    continue
                write_chunk(current, input_file, part_num)
                if total_read >= file_size and not prev_overlap:
                    break
                part_num += 1
                if num_chunks and part_num > num_chunks:
                    break

    # Print summary
    print(f"Total chunks created: {part_num - 1}")
    if num_lines:
        print(f"Lines per chunk: {num_lines}")
        if overlap > 0:
            print(f"Lines overlapping between chunks: {overlap}")
    else:
        print(f"Chunk size: {chunk_size} bytes")


def main() -> None:
    """Parse command-line arguments and run the file splitting process."""
    parser = argparse.ArgumentParser(
        description="Split a file into chunks with optional overlap."
    )
    parser.add_argument("filename", help="The file to split")
    parser.add_argument(
        "-n", "--num_chunks", type=int, help="Number of chunks to create"
    )
    parser.add_argument("-s", "--size", type=int, help="Size of each chunk in bytes")
    parser.add_argument(
        "-o",
        "--overlap",
        type=int,
        default=0,
        help="Overlap in bytes/lines between chunks",
    )
    parser.add_argument("-l", "--lines", type=int, help="Number of lines per chunk")

    args = parser.parse_args()

    if not args.num_chunks and not args.size and not args.lines:
        parser.error(
            "You must specify one of: number of chunks (-n), "
            "chunk size (-s), or lines per chunk (-l)."
        )

    try:
        split_file(args.filename, args.num_chunks, args.size, args.overlap, args.lines)
    except ValueError as e:
        parser.error(str(e))


if __name__ == "__main__":
    main()
