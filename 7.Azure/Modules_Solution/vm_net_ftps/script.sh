#!/bin/bash
sudo apt update
sudo apt install ansible -y
sudo apt install sshpass
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt install docker-ce -y
sudo docker run -d -p 21:21 -p 990:990 -p 21100-21110:21100-21110 -v /home/azureuser:/home/vsftpd --name ftps uliura/ftps:v2
