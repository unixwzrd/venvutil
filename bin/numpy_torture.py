#!/usr/bin/env python
"""
A NumPy benchmark script for measuring performance and memory usage.

This script runs a series of common matrix operations using NumPy and measures:
- Execution time for each operation
- Memory usage via psutil
- Supports configurable matrix sizes and iteration counts
- Can output results to file or stdout

Operations tested:
- Matrix multiplication
- Matrix transposition
- Eigenvalue computation
- Fourier transformation
- Matrix summation

Usage:
    python numpy_torture.py [--size SIZE] [--iterations ITERS] [--output FILE]

Arguments:
    --size SIZE         Dimension N for NxN matrices (default: 2000)
    --iterations ITERS  Number of times to repeat each test (default: 10)
    --output FILE      Optional file path to write results (default: stdout)

Output format:
    Tab-separated values with columns for package, version, matrix size,
    iterations, virtual environment, source, device, test name, runtime (s),
    and memory usage (MB).
"""

import argparse
import time
import os
from typing import Optional

import numpy as np

try:
    import psutil
except ImportError:
    print("psutil is required for memory usage reporting.")
    psutil = None


def get_process_memory_mb() -> float:
    """
    Returns the current resident set size (RSS) of the process in MB.

    Uses psutil to get accurate memory measurements across platforms.
    If psutil is not available, returns 0.0.

    Returns:
        float: Memory usage in megabytes
    """
    if not psutil:
        return 0.0
    process = psutil.Process(os.getpid())
    return process.memory_info().rss / (1024 * 1024)


def format_output(package: str, version: str, size: int, iterations: int,
                  venv: str, test_name: str, runtime: float, memory: float,
                  src: str = "PyPi", device: str = "Default") -> str:
    """
    Formats benchmark results into a tab-separated string matching metrics layout.

    Args:
        package: Name of the package being tested
        version: Version of the package
        size: Matrix dimension used in test
        iterations: Number of test iterations
        venv: Virtual environment name
        test_name: Name of the specific test
        runtime: Test execution time in seconds
        memory: Memory usage in MB
        src: Package source (default: "PyPi")
        device: Computing device used (default: "Default")

    Returns:
        str: Tab-separated string containing all metrics
    """
    return (f"{package:<10}\t{version:<10}\t{size:<8}\t{iterations:<8}\t"
            f"{venv:<15}\t{src:<8}\t{device:<8}\t{test_name:<30}\t"
            f"{runtime:<8.4f}\t{memory:<8.2f}")


def main() -> None:
    """
    Main function that runs the NumPy benchmark suite.

    Parses command line arguments, sets up the test environment,
    runs the benchmark tests, and outputs results. Each test is run
    for the specified number of iterations on matrices of the given size.
    Results include both execution time and memory usage.
    """
    parser = argparse.ArgumentParser(description="NumPy benchmark for matrix ops.")
    parser.add_argument("--size", type=int, default=2000, help="Matrix dimension.")
    parser.add_argument("--iterations", type=int, default=10, help="Number of iterations per test.")
    parser.add_argument("--output", type=str, help="Path to output log file.")
    args = parser.parse_args()

    out_file: Optional[object] = None
    if args.output:
        out_file = open(args.output, "w", encoding="utf-8")

    def log(msg: str) -> None:
        print(msg)
        if out_file:
            out_file.write(f"{msg}\n")
    # Print header
    header = "Package\tVersion\tSize\tIterations\tVirtual Env\tSrc\tDevice\tTest\tRun Time\tMemory"
    log(header)

    venv = os.getenv('CONDA_DEFAULT_ENV', 'unknown')
    size = args.size
    iterations = args.iterations

    # Create random arrays
    a = np.random.rand(size, size)
    b = np.random.rand(size, size)

    # Define tests: (test_name, function)
    tests = [
        ("Matrix multiplication", lambda: np.dot(a, b)),
        ("Matrix transposition", lambda: np.transpose(a)),
        ("Eigenvalue computation", lambda: np.linalg.eigvals(a)),
        ("Fourier transformation", lambda: np.fft.fft(a)),
        ("Matrix Summation", lambda: np.sum(a)),
    ]

    for test_name, func in tests:
        start_t = time.time()
        for _ in range(iterations):
            _ = func()  # Force computation
        elapsed = time.time() - start_t

        # Memory usage after test
        mem_mb = get_process_memory_mb()

        # Format and log output
        output = format_output(
            package="NumPy",
            version=np.__version__,
            size=size,
            iterations=iterations,
            venv=venv,
            test_name=test_name,
            runtime=elapsed,
            memory=mem_mb
        )
        log(output)

    if out_file:
        out_file.close()


if __name__ == "__main__":
    main()
