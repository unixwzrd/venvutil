#!/bin/bash


# Utility functions
__zero_pad(){
    __NUM=$1
    case ${__NUM} in
       [0-9]?)
          ;;
       *)
          __NUM="0${__NUM}"
          ;;
    esac
    echo ${__NUM}
}


__next_step(){
    __SN="$1"
    case "${__SN}" in
       ""|[[:space:]]* )
          __SN=0
          ;;
       [0-9]|[0-9][0-9] )
        __SN=$( expr ${__SN} + 1 )
          ;;
       *)
          echo "Exception, sequence must be a value between 00 and 99."
          return 22 # EINVAL: Invalid Argument
          ;;
    esac
    echo `__zero_pad ${__SN}`
}


# VENV Management functions
snum(){
    #
    # Function to force set the VENV Sequence number
    #
    # USAGE: senv NN
    #
    #   NN = VENV Sequenve to set
    #
    __VENV_NUM=$( __zero_pad $1 )
}


vnum(){
    #
    # Rethurs the current VENV sequence number
    #
    echo ${__VENV_NUM}
}

cact(){
    #
    # Change active VENV
    #
    # Deactivate the currecnt VENV and Activate the one passed
    #
    # cact VENV_NAME
    #
    echo "The venv passed was $1"
    echo "All parameters passed were: $*"
    __VENV_NAME=$1
    __VENV_PREV=${CONDA_DEFAULT_ENV}
    __VENV_PREFIX=$(echo "$*" | cut -d '.' -f 1)
    __VENV_DESC=$(echo "$*" | cut -d '.' -f 3-) &&  __VENV_NUM=$(echo "$*" | cut -d '.' -f 2)
    __VENV_PARMS=$(echo "$*" | cut -d '.' -f 4-)
    echo "CALLING DEACTIVATE FOR ${CONDA_DEFAULT_ENV}"
    dact
    echo "ACTIVATING: ${__VENV_NAME}"
    conda activate  ${__VENV_NAME}
}


dact(){
    #
    # Deactivate the currecnt VENV and Activate the one passed
    #
    # dact
    #
    echo "DEACTIVATING: ${CONDA_DEFAULT_ENV}"
    conda deactivate
}

pact(){
    #
    # Deactivate the currecnt VENV and Activate the one passed
    #
    # dact
    #
    cact ${__VENV_PREV}
}


lenv(){
    #
    # list all current VENV
    #
    # USAGE: lenv
    #
    conda info -e | egrep -v '^#'
}


lastenv(){
    __VENV_PREFIX=$1
    __VENV_LAST=$( lenv | egrep "^${__VENV_PREFIX}." | tail -1 | cut -d " " -f 1 )
    echo ${__VENV_LAST}
}

benv(){
    __VENV_NAME=$1; shift
    __VENV_EXTRA=$*
    echo "CREATING BASE VENV ${__VENV_NAME} ${__VENV_EXTRA}"
    conda create -n ${__VENV_NAME} ${__VENV_EXTRA} -y
    echo "BASE VENV CREATED - ACTIVATING ${__VENV_NAME}"
    cact ${__VENV_NAME}
}


nenv(){
    #
    # New VENV
    #
    # USAGE: nenv PFX
    #
    #    Where PFV is a prefix for the whole VENV series for a test line.
    #
    __VENV_PREFIX=$1
    shift
    __VENV_PARMS=$*
    [ -z "${__VENV_PREFIX}" ] && return
    __VENV_NUM=""
    ccln base
}

denv(){
    #
    # Delete the current active VENV
    #
    __VENV_DEL=$1
    echo "REMOVING VENV -> ${__VENV_DEL}"
    conda remove --all -n ${__VENV_DEL} -y
}

renv(){
    #
    # Remove the a specified VENV
    #
    # USAGE: renv PFX.NN.DESCRIPTION
    #
    #    Where PFV is a prefix for the whole 
    __VENV_DEL=${CONDA_DEFAULT_ENV};
    dact
    denv ${__VENV_DEL}
}

ccln(){
    __VENV_DESC=$1
    __VENV_PARMS=$*
    __VENV_NUM=`__next_step ${__VENV_NUM}`
    __VENV_NAME="${__VENV_PREFIX}.${__VENV_NUM}.${__VENV_DESC}"
    conda create --clone ${CONDA_DEFAULT_ENV} -n ${__VENV_NAME} -y
    dact
    cact "${__VENV_NAME}"
}

