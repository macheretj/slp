#!/bin/bash

trap "echo CTRL-C not allowed!" 2




echo "************** SCRIPT STARTING **************"

function variableInit()
{
        data_dir=data
        ssh_agent_data_file=$data_dir/ssh_agent_file

        echo "**** paths: $data_dir and $ssh_agent_data_file"

}



function slpEnvExists()
{
        if [ -d $data_dir ]
        then
                echo true
        else
                echo false
        fi
}

function createSLPEnv()
{
        echo "**** Data dir path: $data_dir"
        mkdir $data_dir

}

function isAgentRunning()
{

        if [ "`ps -ef | grep ssh-agent | grep -v grep | grep $LOGNAME | awk '{print $2}' | wc -l`" -eq 1 ]
        then

                echo true

        elif [ "`ps -ef | grep ssh-agent | grep -v grep | grep $LOGNAME | awk '{print $2}' | wc -l`" -gt 1 ]
        then

                echo error

        else

                echo false

        fi

}


function purgeSshAgent()
{

for ssh_agent_process in `ps -ef | grep ssh-agent | grep -v grep | grep $LOGNAME | awk '{print $2}'`
do
        echo "**** Killing ssh-agent process PID: $ssh_agent_process"
        kill $ssh_agent_process
done


echo "" > $ssh_agent_data_file

}

function startSshAgent()
{

echo "**** Starting SSH-AGENT"
eval `ssh-agent`
ssh-add ~/.ssh/id_dsa_slp


echo $SSH_AGENT_PID > $ssh_agent_data_file
echo $SSH_AUTH_SOCK >> $ssh_agent_data_file

}

function setSshAgentEnvVar()
{

echo "**** Setting environment variables"

echo "**** SSH-Agent PID: $ssh_agent_pid_value"
export SSH_AGENT_PID=`cat $ssh_agent_data_file | head -1 | tail -1`

echo "**** SSH-Agent Auth Socket: $ssh_agent_auth_sock"
export SSH_AUTH_SOCK=`cat $ssh_agent_data_file | head -2 | tail -1`

}


function checkSshAgentConsistency()
{

stored_agent_pid=`cat $ssh_agent_data_file | head -1 | tail -1`
running_agent_pid=`ps -ef | grep ssh-agent | grep -v grep | grep $LOGNAME | awk '{print $2}'`


if [ $stored_agent_pid == $running_agent_pid ] && [ $stored_agent_pid == $SSH_AGENT_PID ]
then

echo true

else

echo false

fi

}



function main()
{

        variableInit


        case `slpEnvExists` in
                "true") echo "**** SLP ENV OK";;
                "false") echo "**** SLP ENV does not exists, creating..."
                createSLPEnv;;
        esac


        case `isAgentRunning` in
                "true") echo "**** Agent is running"
                        setSshAgentEnvVar

                case `checkSshAgentConsistency` in
                        "true") echo "**** Agent is consistent, stored PID and running process PID matches!";;
                        "false") echo "**** Agent not consistent, stored PID and running PID DO NOT MATCHES!"
                        purgeSshAgent
                        startSshAgent;;
                esac;;

                "false") echo "**** Agent is not Running"
                        startSshAgent;;
                "error")
                        echo "**** Error, more than 1 agent is running for user: $LOGNAME"
                        purgeSshAgent
                        startSshAgent;;
        esac

}

main
