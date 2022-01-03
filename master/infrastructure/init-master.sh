#!/bin/bash

# Update Amazon Linux
yum update -y

# Install Tools and apps
yum install -y lynx
yum install -y docker
yum install -y docker-compose       ####
yum install -y git
yum install -y maven

# Install ansible
amazon-linux-extras install ansible2

# Install Terraform
wget https://releases.hashicorp.com/terraform/1.1.2/terraform_1.1.2_linux_amd64.zip
unzip terraform_1.1.2_linux_amd64.zip -d /usr/bin
sudo systemctl start docker
sudo systemctl enable docker
# Run Jenkins in docker
sudo docker run -d -p 8080:8080 -p 5000:5000 --name jenkins -v jenkins_home:/var_jenkins_home jenkins/jenkins:lts
# Run Nexus in docker
docker volume create --name nexus-data
sudo docker run -d -p 8081:8081 --name nexus sonatype/nexus3  -v nexus-data:/nexus-data sonatype/nexus3


# yum install -y python3
# yum install -y python3-pip
# yum install -y python3-flask
# yum install -y python-virtualenv
