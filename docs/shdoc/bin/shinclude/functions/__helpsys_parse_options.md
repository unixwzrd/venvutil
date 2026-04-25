## __helpsys_parse_options
# Function: __helpsys_parse_options
 `__helpsys_parse_options` - Parse common help/debug options.
## Description
- **Purpose**:
  - Handles common function options consistently across sourced shell libraries.
  - Supports `-h`, `--help`, and `-x`, while allowing callers to process additional
    options through an optional callback.
- **Usage**:
  - `__helpsys_parse_options <optstring> [option_handler] "$@"`
- **Scope**:
  - Internal
- **Input Parameters**:
  - `optstring`: The `getopts` option string for the caller.
  - `option_handler`: Optional callback for caller-specific options.
  - `"$@"`: The caller's original argument list.
- **Output**:
  - Sets `__helpsys_optind` to the parsed `OPTIND` value.
  - Sets `__helpsys_help_requested=true` when help was displayed.
  - Sets caller-scoped `set_here=y` when `-x` is used.
- **Exceptions**:
  - Returns non-zero for invalid options or option-handler failures.

## Defined in Script

* [helpsys_lib.sh](../helpsys_lib_sh.md)
Website: [unixwzrd.ai](https://unixwzrd.ai)
Github Repo: [venvutil](https://github.com/unixwzrd/venvutil)
Copyright (c) 2025 Michael Sullivan
Apache License, Version 2.0

---

Generated Markdown Documentation
Generated on: 2026-04-25 at 12:54:16
