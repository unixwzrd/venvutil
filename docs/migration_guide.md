# Migration Guide - Version 20250206-00_R1

This guide helps you migrate your scripts and configurations to the new library structure introduced in version 20250206-00_R1

## Major Changes

### Library Reorganization
All shell library files have been renamed from `.sh` to `_lib.sh` for better organization and clarity:

| Old Name | New Name |
|----------|----------|
| errno.sh | errno_lib.sh |
| help_sys.sh | helpsys_lib.sh |
| init_env.sh | init_lib.sh |
| util_funcs.sh | util_lib.sh |
| venv_funcs.sh | venv_lib.sh |
| wrapper_funcs.sh | wrapper_lib.sh |

New libraries added:
- `config_lib.sh`: Configuration management
- `type_lib.sh`: Type checking and validation
- `string_lib.sh`: String manipulation

### Updating Your Scripts

1. Update source statements:
   ```bash
   # Old way
   source "${INCLUDE_DIR}/errno.sh"
   
   # New way
   source "${INCLUDE_DIR}/errno_lib.sh"
   ```

2. Use the new source_lib function:
   ```bash
   # Recommended way
   source_lib errno_lib
   ```

### Function Changes

#### Environment Management
- `lenv` now supports headers and Python version display
- `ccln` supports sequence-less cloning
- New `renv` function for environment renaming

Example usage:
```bash
# List all environments with Python versions
lenv

# Clone without sequence number
ccln myenv newenv

# Rename environment
renv oldname newname
```

### Configuration Changes

1. Update your configuration files:
   ```bash
   # Old format
   VENV_INCLUDE="${VENV_BASE}/bin/shinclude"
   
   # New format
   VENV_LIB="${VENV_BASE}/bin/shinclude"
   ```

## New Features

### Type Checking
```bash
# Use new type checking functions
var_type "my_var" 
```

### String Manipulation
```bash
# New string utilities
clean_string "input string"
format_path "/path/to/file"
sanitize_input "user input"
```

## Breaking Changes

1. Direct `.sh` extension references will fail
2. Old environment variable names are deprecated
3. Some function signatures have changed

### Deprecated Features
- Direct shell script sourcing
- Old environment variable names
- Legacy configuration formats

## Troubleshooting

### Common Issues

1. Script sourcing fails:
   ```bash
   # Error
   source: errno.sh: No such file or directory
   
   # Fix
   source_lib errno_lib
   ```

2. Function not found:
   ```bash
   # Error
   function_name: command not found
   
   # Fix
   source_lib util_lib  # Ensure correct library is sourced
   ```

3. Configuration errors:
   ```bash
   # Error
   VENV_INCLUDE: variable not found
   
   # Fix
   Update to VENV_LIB in configuration
   ```

## Best Practices

1. Use `source_lib` instead of direct sourcing
2. Update all script headers
3. Use new type checking functions
4. Implement error handling
5. Update configuration files

## Testing Your Migration

1. Create a test environment:
   ```bash
   benv test-migration
   ```

2. Test your scripts:
   ```bash
   # Run with debug mode
   DEBUG=1 your_script.sh
   ```

3. Verify functionality:
   ```bash
   # Check environment management
   lenv
   ccln test-env
   vren old-name new-name
   ```

## Getting Help

- Use `vhelp` for function documentation
- Check error messages with `errfind`
- Review logs in `~/.venvutil/logs`
- Submit issues on GitHub

## Future Compatibility

- Keep scripts updated with `source_lib`
- Use new function signatures
- Follow type checking guidelines
- Maintain configuration standards

### Library Dependencies and Initialization

The new library structure introduces two main initialization libraries:

- `init_lib.sh`: Core initialization and environment setup
- `venvutil_lib.sh`: Main virtual environment utilities that sources all required dependencies

Using these libraries simplifies dependency management:

```bash
# Old way - manually sourcing each dependency
source "${INCLUDE_DIR}/init_env.sh"

# New way - automatic dependency management
source_lib init_lib      # Core initialization
 
 # or this both will have the same effect.

source_lib venvutil_lib  # Sources all venv-related dependencies
```

Dependencies are now handled automatically:
- `init_lib.sh` provides core initialization
- `venvutil_lib.sh` sources:
  - Type checking functions
  - Error handling
  - String manipulation
  - Configuration management
  - Virtual environment functions
  - Wrapper utilities

This ensures consistent initialization and reduces dependency-related errors.
``` 