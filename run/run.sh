#!/usr/bin/env bash

# *********************************************************** #
# @File         : run.sh                                      #
# @Version      : 1.0.0                                       #
# @Author       : Yannick                                     #
# @Time         : 2017/11/07 14:57                            #
# @Description  : to run jenkins job                          #
# @Note         :                                             #
# *********************************************************** #

PRAM_HOME=$(cd "$(dirname "$0")"; pwd)
PRAM_UTILS=${PRAM_HOME}/utils
PRAM_LOG_DIR=${PRAM_HOME}/log

. ${PRAM_UTILS}/logWriter.sh

declare __DEBUG__=on

# set env
export GOROOT=/usr/local/go
export GOPATH=~/go
export PATH=${PATH}:${GOROOT}/bin
export PATH=${PATH}:GOPATH
export RUN_WORKSPACE=~/run

# set return code
# g_OK has been defined in ./logWriter.sh, so cannot defined it again(assigned value again).
# declare -r g_OK=0
declare -r g_CREATE_DIR_FAILED=21
declare -r g_GO_INSTALL_PROJECT_FAILED=22
declare -r g_TARGET_PROGRAM_NotExist=23
declare -r g_TARGET_PROGRAM_TEST_FAILED=24
declare -r g_COPY_FAILED=25
declare -r g_PUSHD_FAILED=26
declare -r g_POPD_FAILED=27

# set jenkins variable
declare -r g_JENKINS_WORKSPACE=~/jenkins/workspace
declare -r g_JENKINS_JOB="AUTO_GO_DAILY_TEST"
declare -r g_JENKINS_NODE_LABELS=("auto_192.168.1.120")
declare -r g_RUN_LOG=${PRAM_LOG_DIR}/run.log

# the name of a go project
# for a go project: git@github.com:user-name/golang.git, the jenkins fetch all the files(dirs) under the "golang", so
# need to create "golang" under $GOPATH/src
declare -r g_GO_PROJECT_NAME="golang"

# the testing target set
declare TEST_PROGRAM=()

# Check if the dir exist, if not, then create it.
function CheckDir()
{
    logWriter INFO "CheckDir() called begin ..." | tee -a ${g_RUN_LOG}
    for _dir_ in $1
    do
        logWriter INFO "Checking ${_dir_} ..." | tee -a ${g_RUN_LOG}
        if [[ -d ${_dir_} ]] ; then
            logWriter INFO "${_dir_} exists, nothing to do ..." | tee -a ${g_RUN_LOG}
            logWriter INFO "CheckDir() called end ..." | tee -a ${g_RUN_LOG}
            return ${g_OK}
        else
            logWriter INFO "${_dir_} does not exist, now create it ..." | tee -a ${g_RUN_LOG}
            mkdir -p ${_dir_}
            if [[ $? -eq 0 ]]; then
                logWriter INFO "Create ${_dir_} successfully." | tee -a ${g_RUN_LOG}
                logWriter INFO "CheckDir() called end ..." | tee -a ${g_RUN_LOG}
                return ${g_OK}
            else
                 logWriter ERROR "Create ${_dir_} failed(rcode=${g_CREATE_DIR_FAILED}), please check ${g_RUN_LOG} for more details." | tee -a ${g_RUN_LOG}
                 logWriter INFO "CheckDir() called end ..." | tee -a ${g_RUN_LOG}
                return ${g_CREATE_DIR_FAILED}
            fi
        fi
    done

    logWriter INFO "CheckDir() called end ..." | tee -a ${g_RUN_LOG}
}

