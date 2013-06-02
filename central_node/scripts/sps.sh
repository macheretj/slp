#!/bin/bash

echo -e "** Welcome in SPS, a ps command listing only process by strict name" > /dev/tty
echo -e "** Ex: sps.sh ssh-agent, returns only strict ssh-agent process." > /dev/tty

if [ $# -eq 0 ]
then
    echo -e "** Wrong usage! Please specify a process name!"  > /dev/tty
	echo -e "** Exemple: sps.sh ssh-agent, will return only real ssh-agent processes"  > /dev/tty
    exit 0
fi

process_name=$1

while read line
do
	pid=`echo $line | awk '{print $2}'`
	user=`echo $line | awk '{print $1}'`
	comm=`echo $line | awk '{print $3}'`

	case $comm in
	"$process_name")
	echo Found $process_name process: $line > /dev/tty
	echo $line
	;;
	*)
	echo NOTHING FOUND!!! > /dev/tty
	;;
	esac

done < <(ps -e -o user,pid,comm | grep $process_name)  

