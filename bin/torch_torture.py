#!/usr/bin/env python
"""
Extended PyTorch benchmark script measuring time and memory usage
for CPU/MPS/CUDA. Includes advanced tests (conv2d, autograd) that
don't have NumPy equivalents.

This script runs a series of common matrix operations using PyTorch and measures:
- Execution time for each operation
- Memory usage via psutil for CPU and torch.cuda for GPU
- Supports configurable matrix sizes and iteration counts
- Can output results to file or stdout
- Supports multiple compute devices (CPU/CUDA/MPS)

Operations tested:
- Matrix multiplication
- Matrix transposition
- Matrix summation
- Fourier transformation
- 2D Convolution
- Autograd forward/backward pass

Usage:
    python torch_torture.py [--size SIZE] [--iterations ITERS] [--device DEVICE] [--output FILE]

Arguments:
    --size SIZE         Dimension N for NxN matrices (default: 2000)
    --iterations ITERS  Number of times to repeat each test (default: 10)
    --device DEVICE    Device to use: cpu | cuda | mps | auto (default: cpu)
    --output FILE      Optional file path to write results (default: stdout)

Output format:
    Tab-separated values with columns for package, version, matrix size,
    iterations, virtual environment, source, device, test name, runtime (s),
    and memory usage (MB).
"""

import argparse
import os
import time
from typing import Optional

import torch

try:
    import psutil
except ImportError:
    print("psutil is required for CPU memory usage reporting.")
    psutil = None


def get_process_memory_mb() -> float:
    """
    Returns the current resident set size (RSS) of the process in MB.
    If psutil isn't installed, returns 0.0.

    Uses psutil to get accurate memory measurements across platforms.
    If psutil is not available, returns 0.0.

    Returns:
        float: Memory usage in megabytes
    """
    if not psutil:
        return 0.0
    process = psutil.Process(os.getpid())
    return process.memory_info().rss / (1024 * 1024)


def get_gpu_memory_mb(device: torch.device) -> float:
    """
    Returns allocated GPU memory in MB for 'device' if it's CUDA.
    Otherwise returns 0.0 (no MPS memory reporting in PyTorch).

    Args:
        device: PyTorch device to check memory usage for

    Returns:
        float: GPU memory usage in megabytes, or 0.0 if not CUDA
    """
    if device.type == "cuda":
        return torch.cuda.memory_allocated(device=device) / (1024 * 1024)
    return 0.0


def format_output(
    package: str,
    version: str,
    size: int,
    iterations: int,
    venv: str,
    test_name: str,
    runtime: float,
    memory: float,
    src: str = "PyPi",
    device: str = "CPU",
) -> str:
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
        device: Computing device used (default: "CPU")

    Returns:
        str: Tab-separated string containing all metrics
    """
    return (
        f"{package:<10}\t{version:<10}\t{size:<8}\t{iterations:<8}\t"
        f"{venv:<15}\t{src:<8}\t{device:<8}\t{test_name:<30}\t"
        f"{runtime:<8.4f}\t{memory:<8.2f}"
    )


def main() -> None:
    """
    Main function that runs the PyTorch benchmark suite.

    Parses command line arguments, sets up the test environment and device,
    runs the benchmark tests, and outputs results. Each test is run
    for the specified number of iterations on matrices/tensors of the given size.
    Results include both execution time and memory usage (CPU and/or GPU).

    The function handles device selection (CPU/CUDA/MPS), tensor creation,
    and defines the test operations to benchmark. It measures both runtime
    and memory usage for each test, formatting and logging the results.
    """
    parser = argparse.ArgumentParser(description="Extended PyTorch benchmark script.")
    parser.add_argument(
        "--size", type=int, default=2000, help="Matrix dimension for certain tests."
    )
    parser.add_argument(
        "--iterations", type=int, default=10, help="Number of iterations per test."
    )
    parser.add_argument(
        "--device",
        type=str,
        default="cpu",
        help="Device to use: cpu | cuda | mps | auto (auto picks best available)",
    )
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

    # Determine device
    dev_str = args.device.lower()
    if dev_str == "auto":
        if torch.cuda.is_available():
            device = torch.device("cuda")
        elif torch.backends.mps.is_available():
            device = torch.device("mps")
        else:
            device = torch.device("cpu")
    else:
        device = torch.device(dev_str)

    venv = os.getenv("CONDA_DEFAULT_ENV", "unknown")
    size = args.size
    iterations = args.iterations

    # Create random tensors
    a = torch.rand(size, size, device=device)
    b = torch.rand(size, size, device=device)

    def op_matmul():
        return torch.mm(a, b)

    def op_transpose():
        return torch.t(a)

    def op_fft():
        return torch.fft.fft(a)

    def op_sum():
        return torch.sum(a)

    def op_convolution():
        conv = torch.nn.Conv2d(
            in_channels=3, out_channels=8, kernel_size=3, padding=1
        ).to(device)
        inp = torch.randn(16, 3, 64, 64, device=device)
        return conv(inp)

    def op_autograd():
        x = torch.randn(size, size, device=device, requires_grad=True)
        w = torch.randn(size, size, device=device, requires_grad=True)
        y = (x @ w).sum()
        y.backward()
        x.grad.zero_()
        w.grad.zero_()
        return y

    tests = [
        ("Matrix multiplication", op_matmul),
        ("Matrix transposition", op_transpose),
        ("Matrix Summation", op_sum),
        ("Fourier transformation", op_fft),
        ("Convolution test (Conv2D)", op_convolution),
        ("Autograd test (forward/back)", op_autograd),
    ]

    for test_name, func in tests:
        if device.type == "cuda":
            torch.cuda.reset_peak_memory_stats(device=device)

        start_t = time.time()
        for _ in range(iterations):
            _ = func()
        elapsed = time.time() - start_t

        # Get memory usage
        mem_mb = get_process_memory_mb()
        if device.type == "cuda":
            mem_mb += get_gpu_memory_mb(device)

        # Format and log output
        output = format_output(
            package="PyTorch",
            version=torch.__version__,
            size=size,
            iterations=iterations,
            venv=venv,
            test_name=test_name,
            runtime=elapsed,
            memory=mem_mb,
            device=device.type.upper(),
        )
        log(output)

    if out_file:
        out_file.close()


if __name__ == "__main__":
    main()
