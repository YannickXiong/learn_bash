#!/usr/bin/env bash

function ShowMsg()
{
    echo "$1 : $2"
}

cmd=`curl -s -l -H "Content-type: application/json" -X POST http://hq.sinajs.cn/list=sh600081 > ./.query.txt`
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

nowPercentage=`awk 'BEGIN{printf "%.2f%%\n",('${gapPrice}'/'${yesPrice}')*100}'`
higPercentage=`awk 'BEGIN{printf "%.2f%%\n",('${higGapPrice}'/'${yesPrice}')*100}'`
lowPercentage=`awk 'BEGIN{printf "%.2f%%\n",('${lowGapPrice}'/'${yesPrice}')*100}'`


ShowMsg yesPrice ${yesPrice}
ShowMsg nowPrice ${nowPrice}
ShowMsg gapPrice ${gapPrice}
ShowMsg nowPercentage ${nowPercentage}
ShowMsg higPrice ${higPrice}
ShowMsg higPercentage ${higPercentage}
ShowMsg lowPrice ${lowPrice}
ShowMsg lowPercentage ${lowPercentage}
