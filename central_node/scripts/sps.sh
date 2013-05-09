# Strict ps -ef by name

#!/bin/bash

echo -e "** Welcome in SPS, a ps command listing only process by strict name"
echo -e "** Ex: sps.sh ssh-agent, returns only strict ssh-agent process."

if [ $# -eq 0 ]
then
    echo -e '** Wrong usage! Please specify a process name!'
    exit 0
fi

process_name = $0

while read line; do if [ "`echo $line | awk '{print $8}' | grep -Fx $process_name`" == "$process_name" ]; then echo $line; fi; done < <(ps -ef | grep $process_name)
