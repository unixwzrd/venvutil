#!/bin/bash

# Utility functions

# Utility function to strip whitespace
__strip_space(){
    echo $*
}


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
