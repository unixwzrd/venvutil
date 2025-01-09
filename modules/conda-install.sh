#!/usr/bin/env bash


# Conda install
__CONDA() {
    cd ${__BUILD_DIR}
    mkdir tmp
    cd tmp
    curl  https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o miniconda.sh
    # Do a non-destructive Conda install whcih will preserve existing VENV's
    sh miniconda.sh -b -u
    . ${HOME}/miniconda3/bin/activate
    conda init $(basename ${SHELL})
    conda update -n base -c defaults conda -y
    # Replace the shell name below with your preferred shell. The -l switch gives you a login shell
    # and, contrary to what you may heard, you don't have to log out or exit the terminal. Simply
    # exec the shell and it will reload your environment variables with the additional Conda ones
    # set. This also works in Linux and most other Unix-like POSIX operating systems.
    export _CONDA_ROOT
    cd ${__BUILD_BASE}
    # Since the code is re-entrant, we want to make sure we don't re-enter this function.
    # this function will never return so it will never get back to the case statement and
    # write the step number out. I've put that part in the script, but it will never reach that
    # part.  If we don't this will spawn more bash shells, ythan you want to imagine. I'm considering
    # setting ulimit to something like 500
    echo "1" > ${__STEP_FILE}
    echo "${MY_NAME}: Re-running in new Conda environment"
    # [ ${DEBUG} == 1 ] && exec bash -l -x -c "${THIS_SCRIPT}; exec bash -l"
    exec bash -l -c "${THIS_SCRIPT} ${MY_ARGS}; exec bash -l"
}