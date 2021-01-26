#! /bin/bash

####################################################################
## crontab -e
## 每天晚上20,21,22,23晚上开始执行
## 0 20,21,22,23 * * * sh /root/test-data-and-scripts/tpcds-6.X/bin/check_tpcds.sh::
####################################################################

function getTimeStamp()
{
    local myTime
    myTime=$(date +"%Y-%m-%d %H:%M:%S.%N"|cut -b 1-23)
    echo "${myTime}"
}

PROG_NAME="tpcds-test-5t.pl"
PID=$(ps -ef |grep ${PROG_NAME}|grep -v grep|awk '{print $2}')
TRY_TIMES=3
START_CMD="cd /root/test-data-and-scripts/tpcds-6.X/bin/; nohup ./tpcds-test-5t.pl -i conf/config_orc_5t -v hive2 -r qa134 &"
INTERVAL=2

WORKING_HOME=$(dirname "$0")

function log()
{
    echo "$@" >> "${WORKING_HOME}"/check_tpcds.log
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