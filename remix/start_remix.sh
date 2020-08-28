pid=""
function getPid(){
    # pid=`ps -ef |grep remix |grep -v "olor=auto"|grep -v "start_remix"|awk '{print $2}'`
	pid=`pgrep -f "remix-ide"`
}

getPid

if [[ "x"${pid} == "x" ]]; then
	echo "begin to start remix-ide .."
    nohup remix-ide &
	getPid

	if [[ "x"${pid} == "x" ]]; then
		echo "started remix-ide failed."
	else
		echo "started remix-ide(pid=${pid}) successfully."
	fi
else
	echo "remix-ide(pid=${pid}) has been already started, nothing to do .."
fi
