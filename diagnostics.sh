#The script get processor, memory and disk usage information according to given parameter and show user 
#Autohor: Rovshan Musayev
#!/bin/bash

#Help info
show_help() {
cat << EOF
Usage: ${0##*/} [-part] [option] ...
part
    p			Get processor(CPU) information
    m 		  	Memory(RAM) information
    d			Disk usage
option
	free 		Free space
	used		Used space
	total           Whole info

To call with all parameters:  ${0##*/} -ptotal -pused -pfree -mtotal -mused -mfree -dtotal -dused -dfree
EOF
}

#declare variable
OPTIND=1
cpu_info_true=0
mem_info_true=0
disk_info_true=0
cpu_info_full="\nProcessor usage information"
mem_info_full="\nMemory usage information"
disk_info_full="\nDisk usage information\nPartition____________"
disk_info_size='%20.3f '
disk_info_full_size='%- 12s '
disk_info_begin="df -kP | tail -n +2| awk '{printf \""
disk_info_body='\n",$6'
disk_info_end="}'"

#Main part
if [ $# = 0 ];then
   show_help
   exit 0
fi
while getopts "hp:m:d:" optname
	do
		case "$optname" in
			"h")
				show_help
				exit 0
				;;
			"p")
				if [ -z "$cpu_info_raw" ]; then
					cpu_info_raw=`grep 'cpu ' /proc/stat`
				fi
				if [ -z "$cpu_info_total_hz" ]; then
					cpu_info_total_hz=`echo $cpu_info_raw | awk '{print ($2+$4+$5)}'`
				fi
				if [ -z "$cpu_info_used_hz" ]; then
					cpu_info_used_hz=`echo $cpu_info_raw | awk '{print ($2+$4)}'`
				fi 
				if [ $OPTARG = "free" ]; then
					((cpu_info_true++))
					cpu_info_free_hz=$(($cpu_info_total_hz-$cpu_info_used_hz))
					cpu_info_full=$cpu_info_full"\nFree CPU: "$cpu_info_free_hz" hz, "`echo $cpu_info_free_hz $cpu_info_total_hz | awk '{printf "%.2f \n", ($1/$2)*100}'`"%"
				elif [ $OPTARG = "used" ]; then
					((cpu_info_true++))
					cpu_info_full=$cpu_info_full"\nUsed CPU: "$cpu_info_used_hz" hz, "`echo $cpu_info_used_hz $cpu_info_total_hz | awk '{printf "%.2f \n", ($1/$2)*100}'`"%"
				elif [ $OPTARG = "total" ]; then
					((cpu_info_true++))
					cpu_info_full=$cpu_info_full"\nTotal CPU: "$cpu_info_total_hz" hz, 100%"
				else
					echo "Invalid option"
					show_help >&2
					exit 1
				fi
				;;
			"m")
				if [ -z "$mem_info_raw" ]; then
					mem_info_raw=`free -m | grep "buffers/cache"`
				fi
				if [ -z "$mem_info_total_mb" ]; then
					mem_info_total_mb=`free -m | grep "Mem:" |awk '{print $2}'`
				fi
				if [ $OPTARG = "free" ]; then
					((mem_info_true++))
					mem_info_free_mb=`echo $mem_info_raw | awk '{print $4}'`
					mem_info_full=$mem_info_full"\nFree memory: "$mem_info_free_mb" mb, "`echo $mem_info_free_mb $mem_info_total_mb | awk '{printf "%.2f \n", ($1/$2)*100}'`"%"
				elif [ $OPTARG = "used" ]; then
					((mem_info_true++))
					mem_info_used_mb=`echo $mem_info_raw | awk '{print $3}'`
					mem_info_full=$mem_info_full"\nUsed memory: "$mem_info_used_mb" mb, "`echo $mem_info_used_mb $mem_info_total_mb | awk '{printf "%.2f \n", ($1/$2)*100}'`"%"
				elif [ $OPTARG = "total" ]; then
					((mem_info_true++))
					mem_info_full=$mem_info_full"\nTotal memory: "$mem_info_total_mb" mb, 100%"
				else
					echo "Invalid option"
					show_help >&2
					exit 1
				fi
				;;
			"d")
				if [ $OPTARG = "free" ]; then
					disk_info_full=$disk_info_full'___Free Space wih GB___Free Space with%'
					((disk_info_true++))
					disk_info_full_size=$disk_info_full_size`echo $disk_info_size{,}`
					disk_info_body=$disk_info_body',$4/1024/1024,$4*100/$2'
				elif [ $OPTARG = "used" ]; then
					disk_info_full=$disk_info_full'___Used Space wih GB___Used Space with%'
					((disk_info_true++))
					disk_info_full_size=$disk_info_full_size`echo $disk_info_size{,}`
					disk_info_body=$disk_info_body',$3/1024/1024,$3*100/$2'
				elif [ $OPTARG = "total" ]; then
					disk_info_full=$disk_info_full'___Total Space wih GB___Total Space with%'
					((disk_info_true++))
					disk_info_full_size=$disk_info_full_size`echo $disk_info_size{,}`
					disk_info_body=$disk_info_body',$2/1024/1024,100'
				else
					echo "Invalid option"
					show_help >&2
					exit 1
				fi
				;;
			"?")
				show_help >&2
				exit 1
				;;
			":")
				echo "No argument value for option $OPTARG"
				;;
			*)
				echo "Unknown error while processing options"
				;;
		esac
done
if [ $cpu_info_true -gt 0 ]; then
	echo -e $cpu_info_full
fi
if [ $mem_info_true -gt 0 ]; then
	echo -e $mem_info_full
fi	
if [ $disk_info_true -gt 0 ]; then
	echo -e $disk_info_full
	disk_info_result=$disk_info_begin$disk_info_full_size$disk_info_body$disk_info_end
	eval $disk_info_result
fi	
