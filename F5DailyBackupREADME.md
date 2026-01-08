This script involves SSH logins to remote F5s and has been tested from RHEL unit. 
To authenticate using Shared Keys, copy over local ssh public key from /root/.ssh/id_rsa.pub to remote F5 at .ssh/authorized_keys 
(If the local machine does not have ssh keys generated, generate them by using command "ssh-keygen -t rsa")

The script take back ups for last 7 days and also takes Monthly backup
