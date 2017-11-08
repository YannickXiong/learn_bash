#!/usr/bin/env bash

#!/usr/bin/env bash

# *********************************************************** #
# @File         : return_code_test.sh                         #
# @Version      : 1.0.0                                       #
# @Author       : Jason Xiong                                 #
# @Time         : 2017/8/18 17:02                             #
# @Description  : to test how to quote a function return code #
# @Note         :                                             #
# *********************************************************** #


function DemoFunc()
{
    return 10
}

function DemoFunc1()
{
    echo 23
    return 100
}

# 输出空
ret1=`DemoFunc`
echo "ret1=${ret1}"

# 输出 10
# 对比说明shell函数的返回值（return）只返回给$?，并且必须是0-255的一个值，
# 超出后shell自由返回，这个前面证实过
ret2=$?
echo "ret2=${ret2}"

# ret3返回23，ret4返回100，说明直接通过ret=`function`方式得到的，是标准输出值，而不是函数的返回值
# 函数的返回值只能以$?接收。思考下echo "ret4=${ret4}"写在echo "ret3=${ret3}"后面会得到什么？
# 那样的话ret4将是命令echo "ret3=${ret3}"的返回值（为0），而不是DemoFunc1的返回值
ret3=`DemoFunc1`
ret4=$?
echo "ret4=${ret4}"
echo "ret3=${ret3}"



# 使用-x调试会发现解析为if [[ -n 调用结果 ]]，因为不是引用$?，所以调用结果为调用函数时的标准输出
# 所以是 if [[ -n ]] 结果为no
if [[ `DemoFunc` ]]
then
    echo "DemoFunc: yes"
else
   echo "DemoFunc: no"
fi

# 这个结果不用说，自然是yes了
if [[ `DemoFunc1` ]]
then
    echo "DemoFunc1: yes"
else
   echo "DemoFunc1: no"
fi