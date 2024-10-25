
## Scripts

### genmd - Combined Source Code Markdown Generator

#### Description
Generates a markdown file that includes the project's filesystem structure and selected source files based on inclusion and exclusion patterns.

#### Configuration
Set the following environment variables by sourcing the configuration script:

```bash
source "$BASE_DIR/utils/etc/genmd_config.sh"
```

#### Usage

- **Save Current Configuration:**

  ```bash
  ./genmd -c save my_config.gmd -d 2
  ```

- **Load Configuration:**

  ```bash
  ./genmd -c load my_config.gmd -d 2
  ```

- **Run with Current Settings:**

  ```bash
  ./genmd -d 2
  ```

#### Options

- `-d, --debug [level]`: Set debug level (0-9)
- `-h, --help`: Show help message
- `-e, --exclude ["patterns"]`: Exclude directories
- `-f, --file ["patterns"]`: Exclude files
- `-i, --include ["patterns"]`: Include files
- `-p, --pattern ["patterns"]`: Exclude additional patterns
- `-o, --output [file]`: Specify output markdown file
- `-c, --config [save|load] [filename]`: Save or load configuration
- `-s, --settings [modes]`: Display current settings
- `-n, --dry-run`: Do not write the output file
- `-v, --verbose`: Enable verbose output

### filetree.py - Directory Structure Generator

#### Description
Generates a tree structure of the current directory excluding specified directories.

#### Usage

```bash
./filetree.py
```

#### Options

- `--exclude ["directories"]`: List of directories to exclude
```

### **c. Utilize Shared Configuration**

Ensure that both scripts source the same `genmd_config.sh` to maintain consistency.

**Example Integration in `venvutil`:**

- **Setup Script:**  
  Create a setup script to initialize the environment.

  ```bash
  # File: venvutil/setup.sh

  #!/usr/bin/env bash

  # Source the genmd configuration
  source "$BASE_DIR/utils/etc/genmd_config.sh"
  ```

- **Usage:**

  ```bash
  source "$BASE_DIR/venvutil/setup.sh"
  ./venvutil/scripts/genmd -d 2
  ```
