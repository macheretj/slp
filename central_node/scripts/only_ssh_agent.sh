while read line; do if [ "`echo $line | awk '{print $8}' | grep -Fx ssh-agent`" == "ssh-agent" ]; then echo $line; fi; done < <(ps -ef | grep ssh-agent)
