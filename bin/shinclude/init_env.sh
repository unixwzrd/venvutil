#!/bin/bash

[ -L "$0" ] && THIS_SCRIPT=$(readlink -f "$0") || THIS_SCRIPT="$0"
MY_NAME=$(basename ${THIS_SCRIPT})
MY_BIN=$(dirname ${THIS_SCRIPT})
MY_ARGS=$*
MY_INCLUDE="${MY_BIN}/shinclude"

# Initialize from what is put in .bash_profile during initialize.
# >>> conda >>> Lifted 
__conda_setup="$('${HOME}/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "${HOME}/miniconda3/etc/profile.d/conda.sh" ]; then
        . "${HOME}/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="${HOME}/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

[ -f ${MY_INCLUDE}/util_funcs.sh ] && . ${MY_INCLUDE}/util_funcs.sh \
    || ( echo "Could not find venv_funcs.sh in INCLUDEDIR: ${MY_INCLUDE}" && exit 1 )

[ -f ${MY_INCLUDE}/venv_funcs.sh ] && . ${MY_INCLUDE}/venv_funcs.sh \
    || ( echo "Could not find venv_funcs.sh in INCLUDEDIR: ${MY_INCLUDE}" && exit 1 )

