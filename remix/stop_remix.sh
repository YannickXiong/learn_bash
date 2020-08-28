pid=""
function getPid(){
    # pid=`ps -ef |grep remix |grep -v "olor=auto"|grep -v "stop_remix"|awk '{print $2}'`
	pid=`pgrep -f "remix-ide"`
}

getPid

if [[ "x"${pid} == "x" ]];then
	echo "remix has been already stoped, nothing to do."
else
	echo "begin to fore stop remix(pid =${pid}) .."
	kill -9 ${pid}
	_pid=${pid}
	getPid
	if [[ "x"${pid} == "x" ]];then
        echo "stop remix(pid=${_pid}) successfully."
    else
		echo "stop remix failed."
	fi
fi
