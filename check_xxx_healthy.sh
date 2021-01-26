#! /bin/bash

####################################################################
## crontab -e
## 每一分钟执行1次
## */1 * * * * sh /root/ServerAgent-2.2.3/check_healthy.sh
####################################################################

function getTimeStamp()
{
    local myTime
    myTime=$(date +"%Y-%m-%d %H:%M:%S.%N"|cut -b 1-23)
    echo "${myTime}"
}

PROG_NAME="PerfMonAgent"
PID=$(ps -ef |grep ${PROG_NAME}|grep -v grep|awk '{print $2}')
TRY_TIMES=3
START_CMD="cd /root/ServerAgent-2.2.3/; nohup sh startAgent.sh &"
INTERVAL=2

WORKING_HOME=$(dirname "$0")

function log()
{
    echo "$@" >> "${WORKING_HOME}"/check_healthy.log
}

if [ "x""${PID}" = "x" ];then
    log "$(getTimeStamp) ${PROG_NAME} is not running, now start it .."
    i=0
    while [ ${i} -lt ${TRY_TIMES} ]
    do
        ((i++))
        log "$(getTimeStamp) ${i}-time try to exec: ${START_CMD} .."
        eval "$START_CMD"
        PID=$(ps -ef |grep ${PROG_NAME}|grep -v grep|awk '{print $2}')
        if [ "x""${PID}" = "x" ];then
            log "$(getTimeStamp) ${i}-time try to start ${PROG_NAME} failed."
        else
            log "$(getTimeStamp) ${i}-time try to start ${PROG_NAME} successfully."
            break
        fi
        sleep ${INTERVAL}
    done
else
    log "$(getTimeStamp) ${PROG_NAME} is already running with pid = ${PID}, nothing to do."
fi