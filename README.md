# quaggaDockerSetup : Script is use to clone quagga repo and create docker netwrok for quagga
Prerequisit
1. Install pipework "bash -c "curl https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework" > pipework"
2. chown +x pipework
3. To run pipework without password with sudo 
   1. sudo visudo
   2. add "<YOUR_USERNAME> ALL=(ALL:ALL) NOPASSWD: ALL" after root user
4. Install docker
5. Install Perl

Note : Please keep setup.pl and config file in same directory

[config]
CLONE:no
DOCKERS:5
R1:eth1:1.1.1.1/24:R2:eth1:1.1.1.2/24:R3:eth1:1.1.1.3/24
R2:eth2:2.2.2.2/24:R3:eth2:2.2.2.1/24:R4:eth2:2.2.2.3/24

run "perl setup.pl make [PATH_TO_CLONE]"


