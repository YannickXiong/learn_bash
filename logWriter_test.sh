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

. ./logWriter.sh

log_file="/var/log/logWriter_test.log"

# logConsole
logConsole INFO "This is a info message output to console."
logConsole WARN "This is a warning message output to console."
logConsole ERROR "This is a error message output to console."
logConsole OK "This is a successfull message output to console."

# logFile
logFile "$log_file" "This is a info message output to file."
logFile "$log_file" "This is a warning message output to file."
logFile "$log_file" "This is a error message output to file."

# logConsoleFile
logConsoleFile INFO "$log_file" "This is a info message output to console & file."
logConsoleFile WARN "$log_file" "This is a warning message output to console & file."
logConsoleFile ERROR "$log_file" "This is a error message output to console & file."

# # failed test
# logConsole INFO # FAILED WITH recode=11
# logConsole FATAL "This case will run failed with recode=12"

# logFile "This case will run failed with recode=11"

# logConsoleFile "This case will run failed with recode=11"
# logConsoleFile FAT "This case will run failed with recode=12"
