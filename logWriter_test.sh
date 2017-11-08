#!/usr/bin/env bash

# *********************************************************** #
# @File         : logger4shell_test.sh                        #
# @Version      : 1.0.0                                       #
# @Author       : Yannick                                     #
# @Time         : 2017/8/13 12:37                             #
# @Description  : to test if the module logger4shell.sh works #
#                 normally or not.                            #
# @Note         :                                             #
# *********************************************************** #

. logWriter.sh

# __DEBUG__ in source file logger4shell.sh will be over written.
__DEBUG__=on


for ((i=0;i<10;i++))
do
    case $((i+1)) in
        0)
        logWriter info "This is the $((i+1)) time to call LoggerWrite."
        ;;
        1)
        logWriter warn "This is the $((i+1)) time to call LoggerWrite."
        ;;
        2)
        logWriter error "This is the $((i+1)) time to call LoggerWrite."
        ;;
        3)
        logWriter INFO "This is the $((i+1)) time to call LoggerWrite."
        ;;
        4)
        logWriter WARN "This is the $((i+1)) time to call LoggerWrite."
        ;;
        5)
        logWriter RROR "This is the $((i+1)) time to call LoggerWrite."
        ;;
        6)
        logWriter INFO
        ;;
        7)
        logWriter
        ;;
        8)
        logWriter INFO "This is the $((i+1))" "time to call LoggerWrite." " --end"
        ;;
        *)
        logWriter INFO "This is the $((i+1)) time to call LoggerWrite."
        ;;
      esac

      sleep 1
done
