#!/usr/bin/env bash

declare __DEBUG__="on"
declare -r g_VALID_LOG_LEVEL=("ERROR" "INFO" "WARN" "OK")

# define the return code, readonly variable
declare -r g_PARAMETER_ERROR=11
declare -r g_INVALID_LOG_LEVEL_TYPE=12
declare -r g_OK=0

function getTimeStamp()
{
    local myTime
    myTime=$(date +"%Y-%m-%d %H:%M:%S.%N"|cut -b 1-23)
    echo "${myTime}"
}

function _info()
{
    echo -e "\033[37m$(getTimeStamp) INFO $* \033[0m"
}

function _error()
{
    echo -e "\033[31m$(getTimeStamp) ERROR $* \033[0m"
}

function _warning()
{
    echo -e "\033[33m$(getTimeStamp) WARNING $* \033[0m"
}

function _success()
{
    echo -e "\033[34m$(getTimeStamp) INFO $* \033[0m"
}

function logConsole()
{
    if [[ $# -lt 2 ]] ; then
        _error "Called function logConsole() with PARAMETER_ERROR(ReturnCode = 11)"
        _info "Usage: logConsole logLevel <error, info, warn> msg"
        _info "Example: logConsole info The client works normally, all the nodes work normally."
        
        exit ${g_PARAMETER_ERROR}
    fi

    # convert to capital
    local _log_level
    _log_level=$(echo "$1"|tr "[:lower:]" "[:upper:]")
    local _valid_flag=false

    for _loglevel_ in "${g_VALID_LOG_LEVEL[@]}"
    do
        [[ ${_loglevel_} = "${_log_level}" ]] && _valid_flag=true ||:
    done

    if [[ ${_valid_flag} = "false" ]]; then
        _error "Called function logConsole() with INVALID_LOG_LEVEL_TYPE(ReturnCode = 12)"
        _info "The valid log level is < WARN INFO ERROR >. "
        _info "Example: logConsole info The client works normally, all the nodes work normally."

        exit ${g_INVALID_LOG_LEVEL_TYPE}
    fi

    # get sub-str(1,3)
    # _log_level=`echo ${_log_level} |cut -c 1-3`

    # echo INFO 'Install()' called end ...|tr -d [INFO] =>  nstall() called end ...
    # will remove I N F O from the source
    local _message
    _message=$(echo "$@" |cut -d " " -f2-)
    
    # case $_log_level in
    #   ERROR)
    #     [[ ${__DEBUG__} = "on" ]] && error "${_message}" ||:
    #     ;;
    #   WARN)
    #     [[ ${__DEBUG__} = "on" ]] && warning "${_message}" ||:
    #     ;;
    #   INFO)
    #     [[ ${__DEBUG__} = "on" ]] && info "${_message}" ||:
    #     ;;
    # esac

    if [[ ${__DEBUG__} = "on" ]];then
        case $_log_level in
        ERROR)
            _error "${_message}"
            ;;
        WARN)
            _warning "${_message}"
            ;;
        OK)
            _success "${_message}"
            ;;
        INFO)
            _info "${_message}" 
            ;;
        esac
    fi

    return ${g_OK}
}

function logFile(){
    if [[ $# -lt 2 ]] ; then
        _error "Called function logFile() with PARAMETER_ERROR(ReturnCode = 11)"
        _info "Usage: logFile logFile msg"
        _info "Example: logFile /var/run.log The client works normally, all the nodes work normally."
        _exit ${g_PARAMETER_ERROR}
    fi

    local _log_file=$1
    local _message
    _message=$(echo "$*" |cut -d " " -f2-)

    [[ ${__DEBUG__} = "on" ]] && _info "$_message" | tee -a "$_log_file" 1>/dev/null 2>&1 ||:
    
    return ${g_OK}
}

function logConsoleFile(){
    if [[ $# -lt 3 ]] ; then
        _error "Called function logConsoleFile() with PARAMETER_ERROR(ReturnCode = 11)"
        _info "Usage: logLevel <error, info, warn> logFile msg"
        _info "Example: logConsoleFile INFO /var/run.log The client works normally, all the nodes work normally."
        
        exit ${g_PARAMETER_ERROR}
    fi

    local _log_level=$1
    local _log_file=$2
    local _message
    _message=$(echo "$*" |cut -d " " -f3-)

    # Timestamp for one message on console is not different to that in the log file
    # because here are twice called.
    # [[ ${__DEBUG__} = "on" ]] && logConsole "$_log_level" "$_message"
    # [[ ${__DEBUG__} = "on" ]] && logFile "$_log_file" "$_message"

    [[ ${__DEBUG__} = "on" ]] && logConsole "$_log_level" "$_message" | tee -a "$_log_file" ||:
    
    return ${g_OK}
}
