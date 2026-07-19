# venvutil

This is release **v1.0.9**. Venvutil is a practical toolkit of shell functions and scripts for managing Conda/Pip virtual environments, documenting projects, and supporting LLM/Python workflows on macOS and Linux.

If you juggle multiple Python environments, freeze files, and “why does this env not match that one?” moments, venvutil is the glue that keeps your workflow sane.

- [Features](#features)
  - [Upgrade Python in your active environment](#upgrade-python-in-your-active-environment)
  - [What's New in 1.0.9](#whats-new-in-109)
  - [Shell Functions](#shell-functions)
  - [Python Scripts](#python-scripts)
  - [Conda and Pip Logging](#conda-and-pip-logging)
  - [Documentation Generation](#documentation-generation)
  - [LLM and Chat Tools](#llm-and-chat-tools)
  - [Compile Wrappers](#compile-wrappers)
- [Installation](#installation)
- [Configuration](#configuration)
- [Support](#support)

## Features

### Upgrade Python in your active environment

**`vpmg`** is the headline feature: migrate the *currently active* conda environment to a new Python version without rebuilding everything by hand.

It captures your installed packages, renames the old env to a backup, recreates the same env name with the Python version you want, reinstalls from the freeze manifest, and rolls back if anything fails. Use `-p` to keep the backup when you want a safety net.

```bash
(my-project) $ python --version
Python 3.10.16

(my-project) $ vpmg -v 3.12
# freezes packages, renames my-project → my-project_bak,
# recreates my-project with python=3.12, pip install ...

(my-project) $ python --version
Python 3.12.8
```

See [`vpmg` documentation](docs/shdoc/bin/shinclude/functions/vpmg.md) for full options.

### What's New in 1.0.9

- **`vpmg`** — upgrade Python in-place on the active conda env; reinstall from freeze; optional `-p` to preserve the backup.
- **`vdiff`** — normalized side-by-side package comparison; one arg compares against the active env, two args compare named envs.
- **`filetree`** — optional positional root directory (`filetree bin/shinclude`) while keeping GenMD compatibility.
- **Shared help parsing** — consistent `-h` / `--help` / `-x` across venv shell functions via `__helpsys_parse_options`.
- **README refresh** — restored concrete examples (`lenv`, `errno`, `vpmg`) so you can see what you get before you install.

### Shell Functions

These are a few of the shell functions that show why venvutil exists. Source `venvutil_lib.sh` from your `.bashrc` (the installer adds this for you). Full reference: [venvutil Tools](docs/shdoc/README.md).

| Function | What it does |
|----------|----------------|
| **`vhelp`** | Integrated help for scripts and functions |
| **`lenv`** | List all Pip and Conda environments with Python version and last-updated date |
| **`cact` / `dact` / `pact`** | Activate conda, deactivate, or activate a pip venv |
| **`benv` / `nenv` / `denv` / `renv`** | Build, clone, delete, or rename environments |
| **`vpmg`** | **Upgrade Python in the active env** and reinstall packages |
| **`vdiff`** | Compare package sets between environments |
| **`vren`** | Rename the active environment |
| **`ccln`** | Clean conda caches and orphaned package data |
| **`ptree`** | Directory tree with markers for dirs containing certain files |
| **`errfind` / `errno`** | Look up POSIX error names, numbers, and messages |

#### `lenv` — see every environment at a glance

```bash
(base) [unixwzrd@xanax: ~]$ lenv
Date        Python   Environment                   Path
2025-01-27  3.11.11  adv-numpy-daily-pytorch      ~/miniconda3/envs/adv-numpy-daily-pytorch
2025-01-13  3.12.8   base                       * ~/miniconda3
2025-01-25  3.11.11  comp-numpy-daily-pytorch     ~/miniconda3/envs/comp-numpy-daily-pytorch
2025-01-25  3.11.11  comp-numpy-std-pytorch       ~/miniconda3/envs/comp-numpy-std-pytorch
2025-01-02  3.10.16  python-3.10-PA-dev           ~/miniconda3/envs/python-3.10-PA-dev
2024-12-30  3.10.16  python-3.10-dev              ~/miniconda3/envs/python-3.10-dev
```

[Detailed documentation](docs/shdoc/bin/shinclude/functions/lenv.md)

#### `errfind` and `errno` — stop guessing return codes

```bash
(base) [unixwzrd@xanax: ~]$ errfind invalid
(EINVAL: 22): Invalid argument
(base) [unixwzrd@xanax: ~]$ errfind file
(ENOENT: 2): No such file or directory
(EBADF: 9): Bad file descriptor

(base) [unixwzrd@xanax: ~]$ sudo
usage: sudo -h | -K | -k | -V
...
(base) [unixwzrd@xanax: ~]$ errno $?
(EPERM: 1): Operation not permitted
```

[Detailed documentation](docs/shdoc/bin/shinclude/errno_sh.md)

#### `vdiff` — know exactly how two envs differ

```bash
# Compare active env vs another
(my-env) $ vdiff other-env

# Or compare two named envs
$ vdiff env-a env-b
```

There are many more functions — see the [shell function index](docs/shdoc/README.md).

### Python Scripts

| Script | Purpose |
|--------|---------|
| **`filetree`** | Walk directories with include/exclude patterns; used by GenMD |
| **`genmd`** | Generate Markdown documentation from project sources |
| **`numpy-comp`** | Rebuild NumPy against local BLAS/LAPACK on macOS |
| **`extract-chat`** | Convert chat JSON exports to HTML or Markdown |

### Conda and Pip Logging

Destructive operations on virtual environments are logged with the exact command used. A `pip freeze` runs before and after so you can audit what changed. Logs are kept globally under venvutil config and per-environment where applicable.

### Documentation Generation

**GenMD** walks your tree (via `filetree`), applies include/exclude rules, and emits structured Markdown — useful for keeping project docs and LLM context packs current.

### LLM and Chat Tools

Utilities for extracting, converting, and organizing chat transcripts and related assets for documentation and analysis workflows.

### Compile Wrappers

C/C++ compile wrappers (`g++-wrap`, `ld-wrap`, etc.) work around macOS toolchain quirks (for example, incorrect `--version` passed to the linker). See [compile wrappers documentation](docs/compile_wrappers.md).

## Installation

```bash
git clone https://github.com/unixwzrd/venvutil.git
cd venvutil
./setup.sh
```

The installer configures paths, sources `venvutil_lib.sh` into your shell startup, and records package metadata from `setup/setup.cf` (currently **Version 1.0.9**).

Requirements: Python ≥ 3.10, Bash > 4.0, Conda ≥ 22.11. Primary target is macOS; many tools work on Linux.

## Configuration

- **`VENVUTIL_HOME`** — install root (default `~/local/venvutil`)
- **`VENVUTIL_CONFIG`** — config and logs (default `~/.config/venvutil`)
- Freeze files for logging and **`vpmg`** reinstall live under `VENVUTIL_CONFIG/freeze/`

See [docs/](docs/) for per-tool configuration.

## Support

Actively maintained. Current release: **1.0.9**. See [CHANGELOG.md](CHANGELOG.md) for dated entries.

- Issues: https://github.com/unixwzrd/venvutil/issues
- Docs: [docs/](docs/) and [shell function reference](docs/shdoc/README.md)
