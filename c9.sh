#!/bin/bash
get_c9_pid(){
   echo $(ps x | grep '[n]ode server.js' | awk '{print $1}')
}

start() {
    local c9_pid=$(get_c9_pid)
    if [ -z "$c9_pid" ];
    then
	if [ $? -eq 0 ];
        then
	    nohup node server.js --listen 138.68.95.144 -p 8080 -a admin:1q2w3e4r5t6y7u8i9o@# -w /home/rovshan/development/djangoprojects/ >/dev/null 2>&1 &
            echo "c9 started"
	fi
    else
	echo "already running"
    fi
}

stop() {
    local c9_pid=$(get_c9_pid)
    if [ ! -z "$c9_pid" ]; 
    then    
        kill $c9_pid
        if [ $? -eq 0 ]; 
        then 
            echo "killed"
        else
            echo "cannot kill"   
       fi
    else
        echo "Nothing to stop"
    fi
}
status() {
    local c9_pid=$(get_c9_pid)
    if [ -z "$c9_pid" ];
    then
	echo "process is not running"
    else
	echo "process is running"
    fi 
}

case "$1" in 
    start)
           start
           ;;
    stop)
           stop
           ;;
    status)
           status
           ;;
    restart)
	   stop
	   start
	   ;; 
    *)
           echo "Usage: $0 {start|stop|status|restart}"
esac
exit 0 
