#!/bin/bash

trap "echo CTRL-C not allowed!" 2




echo "************** SCRIPT STARTING **************"


# All variable initialization
function variable_init()
{

	# Outputs variable
	debug_out=/dev/null
	user_warning=/dev/tty

	# ssh-agent data vars
        data_dir=.slp_data
        ssh_agent_data_file=$data_dir/ssh_agent_data_file

	# Process list propreties
	ps_options="-e -o user,pid,comm"
	ps_user_col_ref=1
	ps_pid_col_ref=2
	ps_comm_col_ref=3

	# ssh keys data
	ssh_key_path=~/.ssh/
	slp_ssh_key_path=$ssh_key_path/id_dsa_slp


	# ssh-agent process infos

                # Results of PS formated command (user, PID, command), for current user,  awk extracts the command column value, pipe it to egrep -x ssh-agent...
                # ... extracting only process by strict name "ssh-agent"
                ssh_agent_process_list=`bash sps.sh ssh-agent | grep $(whoami)`

		# test if ssh-agent process list is empty
		if [ "$ssh_agent_process_list" == "" ]
		then
			running_ssh_agent_process_number=0
		else
			running_ssh_agent_process_number=`echo "$ssh_agent_process_list" | wc -l`
                	running_agent_pid=`echo $ssh_agent_process_list | awk -v temp=$ps_pid_col_ref '{print $temp}'`
		fi

		echo "**** ssh_agent_process_list value: $ssh_agent_process_list" > $debug_out
		echo "**** running_ssh_agent_process_number value: $running_ssh_agent_process_number" > $debug_out
		echo "**** running_agent_pid: $running_agent_pid" > $debug_out

}


# Checks is SLP data dir exists
function slp_env_exists()
{
        if [ -d $data_dir ]
        then
                echo true
        else
                echo false
        fi
}

# Creates the SLP data dir and data file
function create_slp_env()
{
        echo "**** Data dir path: $data_dir"  > $debug_out
        mkdir $data_dir
	chmod -R 700 $data_dir
	touch $ssh_agent_data_file

}

# Checks if an ssh-agent is already running for the current user
function is_agent_running()
{

	# If only 1 instance of ssh-agent is running for current user.
        if [ $running_ssh_agent_process_number -eq 1 ]
        then
                echo true

	# If there is more than 1 process running for current user, something is probably wrong.
        elif [ $running_ssh_agent_process_number -gt 1 ]
        then

                echo error

	# Anything else, empty value, etc, agent is probably not running.
        else
		echo "**** Agent not running" > $debug_out
                echo false

        fi

}



# Kills all ssh-agents for current user and empty data file

function purge_ssh_agent()
{

	# Kill all ssh-agent process
	echo "**** Purging ssh-agent process"  > $debug_out

	while read line
	do
		proc_pid=`echo $line | awk -v temp=$ps_pid_col_ref '{print $temp}'`
		echo "**** Killing ssh-agent process PID: $proc_pid"  > $debug_out
		kill $proc_pid
	done < <(echo "$ssh_agent_process_list")

	# Empty  SLP data file
	echo "" > $ssh_agent_data_file

}

# Starts a new ssh-agent for current user
function start_ssh_agent()
{


	echo "**** Starting SSH-AGENT"  > $debug_out
	
	eval `ssh-agent` > /dev/null

	#check if ssh-key file does NOT exists
	if [ ! -f ~/.ssh/id_dsa_slp ]
	then
		echo "**** Ssh-key file does NOT exists, script will now generete one"  > $debug_out
		generate_ssh_key
	fi

	# Adds the ssh public key to the running agent.
	ssh-add $slp_ssh_key_path

	echo $SSH_AGENT_PID > $ssh_agent_data_file
	echo $SSH_AUTH_SOCK >> $ssh_agent_data_file

}

# Generated a new SSH key pair
function generate_ssh_key()
{

	echo "**** Please follow the instructions to generate your SSH-KEY" > $user_warning
	echo "**** DO NOT USE AN EMPTY PASSPHRASE!" > $user_warning
	
	# generates the key ending with "_slp" to be different from users created ssh key pairs.
	ssh-keygen -t dsa -f $slp_ssh_key_path -q 

}

# Retreives previously used ssh-agent pid and socket to avoid recreating one and have to enter passphrases again.
# ssh-agent process stays alive after user logout, but the env variable.
# linux bash/shell uses SSH_AGENT_PID and SSH_AUTH_SOCK as environment variable to communicate with the running ssh-agent.
# function fetchs the value from data file and set them as correct env variable.
function set_ssh_agent_env_var()
{

	echo "**** Setting environment variables"  > $debug_out

	echo "**** SSH-Agent PID: $ssh_agent_pid_value"  > $debug_out
	export SSH_AGENT_PID=`cat $ssh_agent_data_file | head -1 | tail -1`

	echo "**** SSH-Agent Auth Socket: $ssh_agent_auth_sock"  > $debug_out
	export SSH_AUTH_SOCK=`cat $ssh_agent_data_file | head -2 | tail -1`

}

# Checks if the running ssh-agent PID matchs the one stored in the data file, done to avoid potential incoherences.
function check_ssh_agent_consistency()
{

	stored_agent_pid=`cat $ssh_agent_data_file | head -1 | tail -1`

	echo "**** Stored agent PID: $stored_agent_pid" > $debug_out
	echo "**** Running agent PID: $running_agent_pid" > $debug_out
	echo "**** Stored Agent PID: $stored_agent_pid" > $debug_out
	echo "**** Env var SSH_AGENT_PID: $SSH_AGENT_PID" > $debug_out


	if [ "$stored_agent_pid" == "$running_agent_pid" ] && [ "$stored_agent_pid" == "$SSH_AGENT_PID" ]
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
                "true") echo "**** SLP ENV OK" > $debug_out;;
                "false") echo "**** SLP ENV does not exists, creating..." > $debug_out
                create_slp_env;;
        esac	


        case `is_agent_running` in
                "true") echo "**** Agent is running" > $debug_out
                        set_ssh_agent_env_var

                case `check_ssh_agent_consistency` in
                        "true") echo "**** Agent is consistent, stored PID and running process PID matches!" > $debug_out;;
                        "false") echo "**** Agent not consistent, stored PID and running PID DO NOT MATCHES!" > $debug_out
                        purge_ssh_agent
                        start_ssh_agent;;
                esac;;

                "false") echo "**** Agent is not Running" > $debug_out
                        start_ssh_agent;;
                "error")
                        echo "**** Error, more than 1 agent is running for user: $LOGNAME" > $debug_out
                        purge_ssh_agent
                        start_ssh_agent;;
        esac

}

main
