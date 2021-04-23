# Hello Pico
## _Chase Schultz_

I'd like to thank you for the opportunity to work on this project and return it back to you all. It's not finished outright, but I'd like to walk through my thoughts on what is in my repo as a POC. I tried to take the approach of staying true to the spirit of the project, and following the requirements and specifications as they were written. I stayed away from third-party modules and took it on with the vanilla AWS provider, which was tricky at times mainly because of how the API calls are wrapped. I would've liked to have refactored and modularized the code a bit more in an extensible fashion for submission, but I have enjoyed working on this. Thanks for making this technical interview a uniquely interesting experience. The load-balancer displays the webpage here at this link: http://sample-load-balancer-1674642776.us-east-1.elb.amazonaws.com. 


## The Deliverable

- There's five files, '01_Networking.tf', '02_IAM.tf', 03_ALB.tf', '04_Fargate.tf', and '05_Bastion_Host.tf' that are deploying the compute infrastructure along with security controls and networking. IAM and Bastion are not super built out, they would need to have controls tightened if this was servicing real users and storing data. 
- Building the container image locally and then pushing to ECR (using terraform's local-exec), where then it's published to Fargate; that was a highlight I enjoyed seeing come together
- I came up with a CodeBuild solution for the terraform deployment, that I planned to use a Lambda with, but I didn't have time to flesh that out fully, so this deliverable isn't a part of a pipeline

## Installation

This is a how-to to install dependencies (Terraform AWS-CLI and Docker) so that the tech challenge can be easily configured and ran
(Intended for RHEL-based distros such as Amazon Linux 2)

```
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

```

## Repo Links

Here's the link to my repo, let me know if there are any questions or thoughts that come up, I'm happy to chat.

Also while you're on my page, feel free to check out the AWS Encyclopedia, I haven't had time to do much with it in awhile, but essentially it's a centralized place where engineers can contribute and also find the best documentation, guides, and most useful cloud solutions out on the web. 

| REPO | README |
| ------ | ------ |
| Tech Challenge HelloPico Repo | [https://github.com/cschultz82/hellopico/blob/master/README.md][PlDb] |
| AWS Encyclopedia | [https://github.com/cschultz82/aws_encyclopedia/blob/master/README.md][PlGh] |




  
 
   [PlDb]: <https://github.com/cschultz82/hellopico/blob/README.md>
   [PlGh]: <https://github.com/cschultz82/aws_encyclopedia/blob/master/README.md>
