SLP - SSH Single Login Point Project
===

1 Introduction
--------

This project aims to automate ssh-agent mechanism for users and provide a secured single point of login. The principle behind it is to have a single point of entry for ssh access to other servers inside your LAN for instance. SLP will provide server side scripts and client side scripts. The server will be in charge of reminding the user ssh-agent process identity and publish public ssh keys to clients. Clients will be able to fetch users ssh-keys and authorizes the keys published by the SLP server to be used for ssh-agent connections.

1.2 Use case Scenario
--------

1.3 SLP exemple infrastructure Overview
--------

![SLP Overview schema](https://www.lucidchart.com/publicSegments/view/51abe29b-f344-465c-b2b9-29720a005a97/image.png "SLP Overview schema")

1.4 Pro/cons
--------

2 Requirements analysis
--------

2.1 System requirements
--------

2.2 Dependencies
--------

2.3 Paths and files definition
--------

On central node:
- slp_install.sh
- /etc/slp.conf
  - SLP config file
- /opt/slp/central_node.sh
  - Main part of SLP, script used to detect running ssh-agent, ask user for ssh-keys creation, store ssh-agent process informations.
  - script will be appended to /etc/environment file for a forced use of SLP for all users.
- /opt/slp/sps.sh
  - Lib script used to list ssh-agent process using a strict name. Ie. sps.sh "ssh-agent" will only return plain and true "ssh-agent" process. 

On all remote nodes:
- /opt/slp/client.sh
  - Client script used to fetch user's ssh public keys from web dir from the central node and adds it to .ssh/authorized_keys.
  - script  will be appended to /etc/environment file for a forced use of SLP for all users.

2.3 General workflow description
--------

2.4 Server side workflow
--------

2.5 Client side workflow
--------

3 Analysis

1.1 SSH-AGENT mechanism analysis
--------

4 Implementation


TODO before alpha version
===

PRIORITARY:
- copy all slp ssh public keys to a web server dir
  - configure an SLP web dir in apache
  - Use posix ACLs to only allow to overide their own ssh keys to the web dir / create onw seperate dir per user in the SLP web dir.

- find a better way to work with ssh-agent processes [OK, see sps.sh]
  - use of arrays [OK]
    - sort processes within arrays [OK, done differently]
  - avoid using ps command more than once [OK, done using variables]
  
- Full documentation [in progress]
  - comment the code [in progress]
  - Docuemnt ssh-agent mechanism overview

SECONDARY:
- implement client side
- install apache2 on server side
  - document install and vhost config
  - script apache2 config
- test server side fully
  - review code
    - make it standard
    - use variable for everything in the code
    - reorganize
  - try to make unit test style test rountines
- much more

