# venvutil - Manage Conda and Pip VENV's with some simple functions and scripts.
(*Still under development*)

## Table of Contents
- [venvutil - Manage Conda and Pip VENV's with some simple functions and scripts.](#venvutil---manage-conda-and-pip-venvs-with-some-simple-functions-and-scripts)
  - [Table of Contents](#table-of-contents)
  - [2024-10-30 - `genmd` Now pre-populates exclusions with .gitignore](#2024-10-30---genmd-now-pre-populates-exclusions-with-gitignore)
  - [2024-10-28 - Updates and stability enhancements to `genmd`](#2024-10-28---updates-and-stability-enhancements-to-genmd)
    - [Refactor option handling and improve configuration loading](#refactor-option-handling-and-improve-configuration-loading)
  - [2024-10-25 - Added  useful markdown wrapper script, well several scripts actually](#2024-10-25---added--useful-markdown-wrapper-script-well-several-scripts-actually)
  - [2024-07-09 - Fixed recursion bug in pip wrapper.](#2024-07-09---fixed-recursion-bug-in-pip-wrapper)
  - [Building all necessary items for oobabooga for macOS on Apple Silicon Series Processors](#building-all-necessary-items-for-oobabooga-for-macos-on-apple-silicon-series-processors)
  - [Tools to help maintain Python VENV's and more](#tools-to-help-maintain-python-venvs-and-more)
  - [To use this/Install, clone the repository locally, then do this:](#to-use-thisinstall-clone-the-repository-locally-then-do-this)
  - [buildvenvs](#buildvenvs)
  - [Misc Items from the old oobabooga-macOS repository](#misc-items-from-the-old-oobabooga-macos-repository)
    - [I've moved these things to here for now.](#ive-moved-these-things-to-here-for-now)

## 2024-10-30 - `genmd` Now pre-populates exclusions with .gitignore

I thoughht it mighht be nice to add twop options to `genmd` to limit the files and directories that are included and excluded. These are the `-C` and `-g` options. The .gitignore is included in the exclusions and inclusions by default. Typically you would want to exclude those files anyway. I plan to move this to a change log at some point, but have additional projects to get loaded.

One project I have almost completed is an extension for Safari to extract all of your CharGPT history into a JSON file.  I'll also have a couple of utilities for parsing it and producing markdown content by date ranges and other criteria. This is so you can get a new GPT instance up ad running as quickly as possible using the context from a prior GPT instance. These are all tools for assisting your workflow when working with ChatGPT. These extracts may be uploaded where a GPT will summarize the conversation and use that for initializing its context.

I do have further plans for this repository, but want to get some other projects moved along further and pushed to make them available as quickly as possibel.

## 2024-10-28 - Updates and stability enhancements to `genmd`

### Refactor option handling and improve configuration loading
- Centralized handling of -c and -o options
- Enhanced display_help function to capture all help comments
- Established configuration loading precedence: defaults, ENV, system .grc, command-line .grc
- Improved array management and duplicate removal
- Enhanced logging and debugging capabilities
- Added comprehensive error handling and exit codes
- Fixed duplicate handling in patterns written to config files.

## 2024-10-25 - Added  useful markdown wrapper script, well several scripts actually

The script will scan a project directory and create a markdown document with only the directory and file patters specified in the config file, using the command line and/or using environment variables. Documentation is in the docs directory.
  - [filetree](docs/filetree.md): generates a file hierarchy tree from the current directory and excludes and includes files and directories based on patterns specified in the command line or in environment variables. Required by `genmd`
  - [genmd](docs/genmd.md): Useful for uploading or pasting on the command line for ChatGPT, groups of related files wrapped in markdown you are working on.  The configuration options may be saved in a config file for later use.
  - [chunktext](docs/chunktext.md): splits a file into chunks of text and then puts the chunks into a markdown file. For breaking your conversations with one GPT into chunks for ingestion by a new instance, keeping context somewhat intact.
  
 I am in the process of getting pip to do a recompile of NumPy but things have been in a state of disarray as I needed to get all my Open Source packages updated, whichI did from source. I now have a working FORTRAN compiler. That and getting loose ends tied up on a bunch of other things like my web site. I wasn't expecting to have to learn Jekyll.
 
 Eventually I will get back to building things again, with a focus on performing text analysis of interpersonal communications using AI to help detect signs of parental alienation. My hope is to be able to stop this before it is too late.

 *I and still open to any sort of remote work, and if you like what you see here, you can always [buy me a coffee](https://www.buymeacoffee.com/unixwzrd), or help fund my work on [Patreon](https://www.patreon.com/unixwzrd). There will be more to come in the next few weeks.*

## 2024-07-09 - Fixed recursion bug in pip wrapper.

All functions seem to be working properly, though there is a lot of cleanup and documentation which needs updating, but they are all pretty handy.  I have the annoyances worked out of the wrapper functions for conda and pip, they work properly run, the intended commands, and the logging, while in place, is not quiet operational.  There are a few issues I'd like to work out such as when cloning an VENV, deleting a VENV and where the changes get logged.

## Building all necessary items for oobabooga for macOS on Apple Silicon Series Processors

The purpose of this originally was to build all the required modules and source code required for oobabooga necessary for best performance possible on macOS on Apple Silicon M-series processors. This is done with a single configuration file. All still under development, but currently in testing.  If you are brave, go right ahead and have a look at the config files in the config directory.

To download, build and install all requirements for running oobabooga on macOS with Apple Silicon, do the following:

(working on this right now)

**Some of the links may be broken as I'm working on the documentation**

## Tools to help maintain Python VENV's and more

I've been working on a number of things, and am attempting to put together a venvdiff function and enhance the pip and conda tracking I have put in the VenvUtil I have built into the set of virtual environment tools I am building here.  IN the bin directory, you will find some Python scripts for checking your GPU and plan to have more on the way.  This will also become my location for LLM, Data Analytics, Artificial Intelligence and clearing house for performance information. There are a number of things I am working on right now, and will be updating the oobabooga-macOS repository soon with the latest oobabooga. I am looking for alternatives to oobabooga and things look promising.  Also, to get best performance out of oobabooga, I am looking into the code and will have updates on the package builds for supporting GGUF models running on macOS soon.

This is an incomplete project to allow for consistent builds of Python VENV's which will allow building/installing Python modules using either Conda or Pip. There are configuration files located in the conf directory, you can edit for building consistent VENV builds and rebuilds.

I am working on documentation, but you can have a look at what's in the [doc directory](docs). More to come.

* [VENV Utility functions used](docs/Functions.md)
  
## To use this/Install, clone the repository locally, then do this:

1. Include the line in your appropriate .bash_profile or .profile file:

    ```bash
    source {repository_path}/bin/shinclude/init_env.sh
    
    # In whatever python environment you are using, you will need to install Rich.
    pip install rich
    ```

    **Be sure to replace `{repository_path}` with the location you cloned the repository in.**

1. Then simply do this:

    ```bash
    exec ${SHELL} -
    ```

This will overlay your shell with a new login shell which, if you did steps above.

Alternately, if you do not want the functions and you simply want to install oobabooga and its dependencies on your machine, you may do the following:

TBD

To list the functions available and get help on them, after sourcing the init_env.sh script into your environment, use the help function, you may need to generate the script and function documentation using the generate_markdown sub-command for vhelp.

    ```bash
    vhelp generate_markdown
    ```

After doing that you will be able to get help on the functions which may be used in scripts or on the command line.

    ```bash
    vhelp

    # or

    vhelp functions
    vhelp scripts

    # To list your VENVs, simply:

    lenv
    ```

## buildvenvs
This is a script which will read out of configuration file in the conf directory the main goal of this is building consistent and repeatable guild and application environments.  It is still  being worked on and I hope to have it ready in a bit, along with a config file for getting the right libraries and packages in the right order, specifically for macOS. I realize there may be other products or systems which do this or similar, but I wanted a flexible tool which would allow me to manage my Python VENV's easily.

All you need to do is run it a and pass a config file name to it and it will do the rest. Configurations can be made for individual applications  or development environments.  Eventually I'd like to have it build several different trees of venv's with different packages in different combinations. The idea is to put together these combinations of installing libraries in different order or re-installing them if the environment gets hosed up.  This would be done to determine compatibility of one package with another, how they were layered, and more.

Ideally, I would like to be able to do regression testing and performance analysis of the various development stacks.

It will do these things right now:
* pip installs
* conda installs
* GitHub repository cloning
* Executing functions included in a configuration script.

Right now there are several things built in which I will be removing and making them their own module or functions. I have a few more things palled like looking at your VENV trees and even comparing the two environments. 

The script buildvenvs will run functions included in the configuration file you wish to run. The config files are in the conf directory. Have a look at them and use one that's there or modify it for your specific needs. I'll be putting together more information on these in the next few days. They may or not work as they are, because things keep moving so rapidly.

## Misc Items from the old oobabooga-macOS repository
---

### I've moved these things to here for now.

Performance and regression test various combinations of venv builds mostly for AI

This is my collection of build scripts, benchmarking tools, and regression testing tools.  This is in a state of flux right now and I am actively working on this.

The first thing likely to emerge is a configuration for building and installing both my macOS version and the oobabooga original text-generation-webui.

Also I will be moving any Apple Silicon M1/M2 GPU performance information to this repo and it will become my location for performance related issues with macOS and Apple Silicon.

For these scripts you will need optimized versions of NumPy and PyTorch, Updates for the builds soon. I'm also putting some things together with Apple's New MLX Framework which looks to have very good performance and am currently looking for possible methods of fine-tuning and training on Apple Silicon M series Macs.

If you find any of my work here helpful, please reach out. I would like to have a dialog with anyone else interested.

Watch this spot, more to come, and you can always buy me a coffee.

```text
This project is licensed under the Apache License
                           Version 2.0, License.

 Copyright 2024 Michael P. Sullivan - unixwzrd@unixwzrd.ai

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```
[Apache License Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

