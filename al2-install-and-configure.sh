#!/bin/bash

#installs dependencies (terraform awscli and docker) so that the tech challenge can be easily configured and ran
#intended for Amazon Linux 2

yum update -y
yum install curl unzip sudo -y

#terraform install 
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
#docker install
sudo amazon-linux-extras install docker
#start up docker
sudo service docker start
#enable ec2-user to execute docker cmds as non-sudo user
sudo usermod -a -G docker ec2-user

#install aws-cli and add symlink
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
sudo ln -s /usr/local/aws-cli /usr/local/bin/aws

cd /home/ec2-user && git clone https://github.com/cschultz82/hellopico.git && cd hellopico

echo "hellopico"


