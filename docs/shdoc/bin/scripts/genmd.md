Name:
      genmd - Combined source code markdown generator.
Usage:
      genmd [options]
Options:
      -d, --debug [level]       Set debug level (0-9)
                                0: No debug output
                                1: Show informational messages
                                2: Show debug messages
                                3: Show regex commands and patterns
                                9: Show xtrace messages
      -h, --help                Show this help message
      -e, --exclude [patterns]  Exclude directories matching the given patterns.
                                Multiple patterns can be separated by '|'.
      -f, --file [patterns]     Exclude files matching the given patterns.
                                Multiple patterns can be separated by '|' or spaces.
      -p, --pattern [patterns]  Exclude additional patterns matching the given strings.
                                Multiple patterns can be separated by '|' or spaces.
      -i, --include [patterns]  Include files matching the given patterns.
                                Multiple patterns can be separated by '|' or spaces.
      -o, --output [filename]   Output file (default: combined_source.md)
      -c, --config [filename]   Load configuration from a .grc or .cfg file.
                                If the filename does not end with .grc or .cfg, .grc will be appended.
      -s, --settings [modes]    Show settings. Modes can be:
                                info: Show current settings
                                cfg: Write to configuration file
                                md: Include settings in markdown output
                                env: Output settings as environment variables
                                all: Perform info, md, and env actions
      -n, --dry-run             Do not write the output file; print the files to be processed.
      -v, --verbose             Show verbose output
Description:
      The genmd script generates markdown from the files in the specified directory,
      excluding files and directories based on provided patterns. It outputs:
      - Project filesystem directory structure
      - Source code in a single markdown file for all included files.
      - Excluded files are omitted based on exclusion patterns.
Examples:
      genmd -e "node_modules|dist" -f "*.log *.tmp"  -i "*css *.js" -s "info,md" -o project_overview.md
      genmd --exclude "node_modules|dist" --file "*.log *.tmp" --include "info" --dry-run
      genmd -s info,md -d 2
Environment:
      GENMD_BASE: The base directory to search for files in.
      GENMD_DIR_EXCLUDES: A default list of directory patterns to exclude from the generated markdown.
      GENMD_FILE_EXCLUDES: A default list of file patterns to exclude from the generated markdown.
      GENMD_PATTERN_EXCLUDES: A default list of additional patterns to exclude from the generated markdown.
      GENMD_FILE_INCLUDES: A default list of file patterns to include in the generated markdown.
      PAGER: The pager to use for output, defaults to `less -R`
Author:
      Michael Sullivan <unixwzrd@unixwzrd.ai>
          https://unixwzrd.ai/
          https://github.com/unixwzrd
License:
      Apache License, Version 2.0

