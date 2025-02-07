# Performance Testing Guide

## Overview
This guide covers the performance testing tools included in the venvutil package. These tools are specifically designed to help you verify and optimize Python package performance on Apple Silicon, particularly focusing on GPU and Neural Engine utilization through the Accelerate framework.

## Tools

### torch_torture.py
A PyTorch stress testing tool for evaluating GPU and Neural Engine performance on Apple Silicon.
Helps verify proper MPS (Metal Performance Shaders) backend utilization.

#### Usage
```bash
torch_torture.py [-h] [-s SIZE] [-i ITERATIONS] [-d DEVICE] [-o OUTPUT]
```

#### Parameters
- `-s, --size`: Matrix size for operations (default: 1000)
- `-i, --iterations`: Number of test iterations (default: 10)
- `-d, --device`: Device to use ('cuda', 'mps', or 'cpu')
- `-o, --output`: Output file for results

#### Tests Performed
- Matrix multiplication
- Convolution operations
- Tensor operations
- Memory transfer speeds
- Training simulation

### numpy_torture.py
A NumPy stress testing tool for evaluating CPU and Accelerate framework optimizations.
Verifies proper utilization of Apple's Accelerate framework and BLAS optimizations.

#### Usage
```bash
numpy_torture.py [-h] [-s SIZE] [-i ITERATIONS] [-o OUTPUT]
```

#### Parameters
- `-s, --size`: Matrix size for operations (default: 1000)
- `-i, --iterations`: Number of test iterations (default: 10)
- `-o, --output`: Output file for results

#### Tests Performed
- Matrix multiplication
- Matrix transposition
- Eigenvalue computation
- Fourier transformation
- Matrix summation

### numpy-comp
A utility for recompiling NumPy with Apple Silicon optimizations.

#### Usage
```bash
numpy-comp [-h] [-v VERSION]
```

This tool ensures NumPy is built with:
- Apple Accelerate framework integration
- BLAS/LAPACK optimizations
- ILP64 support for large arrays
- Platform-specific compiler optimizations

Example command used internally:
```bash
CFLAGS="-I/System/Library/Frameworks/vecLib.framework/Headers -Wl,-framework -Wl,Accelerate -framework Accelerate" pip install numpy==1.26.* --force-reinstall --no-deps --no-cache --no-binary :all: --no-build-isolation --compile -Csetup-args=-Dblas=accelerate -Csetup-args=-Dlapack=accelerate -Csetup-args=-Duse-ilp64=true
```

### compare_test
An experimental framework for performance comparisons. This tool is provided as a starting point for custom testing but is not officially supported.

#### Usage
```bash
compare_test [-h] [-c CONFIG] [-t TESTS] [-o OUTPUT]
```

#### Parameters
- `-c, --config`: Test configuration file
- `-t, --tests`: Specific tests to run
- `-o, --output`: Output file for results

## Metrics Layout

The performance metrics are reported in a standardized format with tab separated values as shown here:

```
Package  Version  Size  Iterations  Virtual Env  Src  Device  Test  Start Time  End Time  Run Time  Memory
```

### Fields Description
- `Package`: Testing package (NumPy/PyTorch)
- `Version`: Package version
- `Size`: Test matrix size
- `Iterations`: Number of test iterations
- `Virtual Env`: Environment name
- `Src`: Package source
- `Device`: Computing device
- `Test`: Test operation name
- `Start/End Time`: Test timing
- `Run Time`: Operation duration
- `Memory`: Peak memory usage

## Best Practices

### Environment Setup
1. Create a clean virtual environment for testing
2. Install only required packages
3. Document all environment variables
4. Use consistent Python versions

### Test Execution
1. Run tests multiple times
2. Vary matrix sizes
3. Test different devices
4. Compare with baseline results

### Results Analysis
1. Look for performance regressions
2. Compare across different configurations
3. Document anomalies
4. Track trends over time

## Troubleshooting

### Common Issues
1. Memory errors
   - Reduce matrix size
   - Check available system memory
   - Monitor swap usage

2. Device errors
   - Verify device availability
   - Check driver versions
   - Monitor temperature

3. Performance inconsistencies
   - Check system load
   - Monitor thermal throttling
   - Verify no background processes

## Example Workflow

1. Setup test environment:
   ```bash
   benv perftest
   pip install -r requirements.txt
   ```

2. Run baseline tests:
   ```bash
   numpy_torture.py -s 1000 -i 20 -o baseline.csv
   ```

3. Run comparison tests:
   ```bash
   compare_test -c test_config.yml -o results.csv
   ```

4. Analyze results:
   ```bash
   python analyze_results.py baseline.csv results.csv
   ```

## Future Improvements

- Add more test operations
- Support distributed testing
- Enhance reporting formats
- Add visualization tools 