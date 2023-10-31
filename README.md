# venvutil

## Tools to help maintain Python VENV's and more

This is an incomplete project to allow for consistent builds of Python VENV's which will allow building/installing Python modules using either Conda or Pip. There are configuration files located in the conf directory, you can edit for building consistent VENV builds and rebuilds.

I am working on documentation, but you can have a look at what's in the [doc directory](doc). More to come.

* [VENV Utility functions used](doc/Functions.md)
  
To use this clone the repository locally, then do this:

1. Put the {repository_dir}/bin in your path
2. Include the line:
    ```bash
    source {repository_path}/bin/shinclude/init_env.sh
    ```

Be sure to replace {repository_path} with the location you cloned the repository in.

To list the functions available and get help on them, after sourcing the init_env.sh script into your environment, use the help function:
```bash
help

# or

help functions
```

## Misc Items from the old oobabooga-macOS repository
---

### I've moved these things to here for now.

Performance and regression test various combinations of venv builds mostly for AI

This is my collection of build scripts, benchmarking tools, and regression testing tools.  This is in a state of flux right now and I am actively working on this.

The first thing likely to emerge is a configuration for building and installing both my macOS version and the oobabooga original text-generation-webui.

Also I will be moving any Apple Silicon M1/M2 GPU performance information to this repo and it will become my location for performance related issues with macOS and Apple Silicon.

Watch this spot, more to come.
