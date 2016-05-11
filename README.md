# FIT
TOP Level

1.) Create your GitHub Account

2.) In your Linux vm or on Windows create a self signed cert for ssh access to the repository
	a.) Linux: https://help.ubuntu.com/community/SSH/OpenSSH/Keys
	b.) Microsoft: https://blogs.msdn.microsoft.com/cesardelatorre/2011/11/29/creating-an-x-509-certificate-for-windows-azure/

3.) Go into your GitHub Profile and add your .pub ssh keyfile. In Debian Linux this file is typically in /home/$USERNAME/.ssh/id_rsa.pub

4.) Prep a directory (git init) and clone this repo by selecting the master or top level branch you want and executing a git clone
	a.) NOTE: BE SURE NOT TO PUT ACCOUNT INFO IN THESE SCRIPTS. USE ENV Variables locally or a keystore(TBD) to store the different accounts and their information.

5.) More help here: http://TBD.wiki.internal.link



