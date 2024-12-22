# numpybench

A utility for benchmarking NumPy performance, particularly useful for testing GPU and Neural Engine acceleration on Apple Silicon.

## Overview

`numpybench` is a benchmarking tool designed to test NumPy performance by running a series of matrix operations. It's particularly useful for:

- Verifying if NumPy is properly utilizing hardware acceleration (GPU/Neural Engine on Apple Silicon)
- Comparing performance between different NumPy builds
- Testing the impact of the Accelerate Framework on macOS
- Measuring performance improvements from hardware optimizations

When NumPy is properly compiled and linked against the Accelerate Framework on Apple Silicon, you can expect to see an 8-9x improvement in performance compared to pre-compiled binaries.

## Usage

```bash
numpybench [-o OUTPUT] [-s] [-c COUNT]
```

### Options

- `-o, --output`: Optional output file for detailed results
- `-s, --skip-tests`: Skip time-consuming tests
- `-c, --count`: Number of iterations for each test (default: 1)

## Tests Performed

The script runs the following matrix operations on 2500x2500 matrices:

1. Matrix multiplication (np.dot)
2. Matrix transposition (np.transpose)
3. Eigenvalue computation (np.linalg.eigvals)
4. Fourier transformation (np.fft.fft)
5. Summation (np.sum)

## Output

The output includes:

- Timestamp for each operation
- NumPy configuration details
- Execution time for each matrix operation
- Virtual environment information

## Examples

1. Basic benchmark:

    ```bash
    numpybench
    ```

2. Run tests with 5 iterations:

    ```bash
    numpybench -c 5
    ```

3. Save results to a file:

    ```bash
    numpybench -o results.txt
    ```

4. Skip time-consuming tests:

    ```bash
    numpybench -s
    ```

## Performance Notes

On Apple Silicon:

- With standard NumPy: Baseline performance
- With Accelerate Framework: 8-9x performance improvement
- Key operations like matrix multiplication and FFT show the most significant improvements

To get maximum performance on Apple Silicon, NumPy should be compiled with:

```bash
CFLAGS="-I/System/Library/Frameworks/vecLib.framework/Headers -Wl,-framework -Wl,Accelerate -framework Accelerate" pip install numpy==1.26.* --force-reinstall --no-deps --no-cache --no-binary :all: --no-build-isolation --compile -Csetup-args=-Dblas=accelerate -Csetup-args=-Dlapack=accelerate -Csetup-args=-Duse-ilp64=true
```

## Implementation Details

- Uses NumPy's random number generation for test matrices
- Measures wall clock time for operations
- Includes NumPy configuration information in output
- Supports virtual environment detection
