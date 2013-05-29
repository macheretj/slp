# Strict ps -ef by name

#!/bin/bash

echo -e "** Welcome in SPS, a ps command listing only process by strict name" > /dev/tty
echo -e "** Ex: sps.sh ssh-agent, returns only strict ssh-agent process." > /dev/tty

if [ $# -eq 0 ]
then
    echo -e "** Wrong usage! Please specify a process name!"  > /dev/tty
    exit 0
fi

process_name = $0

while read line; do if [ "`echo $line | awk '{print $8}' | grep -Fx $process_name`" == "$process_name" ]; then echo $line; fi; done < <(ps -ef | grep $process_name)
