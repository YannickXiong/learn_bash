#!/usr/bin/env bash
declare -r INTERNAL_Time=5

function ShowMsg()
{
    echo "$1 : $2"
}

function ShowEnjoy()
{
    # 为负
    local sourcePrice=$1
    local showPrice=`abs $1`

    local num=0

    if [[ $(echo "${showPrice} < 1" | bc) = 1 ]];then
       num=1
    else
       # 四舍五入取数，如果不加0.5，直接取整，3.78会变成3
       num=`echo ${showPrice} | awk '{print int($1+0.5)}'`
    fi

    local context=" "$2

    for ((i=1;i<num;i++))
    do
        context=${context}" "$2
    done
    echo "[ ${sourcePrice} ]${context}"
}

function abs()
{
    if [[ $(echo "$1 >= 0" | bc) = 1 ]];then
        echo $1
    else
        echo "0 - $1" | bc
    fi
}

while :
do
    cmd=`curl -s -l -H "Content-type: application/json" -X POST http://hq.sinajs.cn/list=sh601390 > ./.query.txt`
    yesPrice=`awk -F "," '{print $3}' .query.txt `
    nowPrice=`awk -F "," '{print $4}' .query.txt `
    higPrice=`awk -F "," '{print $5}' .query.txt `
    lowPrice=`awk -F "," '{print $6}' .query.txt `
    # expr does not support float. Use bc instead
    # gapPrice=`expr ${nowPrice} - ${yesPrice}`
    # higGapPrice=`expr ${higPrice} - ${yesPrice}`
    # lowGapPrice=`expr ${lowPrice} - ${yesPrice}`
    gapPrice=`echo "scale=2;${nowPrice}-${yesPrice}" | bc`
    higGapPrice=`echo "scale=2;${higPrice}-${yesPrice}" | bc`
    lowGapPrice=`echo "scale=2;${lowPrice}-${yesPrice}" | bc`

    # nowPercentage=`expr ${gapPrice} * 100 / ${yesPrice}`
    # higPercentage=`expr ${higGapPrice} * 100 / ${yesPrice}`
    # lowPercentage=`expr ${lowGapPrice} * 100 / ${yesPrice}`

    # nowPercentage=`awk 'BEGIN{printf "%.2f%%\n",('${gapPrice}'/'${yesPrice}')*100}'`
    # higPercentage=`awk 'BEGIN{printf "%.2f%%\n",('${higGapPrice}'/'${yesPrice}')*100*100}'`
    # lowPercentage=`awk 'BEGIN{printf "%.2f%%\n",('${lowGapPrice}'/'${yesPrice}')*100}'`

    nowPercentage=`awk 'BEGIN{printf "%.2f\n",('${gapPrice}'/'${yesPrice}')*100}'`

    # ShowMsg yesPrice ${yesPrice}
    # ShowMsg nowPrice ${nowPrice}
    # ShowMsg gapPrice ${gapPrice}
    # ShowMsg nowPercentage ${nowPercentage}
    # ShowMsg higPrice ${higPrice}
    # ShowMsg higPercentage ${higPercentage}
    # ShowMsg lowPrice ${lowPrice}
    # ShowMsg lowPercentage ${lowPercentage}
    if [[ $(echo "${nowPercentage} < 0"|bc) = 1 ]];then
        ShowEnjoy ${nowPercentage} ":("

    else
        ShowEnjoy ${nowPercentage} ":)"

    fi
    sleep ${INTERNAL_Time}
done
