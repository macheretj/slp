#!/bin/bash

trap "echo CTRL-C not allowed!" 2




echo "************** SCRIPT STARTING **************"

function variable_init()
{

	#ssh-agent data vars
        data_dir=data
        ssh_agent_data_file=$data_dir/ssh_agent_file

	#process list propreties
	ps_options="-e -o user,pid,comm"
	ps_user_col_ref=1
	ps_pid_col_ref=2
	ps_comm_col_ref=3

	#ssh keys data
	ssh_key_path=~/.ssh/
	slp_ssh_key_name=id_dsa_slp

}



function slp_env_exists()
{
        if [ -d $data_dir ]
        then
                echo true
        else
                echo false
        fi
}

function create_slp_env()
{
        echo "**** Data dir path: $data_dir"
        mkdir $data_dir

}

function is_agent_running()
{

        if [ "`ps $ps_options | grep $LOGNAME | awk -v temp=$ps_comm_col_ref '{print $temp}' | egrep -x ssh-agent | wc -l`" -eq 1 ]
        then

                echo true

        elif [ "`ps $ps_options | grep $LOGNAME | awk -v temp=$ps_comm_col_ref '{print $temp}' | egrep -x ssh-agent | wc -l`" -gt 1 ]
        then

                echo error

        else

                echo false

        fi

}


function purge_ssh_agent()
{

echo "**** Purging ssh-agent process"

for ssh_agent_process in `ps $ps_options | grep $LOGNAME | grep ssh-agent | awk -v temp=$ps_pid_col_ref '{print $temp}'`
do
        echo "**** Killing ssh-agent process PID: $ssh_agent_process"
        kill $ssh_agent_process
done


echo "" > $ssh_agent_data_file

}

function start_ssh_agent()
{


echo "**** Starting SSH-AGENT"
eval `ssh-agent`

#check if ssh-key file does NOT exists
if [ ! -f ~/.ssh/id_dsa_slp ]
then
	echo "**** Ssh-key file does NOT exists"
	generate_ssh_key
fi

ssh-add ~/.ssh/id_dsa_slp


echo $SSH_AGENT_PID > $ssh_agent_data_file
echo $SSH_AUTH_SOCK >> $ssh_agent_data_file

}

function generate_ssh_key()
{

echo "**** Please follow the instructions to generate your SSH-KEY"
echo "**** DO NOT USE AN EMPTY PASSPHRASE!"
ssh-keygen -t dsa -f ~/.ssh/id_dsa_slp -q 

}

function set_ssh_agent_env_var()
{

echo "**** Setting environment variables"

echo "**** SSH-Agent PID: $ssh_agent_pid_value"
export SSH_AGENT_PID=`cat $ssh_agent_data_file | head -1 | tail -1`

echo "**** SSH-Agent Auth Socket: $ssh_agent_auth_sock"
export SSH_AUTH_SOCK=`cat $ssh_agent_data_file | head -2 | tail -1`

}


function check_ssh_agent_consistency()
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

        variable_init


        case `slp_env_exists` in
                "true") echo "**** SLP ENV OK";;
                "false") echo "**** SLP ENV does not exists, creating..."
                create_slp_env;;
        esac


        case `is_agent_running` in
                "true") echo "**** Agent is running"
                        set_ssh_agent_env_var

                case `check_ssh_agent_consistency` in
                        "true") echo "**** Agent is consistent, stored PID and running process PID matches!";;
                        "false") echo "**** Agent not consistent, stored PID and running PID DO NOT MATCHES!"
                        purge_ssh_agent
                        start_ssh_agent;;
                esac;;

                "false") echo "**** Agent is not Running"
                        start_ssh_agent;;
                "error")
                        echo "**** Error, more than 1 agent is running for user: $LOGNAME"
                        purge_ssh_agent
                        start_ssh_agent;;
        esac

}

main
