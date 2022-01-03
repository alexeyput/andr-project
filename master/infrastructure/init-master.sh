#!/bin/bash

# Update Amazon Linux
yum update -y

# Install Tools and apps
yum install -y lynx
yum install -y docker
yum install -y docker-compose       ####
yum install -y git
yum install -y maven

usermod -aG docker ec2-user
systemctl start docker
systemctl enable docker
# Install ansible
amazon-linux-extras install ansible2

# Install Terraform
wget https://releases.hashicorp.com/terraform/1.1.2/terraform_1.1.2_linux_amd64.zip
unzip terraform_1.1.2_linux_amd64.zip -d /usr/bin

curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Run Jenkins in docker
sudo docker run -d -p 8080:8080 -p 5000:5000 --name jenkins -v jenkins_home:/var_jenkins_home jenkins/jenkins:lts

# Run Nexus in docker (Comment out due to lack of memory in AWS free tier EC2)
# docker volume create --name nexus-data
# sudo docker run -d -p 8081:8081 --name nexus sonatype/nexus3  -v nexus-data:/nexus-data sonatype/nexus3


# yum install -y python3
# yum install -y python3-pip
# yum install -y python3-flask
# yum install -y python-2virtualenv
