# venvutil - Still under development

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

Watch this spot, more to come.
