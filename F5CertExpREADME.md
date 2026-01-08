# F5_Bash_Scripts
Scripts for Expiring Cert report and daily backups

This Script logs in to Standby Devices and run command to search Expiring Certs within next 30 days.
It copies it locally and send out in email report

This script involves SSH logins to remote F5s and has been tested from RHEL unit. To authenticate using Shared Keys, copy over local ssh public key from /root/.ssh/id_rsa.pub to remote F5 at .ssh/authorized_keys (If the local machine does not have ssh keys generated, generate them by using command "ssh-keygen -t rsa")

Modify script to include your email addresses

Modify script to include your Hostnames/Remote Nodes. Enter IPs if DNS can’t resolve the names.
