#! /bin/bash

. ./logWriter.sh

awk "/\[argodb\]/{a=1}a==1"  tdh.conf|sed -e'1d' -e '/^$/d'  -e 's/#.*//g' -e 's/[ \t]*$//g' -e 's/^[ \t]*//g' -e 's/[ ]/@G@/g' -e '/\[/,$d' -e '/^$/d'

#该脚本必须用 source 命令 而且结果获取为${var}获取，不是return 如：source readIni.sh 否则变量无法外传
# dealIni.sh conf_file section key
# read
# param : conf_file section key    return value --- a str    use: ${iniValue}
# param : conf_file section           return keys (element: key = value) --- a str[]   use: arr_length=${#inikeys[*]}}  element=${inikeys[0]}
# param : conf_file                   returm sections (element: section ) --- a str[]   use: arr_length=${#allSectionsArray[*]}}  element=${allSectionsArray[0]}
# write
#param : -w conf_file section key value  add new element：section key    result:if not --->creat ,have--->update,exist--->do nothing
#key ,value can not be null
 
#params
conf_file=tdh.conf
section=slipstream
key=user

declare -A g_configMap  # dict map, stored as g_configMap[k]=v, key is section_key in a config file, v is value of key.
declare -r g_allSections  # array, to stored all sections name for a config

#resullt
iniValue='default'
inikeys=()
allSectionsArray=()
 
function checkFile()
{
    if [ "${conf_file}" = ""  ] || [ ! -f ${conf_file} ];then
        echo "[error]:file --${conf_file}-- not exist!"
    fi
}

######################################################
# Func: getAllSectionNames
# Desc: get all section names into global array g_allSections.
######################################################
function getAllSectionNames()
{
    # translate into an array.
    logConsole INFO start to collect sessions from config file: ${conf_file} ..
    _allSections=$(awk -F '[][]' '/\[.*]/{print $2}' ${conf_file})
    g_allSections=(${_allSections// /})
    logConsole INFO ${#g_allSections[@]} sessions collected: ${g_allSections[@]}
}

######################################################
# Func: readSectionBlockByName
# Desc: Read section block by section name.
######################################################
function readSectionBlockByName()
{

}

function read2ConfigMap()
{
    # for x in $(echo $a |awk '{print $0}'); do echo $x; done
    #a=(获取匹配到的section之后部分|去除第一行|去除空行|去除每一行行首行尾空格|将行内空格变为@G@(后面分割时为数组时，空格会导致误拆))
    a=$(awk "/\[${section}\]/{a=1}a==1"  ${conf_file}|sed -e'1d' -e '/^$/d'  -e 's/[ \t]*$//g' -e 's/^[ \t]*//g' -e 's/[ ]/@G@/g' -e '/\[/,$d' )
    b=(${a})
    for i in ${b[@]};do
      #剔除非法字符，转换@G@为空格并添加到数组尾
      if [ -n "${i}" ]||[ "${i}" i!= "@S@" ];then
          inikeys[${#inikeys[@]}]=${i//@G@/ }
      fi
    done
    echo "[info]:inikeys size:-${#inikeys[@]}- eles:-${inikeys[@]}-"
    elif [ "${section}" != "" ] && [ "${key}" != "" ];then
 
       # iniValue=`awk -F '=' '/\['${section}'\]/{a=1}a==1&&$1~/'${key}'/{print $2;exit}' $conf_file|sed -e 's/^[ \t]*//g' -e 's/[ \t]*$//g'`
        iniValue=`awk -F '=' "/\[${section}\]/{a=1}a==1" ${conf_file}|sed -e '1d' -e '/^$/d' -e '/^\[.*\]/,$d' -e "/^${key}.*=.*/!d" -e "s/^${key}.*= *//"`
        echo "[info]:iniValue value:-${iniValue}-"
        fi
}
 
function writeconf_file()
{
    #检查文件
    checkFile
    allSections=$(awk -F '[][]' '/\[.*]/{print $2}' ${conf_file})
    allSectionsArray=(${allSections// /})
    #判断是否要新建section
    sectionFlag="0"
    for temp in ${allSectionsArray[@]};do
        if [ "${temp}" = "${section}" ];then
            sectionFlag="1"
            break
        fi
    done
 
    if [ "$sectionFlag" = "0" ];then
        echo "[${section}]" >>${conf_file}
    fi
    #加入或更新value
    awk "/\[${section}\]/{a=1}a==1" ${conf_file}|sed -e '1d' -e '/^$/d'  -e 's/[ \t]*$//g' -e 's/^[ \t]*//g' -e '/\[/,$d'|grep "${key}.\?=">/dev/null
    if [ "$?" = "0" ];then
        #更新
        #找到制定section行号码
        sectionNum=$(sed -n -e "/\[${section}\]/=" ${conf_file})
        sed -i "${sectionNum},/^\[.*\]/s/\(${key}.\?=\).*/\1 ${value}/g" ${conf_file}
        echo "[success] update [$conf_file][$section][$key][$value]"
    else
        #新增
        #echo sed -i "/^\[${section}\]/a\\${key}=${value}" ${conf_file}
        sed -i "/^\[${section}\]/a\\${key} = ${value}" ${conf_file}
        echo "[success] add [$conf_file][$section][$key][$value]"
    fi
}
 
#main
if [ "${mode}" = "iniR" ];then
    checkFile
    read
elif [ "${mode}" = "iniW" ];then
    writeconf_file
fi


# run test
Names