# copy source code from jenkins_workspace to $GOPATH/src
function GetProjectSourceCode()
{
    logWriter INFO "GetProjectSourceCode() called begin ..." | tee -a ${g_RUN_LOG}

    local _work_space=${g_JENKINS_WORKSPACE}/${g_JENKINS_JOB}/label
    for _label_ in ${g_JENKINS_NODE_LABELS[@]}
    do
        logWriter INFO "Begin to scan projects under label: ${_label_} ..." | tee -a ${g_RUN_LOG}
        local _project_dir=${_work_space}/${_label_}
        logWriter INFO "pushd ${_project_dir} ..." | tee -a ${g_RUN_LOG}
        pushd ${_project_dir} >> ${g_RUN_LOG}
        if [[ $? -ne 0 ]]; then
            logWriter ERROR "pushd ${_project_dir} failed(rcode=${g_PUSHD_FAILED}), please check ${g_RUN_LOG} for more details." | tee -a ${g_RUN_LOG}
            exit ${g_PUSHD_FAILED}
        else
            logWriter INFO "pushd ${_project_dir} successfully." | tee -a ${g_RUN_LOG}
        fi

        for _project_ in `ls -F | grep '/$' |cut -d "/" -f1`
        do
            logWriter INFO "Found project: ${_project_} ..." | tee -a ${g_RUN_LOG}
            logWriter INFO "Now begin to move source project:<${_project_}> from ${_project_dir} to ${GOPATH}/src/${g_GO_PROJECT_NAME} ..." | tee -a ${g_RUN_LOG}
            cp -rf ${_project_} ${GOPATH}/src/${g_GO_PROJECT_NAME}
            if [[ $? -ne 0 ]]; then
                logWriter ERROR "Copy source project:<${_project_}> from ${_project_dir} to $GOPATH/src/${g_GO_PROJECT_NAME} failed(rcode=${g_COPY_FAILED}), please check ${g_RUN_LOG} for more details." | tee -a ${g_RUN_LOG}
                exit ${g_COPY_FAILED}
            else
                logWriter INFO "Copy source project:<${_project_}> from ${_project_dir} to $GOPATH/src/${g_GO_PROJECT_NAME} successfully." | tee -a ${g_RUN_LOG}
        fi
        done

        logWriter INFO "popd ${_project_dir} ..." | tee -a ${g_RUN_LOG}
        popd  >> ${g_RUN_LOG}
        if [[ $? -ne 0 ]]; then
            logWriter ERROR "popd ${_project_dir} failed(rcode=${g_POPD_FAILED}), please check ${g_RUN_LOG} for more details." | tee -a ${g_RUN_LOG}
            exit ${g_POPD_FAILED}
        else
            logWriter INFO "popd ${_project_dir} successfully." | tee -a ${g_RUN_LOG}
        fi
    done
}
# Build the testing go project using "go install"
function Install()
{
    logWriter INFO "Install() called begin ..." | tee -a ${g_RUN_LOG}

    cd ${GOPATH}/src/${g_GO_PROJECT_NAME}
    for _project_ in `ls -F | grep '/$' |cut -d "/" -f1`
    do
        # collect the target program
        TEST_PROGRAM=(${TEST_PROGRAM[*]} ${_project_})

        pushd ${_project_} >> ${g_RUN_LOG}
        if [[ $? -ne 0 ]]; then
            logWriter ERROR "pushd ${_project_} failed(rcode=${g_PUSHD_FAILED}), please check ${g_RUN_LOG} for more details." | tee -a ${g_RUN_LOG}
            exit ${g_PUSHD_FAILED}
        else
            logWriter INFO "pushd ${_project_} successfully." | tee -a ${g_RUN_LOG}
        fi

        logWriter INFO "Begin to build ${_project_} ..." | tee -a ${g_RUN_LOG}
        go install >> ${g_RUN_LOG}
        if [[ $? -eq 0 ]]; then
            if [[ -f ${GOPATH}/bin/${_project_} ]]; then
                logWriter INFO "Build project ${_project_} successfully." | tee -a ${g_RUN_LOG}
                # return ${g_OK} # cannot return here, otherwise, the rest will not be built
            fi
        else
            logWriter ERROR "Build project ${_project_} failed(rcode=${g_GO_INSTALL_PROJECT_FAILED}), please check ${g_RUN_LOG} for more details." | tee -a ${g_RUN_LOG}
            logWriter INFO "Install() called end ..." | tee -a ${g_RUN_LOG}
            exit ${g_GO_INSTALL_PROJECT_FAILED}
        fi
        logWriter INFO "Build ${_project_} end ..." | tee -a ${g_RUN_LOG}
        # cd ../
        logWriter INFO "popd ${_project_} ..." | tee -a ${g_RUN_LOG}
        popd  >> ${g_RUN_LOG}
        if [[ $? -ne 0 ]]; then
            logWriter ERROR "popd ${_project_} failed(rcode=${g_POPD_FAILED}), please check ${g_RUN_LOG} for more details." | tee -a ${g_RUN_LOG}
            exit ${g_POPD_FAILED}
        else
            logWriter INFO "popd ${_project_} successfully." | tee -a ${g_RUN_LOG}
        fi
    done

    logWriter INFO "Install() called end ..." | tee -a ${g_RUN_LOG}
    return ${g_OK}
}

# go run test target
function RunTest()
{
    logWriter INFO "RunTest() called begin ..." | tee -a ${g_RUN_LOG}

    cd ${GOPATH}/bin

    for _test_program_ in ${TEST_PROGRAM[*]}
    do
        logWriter INFO "Begin to run test target program: ${_test_program_} ..." | tee -a ${g_RUN_LOG}
        ./${_test_program_} | tee -a ${g_RUN_LOG}
        if [[ $? -ne 0 ]]; then
            logWriter ERROR "Run test target program: ${_test_program_} failed(Rcode=${g_TARGET_PROGRAM_TEST_FAILED}, please check ${g_RUN_LOG} for more details." | tee -a ${g_RUN_LOG}
            exit ${g_TARGET_PROGRAM_TEST_FAILED}
        else
            logWriter INFO "Run test target program: ${_test_program_} successfully." | tee -a ${g_RUN_LOG}
        fi
    done

    logWriter INFO "RunTest() called end ..." | tee -a ${g_RUN_LOG}

    return ${g_OK}
}

# main
function main()
{
    logWriter INFO "main() called begin ..." | tee -a ${g_RUN_LOG}
    CheckDir ${GOPATH}/src
    CheckDir ${GOPATH}/pkg
    CheckDir ${GOPATH}/bin
    CheckDir ${GOPATH}/${g_GO_PROJECT_NAME}
    GetProjectSourceCode
    Install
    RunTest

    logWriter INFO "main() called end ..." | tee -a ${g_RUN_LOG}

    return ${g_OK}

}

main
