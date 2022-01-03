#!/bin/bash

# Update Amazon Linux
yum update -y

# Install Tools and apps
yum install -y lynx
yum install -y docker
yum install -y docker-compose       ####
yum install -y git
yum install -y maven

