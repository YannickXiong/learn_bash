#!/usr/bin/env bash

declare __DEBUG__="on"
declare -r g_VALID_LOG_LEVEL=("ERROR" "INFO" "WARN")

# define the return code, readonly variable
declare -r g_PARAMETER_ERROR=11
declare -r g_INVALID_LOG_LEVEL_TYPE=12
declare -r g_OK=0

function getDate()
{
    local myTime=`date +"%Y-%m-%d %H:%M:%S"`
    echo ${myTime}
}

function logWriter()
{
    if [[ $# -lt 2 ]] ; then
        echo "`getDate` ERR called function logWriter() with PARAMETER_ERROR(rt = 11)"
        echo "`getDate` INF usage: logWriter logLevel <error, info, warn> msg"
        echo "`getDate` INF example: logWriter info The client works normally, all the nodes work normally."
        exit ${g_PARAMETER_ERROR}
    fi

    # convert to capital
    local _log_level=`echo $1|tr [a-z] [A-Z]`
    local _valid_flag=false

    for _loglevel_ in ${g_VALID_LOG_LEVEL[@]}
    do
        [[ ${_loglevel_} = ${_log_level} ]] && _valid_flag=true ||:
    done

    if [[ ${_valid_flag} = "false" ]]; then
        echo "`getDate` ERR called function logWriter() with INVALID_LOG_LEVEL_TYPE(rt = 12)"
        echo "`getDate` INF the valid log level is < WARN INFO ERROR >. "
        exit ${g_INVALID_LOG_LEVEL_TYPE}
    fi

    # get sub-str(1,3)
    _log_level=`echo ${_log_level} |cut -c 1-3`

    # echo INFO 'Install()' called end ...|tr -d [INFO] =>  nstall() called end ...
    # will remove I N F O from the source
    local _message=`echo $* |cut -d " " -f2-`
    # local _message=`echo $* |tr -d [$1]`

    [[ ${__DEBUG__} = "on" ]] && echo `getDate` ${_log_level} ${_message} ||:

    return ${g_OK}
}

